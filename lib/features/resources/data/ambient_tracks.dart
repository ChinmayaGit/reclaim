/// Royalty-free ambient sound catalog.
///
/// Sources:
///   • Wikimedia Commons (CC0 / Public Domain) — upload.wikimedia.org
///   • Internet Archive (CC0 1.0) — archive.org
///
/// All URLs verified via the Wikimedia Commons API (imageinfo) and
/// the Internet Archive file listings. No guessed paths.
/// ─────────────────────────────────────────────────────────────────────────────
class AmbientTrack {
  const AmbientTrack({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.category,
    required this.storageUrl,
    this.license = 'CC0 1.0 — Public Domain',
    this.source = 'commons.wikimedia.org',
  });

  final String id;
  final String name;
  final String emoji;
  final String description;

  /// 'nature' | 'focus' | 'sleep' | 'meditation'
  final String category;

  /// Direct OGG/MP3 URL — streamed via just_audio.
  final String storageUrl;

  final String license;
  final String source;

  bool get isAvailable => storageUrl.isNotEmpty;
}

class AmbientTracks {
  static const List<AmbientTrack> all = [
    // ── Nature ──────────────────────────────────────────────────────────────
    AmbientTrack(
      id: 'rain_gentle',
      name: 'Gentle Rain',
      emoji: '🌧️',
      description: 'Soft rainfall to ease anxiety and sharpen focus.',
      category: 'nature',
      storageUrl:
          'https://archive.org/download/naturesounds-soundtheraphy/Light%20Gentle%20Rain.mp3',
      source: 'archive.org',
    ),
    AmbientTrack(
      id: 'rain_heavy',
      name: 'Sea Storm',
      emoji: '⛈️',
      description: 'Stormy sea rain and wind for deep focus or sleep.',
      category: 'nature',
      storageUrl:
          'https://archive.org/download/naturesounds-soundtheraphy/Sound%20Therapy%20-%20Sea%20Storm.mp3',
      source: 'archive.org',
    ),
    AmbientTrack(
      id: 'ocean_waves',
      name: 'Ocean Waves',
      emoji: '🌊',
      description: 'Waterfall and Atlantic ocean waves for deep relaxation.',
      category: 'nature',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/3/3b/Bubbling_Waterfall_and_Ocean_Waves.ogg',
    ),
    AmbientTrack(
      id: 'forest_birds',
      name: 'Morning Birdsong',
      emoji: '🌲',
      description: 'Dawn birdsong to ground and energise.',
      category: 'nature',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/e/e7/Birdsong_morning_01.ogg',
    ),
    AmbientTrack(
      id: 'mountain_stream',
      name: 'Trickling Stream',
      emoji: '💧',
      description: 'Babbling brook with birdsong — grounding and calm.',
      category: 'nature',
      storageUrl:
          'https://archive.org/download/naturesounds-soundtheraphy/Relaxing%20Nature%20Sounds%20-%20Trickling%20Stream%20Sounds%20%26%20Birds.mp3',
      source: 'archive.org',
    ),

    // ── Focus ────────────────────────────────────────────────────────────────
    AmbientTrack(
      id: 'white_noise',
      name: 'White Noise',
      emoji: '🔊',
      description: 'Steady hiss to block distractions and boost focus.',
      category: 'focus',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/a/aa/White_noise.ogg',
    ),
    AmbientTrack(
      id: 'brown_noise',
      name: 'Forest Wind',
      emoji: '🌬️',
      description: 'Wind through Swedish pine forest — easy on the ears.',
      category: 'focus',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/f/f3/Wind_in_Swedish_pine_forest_at_25_mps.ogg',
    ),
    AmbientTrack(
      id: 'thunder',
      name: 'Distant Thunder',
      emoji: '🌩️',
      description: 'Rolling thunder and rain for deep concentration.',
      category: 'focus',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/b/bd/Storm_thunderbolts.ogg',
    ),

    // ── Meditation ───────────────────────────────────────────────────────────
    AmbientTrack(
      id: 'singing_bowls',
      name: 'Singing Bowls',
      emoji: '🔔',
      description: 'Tibetan bowl resonance to anchor meditation.',
      category: 'meditation',
      storageUrl:
          'https://archive.org/download/singingbowlmeditation/Singing%20Bowl%20Meditation.mp3',
      source: 'archive.org',
    ),
    AmbientTrack(
      id: 'om_drone',
      name: 'Meditation Tone',
      emoji: '🕉️',
      description: 'Deep bowl tone for mindfulness sits.',
      category: 'meditation',
      storageUrl:
          'https://archive.org/download/singingbowlmeditation/Short%20meditation%20track-1.mp3',
      source: 'archive.org',
    ),

    // ── Sleep ────────────────────────────────────────────────────────────────
    AmbientTrack(
      id: 'night_crickets',
      name: 'Summer Night',
      emoji: '🦗',
      description: 'Frogs and insects at a peaceful pond — for sleep.',
      category: 'sleep',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/f/fe/Nature_sounds_ambience_in_a_Dordogne_pond.ogg',
    ),
    AmbientTrack(
      id: 'fireplace',
      name: 'Forge Fire',
      emoji: '🔥',
      description: 'Roaring fire for warmth and comfort.',
      category: 'sleep',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/0/01/WWS_Fireoftheforge.ogg',
    ),
    AmbientTrack(
      id: 'rain_sleep',
      name: 'Night Rain',
      emoji: '🌙',
      description: 'Tropical night rain and jungle sounds for deep sleep.',
      category: 'sleep',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/a/a0/2013-07-24_00-19-04hrs_Chiang_Mai_Chang_Khien_rain_animal_sounds_night_time.ogg',
    ),
  ];

  static const List<String> categories = ['nature', 'focus', 'meditation', 'sleep'];

  static const Map<String, String> categoryEmojis = {
    'nature': '🌿',
    'focus': '🎯',
    'meditation': '🧘',
    'sleep': '🌙',
  };

  static List<AmbientTrack> byCategory(String cat) =>
      all.where((t) => t.category == cat).toList();
}
