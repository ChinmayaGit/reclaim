import 'package:cloud_firestore/cloud_firestore.dart';

// ── Journal public profile ────────────────────────────────────────────────────

enum JournalVisibility {
  private,  // not discoverable
  request,  // free to read after approval
  paid,     // pay to request access (honour-system UPI)
}

class JournalProfile {
  const JournalProfile({
    required this.uid,
    required this.penName,
    this.bio = '',
    this.visibility = JournalVisibility.private,
    this.priceinr = 0,
    this.upiId = '',
    this.autoApprovePaid = true,
    this.tags = const [],
    this.allowedViewers = const [],
    this.entriesCount = 0,
    required this.createdAt,
  });

  final String uid;
  final String penName;       // can be pseudonym
  final String bio;
  final JournalVisibility visibility;
  final double priceinr;       // 0 if not paid
  final String upiId;          // owner's UPI ID for paid access
  final bool autoApprovePaid;  // auto-grant after payment claim
  final List<String> tags;
  final List<String> allowedViewers; // uids with approved access
  final int entriesCount;
  final DateTime createdAt;

  bool get isPublic => visibility != JournalVisibility.private;
  bool get isPaid => visibility == JournalVisibility.paid && priceinr > 0;

  factory JournalProfile.fromJson(Map<String, dynamic> j) => JournalProfile(
        uid: j['uid'] as String,
        penName: j['penName'] as String? ?? 'Anonymous',
        bio: j['bio'] as String? ?? '',
        visibility: JournalVisibility.values.firstWhere(
          (v) => v.name == (j['visibility'] as String? ?? 'private'),
          orElse: () => JournalVisibility.private,
        ),
        priceinr: (j['priceinr'] as num?)?.toDouble() ?? 0,
        upiId: j['upiId'] as String? ?? '',
        autoApprovePaid: j['autoApprovePaid'] as bool? ?? true,
        tags: List<String>.from(j['tags'] ?? []),
        allowedViewers: List<String>.from(j['allowedViewers'] ?? []),
        entriesCount: (j['entriesCount'] as num?)?.toInt() ?? 0,
        createdAt: (j['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'penName': penName,
        'bio': bio,
        'visibility': visibility.name,
        'priceinr': priceinr,
        'upiId': upiId,
        'autoApprovePaid': autoApprovePaid,
        'tags': tags,
        'allowedViewers': allowedViewers,
        'entriesCount': entriesCount,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  JournalProfile copyWith({
    String? penName,
    String? bio,
    JournalVisibility? visibility,
    double? priceinr,
    String? upiId,
    bool? autoApprovePaid,
    List<String>? tags,
    List<String>? allowedViewers,
    int? entriesCount,
  }) =>
      JournalProfile(
        uid: uid,
        penName: penName ?? this.penName,
        bio: bio ?? this.bio,
        visibility: visibility ?? this.visibility,
        priceinr: priceinr ?? this.priceinr,
        upiId: upiId ?? this.upiId,
        autoApprovePaid: autoApprovePaid ?? this.autoApprovePaid,
        tags: tags ?? this.tags,
        allowedViewers: allowedViewers ?? this.allowedViewers,
        entriesCount: entriesCount ?? this.entriesCount,
        createdAt: createdAt,
      );
}

// ── Access request ────────────────────────────────────────────────────────────

enum RequestStatus { pending, approved, denied, cancelled }

class JournalAccessRequest {
  const JournalAccessRequest({
    this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.ownerPenName,
    this.status = RequestStatus.pending,
    this.message = '',
    this.paymentClaimed = false,
    this.amountPaid = 0,
    required this.requestedAt,
    this.respondedAt,
  });

  final String? id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String ownerPenName;
  final RequestStatus status;
  final String message;
  final bool paymentClaimed;
  final double amountPaid;
  final DateTime requestedAt;
  final DateTime? respondedAt;

  bool get isPending => status == RequestStatus.pending;

  factory JournalAccessRequest.fromJson(String id, Map<String, dynamic> j) =>
      JournalAccessRequest(
        id: id,
        fromUid: j['fromUid'] as String,
        fromName: j['fromName'] as String? ?? 'Anonymous',
        toUid: j['toUid'] as String,
        ownerPenName: j['ownerPenName'] as String? ?? '',
        status: RequestStatus.values.firstWhere(
          (s) => s.name == (j['status'] as String? ?? 'pending'),
          orElse: () => RequestStatus.pending,
        ),
        message: j['message'] as String? ?? '',
        paymentClaimed: j['paymentClaimed'] as bool? ?? false,
        amountPaid: (j['amountPaid'] as num?)?.toDouble() ?? 0,
        requestedAt: (j['requestedAt'] as Timestamp).toDate(),
        respondedAt: j['respondedAt'] == null
            ? null
            : (j['respondedAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'fromUid': fromUid,
        'fromName': fromName,
        'toUid': toUid,
        'ownerPenName': ownerPenName,
        'status': status.name,
        'message': message,
        'paymentClaimed': paymentClaimed,
        'amountPaid': amountPaid,
        'requestedAt': Timestamp.fromDate(requestedAt),
        'respondedAt':
            respondedAt == null ? null : Timestamp.fromDate(respondedAt!),
      };
}
