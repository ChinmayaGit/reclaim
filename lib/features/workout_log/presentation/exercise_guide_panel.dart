import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../data/exercise_db_client.dart';
import '../data/exercise_db_models.dart';
import '../data/exercise_db_providers.dart';
import '../data/exercise_guide_catalog.dart';
import '../domain/workout_notifier.dart';

/// Exercise reference gallery + favorites, shown below “Add exercise”.
/// Uses [ExerciseDB](https://github.com/ExerciseDB/exercisedb-api) via RapidAPI (10 exercises per page) when a key is saved below.
class ExerciseGuidePanel extends ConsumerStatefulWidget {
  const ExerciseGuidePanel({super.key});

  @override
  ConsumerState<ExerciseGuidePanel> createState() => _ExerciseGuidePanelState();
}

class _ExerciseGuidePanelState extends ConsumerState<ExerciseGuidePanel> {
  String _categoryId = 'all';
  final List<ExerciseDbExercise> _apiItems = [];
  int _offset = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reloadApiFirstPage());
  }

  Map<String, String>? _gifHeaders() {
    final k = ref.read(rapidApiKeyNotifierProvider).valueOrNull?.trim() ?? '';
    if (k.isEmpty) return null;
    return {
      'X-RapidAPI-Key': k,
      'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
    };
  }

  Future<void> _reloadApiFirstPage() async {
    final client = ref.read(exerciseDbClientProvider);
    if (client == null) {
      setState(() {
        _apiItems.clear();
        _offset = 0;
        _hasMore = false;
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _apiItems.clear();
      _offset = 0;
      _hasMore = true;
    });
    try {
      final part = exerciseDbBodyPartForCategory(_categoryId);
      final page = part == null
          ? await client.fetchExercises(offset: 0, limit: 10)
          : await client.fetchByBodyPart(part, offset: 0, limit: 10);
      if (!mounted) return;
      setState(() {
        _apiItems.addAll(page);
        _offset = page.length;
        _hasMore = page.length >= 10;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = exerciseDbErrorUserMessage(e);
        _loading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMoreApi() async {
    final client = ref.read(exerciseDbClientProvider);
    if (client == null || !_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final part = exerciseDbBodyPartForCategory(_categoryId);
      final page = part == null
          ? await client.fetchExercises(offset: _offset, limit: 10)
          : await client.fetchByBodyPart(part, offset: _offset, limit: 10);
      if (!mounted) return;
      setState(() {
        _apiItems.addAll(page);
        _offset += page.length;
        _hasMore = page.length >= 10;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = exerciseDbErrorUserMessage(e);
        _loadingMore = false;
      });
    }
  }

  void _onCategoryChanged(String id) {
    setState(() => _categoryId = id);
    _reloadApiFirstPage();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rapidApiKeyNotifierProvider, (prev, next) {
      final prevK = prev?.valueOrNull?.trim() ?? '';
      final nextK = next.valueOrNull?.trim() ?? '';
      if (prevK != nextK) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _reloadApiFirstPage();
        });
      }
    });

    final favorites = ref.watch(workoutLogProvider).guideFavoriteIds;
    final apiFavs = ref.watch(workoutLogProvider).apiGuideFavorites;
    final notifier = ref.read(workoutLogProvider.notifier);
    final hasKey = ref.watch(exerciseDbClientProvider) != null;

    final filteredCatalog = guideEntriesForCategory(_categoryId);
    final favCatalog = favorites
        .map(guideEntryById)
        .whereType<ExerciseGuideEntry>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise guide',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colText,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          hasKey
              ? 'ExerciseDB via RapidAPI — 10 exercises per page with GIF previews. '
                  'You can change your key below anytime.'
              : 'Save a RapidAPI key below to load ExerciseDB exercises. Until then, offline samples show for each category.',
          style: TextStyle(fontSize: 12, height: 1.35, color: context.colTextSec),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: kExerciseGuideCategories.map((c) {
              final sel = _categoryId == c.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(c.$2),
                  selected: sel,
                  onSelected: (_) => _onCategoryChanged(c.$1),
                  selectedColor: AppColors.teal400.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.teal600,
                ),
              );
            }).toList(),
          ),
        ),
        if (favCatalog.isNotEmpty || apiFavs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.amber600, size: 18),
              const SizedBox(width: 6),
              Text(
                'Favorites',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: context.colText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favCatalog.length + apiFavs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                if (i < favCatalog.length) {
                  final e = favCatalog[i];
                  return SizedBox(
                    width: 118,
                    child: _GuideCard(
                      entry: e,
                      isFavorite: true,
                      onToggleFavorite: () => notifier.toggleGuideFavorite(e.id),
                      onAdd: () => notifier.addExercise(
                        e.name,
                        muscleGroup: categoryLabel(e.categoryId).toUpperCase(),
                      ),
                    ),
                  );
                }
                final f = apiFavs[i - favCatalog.length];
                return SizedBox(
                  width: 118,
                  child: _ApiExerciseCard(
                    exercise: ExerciseDbExercise(
                      id: f.id,
                      name: f.name,
                      bodyPart: f.bodyPart,
                      target: '',
                      equipment: '',
                    ),
                    imageHeaders: _gifHeaders(),
                    isFavorite: true,
                    onToggleFavorite: () => notifier.toggleApiGuideFavorite(f),
                    onAdd: () => notifier.addExercise(
                      f.name,
                      muscleGroup: f.bodyPart.toUpperCase(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (hasKey) ...[
          Text(
            _categoryId == 'all'
                ? 'ExerciseDB (all body parts)'
                : '${categoryLabel(_categoryId)} — API',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: context.colTextSec,
            ),
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 12, color: AppColors.coral600, height: 1.45),
                  ),
                  if (_error!.contains('403') || _error!.contains('not subscribed'))
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final u = Uri.parse(_kExerciseDbRapidApiUrl);
                          await launchUrl(u, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.subscriptions_outlined, size: 18),
                        label: const Text('Subscribe on RapidAPI (free or paid)'),
                      ),
                    ),
                ],
              ),
            )
          else if (_apiItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No exercises in this category.',
                style: TextStyle(fontSize: 13, color: context.colTextSec),
              ),
            )
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              itemCount: _apiItems.length,
              itemBuilder: (_, i) {
                final ex = _apiItems[i];
                final isFav = apiFavs.any((f) => f.id == ex.id);
                return _ApiExerciseCard(
                  exercise: ex,
                  imageHeaders: _gifHeaders(),
                  isFavorite: isFav,
                  onToggleFavorite: () => notifier.toggleApiGuideFavorite(
                    ApiGuideFavorite(
                      id: ex.id,
                      name: ex.name,
                      bodyPart: ex.bodyPart,
                    ),
                  ),
                  onAdd: () => notifier.addExercise(
                    ex.name,
                    muscleGroup: ex.bodyPart.toUpperCase(),
                  ),
                );
              },
            ),
            if (_hasMore) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loadingMore ? null : _loadMoreApi,
                  child: _loadingMore
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load more (10)'),
                ),
              ),
            ],
          ],
        ],
        if (!hasKey) ...[
          const SizedBox(height: 8),
          Text(
            'Offline samples',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: context.colTextSec,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: filteredCatalog.length,
            itemBuilder: (_, i) {
              final e = filteredCatalog[i];
              final isFav = favorites.contains(e.id);
              return _GuideCard(
                entry: e,
                isFavorite: isFav,
                onToggleFavorite: () => notifier.toggleGuideFavorite(e.id),
                onAdd: () => notifier.addExercise(
                  e.name,
                  muscleGroup: categoryLabel(e.categoryId).toUpperCase(),
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 16),
        const _ExerciseDbRapidApiSubscribeCard(),
        const SizedBox(height: 20),
        _ExerciseDbApiKeyBar(onSaved: _reloadApiFirstPage),
      ],
    );
  }
}

/// RapidAPI subscribe page for ExerciseDB ([listing](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb)).
const _kExerciseDbRapidApiUrl =
    'https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb';

/// Shown below the exercise grids: explains free vs paid subscription on RapidAPI (fixes HTTP 403).
class _ExerciseDbRapidApiSubscribeCard extends StatelessWidget {
  const _ExerciseDbRapidApiSubscribeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.amber50, AppColors.amber50Dk),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amber400.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: AppColors.amber600, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'RapidAPI: subscribe to ExerciseDB',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: context.colText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'If you see HTTP 403 (“not subscribed”), your Application Key is fine — '
            'RapidAPI is blocking calls until you subscribe to this API on their site.\n\n'
            '• Free Basic plan: subscribe at no cost; this app requests up to 10 exercises per call (Basic limit).\n'
            '• Paid plans (Pro / Ultra / Mega): higher limits per ExerciseDB docs if you need more than 10 per request.',
            style: TextStyle(fontSize: 12, height: 1.45, color: context.colTextSec),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () async {
                final u = Uri.parse(_kExerciseDbRapidApiUrl);
                if (!await launchUrl(u, mode: LaunchMode.externalApplication)) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open browser')),
                  );
                }
              },
              child: const Text('Open ExerciseDB on RapidAPI — choose plan & Subscribe'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDbApiKeyBar extends ConsumerStatefulWidget {
  const _ExerciseDbApiKeyBar({required this.onSaved});

  final VoidCallback onSaved;

  @override
  ConsumerState<_ExerciseDbApiKeyBar> createState() => _ExerciseDbApiKeyBarState();
}

class _ExerciseDbApiKeyBarState extends ConsumerState<_ExerciseDbApiKeyBar> {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final repo = ref.read(exerciseApiKeyRepositoryProvider);
      final k = await repo.load();
      if (!mounted) return;
      if (k != null && k.isNotEmpty) _ctrl.text = k;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openRapidApi() async {
    final uri = Uri.parse(_kExerciseDbRapidApiUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open browser')),
      );
    }
  }

  Future<void> _saveAndFetch() async {
    final key = _ctrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste your RapidAPI key first')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(rapidApiKeyNotifierProvider.notifier).setKey(key);
      if (!mounted) return;
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Key saved — loading exercises'),
          backgroundColor: AppColors.teal600,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearKey() async {
    setState(() => _busy = true);
    try {
      await ref.read(rapidApiKeyNotifierProvider.notifier).clear();
      _ctrl.clear();
      if (!mounted) return;
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key removed')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colTint(AppColors.teal50, AppColors.teal50Dk),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal400.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ExerciseDB API (RapidAPI)',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: context.colText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Subscribe on RapidAPI, copy your Application Key, then paste it here.',
            style: TextStyle(fontSize: 12, height: 1.35, color: context.colTextSec),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _busy ? null : _openRapidApi,
            child: Row(
              children: [
                Icon(Icons.open_in_new, size: 16, color: AppColors.teal600),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Open RapidAPI — ExerciseDB (subscribe & get key)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _busy ? null : _saveAndFetch(),
            decoration: InputDecoration(
              labelText: 'RapidAPI key',
              hintText: 'X-RapidAPI-Key value',
              filled: true,
              fillColor: context.colSurface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show key' : 'Hide key',
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _saveAndFetch,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save & fetch'),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _busy ? null : _clearKey,
                child: const Text('Remove key'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.entry,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAdd,
  });

  final ExerciseGuideEntry entry;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colSurface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: entry.mediaUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 400,
                  placeholder: (_, __) => Container(
                    color: context.colTint(AppColors.slate100, AppColors.slate100Dk),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: context.colTint(AppColors.slate100, AppColors.slate100Dk),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.fitness_center,
                      size: 36,
                      color: context.colTextHint,
                    ),
                  ),
                ),
                if (entry.isGif)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'GIF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Text(
              entry.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.colText,
                height: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Row(
              children: [
                IconButton(
                  tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    size: 20,
                    color: isFavorite ? AppColors.amber600 : context.colTextHint,
                  ),
                  onPressed: onToggleFavorite,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiExerciseCard extends StatelessWidget {
  const _ApiExerciseCard({
    required this.exercise,
    required this.imageHeaders,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAdd,
  });

  final ExerciseDbExercise exercise;
  final Map<String, String>? imageHeaders;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final url = ExerciseDbClient.gifImageUrl(exercise.id);
    return Material(
      color: context.colSurface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageHeaders != null)
                  CachedNetworkImage(
                    imageUrl: url,
                    httpHeaders: imageHeaders,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    placeholder: (_, __) => Container(
                      color:
                          context.colTint(AppColors.slate100, AppColors.slate100Dk),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color:
                          context.colTint(AppColors.slate100, AppColors.slate100Dk),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.fitness_center,
                        size: 36,
                        color: context.colTextHint,
                      ),
                    ),
                  )
                else
                  Container(
                    color: context.colTint(AppColors.slate100, AppColors.slate100Dk),
                    alignment: Alignment.center,
                    child: Icon(Icons.lock_outline, color: context.colTextHint),
                  ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'GIF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
            child: Text(
              exercise.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: context.colText,
                height: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Text(
              exercise.bodyPart,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: context.colTextSec),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Row(
              children: [
                IconButton(
                  tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    size: 20,
                    color: isFavorite ? AppColors.amber600 : context.colTextHint,
                  ),
                  onPressed: onToggleFavorite,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
