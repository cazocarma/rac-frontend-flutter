import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/services/auth_session.dart';

/// Keep the exact command in memory until an uncertain result is resolved.
/// Neither credentials nor unpublished legal text belong in preferences/logs.
class EditorialCommand {
  EditorialCommand(String operation, Map<String, dynamic> body)
    : path = _path(operation),
      encodedBody = jsonEncode(body) {
    if (body['event_id'] is! String || (body['event_id'] as String).isEmpty) {
      throw ArgumentError('A stable event_id is required');
    }
  }

  final String path;
  final String encodedBody;

  static String _path(String operation) {
    const operations = {
      'documents/drafts',
      'documents/reviews',
      'documents/publications',
      'documents/activations',
      'assessments/drafts',
      'assessments/reviews',
      'assessments/publications',
    };
    if (!operations.contains(operation)) {
      throw ArgumentError('Unknown editorial operation');
    }
    return '/api/admin/staff/$operation';
  }
}

class EditorialFailure implements Exception {
  const EditorialFailure(this.status, {required this.uncertain});
  final int? status;
  final bool uncertain;
  @override
  String toString() => 'Editorial request failed';
}

/// Uses only the injected staff session. Never provisions an ordinary profile,
/// infers permissions from realm roles, refreshes MFA, or retries a write.
class EditorialApi {
  EditorialApi({
    required this.session,
    required this.client,
    required Uri origin,
  }) : origin = _origin(origin);

  final AuthSession session;
  final http.Client client;
  final Uri origin;

  static Uri _origin(Uri uri) {
    if (!{'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        (uri.path.isNotEmpty && uri.path != '/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw ArgumentError('Explicit API origin required');
    }
    return uri;
  }

  Future<Map<String, String>> _headers() async {
    final token = await session.accessToken();
    if (token == null || token.isEmpty) {
      throw const EditorialFailure(401, uncertain: false);
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> sessionInfo() =>
      _get('/api/admin/staff/session');

  Future<Map<String, dynamic>> read(String resource, String id) {
    if (!{'documents', 'assessments'}.contains(resource) ||
        !RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
        ).hasMatch(id)) {
      throw ArgumentError('Exact resource reference required');
    }
    return _get('/api/admin/staff/$resource/$id');
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final headers = await _headers();
    try {
      return _decode(await _send('GET', path, headers), write: false);
    } on EditorialFailure {
      rethrow;
    } catch (_) {
      throw const EditorialFailure(null, uncertain: false);
    }
  }

  Future<Map<String, dynamic>> submit(EditorialCommand command) async {
    final headers = await _headers();
    try {
      // Exactly one attempt. A manual retry receives the same frozen command.
      return _decode(
        await _send('POST', command.path, headers, command.encodedBody),
        write: true,
      );
    } on EditorialFailure {
      rethrow;
    } catch (_) {
      throw const EditorialFailure(null, uncertain: true);
    }
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, String> headers, [
    String? body,
  ]) async {
    final request = http.Request(method, origin.resolve(path))
      ..followRedirects = false
      ..headers.addAll(headers);
    if (body != null) request.body = body;
    return (() async {
      final response = await client.send(request);
      final bytes = <int>[];
      await for (final chunk in response.stream) {
        if (bytes.length + chunk.length > 1048576) {
          throw const FormatException('Editorial response too large');
        }
        bytes.addAll(chunk);
      }
      return http.Response.bytes(bytes, response.statusCode);
    })().timeout(const Duration(seconds: 8));
  }

  Map<String, dynamic> _decode(http.Response response, {required bool write}) {
    if (response.statusCode != 200) {
      throw EditorialFailure(
        response.statusCode,
        uncertain:
            write && !{400, 401, 403, 404, 409}.contains(response.statusCode),
      );
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (_) {
      throw EditorialFailure(response.statusCode, uncertain: write);
    }
  }
}
