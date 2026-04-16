import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../data/journal_sharing_model.dart';
import '../data/journal_sharing_repository.dart';

// ── Repository ───────────────────────────────────────────────────────────────

final journalSharingRepoProvider = Provider<JournalSharingRepository>((ref) =>
    JournalSharingRepository(ref.watch(firestoreProvider)));

// ── My profile ───────────────────────────────────────────────────────────────

final myJournalProfileProvider = StreamProvider<JournalProfile?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(journalSharingRepoProvider).watchProfile(uid);
});

class JournalProfileNotifier extends StateNotifier<AsyncValue<void>> {
  JournalProfileNotifier(this._repo, this._uid) : super(const AsyncValue.data(null));

  final JournalSharingRepository _repo;
  final String _uid;

  Future<void> save(JournalProfile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.saveProfile(profile));
  }

  Future<void> createDefault(String displayName) async {
    final existing = await _repo.getProfile(_uid);
    if (existing != null) return;
    await _repo.saveProfile(JournalProfile(
      uid: _uid,
      penName: displayName,
      createdAt: DateTime.now(),
    ));
  }
}

final journalProfileNotifierProvider =
    StateNotifierProvider<JournalProfileNotifier, AsyncValue<void>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid ?? '';
  return JournalProfileNotifier(ref.watch(journalSharingRepoProvider), uid);
});

// ── Discovery ─────────────────────────────────────────────────────────────────

final publicJournalsProvider =
    StreamProvider.family<List<JournalProfile>, String?>((ref, tag) =>
        ref.watch(journalSharingRepoProvider).watchPublicProfiles(tag: tag));

// ── Incoming requests (owner) ─────────────────────────────────────────────────

final receivedRequestsProvider =
    StreamProvider<List<JournalAccessRequest>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(journalSharingRepoProvider).watchReceivedRequests(uid);
});

/// Pending request count — used for badge on journal tab.
final pendingRequestCountProvider = Provider<int>((ref) {
  final requests = ref.watch(receivedRequestsProvider).value ?? [];
  return requests.where((r) => r.isPending).length;
});

// ── Sent requests (viewer) ────────────────────────────────────────────────────

final sentRequestsProvider = StreamProvider<List<JournalAccessRequest>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value([]);
  return ref.watch(journalSharingRepoProvider).watchSentRequests(uid);
});

// ── Request actions ───────────────────────────────────────────────────────────

class RequestNotifier extends StateNotifier<AsyncValue<void>> {
  RequestNotifier(this._repo) : super(const AsyncValue.data(null));

  final JournalSharingRepository _repo;

  Future<bool> sendRequest({
    required String fromUid,
    required String fromName,
    required JournalProfile owner,
    String message = '',
    bool paymentClaimed = false,
    double amountPaid = 0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final req = JournalAccessRequest(
        fromUid: fromUid,
        fromName: fromName,
        toUid: owner.uid,
        ownerPenName: owner.penName,
        message: message,
        paymentClaimed: paymentClaimed,
        amountPaid: amountPaid,
        requestedAt: DateTime.now(),
      );
      if (paymentClaimed) {
        await _repo.claimPaymentAndRequest(req, owner);
      } else {
        await _repo.sendRequest(req);
      }
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> approve(JournalAccessRequest req) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _repo.approveRequest(req.id!, req.toUid, req.fromUid));
  }

  Future<void> deny(JournalAccessRequest req) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.denyRequest(req.id!));
  }

  Future<void> revoke(String ownerUid, String viewerUid) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.revokeAccess(ownerUid, viewerUid));
  }

  Future<RequestStatus?> checkExisting(String viewerUid, String ownerUid) =>
      _repo.checkExistingRequest(viewerUid, ownerUid);
}

final requestNotifierProvider =
    StateNotifierProvider<RequestNotifier, AsyncValue<void>>(
        (ref) => RequestNotifier(ref.watch(journalSharingRepoProvider)));

// ── Viewer: read another user's entries ──────────────────────────────────────

final ownerEntriesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, ownerUid) {
  return ref
      .watch(journalSharingRepoProvider)
      .watchOwnerEntries(ownerUid)
      .map((list) => list.cast<Map<String, dynamic>>());
});
