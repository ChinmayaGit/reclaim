import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String? id;
  final String clientId;
  final String counselorId;
  final String counselorName;
  final DateTime scheduledAt;
  final String type; // 'video' | 'chat' | 'async'
  final String status; // 'booked' | 'active' | 'done' | 'cancelled'
  final String? agoraChannelId;
  final String? notesUrl;

  const SessionModel({
    this.id,
    required this.clientId,
    required this.counselorId,
    required this.counselorName,
    required this.scheduledAt,
    required this.type,
    this.status = 'booked',
    this.agoraChannelId,
    this.notesUrl,
  });

  factory SessionModel.fromJson(String id, Map<String, dynamic> json) {
    return SessionModel(
      id: id,
      clientId: json['clientId'] as String,
      counselorId: json['counselorId'] as String,
      counselorName: json['counselorName'] as String? ?? 'Counselor',
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      type: json['type'] as String? ?? 'video',
      status: json['status'] as String? ?? 'booked',
      agoraChannelId: json['agoraChannelId'] as String?,
      notesUrl: json['notesUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'counselorId': counselorId,
    'counselorName': counselorName,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'type': type,
    'status': status,
    'agoraChannelId': agoraChannelId,
    'notesUrl': notesUrl,
  };
}

class ResourceModel {
  final String? id;
  final String title;
  final String type; // 'article' | 'video' | 'audio' | 'worksheet'
  final List<String> categories;
  final bool isPremium;
  final String contentUrl;
  final String? thumbnailUrl;
  final String? description;
  final String uploadedBy;

  const ResourceModel({
    this.id,
    required this.title,
    required this.type,
    this.categories = const [],
    this.isPremium = false,
    required this.contentUrl,
    this.thumbnailUrl,
    this.description,
    required this.uploadedBy,
  });

  factory ResourceModel.fromJson(String id, Map<String, dynamic> json) {
    return ResourceModel(
      id: id,
      title: json['title'] as String,
      type: json['type'] as String? ?? 'article',
      categories: List<String>.from(json['category'] ?? []),
      isPremium: json['isPremium'] as bool? ?? false,
      contentUrl: json['contentUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      description: json['description'] as String?,
      uploadedBy: json['uploadedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type,
    'category': categories,
    'isPremium': isPremium,
    'contentUrl': contentUrl,
    'thumbnailUrl': thumbnailUrl,
    'description': description,
    'uploadedBy': uploadedBy,
  };
}
