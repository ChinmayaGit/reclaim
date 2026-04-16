import 'package:cloud_firestore/cloud_firestore.dart';
import 'journal_sharing_model.dart';

class JournalSharingRepository {
  JournalSharingRepository(this._db);
  final FirebaseFirestore _db;

  static const _profiles  = 'journalProfiles';
  static const _requests  = 'journalAccessRequests';

  // ── My profile ────────────────────────────────────────────────────────────

  Future<JournalProfile?> getProfile(String uid) async {
    final snap = await _db.collection(_profiles).doc(uid).get();
    if (!snap.exists) return null;
    return JournalProfile.fromJson(snap.data()!);
  }

  Stream<JournalProfile?> watchProfile(String uid) =>
      _db.collection(_profiles).doc(uid).snapshots().map((s) =>
          s.exists ? JournalProfile.fromJson(s.data()!) : null);

  Future<void> saveProfile(JournalProfile profile) =>
      _db.collection(_profiles).doc(profile.uid).set(profile.toJson());

  Future<void> deleteProfile(String uid) =>
      _db.collection(_profiles).doc(uid).delete();

  /// Update only entry count (called when user saves/deletes a journal entry).
  Future<void> updateEntryCount(String uid, int count) =>
      _db.collection(_profiles).doc(uid).update({'entriesCount': count});

  // ── Discovery ─────────────────────────────────────────────────────────────

  /// Returns public profiles (request or paid), optionally filtered by tag.
  Stream<List<JournalProfile>> watchPublicProfiles({String? tag}) {
    Query q = _db
        .collection(_profiles)
        .where('visibility', whereIn: ['request', 'paid']);
    if (tag != null && tag != 'all') {
      q = q.where('tags', arrayContains: tag);
    }
    return q.snapshots().map((snap) => snap.docs
        .map((d) => JournalProfile.fromJson(d.data() as Map<String, dynamic>))
        .toList());
  }

  // ── Viewer-side entries ───────────────────────────────────────────────────

  /// Read another user's journal entries (only works if Firestore rules
  /// put the calling uid in ownerProfile.allowedViewers).
  Stream<List<dynamic>> watchOwnerEntries(String ownerUid) =>
      _db
          .collection('journalEntries')
          .where('userId', isEqualTo: ownerUid)
          .snapshots()
          .map((snap) => snap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList());

  // ── Access requests ───────────────────────────────────────────────────────

  /// Outgoing requests from [uid] (as viewer).
  Stream<List<JournalAccessRequest>> watchSentRequests(String uid) =>
      _db.collection(_requests)
          .where('fromUid', isEqualTo: uid)
          .snapshots()
          .map(_mapRequests);

  /// Incoming requests to [uid] (as owner).
  Stream<List<JournalAccessRequest>> watchReceivedRequests(String uid) =>
      _db.collection(_requests)
          .where('toUid', isEqualTo: uid)
          .snapshots()
          .map(_mapRequests);

  List<JournalAccessRequest> _mapRequests(QuerySnapshot snap) =>
      snap.docs.map((d) =>
          JournalAccessRequest.fromJson(d.id, d.data() as Map<String, dynamic>))
      .toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  Future<void> sendRequest(JournalAccessRequest req) =>
      _db.collection(_requests).add(req.toJson());

  Future<void> approveRequest(String requestId, String ownerUid, String viewerUid) async {
    final batch = _db.batch();
    // Mark request approved
    batch.update(_db.collection(_requests).doc(requestId), {
      'status': 'approved',
      'respondedAt': Timestamp.now(),
    });
    // Add viewer to allowedViewers in the owner's profile
    batch.update(_db.collection(_profiles).doc(ownerUid), {
      'allowedViewers': FieldValue.arrayUnion([viewerUid]),
    });
    await batch.commit();
  }

  Future<void> denyRequest(String requestId) =>
      _db.collection(_requests).doc(requestId).update({
        'status': 'denied',
        'respondedAt': Timestamp.now(),
      });

  Future<void> cancelRequest(String requestId) =>
      _db.collection(_requests).doc(requestId).update({
        'status': 'cancelled',
        'respondedAt': Timestamp.now(),
      });

  Future<void> revokeAccess(String ownerUid, String viewerUid) async {
    final batch = _db.batch();
    batch.update(_db.collection(_profiles).doc(ownerUid), {
      'allowedViewers': FieldValue.arrayRemove([viewerUid]),
    });
    // Also deny any active approved request
    final snap = await _db.collection(_requests)
        .where('fromUid', isEqualTo: viewerUid)
        .where('toUid', isEqualTo: ownerUid)
        .where('status', isEqualTo: 'approved')
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'status': 'denied',
        'respondedAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  /// Claim payment + auto-approve if profile has autoApprovePaid=true.
  Future<void> claimPaymentAndRequest(
    JournalAccessRequest req,
    JournalProfile ownerProfile,
  ) async {
    final docRef = await _db.collection(_requests).add(req.toJson());
    if (ownerProfile.autoApprovePaid && req.paymentClaimed) {
      await approveRequest(docRef.id, ownerProfile.uid, req.fromUid);
    }
  }

  /// Check if [viewerUid] already has pending/approved request to [ownerUid].
  Future<RequestStatus?> checkExistingRequest(
      String viewerUid, String ownerUid) async {
    final snap = await _db.collection(_requests)
        .where('fromUid', isEqualTo: viewerUid)
        .where('toUid', isEqualTo: ownerUid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return RequestStatus.values.firstWhere(
      (s) => s.name == (snap.docs.first.data()['status'] as String),
      orElse: () => RequestStatus.pending,
    );
  }
}
