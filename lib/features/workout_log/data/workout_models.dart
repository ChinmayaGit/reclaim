import 'dart:convert';

class WorkoutSet {
  const WorkoutSet({
    required this.id,
    this.kg = 0,
    this.reps = 0,
    this.done = false,
  });

  final String id;
  final double kg;
  final int reps;
  final bool done;

  int get volume => (kg * reps).round();

  Map<String, dynamic> toJson() => {
        'i': id,
        'k': kg,
        'r': reps,
        'd': done,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> j) => WorkoutSet(
        id: j['i'] as String,
        kg: (j['k'] as num?)?.toDouble() ?? 0,
        reps: (j['r'] as num?)?.toInt() ?? 0,
        done: j['d'] as bool? ?? false,
      );

  WorkoutSet copyWith({double? kg, int? reps, bool? done}) => WorkoutSet(
        id: id,
        kg: kg ?? this.kg,
        reps: reps ?? this.reps,
        done: done ?? this.done,
      );
}

class GymExercise {
  const GymExercise({
    required this.id,
    required this.name,
    this.muscleGroup = '',
    this.sets = const [],
  });

  final String id;
  final String name;
  final String muscleGroup;
  final List<WorkoutSet> sets;

  Map<String, dynamic> toJson() => {
        'i': id,
        'n': name,
        'm': muscleGroup,
        's': sets.map((e) => e.toJson()).toList(),
      };

  factory GymExercise.fromJson(Map<String, dynamic> j) => GymExercise(
        id: j['i'] as String,
        name: j['n'] as String,
        muscleGroup: j['m'] as String? ?? '',
        sets: (j['s'] as List<dynamic>?)
                ?.map((e) => WorkoutSet.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList() ??
            const [],
      );

  GymExercise copyWith({
    String? name,
    String? muscleGroup,
    List<WorkoutSet>? sets,
  }) =>
      GymExercise(
        id: id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        sets: sets ?? this.sets,
      );
}

/// In-progress session (also persisted as draft).
class ActiveWorkout {
  const ActiveWorkout({
    required this.id,
    required this.title,
    required this.startedAt,
    this.exercises = const [],
  });

  final String id;
  final String title;
  final DateTime startedAt;
  final List<GymExercise> exercises;

  Map<String, dynamic> toJson() => {
        'i': id,
        't': title,
        'a': startedAt.toIso8601String(),
        'e': exercises.map((x) => x.toJson()).toList(),
      };

  factory ActiveWorkout.fromJson(Map<String, dynamic> j) => ActiveWorkout(
        id: j['i'] as String,
        title: j['t'] as String,
        startedAt: DateTime.parse(j['a'] as String),
        exercises: (j['e'] as List<dynamic>)
            .map((e) => GymExercise.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  ActiveWorkout copyWith({
    String? title,
    List<GymExercise>? exercises,
  }) =>
      ActiveWorkout(
        id: id,
        title: title ?? this.title,
        startedAt: startedAt,
        exercises: exercises ?? this.exercises,
      );
}

/// Saved after tapping Finish.
class FinishedWorkout {
  const FinishedWorkout({
    required this.id,
    required this.finishedAt,
    required this.title,
    required this.exercises,
  });

  final String id;
  final DateTime finishedAt;
  final String title;
  final List<GymExercise> exercises;

  int get totalSets =>
      exercises.fold(0, (a, e) => a + e.sets.where((s) => s.done).length);

  int get totalVolume => exercises.fold(
      0,
      (a, e) =>
          a + e.sets.where((s) => s.done).fold(0, (b, s) => b + s.volume));

  Map<String, dynamic> toJson() => {
        'i': id,
        'f': finishedAt.toIso8601String(),
        't': title,
        'e': exercises.map((x) => x.toJson()).toList(),
      };

  factory FinishedWorkout.fromJson(Map<String, dynamic> j) => FinishedWorkout(
        id: j['i'] as String,
        finishedAt: DateTime.parse(j['f'] as String),
        title: j['t'] as String,
        exercises: (j['e'] as List<dynamic>)
            .map((e) => GymExercise.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class WorkoutWeekStats {
  const WorkoutWeekStats({
    required this.sessionCount,
    required this.totalSets,
    required this.totalVolumeKg,
  });

  final int sessionCount;
  final int totalSets;
  final int totalVolumeKg;
}

String newId() => 'id_${DateTime.now().microsecondsSinceEpoch}';

String encodeFinishedList(List<FinishedWorkout> list) =>
    jsonEncode(list.map((e) => e.toJson()).toList());

List<FinishedWorkout> decodeFinishedList(String raw) {
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => FinishedWorkout.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}
