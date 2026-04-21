import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../data/ambient_download_manager.dart';
import '../data/resource_model.dart';
import 'video_embed_screen.dart';

// Background sound choices for guided exercises
class _SoundOption {
  const _SoundOption(this.emoji, this.name, this.url);
  final String emoji;
  final String name;
  final String url;
}

const _kSoundOptions = [
  _SoundOption('🔇', 'None', ''),
  _SoundOption('🌧️', 'Rain',
      'https://archive.org/download/naturesounds-soundtheraphy/Light%20Gentle%20Rain.mp3'),
  _SoundOption('🌊', 'Ocean',
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1f/Waves.ogg/Waves.ogg.mp3'),
  _SoundOption('🌲', 'Forest',
      'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/42/Bird_singing.ogg/Bird_singing.ogg.mp3'),
  _SoundOption('🔔', 'Bowls',
      'https://archive.org/download/singingbowlmeditation/Singing%20Bowl%20Meditation.mp3'),
];

class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({super.key, required this.resource});
  final ResourceItem resource;

  @override
  Widget build(BuildContext context) {
    return switch (resource.type) {
      'article'   => _ArticleScreen(resource: resource),
      'audio'     => _AudioGuideScreen(resource: resource),
      'worksheet' => _WorksheetScreen(resource: resource),
      'video'     => _VideoScreen(resource: resource),
      _           => _ArticleScreen(resource: resource),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ARTICLE READER
// ─────────────────────────────────────────────────────────────────────────────

class _ArticleScreen extends StatelessWidget {
  const _ArticleScreen({required this.resource});
  final ResourceItem resource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(resource.duration),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.teal50, AppColors.teal100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.teal200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    resource.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.teal900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    resource.description,
                    style: const TextStyle(color: AppColors.teal600, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Article sections
            ...resource.sections.map((s) => _buildSection(context, s)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, ContentSection s) {
    switch (s.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            s.content,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.teal900,
            ),
          ),
        );
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            s.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: AppColors.textPrimary,
            ),
          ),
        );
      case 'bullet':
        return Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 6, color: AppColors.teal600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.content,
                  style: const TextStyle(fontSize: 15, height: 1.55, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        );
      case 'tip':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.amber50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.amber100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.amber600, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  s.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.amber900,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'quote':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.purple50,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: AppColors.purple400, width: 4)),
          ),
          child: Text(
            s.content,
            style: const TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: AppColors.purple900,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUDIO / GUIDED EXERCISE
// ─────────────────────────────────────────────────────────────────────────────

class _AudioGuideScreen extends StatefulWidget {
  const _AudioGuideScreen({required this.resource});
  final ResourceItem resource;

  @override
  State<_AudioGuideScreen> createState() => _AudioGuideScreenState();
}

class _AudioGuideScreenState extends State<_AudioGuideScreen> {
  int _stepIndex = 0;
  int _secondsLeft = 0;
  bool _running = false;
  bool _completed = false;
  Timer? _timer;

  // ── Background audio ──────────────────────────────────────────────────────
  late final AudioPlayer _bgPlayer;
  String _bgTrackUrl = '';

  List<GuideStep> get _steps => widget.resource.steps;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _steps.first.durationSeconds;
    _bgPlayer = AudioPlayer();
    _bgTrackUrl = _defaultTrack(widget.resource.id);
  }

  String _defaultTrack(String id) {
    if (id.contains('grounding')) return _kSoundOptions[3].url; // Forest
    if (id.contains('body_scan') || id.contains('urge')) {
      return _kSoundOptions[2].url; // Ocean
    }
    return _kSoundOptions[4].url; // Singing Bowls
  }

  Future<void> _startBgSound({int attempt = 1}) async {
    if (_bgTrackUrl.isEmpty) return;
    try {
      await _bgPlayer.setLoopMode(LoopMode.one);
      final localPath =
          await AmbientDownloadManager.getLocalPathForUrl(_bgTrackUrl);
      if (localPath != null) {
        await _bgPlayer.setFilePath(localPath);
      } else {
        await _bgPlayer.setUrl(_bgTrackUrl);
      }
      await _bgPlayer.play();
    } catch (_) {
      if (attempt < 3) {
        await Future.delayed(Duration(milliseconds: 500 * attempt));
        await _startBgSound(attempt: attempt + 1);
      }
    }
  }

  Future<void> _selectSound(String url) async {
    final wasRunning = _running;
    await _bgPlayer.stop();
    setState(() => _bgTrackUrl = url);
    if (wasRunning && url.isNotEmpty) await _startBgSound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bgPlayer.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _completed = false;
    });
    _tick();
    _startBgSound();
  }

  void _pause() {
    _timer?.cancel();
    _bgPlayer.pause();
    setState(() => _running = false);
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        _nextStep();
      }
    });
  }

  void _nextStep() {
    _timer?.cancel();
    if (_stepIndex < _steps.length - 1) {
      setState(() {
        _stepIndex++;
        _secondsLeft = _steps[_stepIndex].durationSeconds;
      });
      _tick();
    } else {
      _bgPlayer.pause();
      setState(() {
        _running = false;
        _completed = true;
      });
    }
  }

  void _prevStep() {
    _timer?.cancel();
    if (_stepIndex > 0) {
      setState(() {
        _stepIndex--;
        _secondsLeft = _steps[_stepIndex].durationSeconds;
        _running = false;
      });
    }
  }

  void _restart() {
    _timer?.cancel();
    _bgPlayer.stop();
    setState(() {
      _stepIndex = 0;
      _secondsLeft = _steps.first.durationSeconds;
      _running = false;
      _completed = false;
    });
  }

  double get _stepProgress {
    final total = _steps[_stepIndex].durationSeconds;
    return (total - _secondsLeft) / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: Text(widget.resource.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _completed ? _buildCompleted() : _buildPlayer(),
    );
  }

  Widget _buildPlayer() {
    return Column(
      children: [
        // Background sound picker
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Background Sound',
                style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.4),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _kSoundOptions.map((opt) {
                    final selected = _bgTrackUrl == opt.url;
                    return GestureDetector(
                      onTap: () => _selectSound(opt.url),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.teal400.withValues(alpha: 0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.teal400
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(opt.emoji,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              opt.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? AppColors.teal400
                                    : Colors.white60,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Progress bar across steps
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: List.generate(_steps.length, (i) {
              return Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i < _stepIndex
                        ? AppColors.teal400
                        : i == _stepIndex
                            ? AppColors.teal400.withValues(alpha: 0.6)
                            : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Step counter
                Text(
                  'Step ${_stepIndex + 1} of ${_steps.length}',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 32),

                // Circular timer
                SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: _running ? _stepProgress : 0,
                          strokeWidth: 8,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(AppColors.teal400),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _running ? '$_secondsLeft' : widget.resource.emoji,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _running ? 52 : 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_running)
                            const Text('sec', style: TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_stepIndex > 0)
                      IconButton(
                        onPressed: _prevStep,
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white60, size: 32),
                      ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _running ? _pause : (_completed ? _restart : _start),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppColors.teal400,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_stepIndex < _steps.length - 1)
                      IconButton(
                        onPressed: _nextStep,
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white60, size: 32),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleted() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            const Text(
              'Exercise Complete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Well done. Take a moment to notice how you feel right now.',
              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.replay),
              label: const Text('Do it again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Resources', style: TextStyle(color: Colors.white60)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WORKSHEET (interactive, saves to SharedPreferences)
// ─────────────────────────────────────────────────────────────────────────────

class _WorksheetScreen extends ConsumerStatefulWidget {
  const _WorksheetScreen({required this.resource});
  final ResourceItem resource;

  @override
  ConsumerState<_WorksheetScreen> createState() => _WorksheetScreenState();
}

class _WorksheetScreenState extends ConsumerState<_WorksheetScreen> {
  late final Map<String, TextEditingController> _controllers;
  bool _saving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.resource.fields)
        f.id: TextEditingController(),
    };
    _loadSaved();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _prefKey(String fieldId) =>
      'ws_${widget.resource.id}_$fieldId';

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    for (final f in widget.resource.fields) {
      final saved = prefs.getString(_prefKey(f.id));
      if (saved != null) {
        _controllers[f.id]?.text = saved;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    for (final f in widget.resource.fields) {
      await prefs.setString(_prefKey(f.id), _controllers[f.id]?.text ?? '');
    }
    await prefs.setString(
      'ws_${widget.resource.id}_savedAt',
      DateTime.now().toIso8601String(),
    );
    setState(() {
      _saving = false;
      _saved = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worksheet saved privately on this device.'),
          backgroundColor: AppColors.teal600,
        ),
      );
    }
  }

  Future<void> _clear() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear worksheet?'),
        content: const Text('This will delete all answers you\'ve entered.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    for (final f in widget.resource.fields) {
      await prefs.remove(_prefKey(f.id));
      _controllers[f.id]?.clear();
    }
    setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.resource.title, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Clear'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.amber50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.amber100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.resource.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 10),
                  Text(
                    widget.resource.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amber900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.resource.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.amber600),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 13, color: AppColors.amber600),
                      SizedBox(width: 4),
                      Text(
                        'Saved privately on this device only.',
                        style: TextStyle(fontSize: 12, color: AppColors.amber600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fields
            ...widget.resource.fields.map((f) => _buildField(f)),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved' : 'Save My Answers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _saved ? AppColors.green400 : AppColors.teal600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(WorksheetField f) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            f.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _controllers[f.id],
            maxLines: f.multiline ? 4 : 1,
            onChanged: (_) => setState(() => _saved = false),
            decoration: InputDecoration(
              hintText: f.hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.teal400, width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO RESOURCE — in-app YouTube embed (youtube-nocookie.com, ToS §5C)
// ─────────────────────────────────────────────────────────────────────────────

class _VideoScreen extends StatelessWidget {
  const _VideoScreen({required this.resource});
  final ResourceItem resource;

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // URL could not be launched — browser or YouTube app not available
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEmbed = resource.videoId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Video Resource'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / play card
            GestureDetector(
              onTap: hasEmbed
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoEmbedScreen(
                            videoId: resource.videoId!,
                            title: resource.title,
                            description: resource.videoDescription,
                          ),
                        ),
                      )
                  : null,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(resource.emoji, style: const TextStyle(fontSize: 56)),
                    if (hasEmbed)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xBBFF0000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 34),
                      ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          resource.duration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              resource.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              resource.description,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),

            if (resource.videoDescription != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  resource.videoDescription!,
                  style: const TextStyle(
                      fontSize: 14,
                      height: 1.65,
                      color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasEmbed
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoEmbedScreen(
                              videoId: resource.videoId!,
                              title: resource.title,
                              description: resource.videoDescription,
                            ),
                          ),
                        )
                    : (resource.videoUrl != null
                        ? () => _launchExternal(resource.videoUrl!)
                        : null),
                icon: const Icon(Icons.play_circle_outline),
                label: Text(hasEmbed ? 'Watch Video' : 'Watch on YouTube'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                hasEmbed
                    ? 'Plays in-app via official YouTube embed.'
                    : 'Opens YouTube in your browser.',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
