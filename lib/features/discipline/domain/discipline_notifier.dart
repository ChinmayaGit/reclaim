import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/local_notification_service.dart';
import '../data/habit_model.dart';
import '../data/discipline_repository.dart';

final _repo = DisciplineRepository();

class DisciplineNotifier extends StateNotifier<DisciplineState> {
  DisciplineNotifier() : super(const DisciplineState()) {
    _load();
  }

  Future<void> _load() async {
    await _repo.pruneOld();
    state = await _repo.load();
    _checkStreakReset();
    await LocalNotificationService.instance.syncHabitReminders(state.habits);
  }

  void _checkStreakReset() {
    final last = state.lastCompletedDate;
    if (last == null) return;
    final lastDate = DateTime.tryParse(last);
    if (lastDate == null) return;
    final today = DateTime.now();
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
        .inDays;
    if (diff > 1) {
      state = state.copyWith(streak: 0);
      _repo.saveStreak(0, today);
    }
  }

  Future<void> _persistTodayProgress() async {
    final today = DateTime.now();
    await _repo.saveProgressFor(today, state.habitProgressToday);
  }

  /// One tap: binary habits toggle; repeating habits add one until the daily goal.
  Future<void> tapHabit(String id) async {
    HabitItem? habit;
    for (final h in state.habits) {
      if (h.id == id) {
        habit = h;
        break;
      }
    }
    if (habit == null) return;

    final map = Map<String, int>.from(state.habitProgressToday);
    final c = map[id] ?? 0;
    final g = habit.dailyGoal.clamp(1, 999);
    int next;
    if (g == 1) {
      next = c >= 1 ? 0 : 1;
    } else {
      if (c >= g) return;
      next = c + 1;
    }
    if (next <= 0) {
      map.remove(id);
    } else {
      map[id] = next;
    }
    state = state.copyWith(habitProgressToday: map);
    await _persistTodayProgress();

    if (state.allDone) {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      if (state.lastCompletedDate != todayStr) {
        final newStreak = state.streak + 1;
        state = state.copyWith(streak: newStreak, lastCompletedDate: todayStr);
        await _repo.saveStreak(newStreak, today);
      }
    }
  }

  /// Undo one step for repeating habits, or clear a single-shot habit.
  Future<void> decrementHabit(String id) async {
    HabitItem? habit;
    for (final h in state.habits) {
      if (h.id == id) {
        habit = h;
        break;
      }
    }
    if (habit == null) return;

    final map = Map<String, int>.from(state.habitProgressToday);
    final c = map[id] ?? 0;
    if (c <= 0) return;
    final next = c - 1;
    if (next <= 0) {
      map.remove(id);
    } else {
      map[id] = next;
    }
    state = state.copyWith(habitProgressToday: map);
    await _persistTodayProgress();
  }

  /// @nodoc Kept for older call sites; delegates to [tapHabit].
  Future<void> toggleHabit(String id) => tapHabit(id);

  Future<void> addHabit(HabitItem habit) async {
    final updated = [...state.habits, habit];
    state = state.copyWith(habits: updated);
    await _repo.saveHabits(updated);
    await LocalNotificationService.instance.syncHabitReminders(updated);
  }

  Future<void> removeHabit(String id) async {
    final updated = state.habits.where((h) => h.id != id).toList();
    final map = Map<String, int>.from(state.habitProgressToday)..remove(id);
    state = state.copyWith(habits: updated, habitProgressToday: map);
    await _repo.saveHabits(updated);
    await _persistTodayProgress();
    await LocalNotificationService.instance.syncHabitReminders(updated);
  }

  Future<void> reorderHabits(List<HabitItem> habits) async {
    state = state.copyWith(habits: habits);
    await _repo.saveHabits(habits);
    await LocalNotificationService.instance.syncHabitReminders(habits);
  }

  /// Habits fully satisfied on [day] (local date), for calendar / history UI.
  Future<Set<String>> completedIdsOn(DateTime day) async {
    final map = await _repo.loadProgressFor(day);
    final out = <String>{};
    for (final h in state.habits) {
      final c = map[h.id] ?? 0;
      if (c >= h.dailyGoal.clamp(1, 999)) out.add(h.id);
    }
    return out;
  }

  Future<Map<String, int>> progressMapOn(DateTime day) =>
      _repo.loadProgressFor(day);
}

final disciplineProvider =
    StateNotifierProvider<DisciplineNotifier, DisciplineState>(
        (_) => DisciplineNotifier());
