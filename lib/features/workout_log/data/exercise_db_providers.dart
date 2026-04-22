import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exercise_api_key_repository.dart';
import 'exercise_db_client.dart';

final exerciseApiKeyRepositoryProvider = Provider<ExerciseApiKeyRepository>(
  (_) => ExerciseApiKeyRepository(),
);

/// Loads / updates the RapidAPI key saved on this device.
final rapidApiKeyNotifierProvider =
    AsyncNotifierProvider<RapidApiKeyNotifier, String>(RapidApiKeyNotifier.new);

class RapidApiKeyNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return await ref.read(exerciseApiKeyRepositoryProvider).load() ?? '';
  }

  Future<void> setKey(String key) async {
    final trimmed = key.trim();
    await ref.read(exerciseApiKeyRepositoryProvider).save(trimmed);
    state = AsyncData(trimmed);
  }

  Future<void> clear() async {
    await ref.read(exerciseApiKeyRepositoryProvider).clear();
    state = const AsyncData('');
  }
}

final exerciseDbClientProvider = Provider<ExerciseDbClient?>((ref) {
  final async = ref.watch(rapidApiKeyNotifierProvider);
  final key = async.valueOrNull?.trim() ?? '';
  if (key.isEmpty) return null;
  return ExerciseDbClient(apiKey: key);
});
