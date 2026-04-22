import 'package:shared_preferences/shared_preferences.dart';
import 'water_model.dart';

class WaterRepository {
  static const _kGoal      = 'water_goal_ml';
  static const _kReminder  = 'water_reminder_enabled';
  static const _kInterval  = 'water_reminder_interval';
  static const _kPrefix    = 'water_entries_'; // + yyyy-MM-dd

  String _todayKey() {
    final d = DateTime.now();
    return _dateKey(d);
  }

  String _dateKey(DateTime d) =>
      '$_kPrefix${d.year}-${_p(d.month)}-${_p(d.day)}';

  String _p(int v) => v.toString().padLeft(2, '0');

  /// Water log for a specific calendar day (if still in SharedPreferences).
  Future<List<WaterEntry>> loadEntriesForDay(DateTime day) async {
    final p = await SharedPreferences.getInstance();
    final d = DateTime(day.year, day.month, day.day);
    final raw = p.getString(_dateKey(d));
    if (raw == null || raw.isEmpty) return [];
    try {
      return WaterState.entriesFromJson(raw);
    } catch (_) {
      return [];
    }
  }

  Future<int> loadGoalMl() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kGoal) ?? 3000;
  }

  Future<WaterState> load() async {
    final p = await SharedPreferences.getInstance();
    final key = _todayKey();
    final raw = p.getString(key);
    final entries = raw != null ? WaterState.entriesFromJson(raw) : <WaterEntry>[];
    return WaterState(
      goalMl: p.getInt(_kGoal) ?? 3000,
      entries: entries,
      reminderEnabled: p.getBool(_kReminder) ?? false,
      reminderIntervalHours: p.getInt(_kInterval) ?? 2,
    );
  }

  Future<void> saveEntries(List<WaterEntry> entries) async {
    final p = await SharedPreferences.getInstance();
    final state = WaterState(entries: entries);
    await p.setString(_todayKey(), state.entriesToJson());
  }

  Future<void> saveSettings({
    required int goalMl,
    required bool reminderEnabled,
    required int reminderIntervalHours,
  }) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setInt(_kGoal, goalMl),
      p.setBool(_kReminder, reminderEnabled),
      p.setInt(_kInterval, reminderIntervalHours),
    ]);
  }

  Future<void> pruneOld() async {
    final p = await SharedPreferences.getInstance();
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    for (final key in p.getKeys().where((k) => k.startsWith(_kPrefix))) {
      final dateStr = key.substring(_kPrefix.length);
      final d = DateTime.tryParse(dateStr);
      if (d != null && d.isBefore(cutoff)) await p.remove(key);
    }
  }
}
