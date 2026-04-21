import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/craving_content.dart';

class CravingShieldScreen extends StatefulWidget {
  const CravingShieldScreen({super.key, required this.addictionKey});
  final String addictionKey;

  @override
  State<CravingShieldScreen> createState() => _CravingShieldScreenState();
}

class _CravingShieldScreenState extends State<CravingShieldScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final AddictionContent _content;

  @override
  void initState() {
    super.initState();
    _content = contentFor(widget.addictionKey);
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1120),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1120),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Text(_content.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Craving Shield',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.teal400,
          labelColor: AppColors.teal400,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.play_circle_outline, size: 20), text: 'Videos'),
            Tab(icon: Icon(Icons.menu_book_outlined, size: 20), text: 'Stories'),
            Tab(icon: Icon(Icons.music_note_outlined, size: 20), text: 'Sounds'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _VideosTab(videos: _content.videos),
          _StoriesTab(stories: _content.stories),
          _SoundsTab(sounds: _content.sounds),
        ],
      ),
    );
  }
}

// ─── Videos Tab ───────────────────────────────────────────────────────────────

class _VideosTab extends StatelessWidget {
  const _VideosTab({required this.videos});
  final List<CravingVideo> videos;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '📺 These videos show the real consequences of addiction. Watching before acting on a craving is one of the most effective tools in relapse prevention.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        ...videos.map((v) => _VideoCard(video: v)),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});
  final CravingVideo video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _YoutubeSearchPage(
            title: video.title,
            url: video.youtubeSearchUrl,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.teal900,
                borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
              ),
              child: const Icon(Icons.play_circle_filled_rounded, color: AppColors.teal400, size: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _YoutubeSearchPage extends StatefulWidget {
  const _YoutubeSearchPage({required this.title, required this.url});
  final String title, url;

  @override
  State<_YoutubeSearchPage> createState() => _YoutubeSearchPageState();
}

class _YoutubeSearchPageState extends State<_YoutubeSearchPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1120),
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 14)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.teal400)),
        ],
      ),
    );
  }
}

// ─── Stories Tab ──────────────────────────────────────────────────────────────

class _StoriesTab extends StatelessWidget {
  const _StoriesTab({required this.stories});
  final List<CravingStory> stories;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '📖 Facts and real stories about the consequences. Reading these during a craving interrupts the urge cycle and reconnects you with your "why".',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        ...stories.map((s) => _StoryCard(story: s)),
      ],
    );
  }
}

class _StoryCard extends StatefulWidget {
  const _StoryCard({required this.story});
  final CravingStory story;

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.story.color);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.story.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.story.headline,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),

            // Body
            if (_expanded)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.body,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.story.source,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Sounds Tab ───────────────────────────────────────────────────────────────

class _SoundsTab extends StatefulWidget {
  const _SoundsTab({required this.sounds});
  final List<CravingSound> sounds;

  @override
  State<_SoundsTab> createState() => _SoundsTabState();
}

class _SoundsTabState extends State<_SoundsTab> {
  final AudioPlayer _player = AudioPlayer();
  int? _playing;
  bool _loading = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(int index, String url) async {
    if (_loading) return;
    if (_playing == index) {
      await _player.pause();
      setState(() => _playing = null);
      return;
    }
    setState(() { _loading = true; _playing = null; });
    try {
      await _player.stop();
      await _player.setLoopMode(LoopMode.one);
      await _player.setUrl(url);
      await _player.play();
      setState(() { _playing = index; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '🎵 These sounds activate the parasympathetic nervous system, reducing craving intensity. Play one and breathe slowly for 2–5 minutes.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.sounds.asMap().entries.map(
          (e) => _SoundCard(
            index: e.key,
            sound: e.value,
            isPlaying: _playing == e.key,
            isLoading: _loading && _playing == null,
            onTap: () => _toggleSound(e.key, e.value.audioUrl),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Use headphones for the best effect',
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({
    required this.index,
    required this.sound,
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });
  final int index;
  final CravingSound sound;
  final bool isPlaying, isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.teal400.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying ? AppColors.teal400 : Colors.white.withValues(alpha: 0.08),
            width: isPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(sound.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound.name,
                    style: TextStyle(
                      color: isPlaying ? AppColors.teal400 : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sound.why,
                    style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isPlaying
                    ? AppColors.teal400
                    : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
