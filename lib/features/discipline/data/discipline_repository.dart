import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_model.dart';

class DisciplineRepository {
  static const _kHabits    = 'discipline_habits';
  static const _kStreak    = 'discipline_streak';
  static const _kLastDate  = 'discipline_last_date';
  static const _kPrefix    = 'discipline_done_'; // + yyyy-MM-dd

  String _todayKey() {
    final d = DateTime.now();
    return '$_kPrefix${d.year}-${_p(d.month)}-${_p(d.day)}';
  }

  String _p(int v) => v.toString().padLeft(2, '0');
  String _dateStr(DateTime d) =>
      '${d.year}-${_p(d.month)}-${_p(d.day)}';

  Future<DisciplineState> load() async {
    final p = await SharedPreferences.getInstance();

    final habitsRaw = p.getString(_kHabits);
    final habits = habitsRaw != null
        ? DisciplineState.habitsFromJson(habitsRaw)
        : List<HabitItem>.from(kDefaultHabits);

    final doneRaw = p.getStringList(_todayKey()) ?? [];
    final completedToday = doneRaw.toSet();

    return DisciplineState(
      habits: habits,
      completedToday: completedToday,
      streak: p.getInt(_kStreak) ?? 0,
      lastCompletedDate: p.getString(_kLastDate),
    );
  }

  Future<void> saveHabits(List<HabitItem> habits) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kHabits, jsonEncode(habits.map((h) => h.toJson()).toList()));
  }

  Future<void> saveCompleted(Set<String> ids) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_todayKey(), ids.toList());
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
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    for (final key in p.getKeys().where((k) => k.startsWith(_kPrefix))) {
      final dateStr = key.substring(_kPrefix.length);
      final d = DateTime.tryParse(dateStr);
      if (d != null && d.isBefore(cutoff)) await p.remove(key);
    }
  }
}
