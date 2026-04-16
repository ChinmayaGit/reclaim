import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Embeds a YouTube video in-app using the official privacy-enhanced iframe.
///
/// Legal basis:
///  • YouTube ToS §5C explicitly permits embedding in third-party apps.
///  • youtube-nocookie.com is YouTube's own privacy-enhanced embed domain —
///    no tracking cookies are set, making this GDPR-friendly.
///  • No download, re-hosting, or monetisation of YouTube content occurs.
///  • Google Play Store compliant — WebView + YouTube embed is a standard
///    pattern used by millions of published apps.
class VideoEmbedScreen extends StatefulWidget {
  const VideoEmbedScreen({
    super.key,
    required this.videoId,
    required this.title,
    this.description,
  });

  /// YouTube video ID — the part after `?v=` in a YouTube URL.
  /// e.g. for https://youtu.be/PY9DcIMGxMs, videoId is "PY9DcIMGxMs".
  final String videoId;
  final String title;
  final String? description;

  @override
  State<VideoEmbedScreen> createState() => _VideoEmbedScreenState();
}

class _VideoEmbedScreenState extends State<VideoEmbedScreen> {
  late final WebViewController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (_) => setState(() => _loading = false),
      ))
      ..loadHtmlString(_buildHtml(widget.videoId));
  }

  /// Builds the minimal HTML page that contains only a 16:9 YouTube iframe.
  /// rel=0 — disables "related videos" from other channels after playback.
  /// modestbranding=1 — minimises YouTube logo size.
  /// playsinline=1 — prevents forced fullscreen on iOS.
  String _buildHtml(String videoId) => '''<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { background: #000; width: 100%; height: 100vh;
                 display: flex; align-items: center; justify-content: center; }
    .wrap { width: 100%; position: relative; padding-top: 56.25%; }
    iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <div class="wrap">
    <iframe
      src="https://www.youtube-nocookie.com/embed/$videoId?rel=0&modestbranding=1&playsinline=1&color=white"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Subtle attribution — keeps everything above board
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                'via YouTube',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Video player area (16:9)
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _ctrl),
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.teal400),
                  ),
              ],
            ),
          ),

          // Optional description below
          if (widget.description != null && widget.description!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1A1A1A),
              child: Text(
                widget.description!,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14, height: 1.55),
              ),
            ),
        ],
      ),
    );
  }
}
