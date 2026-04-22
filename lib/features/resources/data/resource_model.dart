/// A single section within an article (heading, paragraph, tip, quote, bullet).
class ContentSection {
  const ContentSection({required this.type, required this.content});
  final String type; // 'heading' | 'paragraph' | 'tip' | 'quote' | 'bullet'
  final String content;
}

/// One step in a guided audio/breathing exercise.
class GuideStep {
  const GuideStep({
    required this.instruction,
    required this.durationSeconds,
    this.cue = '',
  });
  final String instruction;  // Shown as the main step text
  final int durationSeconds; // Countdown timer for this step
  final String cue;          // Short repeated cue shown during the countdown
}

/// A single field in an interactive worksheet.
class WorksheetField {
  const WorksheetField({
    required this.id,
    required this.label,
    required this.hint,
    this.multiline = false,
  });
  final String id;
  final String label;
  final String hint;
  final bool multiline;
}

/// A resource item (article, audio guide, video, or worksheet).
class ResourceItem {
  const ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.categories,
    required this.isPremium,
    required this.duration,
    this.sections = const [],
    this.steps = const [],
    this.fields = const [],
    this.videoId,
    this.videoUrl,
    this.videoDescription,
    this.videoTopic,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final String type;           // 'article' | 'audio' | 'video' | 'worksheet'
  final List<String> categories; // e.g. ['addiction', 'stress']
  final bool isPremium;
  final String duration;

  // Article content
  final List<ContentSection> sections;

  // Audio guide steps (each step has a timer)
  final List<GuideStep> steps;

  // Worksheet interactive fields
  final List<WorksheetField> fields;

  // Video
  /// YouTube video ID (the part after ?v=). Used for in-app embed.
  /// e.g. for https://youtu.be/PY9DcIMGxMs, set videoId: 'PY9DcIMGxMs'
  final String? videoId;

  /// Fallback external URL — only used when videoId is null.
  final String? videoUrl;
  final String? videoDescription;
  /// In-app video category (Videos tab chips). e.g. `stories`, `therapy`, `body`.
  final String? videoTopic;
}

/// Topic keys for the Videos tab (see [ResourceItem.videoTopic]).
const kVideoTopics = [
  ('all', 'All'),
  ('stories', 'Stories'),
  ('therapy', 'Therapy skills'),
  ('body', 'Body & nervous system'),
  ('motivation', 'Motivation'),
  ('science', 'Science & education'),
];
