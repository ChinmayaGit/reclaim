import 'package:flutter/services.dart';

/// Flutter bridge to the native DNS-filter VPN service.
class VpnChannel {
  static const _ch = MethodChannel('com.chinu.reclaim/vpn');

  /// Whether the system has already granted VPN consent for this app.
  static Future<bool> hasPermission() async {
    try {
      return await _ch.invokeMethod<bool>('hasVpnPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Shows the Android VPN consent dialog.
  /// Returns true if the user approved, false if they cancelled.
  static Future<bool> requestConsent() async {
    try {
      return await _ch.invokeMethod<bool>('requestVpnConsent') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Starts the DNS VPN service with the given [blockedDomains] list.
  static Future<void> start(List<String> blockedDomains) async {
    try {
      await _ch.invokeMethod('startVpn', {'domains': blockedDomains});
    } catch (_) {}
  }

  /// Stops the DNS VPN service.
  static Future<void> stop() async {
    try {
      await _ch.invokeMethod('stopVpn');
    } catch (_) {}
  }

  /// Whether the VPN service is currently running.
  static Future<bool> isRunning() async {
    try {
      return await _ch.invokeMethod<bool>('isVpnRunning') ?? false;
    } catch (_) {
      return false;
    }
  }
}
