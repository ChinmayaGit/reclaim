import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ambient_tracks.dart';

/// Handles downloading ambient tracks to local storage for offline playback.
///
/// Tracks are stored in `<appDocDir>/ambient_tracks/<trackId>.<ext>`.
/// A SharedPreferences flag marks when all tracks have been downloaded.
class AmbientDownloadManager {
  static const _prefKey = 'ambient_tracks_downloaded_v3';

  // ── Directory / file helpers ─────────────────────────────────────────────

  static Future<Directory> _trackDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/ambient_tracks');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static String _fileName(AmbientTrack track) {
    final ext = Uri.parse(track.storageUrl).pathSegments.last.split('.').last;
    return '${track.id}.$ext';
  }

  // ── Public API ───────────────────────────────────────────────────────────

  static Future<bool> areTracksDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Returns the local file path if this track has been downloaded, else null.
  static Future<String?> getLocalPath(AmbientTrack track) async {
    final dir = await _trackDir();
    final file = File('${dir.path}/${_fileName(track)}');
    return file.existsSync() ? file.path : null;
  }

  /// Look up local path by remote URL (used by resource_detail_screen).
  static Future<String?> getLocalPathForUrl(String url) async {
    final track = AmbientTracks.all
        .where((t) => t.storageUrl == url)
        .firstOrNull;
    if (track == null) return null;
    return getLocalPath(track);
  }

  /// Download every available track. Skips tracks that fail and continues.
  /// [onProgress] receives (completed, total, failedNames).
  static Future<List<String>> downloadAll({
    required void Function(int completed, int total, List<String> failed)
        onProgress,
  }) async {
    final tracks = AmbientTracks.all.where((t) => t.isAvailable).toList();
    final dir = await _trackDir();
    int completed = 0;
    final List<String> failed = [];

    for (final track in tracks) {
      final file = File('${dir.path}/${_fileName(track)}');

      if (!file.existsSync()) {
        try {
          await _downloadFile(track.storageUrl, file);
        } catch (e) {
          debugPrint('Failed to download ${track.name}: $e');
          if (file.existsSync()) file.deleteSync();
          failed.add(track.name);
        }
      }

      completed++;
      onProgress(completed, tracks.length, failed);
    }

    if (failed.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    }

    return failed;
  }

  static Future<void> _downloadFile(String url, File dest) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers
        ..set('User-Agent',
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/125.0 Mobile Safari/537.36')
        ..set('Accept', '*/*');
      final res = await req.close();

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final sink = dest.openWrite();
        await res.pipe(sink);
      } else {
        throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(url));
      }
    } finally {
      client.close();
    }
  }
}
