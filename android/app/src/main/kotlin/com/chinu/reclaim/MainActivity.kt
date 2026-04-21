package com.chinu.reclaim

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.VpnService
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {

    private val usageChannel = "com.chinu.reclaim/usage"
    private val vpnChannel = "com.chinu.reclaim/vpn"

    private var pendingVpnResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, usageChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsagePermission" -> result.success(hasUsagePermission())
                    "openUsageSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "getAppUsage" -> result.success(getAppUsage())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, vpnChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasVpnPermission" -> result.success(hasVpnPermission())
                    "requestVpnConsent" -> requestVpnConsent(result)
                    "startVpn" -> {
                        val domains = call.argument<List<String>>("domains") ?: emptyList()
                        startVpnService(domains)
                        result.success(null)
                    }
                    "stopVpn" -> {
                        stopVpnService()
                        result.success(null)
                    }
                    "isVpnRunning" -> result.success(isVpnRunning())
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun todayRangeMillis(): Pair<Long, Long> {
        val cal = Calendar.getInstance()
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        return cal.timeInMillis to System.currentTimeMillis()
    }

    private fun mergedUserAppUsageMsToday(): Map<String, Pair<String, Long>> {
        if (!hasUsagePermission()) return emptyMap()
        val (start, end) = todayRangeMillis()
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
            ?: return emptyMap()
        val pm = packageManager
        val out = mutableMapOf<String, Pair<String, Long>>()
        for (stat in stats) {
            if (stat.packageName == packageName) continue
            try {
                val info = pm.getApplicationInfo(stat.packageName, 0)
                if (info.flags and ApplicationInfo.FLAG_SYSTEM != 0 &&
                    info.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP == 0
                ) {
                    continue
                }
                val label = pm.getApplicationLabel(info).toString()
                val pkg = stat.packageName
                val prev = out[pkg]?.second ?: 0L
                val ms = maxOf(prev, stat.totalTimeInForeground)
                out[pkg] = label to ms
            } catch (_: Exception) {
            }
        }
        return out
    }

    private fun getAppUsage(): List<Map<String, Any>> {
        return mergedUserAppUsageMsToday()
            .map { (pkg, pair) ->
                val sec = (pair.second / 1000L).toInt()
                mapOf(
                    "package" to pkg,
                    "name" to pair.first,
                    "seconds" to sec,
                    "minutes" to (sec / 60),
                )
            }
            .sortedByDescending { it["seconds"] as Int }
    }

    private fun hasVpnPermission(): Boolean =
        VpnService.prepare(this) == null

    private fun requestVpnConsent(result: MethodChannel.Result) {
        val intent = VpnService.prepare(this)
        if (intent == null) {
            result.success(true)
            return
        }
        pendingVpnResult = result
        @Suppress("DEPRECATION")
        startActivityForResult(intent, REQUEST_VPN)
    }

    @Suppress("OVERRIDE_DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_VPN) {
            val granted = resultCode == RESULT_OK
            pendingVpnResult?.success(granted)
            pendingVpnResult = null
        }
    }

    private fun startVpnService(domains: List<String>) {
        val intent = Intent(this, DnsVpnService::class.java).apply {
            action = DnsVpnService.ACTION_START
            putStringArrayListExtra(DnsVpnService.EXTRA_DOMAINS, ArrayList(domains))
        }
        startService(intent)
    }

    private fun stopVpnService() {
        startService(Intent(this, DnsVpnService::class.java).apply {
            action = DnsVpnService.ACTION_STOP
        })
    }

    private fun isVpnRunning(): Boolean = VpnService.prepare(this) == null

    companion object {
        private const val REQUEST_VPN = 1001
    }
}
