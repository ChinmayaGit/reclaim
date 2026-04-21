import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'workout_models.dart';

class WorkoutRepository {
  static const _kHistory = 'workout_history_json';
  static const _kDraft = 'workout_draft_json';

  Future<List<FinishedWorkout>> loadHistory() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      return decodeFinishedList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<FinishedWorkout> list) async {
    final p = await SharedPreferences.getInstance();
    final trimmed = list.length > 120 ? list.sublist(list.length - 120) : list;
    await p.setString(_kHistory, encodeFinishedList(trimmed));
  }

  Future<ActiveWorkout?> loadDraft() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kDraft);
    if (raw == null || raw.isEmpty) return null;
    try {
      return ActiveWorkout.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDraft(ActiveWorkout? w) async {
    final p = await SharedPreferences.getInstance();
    if (w == null) {
      await p.remove(_kDraft);
    } else {
      await p.setString(_kDraft, jsonEncode(w.toJson()));
    }
  }
}
