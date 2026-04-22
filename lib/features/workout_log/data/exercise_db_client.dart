import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exercise_db_models.dart';

/// HTTP client for [ExerciseDB on RapidAPI](https://edb-docs.up.railway.app/docs/exercise-service/intro).
///
/// A valid **X-RapidAPI-Key** alone is not enough: you must **subscribe** to the ExerciseDB API
/// on RapidAPI (free Basic plan works). Otherwise RapidAPI returns **HTTP 403**.
///
/// Free tier: [limit is capped at 10](https://edb-docs.up.railway.app/docs/exercise-service/exercises)
/// per request — this client always uses `limit=10`.
class ExerciseDbClient {
  ExerciseDbClient({required this.apiKey});

  final String apiKey;

  static const _host = 'exercisedb.p.rapidapi.com';
  static const _base = 'https://$_host';

  Map<String, String> get _headers => {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': _host,
      };

  /// GIF preview (Basic tier: resolution `180` only per docs).
  static String gifImageUrl(String exerciseId, {int resolution = 180}) {
    final u = Uri.https(_host, '/image', {
      'exerciseId': exerciseId,
      'resolution': '$resolution',
    });
    return u.toString();
  }

  Future<List<ExerciseDbExercise>> fetchExercises({
    int offset = 0,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$_base/exercises').replace(queryParameters: {
      'offset': '$offset',
      'limit': '$limit',
    });
    final res = await http.get(uri, headers: _headers);
    _throwIfBad(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ExerciseDbExercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((x) => x.id.isNotEmpty)
        .toList();
  }

  Future<List<ExerciseDbExercise>> fetchByBodyPart(
    String bodyPart, {
    int offset = 0,
    int limit = 10,
  }) async {
    final path =
        '/exercises/bodyPart/${Uri.encodeComponent(bodyPart.trim())}';
    final uri = Uri.parse('$_base$path').replace(queryParameters: {
      'offset': '$offset',
      'limit': '$limit',
    });
    final res = await http.get(uri, headers: _headers);
    _throwIfBad(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ExerciseDbExercise.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((x) => x.id.isNotEmpty)
        .toList();
  }

  void _throwIfBad(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw ExerciseDbException(
      statusCode: res.statusCode,
      body: res.body.length > 200 ? '${res.body.substring(0, 200)}…' : res.body,
    );
  }
}

class ExerciseDbException implements Exception {
  ExerciseDbException({required this.statusCode, required this.body});
  final int statusCode;
  final String body;

  bool get isForbidden => statusCode == 403;

  /// Short message for SnackBars and inline UI.
  String get userMessage {
    if (statusCode == 403) {
      return 'HTTP 403 — you are not subscribed to ExerciseDB on RapidAPI. '
          'Open the ExerciseDB API page and tap Subscribe: choose the **free Basic** plan '
          '(works with this app; 10 exercises per request) or a **paid** plan for higher limits, '
          'then tap Save & fetch again.';
    }
    if (statusCode == 401) {
      return 'HTTP 401 — invalid RapidAPI key. Check your Application Key and try again.';
    }
    return 'ExerciseDB request failed ($statusCode).';
  }

  @override
  String toString() =>
      '$userMessage ${body.isNotEmpty ? "($body)" : ""}'.trim();
}

/// Maps API errors to short UI copy (403 = not subscribed on RapidAPI).
String exerciseDbErrorUserMessage(Object error) {
  if (error is ExerciseDbException) return error.userMessage;
  return error.toString();
}
