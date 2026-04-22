import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user’s RapidAPI key locally (device only). Never commit this value.
class ExerciseApiKeyRepository {
  static const _kPrefsKey = 'exercise_rapidapi_key_v1';

  Future<String?> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kPrefsKey);
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> save(String key) async {
    final p = await SharedPreferences.getInstance();
    final t = key.trim();
    if (t.isEmpty) {
      await p.remove(_kPrefsKey);
    } else {
      await p.setString(_kPrefsKey, t);
    }
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kPrefsKey);
  }
}
