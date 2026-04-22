import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../data/community_repository.dart';
import '../domain/community_notifier.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _activeType = 'all';

  static const _typeTabs = [
    ('all',      'All',        '💬'),
    ('expert',   'Expert',     '🎓'),
    ('win',      'Wins',       '🌟'),
    ('story',    'Stories',    '📖'),
    ('question', 'Questions',  '❓'),
    ('support',  'Support',    '🤝'),
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _typeTabs.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() => _activeType = _typeTabs[_tab.index].$1);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Community'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _typeTabs.map((t) => Tab(
            child: Row(
              children: [
                Text(t.$3, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(t.$2),
              ],
            ),
          )).toList(),
        ),
      ),
      body: _PostFeed(type: _activeType),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community_post',
        onPressed: () => _showNewPostSheet(context),
        backgroundColor: AppColors.teal600,
        icon: const Icon(Icons.edit_outlined, color: Colors.white),
        label: const Text('Share', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showNewPostSheet(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colSurface,
      builder: (ctx) => _NewPostSheet(
        scaffoldMessenger: messenger,
      ),
    );
  }
}

// ─── Feed ─────────────────────────────────────────────────────────────────────

class _PostFeed extends ConsumerWidget {
  const _PostFeed({required this.type});
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);
    final uid = ref.watch(currentUserProvider)?.uid ?? '';

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😔', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'Couldn\'t load posts.\nCheck your connection.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colTextSec),
              ),
            ],
          ),
        ),
      ),
      data: (posts) {
        final filtered = type == 'all'
            ? posts
            : posts.where((p) => p.type == type).toList();

        if (filtered.isEmpty) {
          return _EmptyFeed(type: type);
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _PostCard(
            post: filtered[i],
            currentUid: uid,
            onHeart: () => ref
                .read(communityNotifierProvider.notifier)
                .toggleHeart(filtered[i].id),
          ),
        );
      },
    );
  }
}

// ─── Post card ────────────────────────────────────────────────────────────────

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.currentUid,
    required this.onHeart,
  });

  final CommunityPost post;
  final String currentUid;
  final VoidCallback onHeart;

  Color _typeColor(String type) => switch (type) {
    'win'      => AppColors.amber600,
    'support'  => AppColors.purple600,
    'question' => AppColors.blue600,
    _          => AppColors.teal600,
  };

  String _typeLabel(String type) => switch (type) {
    'win'      => '🌟 WIN',
    'support'  => '🤝 SUPPORT',
    'question' => '❓ QUESTION',
    _          => '📖 STORY',
  };

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final liked = post.isHeartedBy(currentUid);
    final tc = _typeColor(post.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.anonymousName[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.anonymousName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: context.colText,
                      ),
                    ),
                    Text(
                      _formatTime(post.createdAt),
                      style: TextStyle(fontSize: 11, color: context.colTextHint),
                    ),
                  ],
                ),
              ),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tc.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _typeLabel(post.type),
                  style: TextStyle(
                    fontSize: 10,
                    color: tc,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Content
          const SizedBox(height: 12),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: context.colText,
            ),
          ),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined,
                      color: context.colTextHint),
                ),
              ),
            ),
          ],

          // Actions
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: onHeart,
                child: Row(
                  children: [
                    Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: liked ? AppColors.coral400 : context.colTextHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.hearts}',
                      style: TextStyle(fontSize: 12, color: context.colTextSec),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.flag_outlined, size: 16, color: context.colTextHint),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── New post bottom sheet ────────────────────────────────────────────────────

class _NewPostSheet extends ConsumerStatefulWidget {
  const _NewPostSheet({required this.scaffoldMessenger});
  final ScaffoldMessengerState scaffoldMessenger;

  @override
  ConsumerState<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends ConsumerState<_NewPostSheet> {
  final _ctrl = TextEditingController();
  String _type = 'story';
  bool _posting = false;
  XFile? _pickedImage;

  static const _types = [
    ('win',      '🌟 Win',          'Celebrate a milestone or progress'),
    ('story',    '📖 Story',        'Share your experience'),
    ('question', '❓ Question',     'Ask the community'),
    ('support',  '🤝 Need Support', 'Ask for encouragement'),
    ('expert',   '🎓 Expert',       'Evidence-based tips & professional perspective'),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<String?> _uploadLocalImage(String path) async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return null;
    final storage = ref.read(storageProvider);
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final refFile = storage.ref().child('community_posts').child(uid).child(name);
    await refFile.putFile(File(path));
    return refFile.getDownloadURL();
  }

  Future<void> _submit() async {
    if (_posting || _ctrl.text.trim().isEmpty) return;
    setState(() => _posting = true);
    try {
      String? imageUrl;
      final path = _pickedImage?.path;
      if (path != null && path.isNotEmpty) {
        imageUrl = await _uploadLocalImage(path);
      }
      await ref.read(communityNotifierProvider.notifier).createPost(
            content: _ctrl.text,
            type: _type,
            imageUrl: imageUrl,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Shared anonymously with the community.'),
        backgroundColor: AppColors.teal600,
      ));
    } catch (e) {
      if (mounted) {
        widget.scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Could not post: $e'),
            backgroundColor: AppColors.coral600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Share with Community',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 13, color: AppColors.teal600),
              const SizedBox(width: 4),
              Text(
                'Posted anonymously — your real name is never shown.',
                style: TextStyle(fontSize: 12, color: context.colTextSec),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Type selector
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _types.map((t) {
              final selected = _type == t.$1;
              return GestureDetector(
                onTap: () => setState(() => _type = t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.teal50
                        : context.colTint(AppColors.slate50, AppColors.slate50Dk),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.teal400 : context.colBorder,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    t.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.teal600 : context.colTextSec,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            _types.firstWhere((t) => t.$1 == _type).$3,
            style: TextStyle(fontSize: 11, color: context.colTextHint),
          ),
          const SizedBox(height: 12),

          // Text input
          TextField(
            controller: _ctrl,
            maxLines: 5,
            maxLength: 600,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              fillColor: context.colTint(AppColors.slate50, AppColors.slate50Dk),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _posting
                ? null
                : () async {
                    final file = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1600,
                      imageQuality: 88,
                    );
                    if (file != null) setState(() => _pickedImage = file);
                  },
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: Text(
              _pickedImage == null
                  ? 'Add image (optional)'
                  : 'Image attached — tap to change',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),

          // Post button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _posting || _ctrl.text.trim().isEmpty ? null : _submit,
              child: _posting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white,
                      ),
                    )
                  : const Text('Post Anonymously'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final (emoji, label) = switch (type) {
      'win'      => ('🌟', 'wins'),
      'story'    => ('📖', 'stories'),
      'question' => ('❓', 'questions'),
      'support'  => ('🤝', 'support posts'),
      'expert'   => ('🎓', 'expert posts'),
      _          => ('💬', 'posts'),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No $label yet.',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share. Your words might be\nexactly what someone needs today.',
              style: TextStyle(color: context.colTextSec, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

