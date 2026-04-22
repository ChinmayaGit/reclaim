import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_db_models.dart';
import 'workout_models.dart';

class WorkoutRepository {
  static const _kHistory = 'workout_history_json';
  static const _kDraft = 'workout_draft_json';
  static const _kGuideFavorites = 'workout_guide_favorite_ids';
  static const _kApiGuideFavorites = 'workout_api_guide_favorites_json';

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

  Future<List<String>> loadGuideFavorites() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList(_kGuideFavorites) ?? [];
  }

  Future<void> saveGuideFavorites(List<String> ids) async {
    final p = await SharedPreferences.getInstance();
    final seen = <String>{};
    final dedup = <String>[];
    for (final id in ids) {
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      dedup.add(id);
    }
    await p.setStringList(_kGuideFavorites, dedup);
  }

  Future<List<ApiGuideFavorite>> loadApiGuideFavorites() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kApiGuideFavorites);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ApiGuideFavorite.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((f) => f.id.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveApiGuideFavorites(List<ApiGuideFavorite> list) async {
    final p = await SharedPreferences.getInstance();
    final seen = <String>{};
    final out = <ApiGuideFavorite>[];
    for (final f in list) {
      if (f.id.isEmpty || seen.contains(f.id)) continue;
      seen.add(f.id);
      out.add(f);
    }
    await p.setString(
      _kApiGuideFavorites,
      jsonEncode(out.map((e) => e.toJson()).toList()),
    );
  }
}
