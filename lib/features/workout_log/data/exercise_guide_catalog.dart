/// Curated exercise guides using **free** media:
/// - [Wikimedia Commons](https://commons.wikimedia.org) GIFs (CC-licensed)
/// - [wger](https://wger.de) exercise illustrations (open fitness DB)
///
/// URLs may change; [CachedNetworkImage] shows a fallback if a link fails.
class ExerciseGuideEntry {
  const ExerciseGuideEntry({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.mediaUrl,
    this.isGif = false,
  });

  /// Stable slug for favorites storage.
  final String id;
  final String name;
  /// chest | arms | back | legs | shoulders | core | cardio
  final String categoryId;
  final String mediaUrl;
  final bool isGif;
}

/// UI labels for filter chips (id, label).
const kExerciseGuideCategories = <(String, String)>[
  ('all', 'All'),
  ('chest', 'Chest'),
  ('arms', 'Arms'),
  ('back', 'Back'),
  ('legs', 'Legs'),
  ('shoulders', 'Shoulders'),
  ('core', 'Core'),
  ('cardio', 'Cardio'),
];

/// Public-domain / open-licensed reference media only.
const kExerciseGuideEntries = <ExerciseGuideEntry>[
  ExerciseGuideEntry(
    id: 'pushup_loop',
    name: 'Push-up',
    categoryId: 'chest',
    mediaUrl:
        'https://upload.wikimedia.org/wikipedia/commons/1/13/Man_Doing_Push_Ups_GIF_Animation_Loop.gif',
    isGif: true,
  ),
  ExerciseGuideEntry(
    id: 'crucifix_pushup',
    name: 'Crucifix push-up',
    categoryId: 'chest',
    mediaUrl:
        'https://upload.wikimedia.org/wikipedia/commons/9/94/Crucifix-push-up.gif',
    isGif: true,
  ),
  ExerciseGuideEntry(
    id: 'crunches',
    name: 'Crunches',
    categoryId: 'core',
    mediaUrl: 'https://wger.de/media/exercise-images/91/Crunches-1.png',
  ),
  ExerciseGuideEntry(
    id: 'decline_crunch',
    name: 'Decline crunch',
    categoryId: 'core',
    mediaUrl: 'https://wger.de/media/exercise-images/93/Decline-crunch-1.png',
  ),
  ExerciseGuideEntry(
    id: 'hyperextension',
    name: 'Back extension',
    categoryId: 'back',
    mediaUrl: 'https://wger.de/media/exercise-images/128/Hyperextensions-1.png',
  ),
  ExerciseGuideEntry(
    id: 'bench_press',
    name: 'Bench press',
    categoryId: 'chest',
    mediaUrl: 'https://wger.de/media/exercise-images/82/Bench-press-1.png',
  ),
  ExerciseGuideEntry(
    id: 'incline_db_press',
    name: 'Incline dumbbell press',
    categoryId: 'chest',
    mediaUrl: 'https://wger.de/media/exercise-images/15/Incline-bench-press-1.png',
  ),
  ExerciseGuideEntry(
    id: 'bicep_curl',
    name: 'Biceps curl',
    categoryId: 'arms',
    mediaUrl: 'https://wger.de/media/exercise-images/74/Standing-biceps-curl-1.png',
  ),
  ExerciseGuideEntry(
    id: 'tricep_extension',
    name: 'Triceps extension',
    categoryId: 'arms',
    mediaUrl: 'https://wger.de/media/exercise-images/85/Triceps-pushdown-1.png',
  ),
  ExerciseGuideEntry(
    id: 'hammer_curl',
    name: 'Hammer curl',
    categoryId: 'arms',
    mediaUrl: 'https://wger.de/media/exercise-images/81/Hammer-curls-with-dumbbell-1.png',
  ),
  ExerciseGuideEntry(
    id: 'lat_pulldown',
    name: 'Lat pulldown',
    categoryId: 'back',
    mediaUrl: 'https://wger.de/media/exercise-images/79/Lat-pulldown-1.png',
  ),
  ExerciseGuideEntry(
    id: 'barbell_row',
    name: 'Barbell row',
    categoryId: 'back',
    mediaUrl: 'https://wger.de/media/exercise-images/83/Bent-over-rowing-1.png',
  ),
  ExerciseGuideEntry(
    id: 'squat',
    name: 'Squat',
    categoryId: 'legs',
    mediaUrl: 'https://wger.de/media/exercise-images/111/Squats-1.png',
  ),
  ExerciseGuideEntry(
    id: 'lunge',
    name: 'Lunge',
    categoryId: 'legs',
    mediaUrl: 'https://wger.de/media/exercise-images/113/Lunges-1.png',
  ),
  ExerciseGuideEntry(
    id: 'leg_press',
    name: 'Leg press',
    categoryId: 'legs',
    mediaUrl: 'https://wger.de/media/exercise-images/116/Leg-press-1.png',
  ),
  ExerciseGuideEntry(
    id: 'shoulder_press',
    name: 'Shoulder press',
    categoryId: 'shoulders',
    mediaUrl: 'https://wger.de/media/exercise-images/77/Shoulder-press-1.png',
  ),
  ExerciseGuideEntry(
    id: 'lateral_raise',
    name: 'Lateral raise',
    categoryId: 'shoulders',
    mediaUrl: 'https://wger.de/media/exercise-images/78/Lateral-raises-1.png',
  ),
  ExerciseGuideEntry(
    id: 'plank',
    name: 'Plank',
    categoryId: 'core',
    mediaUrl: 'https://wger.de/media/exercise-images/92/Plank-1.png',
  ),
  ExerciseGuideEntry(
    id: 'burpee',
    name: 'Burpee',
    categoryId: 'cardio',
    mediaUrl: 'https://wger.de/media/exercise-images/109/Burpees-1.png',
  ),
  ExerciseGuideEntry(
    id: 'jumping_jack',
    name: 'Jumping jacks',
    categoryId: 'cardio',
    mediaUrl: 'https://wger.de/media/exercise-images/107/Jumping-jacks-1.png',
  ),
];

List<ExerciseGuideEntry> guideEntriesForCategory(String categoryId) {
  if (categoryId == 'all') return kExerciseGuideEntries.toList();
  return kExerciseGuideEntries
      .where((e) => e.categoryId == categoryId)
      .toList();
}

ExerciseGuideEntry? guideEntryById(String id) {
  for (final e in kExerciseGuideEntries) {
    if (e.id == id) return e;
  }
  return null;
}

String categoryLabel(String categoryId) {
  for (final c in kExerciseGuideCategories) {
    if (c.$1 == categoryId) return c.$2;
  }
  return categoryId;
}

/// Maps UI filter chips to ExerciseDB [`/exercises/bodyPart/{bodyPart}`](https://edb-docs.up.railway.app/docs/exercise-service/intro).
/// Returns `null` for **All** (uses `/exercises` instead).
String? exerciseDbBodyPartForCategory(String categoryId) {
  switch (categoryId) {
    case 'all':
      return null;
    case 'chest':
      return 'chest';
    case 'arms':
      return 'upper arms';
    case 'back':
      return 'back';
    case 'legs':
      return 'upper legs';
    case 'shoulders':
      return 'shoulders';
    case 'core':
      return 'waist';
    case 'cardio':
      return 'cardio';
    default:
      return null;
  }
}
