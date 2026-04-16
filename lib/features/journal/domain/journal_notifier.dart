import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/journal_repository.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/models/journal_model.dart';

// ─── Journal entries stream ───────────────────────────────────────────────────

final journalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(journalRepositoryProvider).watchEntries(uid);
});

// ─── Mood history stream ──────────────────────────────────────────────────────

final moodHistoryProvider = StreamProvider<List<MoodCheckin>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(journalRepositoryProvider).watchMoodHistory(uid);
});

// ─── Journal Notifier ─────────────────────────────────────────────────────────

class JournalState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const JournalState({this.isLoading = false, this.error, this.successMessage});
}

class JournalNotifier extends StateNotifier<JournalState> {
  JournalNotifier(this._repo) : super(const JournalState());

  final JournalRepository _repo;

  Future<bool> addEntry(JournalEntry entry) async {
    state = const JournalState(isLoading: true);
    try {
      await _repo.createEntry(entry);
      state = const JournalState(successMessage: 'Journal entry saved.');
      return true;
    } catch (e) {
      state = JournalState(error: 'Failed to save entry.');
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      await _repo.deleteEntry(id);
      return true;
    } catch (e) {
      state = JournalState(error: 'Failed to delete entry.');
      return false;
    }
  }

  Future<bool> saveMoodCheckin(MoodCheckin checkin) async {
    state = const JournalState(isLoading: true);
    try {
      await _repo.saveMoodCheckin(checkin);
      state = const JournalState(successMessage: 'Check-in saved!');
      return true;
    } catch (e) {
      state = JournalState(error: 'Failed to save check-in.');
      return false;
    }
  }

  void clear() => state = const JournalState();
}

final journalNotifierProvider =
    StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier(ref.watch(journalRepositoryProvider));
});
