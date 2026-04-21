import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../data/ambient_tracks.dart';
import '../data/ambient_download_manager.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen ambient sound player.
///
/// Tracks are downloaded to local storage on first visit for offline playback.
/// Audio plays from local files via just_audio — looped continuously.
class AmbientPlayerScreen extends StatefulWidget {
  const AmbientPlayerScreen({super.key, this.initialTrackId});

  /// If provided, starts on this track ID (from [AmbientTracks.all]).
  final String? initialTrackId;

  @override
  State<AmbientPlayerScreen> createState() => _AmbientPlayerScreenState();
}

class _AmbientPlayerScreenState extends State<AmbientPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final AnimationController _pulseCtrl;

  AmbientTrack? _current;
  bool _loading = false;
  bool _audioReady = false;
  String? _error;
  String _activeCategory = 'nature';

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _player = AudioPlayer();

    _player.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });

    _init();
  }

  Future<void> _init() async {
    await _initSession();

    final downloaded = await AmbientDownloadManager.areTracksDownloaded();
    if (!downloaded && mounted) {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _DownloadDialog(),
      );
    }

    if (!mounted) return;
    final initial = widget.initialTrackId != null
        ? AmbientTracks.all.firstWhere(
            (t) => t.id == widget.initialTrackId,
            orElse: () => AmbientTracks.all.first)
        : AmbientTracks.all.first;
    _loadTrack(initial);
  }

  Future<void> _initSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType:
          AndroidAudioFocusGainType.gainTransientMayDuck,
    ));
  }

  Future<void> _loadTrack(AmbientTrack track) async {
    if (_current?.id == track.id && _error == null) {
      _togglePlayPause();
      return;
    }
    final wasPlaying = _player.playing;
    await _player.stop();

    setState(() {
      _current = track;
      _loading = true;
      _audioReady = false;
      _error = null;
      _activeCategory = track.category;
    });

    if (!track.isAvailable) {
      setState(() {
        _loading = false;
        _error =
            'Track not uploaded yet.\nSee ambient_tracks.dart for setup instructions.';
      });
      return;
    }

    try {
      await _player.setLoopMode(LoopMode.one);
      final localPath = await AmbientDownloadManager.getLocalPath(track);
      if (localPath != null) {
        await _player.setFilePath(localPath);
      } else {
        await _player.setUrl(track.storageUrl);
      }
      setState(() {
        _loading = false;
        _audioReady = true;
      });
      if (wasPlaying) await _player.play();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Could not load track.\n$e';
      });
    }
  }

  void _togglePlayPause() {
    if (_error != null && _current != null) {
      _retryCurrentTrack();
      return;
    }
    if (!_audioReady) return;
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  Future<void> _retryCurrentTrack() async {
    final track = _current!;
    setState(() {
      _current = null;
    });
    await _loadTrack(track);
    if (_audioReady) await _player.play();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  // ─── Colors per category ──────────────────────────────────────────────────

  Color get _primaryColor => switch (_activeCategory) {
        'focus' => AppColors.blue400,
        'meditation' => AppColors.purple400,
        'sleep' => const Color(0xFF5B7FA6),
        _ => AppColors.teal400,
      };

  Color get _primaryDark => switch (_activeCategory) {
        'focus' => AppColors.blue600,
        'meditation' => AppColors.purple600,
        'sleep' => const Color(0xFF2C4A6A),
        _ => AppColors.teal600,
      };

  Color get _bgColor => switch (_activeCategory) {
        'focus' => const Color(0xFF0A1520),
        'meditation' => const Color(0xFF100D1E),
        'sleep' => const Color(0xFF080E18),
        _ => const Color(0xFF0A1A12),
      };

  // ─── Build ────────────────────────────────────────────────────────────────

  // ─── Mini player bottom bar ───────────────────────────────────────────────

  Widget _buildMiniPlayerBar(bool isPlaying) {
    if (_current == null) return const SizedBox.shrink();
    return SafeArea(
      child: Container(
        color: _primaryDark.withValues(alpha: 0.9),
        padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
        child: Row(
          children: [
            Text(_current!.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _current!.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _loading
                        ? 'Loading…'
                        : isPlaying
                            ? '∞  Looping'
                            : _error != null
                                ? 'Error — tap ▶ to retry'
                                : 'Paused',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
            // Play / Pause
            GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_audioReady && _error == null)
                      ? _primaryColor
                      : Colors.white12,
                ),
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // Stop
            GestureDetector(
              onTap: () async {
                await _player.stop();
                setState(() {});
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white10,
                ),
                child: const Icon(Icons.stop_rounded,
                    color: Colors.white54, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isPlaying = _player.playing;

    return Scaffold(
      backgroundColor: _bgColor,
      bottomNavigationBar: _buildMiniPlayerBar(isPlaying),
      appBar: AppBar(
        backgroundColor: _bgColor,
        foregroundColor: Colors.white70,
        elevation: 0,
        title:
            const Text('Ambient Sounds', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Text(
                'CC0 · Public Domain',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Animated player ─────────────────────────────────────────────
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                // Breathing pulse rings
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) {
                    final pulse = isPlaying ? _pulseCtrl.value : 0.0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 220 + 20 * pulse,
                          height: 220 + 20 * pulse,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primaryColor
                                .withValues(alpha: 0.06 * (isPlaying ? 1 : 0)),
                          ),
                        ),
                        // Mid ring
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 180 + 14 * pulse,
                          height: 180 + 14 * pulse,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primaryColor
                                .withValues(alpha: 0.10 * (isPlaying ? 1 : 0)),
                          ),
                        ),
                        // Core
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          width: 144,
                          height: 144,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _primaryColor
                                    .withValues(alpha: isPlaying ? 0.9 : 0.35),
                                _primaryDark
                                    .withValues(alpha: isPlaying ? 0.7 : 0.25),
                              ],
                            ),
                          ),
                          child: Center(
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5)
                                : Text(
                                    _current?.emoji ?? '🎵',
                                    style: const TextStyle(fontSize: 50),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _current?.name ?? 'Select a track',
                    key: ValueKey(_current?.id),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _current?.description ?? '',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                  textAlign: TextAlign.center,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.amber400, fontSize: 12),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Play / Pause
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (_audioReady && _error == null)
                          ? _primaryColor
                          : Colors.white12,
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _loading
                      ? 'Loading…'
                      : isPlaying
                          ? '∞ Looping'
                          : 'Tap to play',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                ),
              ],
            ),
          ),
        ),

          // ── Category chips ───────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: AmbientTracks.categories.map((cat) {
                final selected = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? _primaryColor.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? _primaryColor.withValues(alpha: 0.6)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '${AmbientTracks.categoryEmojis[cat]} ${cat[0].toUpperCase()}${cat.substring(1)}',
                        style: TextStyle(
                          color: selected ? _primaryColor : Colors.white54,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // ── Track list ───────────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
              itemCount:
                  AmbientTracks.byCategory(_activeCategory).length,
              itemBuilder: (_, i) {
                final track =
                    AmbientTracks.byCategory(_activeCategory)[i];
                final isSelected = _current?.id == track.id;
                return GestureDetector(
                  onTap: () => _loadTrack(track),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _primaryColor.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _primaryColor.withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(track.emoji,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.name,
                                style: TextStyle(
                                  color: isSelected
                                      ? _primaryColor
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                track.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.38),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!track.isAvailable)
                          Text(
                            'Setup needed',
                            style: TextStyle(
                                fontSize: 10,
                                color:
                                    Colors.white.withValues(alpha: 0.3)),
                          )
                        else if (isSelected && isPlaying)
                          Icon(Icons.volume_up_rounded,
                              color: _primaryColor, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── License footer ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '🔓 CC0 Public Domain · Wikimedia Commons & Internet Archive',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.2), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ONE-TIME DOWNLOAD DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog();

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  bool _downloading = false;
  bool _done = false;
  int _completed = 0;
  int _total = 0;
  List<String> _failed = [];

  int get _totalTracks =>
      AmbientTracks.all.where((t) => t.isAvailable).length;

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _done = false;
      _failed = [];
      _total = _totalTracks;
    });
    final failed = await AmbientDownloadManager.downloadAll(
      onProgress: (completed, total, failedNames) {
        if (mounted) {
          setState(() {
            _completed = completed;
            _total = total;
            _failed = failedNames;
          });
        }
      },
    );
    if (!mounted) return;
    setState(() {
      _downloading = false;
      _done = true;
      _failed = failed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF152019),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            _done && _failed.isEmpty
                ? Icons.check_circle_rounded
                : Icons.download_rounded,
            color: _done && _failed.isEmpty
                ? AppColors.green400
                : AppColors.teal400,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _done ? 'Download Complete' : 'Download Sounds',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_downloading && !_done)
            Text(
              'Download all $_totalTracks ambient tracks for offline playback. '
              'This is a one-time download.',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          if (_downloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _total > 0 ? _completed / _total : 0,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.teal400),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_completed of $_total tracks…',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          if (_done && _failed.isEmpty)
            const Text(
              'All tracks ready for offline playback!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          if (_done && _failed.isNotEmpty) ...[
            Text(
              '${_total - _failed.length} of $_total tracks downloaded. '
              '${_failed.length} failed:',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...(_failed.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '  · $name',
                    style: const TextStyle(
                        color: AppColors.amber400, fontSize: 12),
                  ),
                ))),
            const SizedBox(height: 8),
            const Text(
              'Failed tracks will stream when played.',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        if (!_downloading)
          TextButton(
            onPressed: () => Navigator.pop(context, _done),
            child: Text(
              _done ? 'Done' : 'Skip',
              style: TextStyle(
                color: _done ? AppColors.teal400 : Colors.white38,
              ),
            ),
          ),
        if (!_downloading && !_done)
          ElevatedButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal400,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        if (_done && _failed.isNotEmpty)
          ElevatedButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry Failed'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal400,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
      ],
    );
  }
}
