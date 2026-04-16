import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final List<String> recoveryTypes;
  final String? recoverySubType;
  final DateTime? sobrietyDate;
  final String role;
  final String? subRole;
  final String? assignedCounselorId;
  final List<EmergencyContact> emergencyContacts;
  final DateTime createdAt;
  final String? fcmToken;
  final bool onboardingComplete;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.recoveryTypes = const [],
    this.recoverySubType,
    this.sobrietyDate,
    this.role = 'free',
    this.subRole,
    this.assignedCounselorId,
    this.emergencyContacts = const [],
    required this.createdAt,
    this.fcmToken,
    this.onboardingComplete = false,
  });

  bool get isPremium => role == 'premium' || role == 'admin';
  bool get isCounselor => role == 'counselor' || role == 'admin';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      recoveryTypes: List<String>.from(json['recoveryTypes'] ?? []),
      recoverySubType: json['recoverySubType'] as String?,
      sobrietyDate: json['sobrietyDate'] != null
          ? (json['sobrietyDate'] as Timestamp).toDate()
          : null,
      role: json['role'] as String? ?? 'free',
      subRole: json['subRole'] as String?,
      assignedCounselorId: json['assignedCounselorId'] as String?,
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>? ?? [])
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      fcmToken: json['fcmToken'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'photoUrl': photoUrl,
    'recoveryTypes': recoveryTypes,
    'recoverySubType': recoverySubType,
    'sobrietyDate': sobrietyDate != null ? Timestamp.fromDate(sobrietyDate!) : null,
    'role': role,
    'subRole': subRole,
    'assignedCounselorId': assignedCounselorId,
    'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'fcmToken': fcmToken,
    'onboardingComplete': onboardingComplete,
  };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    List<String>? recoveryTypes,
    String? recoverySubType,
    DateTime? sobrietyDate,
    String? role,
    String? subRole,
    String? assignedCounselorId,
    List<EmergencyContact>? emergencyContacts,
    String? fcmToken,
    bool? onboardingComplete,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      recoveryTypes: recoveryTypes ?? this.recoveryTypes,
      recoverySubType: recoverySubType ?? this.recoverySubType,
      sobrietyDate: sobrietyDate ?? this.sobrietyDate,
      role: role ?? this.role,
      subRole: subRole ?? this.subRole,
      assignedCounselorId: assignedCounselorId ?? this.assignedCounselorId,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      createdAt: createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
    name: json['name'] as String,
    phone: json['phone'] as String,
    relationship: json['relationship'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'relationship': relationship,
  };
}
