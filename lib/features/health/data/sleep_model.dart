import 'dart:convert';

class SleepEntry {
  const SleepEntry({required this.bedtimeIso, required this.wakeTimeIso});

  final String bedtimeIso;
  final String wakeTimeIso;

  DateTime get bedtime => DateTime.parse(bedtimeIso);
  DateTime get wakeTime => DateTime.parse(wakeTimeIso);
  double get hours => wakeTime.difference(bedtime).inMinutes / 60.0;

  Map<String, dynamic> toJson() => {'b': bedtimeIso, 'w': wakeTimeIso};

  factory SleepEntry.fromJson(Map<String, dynamic> j) => SleepEntry(
        bedtimeIso: j['b'] as String,
        wakeTimeIso: j['w'] as String,
      );
}

class SleepState {
  const SleepState({
    this.goalHours = 8.0,
    this.entries = const [],
    this.bedtimeReminderEnabled = false,
    this.bedtimeHour = 22,
    this.bedtimeMinute = 0,
  });

  final double goalHours;
  final List<SleepEntry> entries;
  final bool bedtimeReminderEnabled;
  final int bedtimeHour;
  final int bedtimeMinute;

  SleepEntry? get lastEntry => entries.isEmpty ? null : entries.last;
  double? get lastNightHours => lastEntry?.hours;

  List<SleepEntry> get last7 {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return entries.where((e) => e.wakeTime.isAfter(cutoff)).toList();
  }

  SleepState copyWith({
    double? goalHours,
    List<SleepEntry>? entries,
    bool? bedtimeReminderEnabled,
    int? bedtimeHour,
    int? bedtimeMinute,
  }) =>
      SleepState(
        goalHours: goalHours ?? this.goalHours,
        entries: entries ?? this.entries,
        bedtimeReminderEnabled:
            bedtimeReminderEnabled ?? this.bedtimeReminderEnabled,
        bedtimeHour: bedtimeHour ?? this.bedtimeHour,
        bedtimeMinute: bedtimeMinute ?? this.bedtimeMinute,
      );

  String entriesToJson() =>
      jsonEncode(entries.map((e) => e.toJson()).toList());

  static List<SleepEntry> entriesFromJson(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => SleepEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
