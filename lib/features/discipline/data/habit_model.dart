import 'dart:convert';

class HabitItem {
  const HabitItem({
    required this.id,
    required this.name,
    this.iconCode = 0xe86c, // check_circle_outline
    this.colorValue = 0xFF2EB89A,
  });

  final String id;
  final String name;
  final int iconCode;
  final int colorValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': iconCode,
        'color': colorValue,
      };

  factory HabitItem.fromJson(Map<String, dynamic> j) => HabitItem(
        id: j['id'] as String,
        name: j['name'] as String,
        iconCode: j['icon'] as int? ?? 0xe86c,
        colorValue: j['color'] as int? ?? 0xFF2EB89A,
      );
}

class DisciplineState {
  const DisciplineState({
    this.habits = const [],
    this.completedToday = const {},
    this.streak = 0,
    this.lastCompletedDate,
  });

  final List<HabitItem> habits;
  final Set<String> completedToday;
  final int streak;
  final String? lastCompletedDate;

  int get completedCount => completedToday.length;
  int get totalCount => habits.length;
  double get progress =>
      totalCount == 0 ? 0 : completedCount / totalCount;
  bool get allDone => totalCount > 0 && completedCount >= totalCount;

  DisciplineState copyWith({
    List<HabitItem>? habits,
    Set<String>? completedToday,
    int? streak,
    String? lastCompletedDate,
    bool clearDate = false,
  }) =>
      DisciplineState(
        habits: habits ?? this.habits,
        completedToday: completedToday ?? this.completedToday,
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

// ── Default starter habits ────────────────────────────────────────────────────

const kDefaultHabits = [
  HabitItem(id: 'water',    name: 'Drink water',       iconCode: 0xe798, colorValue: 0xFF3B8BD4),
  HabitItem(id: 'nosmoke',  name: 'No smoking',        iconCode: 0xe1a3, colorValue: 0xFF2EB89A),
  HabitItem(id: 'workout',  name: 'Workout',           iconCode: 0xe3f8, colorValue: 0xFFF0AA2A),
  HabitItem(id: 'nocontact',name: 'No contact',        iconCode: 0xe1b7, colorValue: 0xFFF0714F),
  HabitItem(id: 'read',     name: 'Read 10 min',       iconCode: 0xe865, colorValue: 0xFF7C6FE0),
  HabitItem(id: 'meditate', name: 'Meditate',          iconCode: 0xe57d, colorValue: 0xFF34A85A),
];
