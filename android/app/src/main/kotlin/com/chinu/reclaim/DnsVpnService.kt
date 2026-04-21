package com.chinu.reclaim

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import kotlin.concurrent.thread

/**
 * A lightweight VPN-based DNS filter.
 *
 * It creates a local TUN interface, overrides the system DNS to point at the TUN
 * address, then processes each DNS query that arrives through the TUN:
 *   - Blocked domain  →  NXDOMAIN response (dropped at DNS level, no TCP conn)
 *   - Other domain    →  forwarded to 8.8.8.8 and relayed back
 *
 * All non-DNS traffic is unaffected (we only route the DNS server IP).
 */
class DnsVpnService : VpnService() {

    companion object {
        const val ACTION_START   = "com.chinu.reclaim.VPN_START"
        const val ACTION_STOP    = "com.chinu.reclaim.VPN_STOP"
        const val EXTRA_DOMAINS  = "blocked_domains"

        private const val VPN_ADDR   = "10.111.0.2"   // TUN client address
        private const val DNS_ADDR   = "10.111.0.1"   // fake DNS inside TUN
        private const val UPSTREAM   = "8.8.8.8"
        private const val NOTIF_CH   = "reclaim_vpn"
        private const val NOTIF_ID   = 9001
    }

    private var tun: ParcelFileDescriptor? = null
    @Volatile private var running = false
    private var blockedDomains = emptySet<String>()

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            shutdown()
            return START_NOT_STICKY
        }
        val domains = intent?.getStringArrayListExtra(EXTRA_DOMAINS) ?: emptyList()
        blockedDomains = domains.map { it.lowercase().trim() }.toSet()
        startForegroundNotification()
        startTun()
        return START_STICKY
    }

    override fun onDestroy() {
        shutdown()
        super.onDestroy()
    }

    // ── VPN start / stop ──────────────────────────────────────────────────────

    private fun startTun() {
        shutdown()
        val iface = Builder()
            .setSession("Reclaim Website Blocker")
            .addAddress(VPN_ADDR, 32)
            .addDnsServer(DNS_ADDR)
            .addRoute(DNS_ADDR, 32)   // only route our fake DNS IP through TUN
            .setMtu(1500)
            .also { b ->
                try { b.addDisallowedApplication(packageName) } catch (_: Exception) {}
            }
            .establish() ?: return

        tun = iface
        running = true
        thread(name = "reclaim-dns-vpn", isDaemon = true) { processLoop(iface) }
    }

    private fun shutdown() {
        running = false
        try { tun?.close() } catch (_: Exception) {}
        tun = null
        stopForeground(true)
        stopSelf()
    }

    // ── Packet processing loop ────────────────────────────────────────────────

    private fun processLoop(iface: ParcelFileDescriptor) {
        val inp = FileInputStream(iface.fileDescriptor)
        val out = FileOutputStream(iface.fileDescriptor)
        val upstreamAddr = InetAddress.getByName(UPSTREAM)
        val udpSock = DatagramSocket().also { protect(it) }
        val buf = ByteArray(4096)

        while (running) {
            val n = try { inp.read(buf) } catch (_: Exception) { break }
            if (n < 28) continue

            // IPv4 only
            if ((buf[0].toInt() and 0xF0) != 0x40) continue
            // UDP only (protocol = 17)
            if ((buf[9].toInt() and 0xFF) != 17) continue

            val ihl = (buf[0].toInt() and 0x0F) * 4
            val dstPort = portFrom(buf, ihl + 2)
            if (dstPort != 53) continue

            val dnsStart = ihl + 8
            val dnsLen   = n - dnsStart
            if (dnsLen < 12) continue

            val dns    = buf.copyOfRange(dnsStart, dnsStart + dnsLen)
            val domain = extractQueryName(dns)

            val reply: ByteArray = if (domain != null && shouldBlock(domain)) {
                buildNxDomain(dns)
            } else {
                forwardToUpstream(udpSock, upstreamAddr, dns) ?: continue
            }

            writeIpUdpReply(out, buf, ihl, reply)
        }

        try { udpSock.close() } catch (_: Exception) {}
        try { iface.close() } catch (_: Exception) {}
    }

    // ── Domain helpers ────────────────────────────────────────────────────────

    private fun shouldBlock(domain: String): Boolean {
        val d = domain.lowercase().trimEnd('.')
        return blockedDomains.any { b -> d == b || d.endsWith(".$b") }
    }

    private fun extractQueryName(dns: ByteArray): String? = try {
        val sb = StringBuilder()
        var i = 12
        while (i < dns.size) {
            val len = dns[i].toInt() and 0xFF
            if (len == 0) break
            if (sb.isNotEmpty()) sb.append('.')
            sb.append(String(dns, i + 1, len, Charsets.UTF_8))
            i += len + 1
        }
        sb.toString().ifEmpty { null }
    } catch (_: Exception) { null }

    // ── DNS response builders ─────────────────────────────────────────────────

    private fun buildNxDomain(query: ByteArray): ByteArray {
        val r = query.copyOf()
        r[2] = 0x81.toByte()  // QR=1, Opcode=0, AA=0, TC=0, RD=1
        r[3] = 0x83.toByte()  // RA=1, Z=0, RCODE=3 (NXDOMAIN)
        r[6] = 0; r[7] = 0    // ANCOUNT = 0
        r[8] = 0; r[9] = 0    // NSCOUNT = 0
        r[10] = 0; r[11] = 0  // ARCOUNT = 0
        return r
    }

    private fun forwardToUpstream(
        sock: DatagramSocket,
        upstream: InetAddress,
        query: ByteArray,
    ): ByteArray? = try {
        sock.send(DatagramPacket(query, query.size, upstream, 53))
        val resp = ByteArray(4096)
        val pkt  = DatagramPacket(resp, resp.size)
        sock.soTimeout = 3000
        sock.receive(pkt)
        resp.copyOf(pkt.length)
    } catch (_: Exception) { null }

    // ── Packet assembly ───────────────────────────────────────────────────────

    /**
     * Wraps a DNS payload in IPv4 + UDP, swapping src/dst so the fake DNS
     * server appears to reply to the original requester.
     */
    private fun writeIpUdpReply(
        out: FileOutputStream,
        orig: ByteArray,
        ihl: Int,
        dnsPayload: ByteArray,
    ) {
        val total  = ihl + 8 + dnsPayload.size
        val pkt    = ByteArray(total)

        // IP header — copy then patch
        System.arraycopy(orig, 0, pkt, 0, ihl)
        // Swap src ↔ dst IP
        System.arraycopy(orig, 12, pkt, 16, 4)
        System.arraycopy(orig, 16, pkt, 12, 4)
        // Total length
        pkt[2] = (total ushr 8).toByte()
        pkt[3] = (total and 0xFF).toByte()
        // TTL = 64
        pkt[8] = 64
        // Recompute IP checksum
        pkt[10] = 0; pkt[11] = 0
        val ck = ipChecksum(pkt, ihl)
        pkt[10] = (ck ushr 8).toByte()
        pkt[11] = (ck and 0xFF).toByte()

        // UDP header — swap src/dst ports (reply from port 53 → original src)
        pkt[ihl]     = orig[ihl + 2]; pkt[ihl + 1] = orig[ihl + 3]
        pkt[ihl + 2] = orig[ihl];     pkt[ihl + 3] = orig[ihl + 1]
        val udpLen = 8 + dnsPayload.size
        pkt[ihl + 4] = (udpLen ushr 8).toByte()
        pkt[ihl + 5] = (udpLen and 0xFF).toByte()
        pkt[ihl + 6] = 0; pkt[ihl + 7] = 0  // checksum optional for outgoing

        // DNS payload
        System.arraycopy(dnsPayload, 0, pkt, ihl + 8, dnsPayload.size)

        try { out.write(pkt) } catch (_: Exception) {}
    }

    // ── Utilities ─────────────────────────────────────────────────────────────

    private fun portFrom(buf: ByteArray, offset: Int): Int =
        ((buf[offset].toInt() and 0xFF) shl 8) or (buf[offset + 1].toInt() and 0xFF)

    private fun ipChecksum(data: ByteArray, len: Int): Int {
        var sum = 0
        var i = 0
        while (i < len - 1) {
            sum += ((data[i].toInt() and 0xFF) shl 8) or (data[i + 1].toInt() and 0xFF)
            i += 2
        }
        if (len % 2 != 0) sum += (data[len - 1].toInt() and 0xFF) shl 8
        while (sum ushr 16 != 0) sum = (sum and 0xFFFF) + (sum ushr 16)
        return sum.inv() and 0xFFFF
    }

    // ── Foreground notification ───────────────────────────────────────────────

    private fun startForegroundNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(
                NotificationChannel(NOTIF_CH, "Website Blocker", NotificationManager.IMPORTANCE_LOW)
                    .apply { description = "Active DNS filter" }
            )
        }
        val stopIntent = PendingIntent.getService(
            this, 0,
            Intent(this, DnsVpnService::class.java).apply { action = ACTION_STOP },
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val notif: Notification = NotificationCompat.Builder(this, NOTIF_CH)
            .setContentTitle("Website Blocker active")
            .setContentText("Reclaim is filtering trigger sites via DNS")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Stop", stopIntent)
            .build()
        startForeground(NOTIF_ID, notif)
    }
}
