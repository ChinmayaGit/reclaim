import 'package:cloud_firestore/cloud_firestore.dart';

class TrackerModel {
  final String userId;
  final List<RecoveryCounter> counters;
  final int currentStreakDays;
  final int longestStreak;
  final DateTime? lastCheckIn;
  final List<String> milestones; // earned milestone labels: "7d", "30d"…
  final List<String> checkInDates; // 'yyyy-MM-dd' strings of each check-in day

  const TrackerModel({
    required this.userId,
    this.counters = const [],
    this.currentStreakDays = 0,
    this.longestStreak = 0,
    this.lastCheckIn,
    this.milestones = const [],
    this.checkInDates = const [],
  });

  bool get checkedInToday {
    if (lastCheckIn == null) return false;
    final now = DateTime.now();
    return lastCheckIn!.year == now.year &&
        lastCheckIn!.month == now.month &&
        lastCheckIn!.day == now.day;
  }

  factory TrackerModel.fromJson(Map<String, dynamic> json) {
    return TrackerModel(
      userId: json['userId'] as String,
      counters: (json['counters'] as List<dynamic>? ?? [])
          .map((e) => RecoveryCounter.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentStreakDays: (json['currentStreakDays'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastCheckIn: json['lastCheckIn'] != null
          ? (json['lastCheckIn'] as Timestamp).toDate()
          : null,
      milestones: List<String>.from(json['milestones'] ?? []),
      checkInDates: List<String>.from(json['checkInDates'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'counters': counters.map((c) => c.toJson()).toList(),
    'currentStreakDays': currentStreakDays,
    'longestStreak': longestStreak,
    'lastCheckIn':
        lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
    'milestones': milestones,
    'checkInDates': checkInDates,
  };
}

class RecoveryCounter {
  final String label;
  final DateTime startDate;
  final bool active;

  const RecoveryCounter({
    required this.label,
    required this.startDate,
    this.active = true,
  });

  int get daysSince {
    return DateTime.now().difference(startDate).inDays;
  }

  factory RecoveryCounter.fromJson(Map<String, dynamic> json) {
    return RecoveryCounter(
      label: json['label'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'startDate': Timestamp.fromDate(startDate),
    'active': active,
  };
}

class UrgeLog {
  final String? id;
  final int intensity; // 1–10
  final String trigger;
  final String outcome; // 'resisted' | 'relapsed'
  final DateTime loggedAt;

  const UrgeLog({
    this.id,
    required this.intensity,
    required this.trigger,
    required this.outcome,
    required this.loggedAt,
  });

  factory UrgeLog.fromJson(String id, Map<String, dynamic> json) {
    return UrgeLog(
      id: id,
      intensity: (json['intensity'] as num?)?.toInt() ?? 5,
      trigger: json['trigger'] as String? ?? '',
      outcome: json['outcome'] as String? ?? 'resisted',
      loggedAt: (json['loggedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'intensity': intensity,
    'trigger': trigger,
    'outcome': outcome,
    'loggedAt': Timestamp.fromDate(loggedAt),
  };
}
