import 'package:flutter/services.dart';

class AppUsageStat {
  const AppUsageStat({
    required this.packageName,
    required this.appName,
    required this.secondsToday,
  });

  final String packageName;
  final String appName;
  final int secondsToday;

  int get minutesToday => secondsToday ~/ 60;
}

class UsageChannel {
  static const _ch = MethodChannel('com.chinu.reclaim/usage');

  static Future<bool> hasPermission() async {
    try {
      return await _ch.invokeMethod<bool>('hasUsagePermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openPermissionSettings() async {
    try {
      await _ch.invokeMethod('openUsageSettings');
    } catch (_) {}
  }

  static Future<List<AppUsageStat>> getAppUsage() async {
    try {
      final raw = await _ch.invokeListMethod<Map>('getAppUsage') ?? [];
      return raw.map((m) {
        final sec = (m['seconds'] as num?)?.toInt() ??
            (((m['minutes'] as num?)?.toInt() ?? 0) * 60);
        return AppUsageStat(
          packageName: m['package'] as String,
          appName: m['name'] as String,
          secondsToday: sec,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
