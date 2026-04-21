import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/water_model.dart';
import '../data/water_repository.dart';

final _repo = WaterRepository();

class WaterNotifier extends StateNotifier<WaterState> {
  WaterNotifier() : super(const WaterState()) {
    _load();
  }

  Future<void> _load() async {
    await _repo.pruneOld();
    state = await _repo.load();
  }

  Future<void> addWater(int amountMl) async {
    final entry = WaterEntry(
      amountMl: amountMl,
      timeIso: DateTime.now().toIso8601String(),
    );
    final updated = [...state.entries, entry];
    state = state.copyWith(entries: updated);
    await _repo.saveEntries(updated);
  }

  Future<void> removeEntry(int index) async {
    final updated = [...state.entries]..removeAt(index);
    state = state.copyWith(entries: updated);
    await _repo.saveEntries(updated);
  }

  Future<void> setGoal(int ml) async {
    state = state.copyWith(goalMl: ml);
    await _repo.saveSettings(
      goalMl: state.goalMl,
      reminderEnabled: state.reminderEnabled,
      reminderIntervalHours: state.reminderIntervalHours,
    );
  }

  Future<void> setReminder({
    required bool enabled,
    int? intervalHours,
  }) async {
    state = state.copyWith(
      reminderEnabled: enabled,
      reminderIntervalHours: intervalHours ?? state.reminderIntervalHours,
    );
    await _repo.saveSettings(
      goalMl: state.goalMl,
      reminderEnabled: state.reminderEnabled,
      reminderIntervalHours: state.reminderIntervalHours,
    );
  }

  void reload() => _load();
}

final waterProvider =
    StateNotifierProvider<WaterNotifier, WaterState>((_) => WaterNotifier());
