import 'package:shared_preferences/shared_preferences.dart';
import 'focus_model.dart';

class FocusRepository {
  static const _keyUsageLimit    = 'focus_usage_limit_enabled';
  static const _keyLimitMinutes  = 'focus_limit_minutes';
  static const _keySchedule      = 'focus_schedule_enabled';
  static const _keyStartHour     = 'focus_start_hour';
  static const _keyEndHour       = 'focus_end_hour';
  static const _keyLinkBlock     = 'focus_link_block_enabled';
  static const _keyDomains       = 'focus_blocked_domains';
  static const _keyUsagePrefix   = 'focus_usage_'; // + YYYY-MM-DD

  Future<FocusSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final domains = p.getStringList(_keyDomains) ?? [];
    return FocusSettings(
      usageLimitEnabled: p.getBool(_keyUsageLimit)   ?? false,
      dailyLimitMinutes: p.getInt(_keyLimitMinutes)  ?? 60,
      scheduleEnabled:   p.getBool(_keySchedule)     ?? false,
      scheduleStartHour: p.getInt(_keyStartHour)     ?? 7,
      scheduleEndHour:   p.getInt(_keyEndHour)       ?? 22,
      linkBlockingEnabled: p.getBool(_keyLinkBlock)  ?? false,
      blockedDomains:    domains,
    );
  }

  Future<void> save(FocusSettings s) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setBool(_keyUsageLimit,   s.usageLimitEnabled),
      p.setInt(_keyLimitMinutes,  s.dailyLimitMinutes),
      p.setBool(_keySchedule,     s.scheduleEnabled),
      p.setInt(_keyStartHour,     s.scheduleStartHour),
      p.setInt(_keyEndHour,       s.scheduleEndHour),
      p.setBool(_keyLinkBlock,    s.linkBlockingEnabled),
      p.setStringList(_keyDomains, s.blockedDomains),
    ]);
  }

  // ── Usage tracking ───────────────────────────────────────────────────────

  String _todayKey() {
    final d = DateTime.now();
    return '$_keyUsagePrefix${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<int> loadTodayUsageSeconds() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_todayKey()) ?? 0;
  }

  Future<void> saveTodayUsageSeconds(int seconds) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_todayKey(), seconds);
  }

  /// Remove usage entries older than 7 days.
  Future<void> pruneOldUsage() async {
    final p = await SharedPreferences.getInstance();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keys = p.getKeys()
        .where((k) => k.startsWith(_keyUsagePrefix))
        .toList();
    for (final key in keys) {
      final dateStr = key.substring(_keyUsagePrefix.length);
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final d = DateTime.tryParse(dateStr);
        if (d != null && d.isBefore(cutoff)) await p.remove(key);
      }
    }
  }
}
