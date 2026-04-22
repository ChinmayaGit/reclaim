/// One exercise row from [ExerciseDB](https://github.com/ExerciseDB/exercisedb-api) (RapidAPI gateway).
class ExerciseDbExercise {
  const ExerciseDbExercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.target,
    required this.equipment,
  });

  final String id;
  final String name;
  final String bodyPart;
  final String target;
  final String equipment;

  factory ExerciseDbExercise.fromJson(Map<String, dynamic> j) {
    return ExerciseDbExercise(
      id: j['id']?.toString() ?? '',
      name: j['name'] as String? ?? 'Exercise',
      bodyPart: j['bodyPart'] as String? ?? '',
      target: j['target'] as String? ?? '',
      equipment: j['equipment'] as String? ?? '',
    );
  }
}

/// Persisted favorite for API-backed guide cards (GIF requires id + headers).
class ApiGuideFavorite {
  const ApiGuideFavorite({
    required this.id,
    required this.name,
    required this.bodyPart,
  });

  final String id;
  final String name;
  final String bodyPart;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bodyPart': bodyPart,
      };

  factory ApiGuideFavorite.fromJson(Map<String, dynamic> j) {
    return ApiGuideFavorite(
      id: j['id']?.toString() ?? '',
      name: j['name'] as String? ?? '',
      bodyPart: j['bodyPart'] as String? ?? '',
    );
  }
}
