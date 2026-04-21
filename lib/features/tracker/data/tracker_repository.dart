import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/tracker_model.dart';

class TrackerRepository {
  TrackerRepository(this._firestore);
  final FirebaseFirestore _firestore;

  DocumentReference _trackerDoc(String uid) =>
      _firestore.collection(AppConstants.colTrackers).doc(uid);

  CollectionReference _urgeLogCol(String uid) =>
      _firestore.collection(AppConstants.colTrackers).doc(uid).collection('urgeLog');

  // ─── Tracker ──────────────────────────────────────────────────────────────

  Stream<TrackerModel?> watchTracker(String uid) {
    return _trackerDoc(uid).snapshots().asyncMap((snap) async {
      if (!snap.exists || snap.data() == null) {
        // Auto-create on first login so the dashboard never hangs on null
        await createTracker(uid);
        return TrackerModel(
          userId: uid,
          counters: [RecoveryCounter(label: 'My Recovery', startDate: DateTime.now())],
        );
      }
      return TrackerModel.fromJson(snap.data() as Map<String, dynamic>);
    });
  }

  Future<void> createTracker(String uid) async {
    final tracker = TrackerModel(
      userId: uid,
      counters: [
        RecoveryCounter(label: 'My Recovery', startDate: DateTime.now()),
      ],
      lastCheckIn: null,
    );
    await _trackerDoc(uid).set(tracker.toJson());
  }

  Future<void> checkIn(String uid) async {
    final now = DateTime.now();
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(_trackerDoc(uid));
      if (!snap.exists) return;
      final tracker = TrackerModel.fromJson(snap.data() as Map<String, dynamic>);

      int newStreak = tracker.currentStreakDays;
      if (!tracker.checkedInToday) {
        final yesterday = now.subtract(const Duration(days: 1));
        final lastCheckIn = tracker.lastCheckIn;
        final isConsecutive = lastCheckIn != null &&
            lastCheckIn.year == yesterday.year &&
            lastCheckIn.month == yesterday.month &&
            lastCheckIn.day == yesterday.day;
        newStreak = isConsecutive ? newStreak + 1 : 1;
      }

      final newLongest = newStreak > tracker.longestStreak
          ? newStreak
          : tracker.longestStreak;

      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      tx.update(_trackerDoc(uid), {
        'lastCheckIn': Timestamp.fromDate(now),
        'currentStreakDays': newStreak,
        'longestStreak': newLongest,
        'checkInDates': FieldValue.arrayUnion([dateStr]),
      });
    });
  }

  Future<void> logRelapse(String uid) async {
    await _trackerDoc(uid).update({
      'currentStreakDays': 0,
      'lastCheckIn': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> addCounter(String uid, RecoveryCounter counter) async {
    await _trackerDoc(uid).update({
      'counters': FieldValue.arrayUnion([counter.toJson()]),
    });
  }

  Future<void> addMilestone(String uid, String milestoneLabel) async {
    await _trackerDoc(uid).update({
      'milestones': FieldValue.arrayUnion([milestoneLabel]),
    });
  }

  // ─── Urge Log ─────────────────────────────────────────────────────────────

  Future<void> logUrge(String uid, UrgeLog log) async {
    await _urgeLogCol(uid).add(log.toJson());
  }

  Stream<List<UrgeLog>> watchUrgeLogs(String uid) {
    return _urgeLogCol(uid)
        .orderBy('loggedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UrgeLog.fromJson(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }
}

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  return TrackerRepository(ref.watch(firestoreProvider));
});
