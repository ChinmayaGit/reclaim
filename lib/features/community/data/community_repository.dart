import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/constants/app_constants.dart';

// ─── Anonymous name generation ────────────────────────────────────────────────
// Deterministic: same UID always produces the same anonymous display name.
String generateAnonName(String uid) {
  const adj = [
    'Brave', 'Gentle', 'Rising', 'Hopeful', 'Steady',
    'Quiet', 'Bold', 'Warm', 'Strong', 'Open',
    'Calm', 'Free', 'Kind', 'True', 'Soft',
    'Clear', 'Deep', 'Still', 'Light', 'Real',
  ];
  const noun = [
    'Soul', 'Star', 'Phoenix', 'Wave', 'Path',
    'Heart', 'Voice', 'Spirit', 'Journey', 'Hope',
    'Dawn', 'River', 'Flame', 'Stone', 'Sky',
    'Shore', 'Bloom', 'Bridge', 'Spark', 'Song',
  ];
  final sum = uid.codeUnits.fold(0, (a, b) => a + b);
  return '${adj[sum % adj.length]}${noun[(sum ~/ 3) % noun.length]}';
}

// ─── Model ────────────────────────────────────────────────────────────────────

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.anonymousName,
    required this.content,
    required this.type,
    required this.heartedBy,
    required this.createdAt,
    this.groupId,
  });

  final String id;
  final String userId;
  final String anonymousName;
  final String content;
  final String type; // 'win' | 'story' | 'question' | 'support'
  final List<String> heartedBy;
  final DateTime createdAt;
  final String? groupId;

  int get hearts => heartedBy.length;
  bool isHeartedBy(String uid) => heartedBy.contains(uid);

  factory CommunityPost.fromJson(String id, Map<String, dynamic> j) {
    return CommunityPost(
      id: id,
      userId: j['userId'] as String? ?? '',
      anonymousName: j['anonymousName'] as String? ?? 'Anonymous',
      content: j['content'] as String? ?? '',
      type: j['type'] as String? ?? 'story',
      heartedBy: List<String>.from(j['heartedBy'] as List? ?? []),
      createdAt: (j['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groupId: j['groupId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'anonymousName': anonymousName,
    'content': content,
    'type': type,
    'heartedBy': heartedBy,
    'createdAt': Timestamp.fromDate(createdAt),
    if (groupId != null) 'groupId': groupId,
  };
}

// ─── Repository ───────────────────────────────────────────────────────────────

class CommunityRepository {
  CommunityRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference get _col =>
      _firestore.collection(AppConstants.colCommunityPosts);

  /// Real-time stream of the latest 60 posts, newest first.
  Stream<List<CommunityPost>> watchPosts() {
    return _col
        .orderBy('createdAt', descending: true)
        .limit(60)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CommunityPost.fromJson(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> createPost(CommunityPost post) async {
    await _col.add(post.toJson());
  }

  /// Toggle heart: add if not hearted, remove if already hearted.
  Future<void> toggleHeart(String postId, String uid) async {
    final ref = _col.doc(postId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final list = List<String>.from(data['heartedBy'] as List? ?? []);
      if (list.contains(uid)) {
        tx.update(ref, {'heartedBy': FieldValue.arrayRemove([uid])});
      } else {
        tx.update(ref, {'heartedBy': FieldValue.arrayUnion([uid])});
      }
    });
  }

  Future<void> deletePost(String postId) async {
    await _col.doc(postId).delete();
  }
}

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(ref.watch(firestoreProvider));
});
