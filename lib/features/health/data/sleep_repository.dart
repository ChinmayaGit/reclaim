import 'package:shared_preferences/shared_preferences.dart';
import 'sleep_model.dart';

class SleepRepository {
  static const _kEntries  = 'sleep_entries';
  static const _kGoal     = 'sleep_goal_hours';
  static const _kReminder = 'sleep_reminder_enabled';
  static const _kBedHour  = 'sleep_bedtime_hour';
  static const _kBedMin   = 'sleep_bedtime_minute';

  Future<SleepState> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kEntries);
    final entries = raw != null ? SleepState.entriesFromJson(raw) : <SleepEntry>[];
    return SleepState(
      goalHours: (p.getDouble(_kGoal) ?? p.getInt(_kGoal)?.toDouble()) ?? 8.0,
      entries: entries,
      bedtimeReminderEnabled: p.getBool(_kReminder) ?? false,
      bedtimeHour: p.getInt(_kBedHour) ?? 22,
      bedtimeMinute: p.getInt(_kBedMin) ?? 0,
    );
  }

  Future<void> saveEntries(List<SleepEntry> entries) async {
    final p = await SharedPreferences.getInstance();
    final s = SleepState(entries: entries);
    await p.setString(_kEntries, s.entriesToJson());
  }

  Future<void> saveSettings({
    required double goalHours,
    required bool reminderEnabled,
    required int bedtimeHour,
    required int bedtimeMinute,
  }) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setDouble(_kGoal, goalHours),
      p.setBool(_kReminder, reminderEnabled),
      p.setInt(_kBedHour, bedtimeHour),
      p.setInt(_kBedMin, bedtimeMinute),
    ]);
  }
}
