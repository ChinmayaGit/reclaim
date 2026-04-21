import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/workout_models.dart';
import '../data/workout_repository.dart';

final _workoutRepo = WorkoutRepository();

class WorkoutLogState {
  const WorkoutLogState({
    this.active,
    this.history = const [],
  });

  final ActiveWorkout? active;
  final List<FinishedWorkout> history;

  WorkoutWeekStats weekStats(DateTime now) {
    final cutoff = now.subtract(const Duration(days: 7));
    int sessions = 0;
    int sets = 0;
    int vol = 0;
    for (final w in history) {
      if (w.finishedAt.isBefore(cutoff)) continue;
      sessions++;
      sets += w.totalSets;
      vol += w.totalVolume;
    }
    return WorkoutWeekStats(
      sessionCount: sessions,
      totalSets: sets,
      totalVolumeKg: vol,
    );
  }

  /// Last finished exercise matching [name] (case-insensitive), for "Previous" column.
  GymExercise? lastMatchForExercise(String name) {
    final n = name.toLowerCase().trim();
    for (final w in history.reversed) {
      for (final ex in w.exercises) {
        if (ex.name.toLowerCase().trim() == n) return ex;
      }
    }
    return null;
  }
}

class WorkoutLogNotifier extends StateNotifier<WorkoutLogState> {
  WorkoutLogNotifier() : super(const WorkoutLogState()) {
    _load();
  }

  Future<void> _load() async {
    final hist = await _workoutRepo.loadHistory();
    final draft = await _workoutRepo.loadDraft();
    state = WorkoutLogState(active: draft, history: hist);
    if (draft == null) {
      await startNewSession(title: 'Workout');
    }
  }

  Future<void> startNewSession({String title = 'Workout'}) async {
    final w = ActiveWorkout(
      id: newId(),
      title: title,
      startedAt: DateTime.now(),
      exercises: const [],
    );
    state = WorkoutLogState(active: w, history: state.history);
    await _workoutRepo.saveDraft(w);
  }

  Future<void> _persistActive() async {
    await _workoutRepo.saveDraft(state.active);
  }

  Future<void> setTitle(String title) async {
    final a = state.active;
    if (a == null) return;
    state = WorkoutLogState(
      active: a.copyWith(title: title),
      history: state.history,
    );
    await _persistActive();
  }

  Future<void> addExercise(String name, {String muscleGroup = ''}) async {
    final a = state.active;
    if (a == null) return;
    final ex = GymExercise(
      id: newId(),
      name: name.trim().isEmpty ? 'Exercise' : name.trim(),
      muscleGroup: muscleGroup,
      sets: [
        WorkoutSet(id: newId()),
      ],
    );
    state = WorkoutLogState(
      active: a.copyWith(exercises: [...a.exercises, ex]),
      history: state.history,
    );
    await _persistActive();
  }

  Future<void> removeExercise(String exerciseId) async {
    final a = state.active;
    if (a == null) return;
    state = WorkoutLogState(
      active: a.copyWith(
        exercises: a.exercises.where((e) => e.id != exerciseId).toList(),
      ),
      history: state.history,
    );
    await _persistActive();
  }

  Future<void> addSet(String exerciseId) async {
    final a = state.active;
    if (a == null) return;
    final list = a.exercises.map((e) {
      if (e.id != exerciseId) return e;
      return e.copyWith(sets: [...e.sets, WorkoutSet(id: newId())]);
    }).toList();
    state = WorkoutLogState(active: a.copyWith(exercises: list), history: state.history);
    await _persistActive();
  }

  Future<void> updateSet(
    String exerciseId,
    String setId, {
    double? kg,
    int? reps,
    bool? done,
  }) async {
    final a = state.active;
    if (a == null) return;
    final list = a.exercises.map((e) {
      if (e.id != exerciseId) return e;
      final sets = e.sets.map((s) {
        if (s.id != setId) return s;
        return s.copyWith(kg: kg, reps: reps, done: done);
      }).toList();
      return e.copyWith(sets: sets);
    }).toList();
    state = WorkoutLogState(active: a.copyWith(exercises: list), history: state.history);
    await _persistActive();
  }

  Future<void> finishSession() async {
    final a = state.active;
    if (a == null) return;
    final finished = FinishedWorkout(
      id: a.id,
      finishedAt: DateTime.now(),
      title: a.title,
      exercises: a.exercises,
    );
    final hist = [...state.history, finished];
    state = WorkoutLogState(active: null, history: hist);
    await _workoutRepo.saveHistory(hist);
    await _workoutRepo.saveDraft(null);
    await startNewSession(title: 'Workout');
  }

  Future<void> discardDraft() async {
    state = WorkoutLogState(active: null, history: state.history);
    await _workoutRepo.saveDraft(null);
    await startNewSession(title: 'Workout');
  }
}

final workoutLogProvider =
    StateNotifierProvider<WorkoutLogNotifier, WorkoutLogState>(
  (_) => WorkoutLogNotifier(),
);
