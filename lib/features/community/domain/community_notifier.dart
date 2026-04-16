import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/community_repository.dart';
import '../../../core/providers/core_providers.dart';

// ─── Stream of all posts ──────────────────────────────────────────────────────

final communityPostsProvider = StreamProvider<List<CommunityPost>>((ref) {
  return ref.watch(communityRepositoryProvider).watchPosts();
});

// ─── Notifier for create / heart / delete ────────────────────────────────────

class CommunityNotifier extends StateNotifier<AsyncValue<void>> {
  CommunityNotifier(this._repo, this._ref) : super(const AsyncData(null));

  final CommunityRepository _repo;
  final Ref _ref;

  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> createPost({
    required String content,
    required String type,
    String? groupId,
  }) async {
    final uid = _uid;
    if (uid == null || content.trim().isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.createPost(
      CommunityPost(
        id: '',
        userId: uid,
        anonymousName: generateAnonName(uid),
        content: content.trim(),
        type: type,
        heartedBy: const [],
        createdAt: DateTime.now(),
        groupId: groupId,
      ),
    ));
  }

  Future<void> toggleHeart(String postId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.toggleHeart(postId, uid);
  }

  Future<void> deletePost(String postId) async {
    await _repo.deletePost(postId);
  }
}

final communityNotifierProvider =
    StateNotifierProvider<CommunityNotifier, AsyncValue<void>>((ref) {
  return CommunityNotifier(ref.watch(communityRepositoryProvider), ref);
});
