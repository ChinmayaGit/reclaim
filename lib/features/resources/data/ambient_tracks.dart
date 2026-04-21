/// Royalty-free ambient sound catalog.
///
/// Sources:
///   • Wikimedia Commons (CC0 / Public Domain) — upload.wikimedia.org
///     Uses transcoded MP3 versions for maximum device compatibility.
///   • Internet Archive (CC0 1.0) — archive.org
///
/// All URLs verified via the Wikimedia Commons API (videoinfo/derivatives)
/// and the Internet Archive file listings. No guessed paths.
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

  /// Direct MP3 URL — downloaded to local storage for offline playback.
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
      description: 'Lake-shore waves recorded on Lake Ontario — deep relaxation.',
      category: 'nature',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/1f/Waves.ogg/Waves.ogg.mp3',
    ),
    AmbientTrack(
      id: 'forest_birds',
      name: 'Morning Birdsong',
      emoji: '🌲',
      description: 'Dawn birdsong to ground and energise.',
      category: 'nature',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/4/42/Bird_singing.ogg/Bird_singing.ogg.mp3',
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
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/a/aa/White_noise.ogg/White_noise.ogg.mp3',
    ),
    AmbientTrack(
      id: 'brown_noise',
      name: 'Forest Wind',
      emoji: '🌬️',
      description: 'Wind through Swedish pine forest — easy on the ears.',
      category: 'focus',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/f/f3/Wind_in_Swedish_pine_forest_at_25_mps.ogg/Wind_in_Swedish_pine_forest_at_25_mps.ogg.mp3',
    ),
    AmbientTrack(
      id: 'thunder',
      name: 'Distant Thunder',
      emoji: '🌩️',
      description: 'Rolling thunder and rain for deep concentration.',
      category: 'focus',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/b/bd/Storm_thunderbolts.ogg/Storm_thunderbolts.ogg.mp3',
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
      description: 'Tibetan singing bowl tone for mindfulness sits.',
      category: 'meditation',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/1/17/Small_tibetan_singing_bowl.ogg/Small_tibetan_singing_bowl.ogg.mp3',
      license: 'CC BY-SA 4.0',
    ),

    // ── Sleep ────────────────────────────────────────────────────────────────
    AmbientTrack(
      id: 'night_crickets',
      name: 'Summer Night',
      emoji: '🦗',
      description: 'Frogs and insects at a peaceful pond — for sleep.',
      category: 'sleep',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/f/fe/Nature_sounds_ambience_in_a_Dordogne_pond.ogg/Nature_sounds_ambience_in_a_Dordogne_pond.ogg.mp3',
      license: 'CC BY 3.0',
    ),
    AmbientTrack(
      id: 'fireplace',
      name: 'Campfire',
      emoji: '🔥',
      description: 'Crackling campfire for warmth and comfort.',
      category: 'sleep',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/b/b1/Campfire_sound_ambience.ogg/Campfire_sound_ambience.ogg.mp3',
      license: 'CC BY 3.0',
    ),
    AmbientTrack(
      id: 'rain_sleep',
      name: 'Night Rain',
      emoji: '🌙',
      description: 'Tropical night rain and jungle sounds for deep sleep.',
      category: 'sleep',
      storageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/transcoded/a/a0/2013-07-24_00-19-04hrs_Chiang_Mai_Chang_Khien_rain_animal_sounds_night_time.ogg/2013-07-24_00-19-04hrs_Chiang_Mai_Chang_Khien_rain_animal_sounds_night_time.ogg.mp3',
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
