import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tracker_repository.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/tracker_model.dart';
import '../../../shared/constants/app_constants.dart';

// ─── Stream provider ──────────────────────────────────────────────────────────

final trackerProvider = StreamProvider<TrackerModel?>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(trackerRepositoryProvider).watchTracker(uid);
});

final urgeLogsProvider = StreamProvider<List<UrgeLog>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(trackerRepositoryProvider).watchUrgeLogs(uid);
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class TrackerNotifier extends StateNotifier<AsyncValue<void>> {
  TrackerNotifier(this._repo, this._ref) : super(const AsyncData(null));

  final TrackerRepository _repo;
  final Ref _ref;

  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> checkIn() async {
    final uid = _uid;
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.checkIn(uid);
      // Check milestone after check-in
      final tracker = await _repo.watchTracker(uid).first;
      if (tracker != null) {
        final days = tracker.currentStreakDays;
        if (AppConstants.milestoneDays.contains(days) &&
            !tracker.milestones.contains('${days}d')) {
          await _repo.addMilestone(uid, '${days}d');
        }
      }
    });
  }

  Future<void> logRelapse() async {
    final uid = _uid;
    if (uid == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.logRelapse(uid));
  }

  Future<void> logUrge(UrgeLog log) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.logUrge(uid, log);
  }

  Future<void> addCounter(RecoveryCounter counter) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.addCounter(uid, counter);
  }
}

final trackerNotifierProvider =
    StateNotifierProvider<TrackerNotifier, AsyncValue<void>>((ref) {
  return TrackerNotifier(ref.watch(trackerRepositoryProvider), ref);
});
