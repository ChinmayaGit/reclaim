import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String? id;
  final String userId;
  final String text;
  final int moodScore; // 1–10
  final List<String> emotionTags;
  final String? voiceNoteUrl;
  final List<String> photoUrls;
  final DateTime createdAt;
  final bool isPrompted;
  final String? promptText;

  const JournalEntry({
    this.id,
    required this.userId,
    required this.text,
    required this.moodScore,
    this.emotionTags = const [],
    this.voiceNoteUrl,
    this.photoUrls = const [],
    required this.createdAt,
    this.isPrompted = false,
    this.promptText,
  });

  factory JournalEntry.fromJson(String id, Map<String, dynamic> json) {
    return JournalEntry(
      id: id,
      userId: json['userId'] as String,
      text: json['text'] as String? ?? '',
      moodScore: (json['moodScore'] as num?)?.toInt() ?? 5,
      emotionTags: List<String>.from(json['emotionTags'] ?? []),
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isPrompted: json['isPrompted'] as bool? ?? false,
      promptText: json['promptText'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'text': text,
    'moodScore': moodScore,
    'emotionTags': emotionTags,
    'voiceNoteUrl': voiceNoteUrl,
    'photoUrls': photoUrls,
    'createdAt': Timestamp.fromDate(createdAt),
    'isPrompted': isPrompted,
    'promptText': promptText,
  };
}

class MoodCheckin {
  final String? id;
  final String userId;
  final int moodScore; // 1–5
  final String? note;
  final DateTime checkinDate;

  const MoodCheckin({
    this.id,
    required this.userId,
    required this.moodScore,
    this.note,
    required this.checkinDate,
  });

  factory MoodCheckin.fromJson(String id, Map<String, dynamic> json) {
    return MoodCheckin(
      id: id,
      userId: json['userId'] as String,
      moodScore: (json['moodScore'] as num?)?.toInt() ?? 3,
      note: json['note'] as String?,
      checkinDate: (json['checkinDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'moodScore': moodScore,
    'note': note,
    'checkinDate': Timestamp.fromDate(checkinDate),
  };
}
