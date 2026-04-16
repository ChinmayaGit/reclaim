import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/journal_model.dart';

class JournalRepository {
  JournalRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference get _col =>
      _firestore.collection(AppConstants.colJournal);

  CollectionReference get _moodCol =>
      _firestore.collection(AppConstants.colMoodCheckins);

  // ─── Journal Entries ──────────────────────────────────────────────────────

  Stream<List<JournalEntry>> watchEntries(String uid) {
    // Query by userId only — no composite index needed.
    // Sort by createdAt descending in Dart to avoid requiring a manual
    // Firestore composite index on [userId, createdAt] (same pattern as
    // watchMoodHistory). This eliminates the cloud_firestore/failed-precondition
    // error that occurs when the index has not been deployed yet.
    return _col
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => JournalEntry.fromJson(d.id, d.data() as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> createEntry(JournalEntry entry) async {
    await _col.add(entry.toJson());
  }

  Future<void> updateEntry(String id, JournalEntry entry) async {
    await _col.doc(id).update(entry.toJson());
  }

  Future<void> deleteEntry(String id) async {
    await _col.doc(id).delete();
  }

  Future<int> getMonthlyCount(String uid) async {
    final start = DateTime.now();
    final firstOfMonth = DateTime(start.year, start.month, 1);
    final snap = await _col
        .where('userId', isEqualTo: uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstOfMonth))
        .count()
        .get();
    return snap.count ?? 0;
  }

  // ─── Mood Check-ins ───────────────────────────────────────────────────────

  Future<void> saveMoodCheckin(MoodCheckin checkin) async {
    // Only one checkin per day – use date as document ID
    final dayKey =
        '${checkin.userId}_${checkin.checkinDate.year}-${checkin.checkinDate.month.toString().padLeft(2, '0')}-${checkin.checkinDate.day.toString().padLeft(2, '0')}';
    await _moodCol.doc(dayKey).set(checkin.toJson());
  }

  Stream<List<MoodCheckin>> watchMoodHistory(String uid, {int days = 30}) {
    // Query by userId only (no composite index needed).
    // Date filtering and sorting happen in Dart to avoid requiring a
    // manual Firestore composite index on [userId, checkinDate].
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _moodCol
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => MoodCheckin.fromJson(d.id, d.data() as Map<String, dynamic>))
              .where((m) => m.checkinDate.isAfter(cutoff))
              .toList()
            ..sort((a, b) => b.checkinDate.compareTo(a.checkinDate));
          return list;
        });
  }

  Future<bool> hasCheckedInToday(String uid) async {
    final today = DateTime.now();
    final dayKey =
        '${uid}_${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final snap = await _moodCol.doc(dayKey).get();
    return snap.exists;
  }
}

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository(ref.watch(firestoreProvider));
});
