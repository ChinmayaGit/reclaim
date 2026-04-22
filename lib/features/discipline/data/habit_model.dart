import 'dart:convert';

/// Optional difficulty presets map to stored [pointsWeight].
int pointsForDifficulty(String difficulty) => switch (difficulty) {
      'easy' => 1,
      'medium' => 2,
      'hard' => 3,
      'expert' => 5,
      _ => 1,
    };

/// How the habit tile chooses its visual: Material icon, emoji text, or a photo.
enum HabitIconSource {
  material,
  emoji,
  customImage,
}

HabitIconSource habitIconSourceFromJson(Object? raw, HabitItem fallback) {
  if (raw is! String) return _inferIconSource(fallback);
  try {
    return HabitIconSource.values.byName(raw);
  } catch (_) {
    return _inferIconSource(fallback);
  }
}

HabitIconSource _inferIconSource(HabitItem h) {
  final path = h.customImagePath;
  if (path != null && path.trim().isNotEmpty) {
    return HabitIconSource.customImage;
  }
  if (h.emoji != null && h.emoji!.trim().isNotEmpty) {
    return HabitIconSource.emoji;
  }
  return HabitIconSource.material;
}

class HabitItem {
  const HabitItem({
    required this.id,
    required this.name,
    this.iconCode = 0xe86c,
    this.colorValue = 0xFF2EB89A,
    this.emoji,
    this.customImagePath,
    this.pointsWeight = 1,
    this.iconSource = HabitIconSource.material,
    this.dailyGoal = 1,
    this.reminderEnabled = false,
    this.reminderHour = 9,
    this.reminderMinute = 0,
  });

  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final String? emoji;
  final String? customImagePath;
  /// Max points for this habit when the daily goal is fully met (difficulty weight).
  final int pointsWeight;
  final HabitIconSource iconSource;
  /// Times to log per day (e.g. 8 glasses of water). Use 1 for once-per-day habits.
  final int dailyGoal;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  HabitItem copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    String? emoji,
    String? customImagePath,
    int? pointsWeight,
    HabitIconSource? iconSource,
    int? dailyGoal,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) =>
      HabitItem(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
        colorValue: colorValue ?? this.colorValue,
        emoji: emoji ?? this.emoji,
        customImagePath: customImagePath ?? this.customImagePath,
        pointsWeight: pointsWeight ?? this.pointsWeight,
        iconSource: iconSource ?? this.iconSource,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderHour: reminderHour ?? this.reminderHour,
        reminderMinute: reminderMinute ?? this.reminderMinute,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconCode,
        'color': colorValue,
        if (emoji != null && emoji!.isNotEmpty) 'emoji': emoji,
        if (customImagePath != null && customImagePath!.isNotEmpty)
          'imagePath': customImagePath,
        'points': pointsWeight,
        'iconSource': iconSource.name,
        'dailyGoal': dailyGoal,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
      };

  factory HabitItem.fromJson(Map<String, dynamic> j) {
    final emoji = j['emoji'] as String?;
    final imagePath = j['imagePath'] as String?;
    final tmp = HabitItem(
      id: j['id'] as String,
      name: j['name'] as String,
      iconCode: j['icon'] as int? ?? 0xe86c,
      colorValue: j['color'] as int? ?? 0xFF2EB89A,
      emoji: emoji,
      customImagePath: imagePath,
      pointsWeight: (j['points'] as num?)?.toInt() ??
          (j['difficultyPoints'] as num?)?.toInt() ??
          1,
      iconSource: HabitIconSource.material,
      dailyGoal: (j['dailyGoal'] as num?)?.toInt() ?? 1,
      reminderEnabled: j['reminderEnabled'] as bool? ?? false,
      reminderHour: (j['reminderHour'] as num?)?.toInt() ?? 9,
      reminderMinute: (j['reminderMinute'] as num?)?.toInt() ?? 0,
    );
    return tmp.copyWith(
      iconSource: habitIconSourceFromJson(j['iconSource'], tmp),
    );
  }
}

class DisciplineState {
  const DisciplineState({
    this.habits = const [],
    this.habitProgressToday = const {},
    this.streak = 0,
    this.lastCompletedDate,
  });

  final List<HabitItem> habits;
  /// Logged completions or servings today (e.g. glasses of water).
  final Map<String, int> habitProgressToday;
  final int streak;
  final String? lastCompletedDate;

  int countFor(String habitId) => habitProgressToday[habitId] ?? 0;

  bool isHabitSatisfied(HabitItem h) =>
      countFor(h.id) >= h.dailyGoal.clamp(1, 999);

  int get satisfiedHabitsCount =>
      habits.where(isHabitSatisfied).length;

  int get totalCount => habits.length;

  int get totalPointsToday =>
      habits.fold(0, (sum, h) => sum + h.pointsWeight.clamp(1, 100));

  int get earnedPointsToday {
    var sum = 0;
    for (final h in habits) {
      final g = h.dailyGoal.clamp(1, 999);
      final c = countFor(h.id).clamp(0, g);
      sum += ((c * h.pointsWeight) / g).round();
    }
    return sum;
  }

  /// Performance score: points earned / total possible points for today.
  double get pointsProgress =>
      totalPointsToday == 0 ? 0 : earnedPointsToday / totalPointsToday;

  bool get allDone =>
      totalCount > 0 && habits.every(isHabitSatisfied);

  DisciplineState copyWith({
    List<HabitItem>? habits,
    Map<String, int>? habitProgressToday,
    int? streak,
    String? lastCompletedDate,
    bool clearDate = false,
  }) =>
      DisciplineState(
        habits: habits ?? this.habits,
        habitProgressToday: habitProgressToday ?? this.habitProgressToday,
        streak: streak ?? this.streak,
        lastCompletedDate:
            clearDate ? null : (lastCompletedDate ?? this.lastCompletedDate),
      );

  String habitsToJson() =>
      jsonEncode(habits.map((h) => h.toJson()).toList());

  static List<HabitItem> habitsFromJson(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => HabitItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Suggested habits when adding from templates (not auto-loaded on first launch).
const kHabitPresets = [
  HabitItem(
    id: '_preset_book_reading',
    name: 'Book reading',
    iconCode: 0xe865,
    colorValue: 0xFF7C6FE0,
    emoji: '📚',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 3,
    pointsWeight: 2,
  ),
  HabitItem(
    id: '_preset_water',
    name: 'Drink water',
    iconCode: 0xe798,
    colorValue: 0xFF3B8BD4,
    emoji: '💧',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 8,
    pointsWeight: 1,
  ),
  HabitItem(
    id: '_preset_workout',
    name: 'Workout',
    iconCode: 0xe3f8,
    colorValue: 0xFFF0AA2A,
    emoji: '💪',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 1,
    pointsWeight: 3,
  ),
  HabitItem(
    id: '_preset_meditate',
    name: 'Meditate',
    iconCode: 0xe57d,
    colorValue: 0xFF34A85A,
    emoji: '🧘',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 2,
    pointsWeight: 2,
  ),
  HabitItem(
    id: '_preset_nosmoke',
    name: 'No smoking',
    iconCode: 0xe1a3,
    colorValue: 0xFF2EB89A,
    emoji: '🚭',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 1,
    pointsWeight: 3,
  ),
  HabitItem(
    id: '_preset_journal',
    name: 'Journal',
    iconCode: 0xe873,
    colorValue: 0xFF5B8DEF,
    emoji: '✍️',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 1,
    pointsWeight: 2,
  ),
  HabitItem(
    id: '_preset_walk',
    name: 'Walking',
    iconCode: 0xe566,
    colorValue: 0xFF2E8B57,
    emoji: '🚶',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 3,
    pointsWeight: 2,
  ),
  HabitItem(
    id: '_preset_stretch',
    name: 'Stretch / mobility',
    iconCode: 0xe52f,
    colorValue: 0xFF6B9AC4,
    emoji: '🤸',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 2,
    pointsWeight: 1,
  ),
  HabitItem(
    id: '_preset_breath',
    name: 'Deep breathing',
    iconCode: 0xe1a4,
    colorValue: 0xFF5C6BC0,
    emoji: '🌬️',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 4,
    pointsWeight: 1,
  ),
  HabitItem(
    id: '_preset_gratitude',
    name: 'Gratitude notes',
    iconCode: 0xe87d,
    colorValue: 0xFFFFB74D,
    emoji: '🙏',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 3,
    pointsWeight: 1,
  ),
  HabitItem(
    id: '_preset_sleep_window',
    name: 'Sleep window',
    iconCode: 0xe8b4,
    colorValue: 0xFF7E57C2,
    emoji: '😴',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 1,
    pointsWeight: 2,
  ),
  HabitItem(
    id: '_preset_screentime',
    name: 'Screen-off hour',
    iconCode: 0xe6b3,
    colorValue: 0xFF78909C,
    emoji: '📵',
    iconSource: HabitIconSource.emoji,
    dailyGoal: 1,
    pointsWeight: 2,
  ),
];
