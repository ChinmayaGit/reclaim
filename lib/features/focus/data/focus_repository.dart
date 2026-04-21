import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'focus_model.dart';

class FocusRepository {
  static const _keyTrackedApps = 'focus_tracked_app_usage_json';
  static const _keySchedule = 'focus_schedule_enabled';
  static const _keyStartHour = 'focus_start_hour';
  static const _keyEndHour = 'focus_end_hour';
  static const _keyLinkBlock = 'focus_link_block_enabled';
  static const _keyDomains = 'focus_blocked_domains';

  Future<FocusSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final domains = p.getStringList(_keyDomains) ?? [];
    List<AppUsageTrackedApp> tracked = const [];
    final rawTracked = p.getString(_keyTrackedApps);
    if (rawTracked != null && rawTracked.isNotEmpty) {
      try {
        final list = jsonDecode(rawTracked) as List<dynamic>;
        tracked = list
            .map((e) =>
                AppUsageTrackedApp.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {}
    }
    return FocusSettings(
      trackedAppUsage: tracked,
      scheduleEnabled: p.getBool(_keySchedule) ?? false,
      scheduleStartHour: p.getInt(_keyStartHour) ?? 7,
      scheduleEndHour: p.getInt(_keyEndHour) ?? 22,
      linkBlockingEnabled: p.getBool(_keyLinkBlock) ?? false,
      blockedDomains: domains,
    );
  }

  Future<void> save(FocusSettings s) async {
    final p = await SharedPreferences.getInstance();
    final trackedJson =
        jsonEncode(s.trackedAppUsage.map((e) => e.toJson()).toList());
    await Future.wait([
      p.setString(_keyTrackedApps, trackedJson),
      p.setBool(_keySchedule, s.scheduleEnabled),
      p.setInt(_keyStartHour, s.scheduleStartHour),
      p.setInt(_keyEndHour, s.scheduleEndHour),
      p.setBool(_keyLinkBlock, s.linkBlockingEnabled),
      p.setStringList(_keyDomains, s.blockedDomains),
    ]);
  }
}
