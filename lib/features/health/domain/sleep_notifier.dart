import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sleep_model.dart';
import '../data/sleep_repository.dart';

final _repo = SleepRepository();

class SleepNotifier extends StateNotifier<SleepState> {
  SleepNotifier() : super(const SleepState()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.load();
  }

  Future<void> logSleep({
    required DateTime bedtime,
    required DateTime wakeTime,
  }) async {
    final entry = SleepEntry(
      bedtimeIso: bedtime.toIso8601String(),
      wakeTimeIso: wakeTime.toIso8601String(),
    );
    // Keep last 30 entries
    final updated = [...state.entries, entry].reversed.take(30).toList().reversed.toList();
    state = state.copyWith(entries: updated);
    await _repo.saveEntries(updated);
  }

  Future<void> deleteEntry(int index) async {
    final updated = [...state.entries]..removeAt(index);
    state = state.copyWith(entries: updated);
    await _repo.saveEntries(updated);
  }

  Future<void> setGoal(double hours) async {
    state = state.copyWith(goalHours: hours);
    await _repo.saveSettings(
      goalHours: state.goalHours,
      reminderEnabled: state.bedtimeReminderEnabled,
      bedtimeHour: state.bedtimeHour,
      bedtimeMinute: state.bedtimeMinute,
    );
  }

  Future<void> setReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    state = state.copyWith(
      bedtimeReminderEnabled: enabled,
      bedtimeHour: hour ?? state.bedtimeHour,
      bedtimeMinute: minute ?? state.bedtimeMinute,
    );
    await _repo.saveSettings(
      goalHours: state.goalHours,
      reminderEnabled: state.bedtimeReminderEnabled,
      bedtimeHour: state.bedtimeHour,
      bedtimeMinute: state.bedtimeMinute,
    );
  }
}

final sleepProvider =
    StateNotifierProvider<SleepNotifier, SleepState>((_) => SleepNotifier());
