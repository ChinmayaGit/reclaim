import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_model.dart';

class DisciplineRepository {
  static const _kHabits = 'discipline_habits';
  static const _kStreak = 'discipline_streak';
  static const _kLastDate = 'discipline_last_date';
  static const _kPrefix = 'discipline_done_'; // + yyyy-MM-dd

  String _p(int v) => v.toString().padLeft(2, '0');
  String _dateStr(DateTime d) =>
      '${d.year}-${_p(d.month)}-${_p(d.day)}';

  String _doneKey(DateTime d) => '$_kPrefix${_dateStr(d)}';

  String _todayKey() => _doneKey(DateTime.now());

  /// Decode progress map; supports legacy `StringList` (each id → count 1) and JSON map.
  ///
  /// Same [key] was used for `setStringList` then `setString`; [getString] throws if the
  /// native value is still a list — try list first, then string, each in try/catch.
  Map<String, int> _decodeProgress(SharedPreferences p, String key) {
    try {
      final legacy = p.getStringList(key);
      if (legacy != null && legacy.isNotEmpty) {
        return {for (final id in legacy) id: 1};
      }
    } catch (_) {
      // Value is JSON [String], not a list — fall through.
    }
    try {
      final rawStr = p.getString(key);
      if (rawStr != null && rawStr.isNotEmpty) {
        final decoded = jsonDecode(rawStr) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      }
    } catch (_) {}
    return {};
  }

  Future<DisciplineState> load() async {
    final p = await SharedPreferences.getInstance();

    final habitsRaw = p.getString(_kHabits);
    final habits = habitsRaw != null
        ? DisciplineState.habitsFromJson(habitsRaw)
        : <HabitItem>[];

    final habitProgressToday = _decodeProgress(p, _todayKey());

    return DisciplineState(
      habits: habits,
      habitProgressToday: habitProgressToday,
      streak: p.getInt(_kStreak) ?? 0,
      lastCompletedDate: p.getString(_kLastDate),
    );
  }

  Future<Map<String, int>> loadProgressFor(DateTime day) async {
    final p = await SharedPreferences.getInstance();
    final key = _doneKey(DateTime(day.year, day.month, day.day));
    return _decodeProgress(p, key);
  }

  Future<void> saveHabits(List<HabitItem> habits) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kHabits, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  Future<void> saveProgressFor(DateTime day, Map<String, int> progress) async {
    final p = await SharedPreferences.getInstance();
    final key = _doneKey(DateTime(day.year, day.month, day.day));
    final cleaned = Map<String, int>.fromEntries(
      progress.entries.where((e) => e.value > 0),
    );
    await p.setString(key, jsonEncode(cleaned));
  }

  /// @deprecated Use [loadProgressFor] + habit goals; kept for gradual migration.
  Future<Set<String>> loadCompletedFor(DateTime day) async {
    final map = await loadProgressFor(day);
    return map.entries.where((e) => e.value >= 1).map((e) => e.key).toSet();
  }

  Future<void> saveStreak(int streak, DateTime date) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setInt(_kStreak, streak),
      p.setString(_kLastDate, _dateStr(date)),
    ]);
  }

  Future<void> pruneOld() async {
    final p = await SharedPreferences.getInstance();
    final cutoff = DateTime.now().subtract(const Duration(days: 120));
    for (final key in p.getKeys().where((k) => k.startsWith(_kPrefix))) {
      final dateStr = key.substring(_kPrefix.length);
      final d = DateTime.tryParse(dateStr);
      if (d != null && d.isBefore(cutoff)) await p.remove(key);
    }
  }
}
