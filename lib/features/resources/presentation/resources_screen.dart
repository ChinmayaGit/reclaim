import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/constants/app_constants.dart';
import '../data/resource_model.dart';
import '../data/resources_data.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _selectedCategory = 'all';

  static const _categories = [
    ('all', 'All'),
    ('addiction', 'Addiction'),
    ('breakup', 'Heartbreak'),
    ('trauma', 'Trauma'),
    ('stress', 'Stress'),
  ];

  static const _tabs = [
    ('article', 'Articles', Icons.article_outlined),
    ('audio', 'Guided', Icons.headphones_outlined),
    ('video', 'Videos', Icons.play_circle_outline),
    ('worksheet', 'Worksheets', Icons.edit_note_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: context.colBackground,
      appBar: AppBar(
        backgroundColor: context.colSurface,
        title: const Text('Resource Library'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((t) => Tab(
                    child: Row(
                      children: [
                        Icon(t.$3, size: 16),
                        const SizedBox(width: 6),
                        Text(t.$2),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: Column(
        children: [
          // ── Category filter ───────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.teal400 : context.colSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.teal400 : context.colBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat.$2,
                        style: TextStyle(
                          color: isSelected ? Colors.white : context.colTextSec,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Ambient sounds banner ─────────────────────────────────────
          GestureDetector(
            onTap: () => context.push(AppConstants.routeAmbient),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.teal600.withValues(alpha: 0.15),
                    AppColors.purple600.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppColors.teal400.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🎵', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ambient Sounds — CC0 rain, ocean, forest & more',
                      style: TextStyle(
                          fontSize: 13,
                          color: context.colText,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 18, color: context.colTextSec),
                ],
              ),
            ),
          ),

          // ── Tab content ───────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _tabs
                  .map((t) => _ResourceList(
                        type: t.$1,
                        category: _selectedCategory,
                        isPremium: isPremium,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResourceList extends StatelessWidget {
  const _ResourceList({
    required this.type,
    required this.category,
    required this.isPremium,
  });

  final String type;
  final String category;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final items = ResourcesData.byType(type, category: category);

    if (items.isEmpty) {
      return _EmptyState(type: type, category: category);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = items[i];
        final locked = item.isPremium && !isPremium;
        return _ResourceCard(
          resource: item,
          locked: locked,
          onTap: locked
              ? () => _showUpgradePrompt(context)
              : () => _openResource(context, item),
        );
      },
    );
  }

  void _openResource(BuildContext context, ResourceItem item) {
    context.push(AppConstants.routeResourceDetail, extra: item);
  }

  void _showUpgradePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('🔒', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Premium Content'),
          ],
        ),
        content: const Text(
          'Upgrade to Premium to unlock all guided exercises, in-depth articles, '
          'and worksheets that support deeper recovery work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Premium upgrade coming soon — contact support.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal600),
            child: const Text('Upgrade', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.locked,
    required this.onTap,
  });

  final ResourceItem resource;
  final bool locked;
  final VoidCallback onTap;

  IconData get _typeIcon => switch (resource.type) {
        'article' => Icons.article_outlined,
        'audio' => Icons.headphones_outlined,
        'video' => Icons.play_circle_outline,
        'worksheet' => Icons.edit_note_outlined,
        _ => Icons.description_outlined,
      };

  Color get _accentColor => switch (resource.type) {
        'article' => AppColors.teal600,
        'audio' => AppColors.purple600,
        'video' => AppColors.coral600,
        'worksheet' => AppColors.amber600,
        _ => AppColors.teal600,
      };

  Color _accentBg(BuildContext context) => switch (resource.type) {
        'article' => context.colTint(AppColors.teal50, AppColors.teal50Dk),
        'audio' => context.colTint(AppColors.purple50, AppColors.purple50Dk),
        'video' => context.colTint(AppColors.coral50, AppColors.coral50Dk),
        'worksheet' => context.colTint(AppColors.amber50, AppColors.amber50Dk),
        _ => context.colTint(AppColors.teal50, AppColors.teal50Dk),
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: locked
                    ? context.colTint(AppColors.slate100, AppColors.slate100Dk)
                    : _accentBg(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  resource.emoji,
                  style: TextStyle(
                    fontSize: 26,
                    color: locked ? null : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          resource.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color:
                                locked ? context.colTextHint : context.colText,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      if (locked)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.lock_outline,
                              size: 15, color: AppColors.amber600),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: locked ? context.colTextHint : context.colTextSec,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: locked
                              ? context.colTint(
                                  AppColors.amber50, AppColors.amber50Dk)
                              : _accentBg(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              locked ? Icons.lock_outline : _typeIcon,
                              size: 10,
                              color: locked ? AppColors.amber600 : _accentColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              locked ? 'Premium' : resource.duration,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color:
                                    locked ? AppColors.amber600 : _accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Category badges
                      ...resource.categories.take(2).map((cat) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colTint(
                                  AppColors.slate100, AppColors.slate100Dk),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 9,
                                color: context.colTextSec,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            if (!locked)
              Icon(Icons.chevron_right, color: context.colTextHint, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type, required this.category});
  final String type;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No $type resources for "$category"',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting "All" or a different category.',
              style: TextStyle(color: context.colTextSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
