import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // Streak broken
      state = state.copyWith(streak: 0);
      _repo.saveStreak(0, today);
    }
  }

  Future<void> toggleHabit(String id) async {
    final done = Set<String>.from(state.completedToday);
    if (done.contains(id)) {
      done.remove(id);
    } else {
      done.add(id);
    }
    state = state.copyWith(completedToday: done);
    await _repo.saveCompleted(done);

    // Update streak when all done
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

  Future<void> addHabit(HabitItem habit) async {
    final updated = [...state.habits, habit];
    state = state.copyWith(habits: updated);
    await _repo.saveHabits(updated);
  }

  Future<void> removeHabit(String id) async {
    final updated = state.habits.where((h) => h.id != id).toList();
    final done = Set<String>.from(state.completedToday)..remove(id);
    state = state.copyWith(habits: updated, completedToday: done);
    await _repo.saveHabits(updated);
    await _repo.saveCompleted(done);
  }

  Future<void> reorderHabits(List<HabitItem> habits) async {
    state = state.copyWith(habits: habits);
    await _repo.saveHabits(habits);
  }
}

final disciplineProvider =
    StateNotifierProvider<DisciplineNotifier, DisciplineState>(
        (_) => DisciplineNotifier());
