import 'dart:convert';

class WaterEntry {
  const WaterEntry({required this.amountMl, required this.timeIso});

  final int amountMl;
  final String timeIso;

  DateTime get time => DateTime.parse(timeIso);

  Map<String, dynamic> toJson() => {'a': amountMl, 't': timeIso};

  factory WaterEntry.fromJson(Map<String, dynamic> j) => WaterEntry(
        amountMl: j['a'] as int,
        timeIso: j['t'] as String,
      );
}

class WaterState {
  const WaterState({
    this.goalMl = 3000,
    this.entries = const [],
    this.reminderEnabled = false,
    this.reminderIntervalHours = 2,
  });

  final int goalMl;
  final List<WaterEntry> entries;
  final bool reminderEnabled;
  final int reminderIntervalHours;

  int get totalTodayMl => entries.fold(0, (s, e) => s + e.amountMl);
  double get progress => (totalTodayMl / goalMl).clamp(0.0, 1.0);
  bool get goalReached => totalTodayMl >= goalMl;

  WaterState copyWith({
    int? goalMl,
    List<WaterEntry>? entries,
    bool? reminderEnabled,
    int? reminderIntervalHours,
  }) =>
      WaterState(
        goalMl: goalMl ?? this.goalMl,
        entries: entries ?? this.entries,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderIntervalHours:
            reminderIntervalHours ?? this.reminderIntervalHours,
      );

  String entriesToJson() =>
      jsonEncode(entries.map((e) => e.toJson()).toList());

  static List<WaterEntry> entriesFromJson(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => WaterEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
