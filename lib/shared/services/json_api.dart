import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'session.dart';
import 'pending_documents.dart';

class ApiException implements Exception {
  const ApiException(this.status, this.code);
  final int status;
  final String code;
}

/// Shared authenticated transport: bounded requests, one refresh, stable payload.
class JsonApi {
  JsonApi(
    this.base, {
    required this.apiPath,
    this.exception = ApiException.new,
    this.onDocumentsRequired = DocumentPreconditions.notify,
    this.onAssessmentRequired = DocumentPreconditions.requireAssessment,
    http.Client? client,
    Future<String?> Function()? token,
    Future<void> Function()? refresh,
  }) : client = client ?? http.Client(),
       token = token ?? Session.accessToken,
       refresh = refresh ?? Session.auth.refresh;
  final String base, apiPath;
  final http.Client client;
  final Future<String?> Function() token;
  final Future<void> Function() refresh;
  final ApiException Function(int, String) exception;
  final void Function(DocumentPrecondition) onDocumentsRequired;
  final void Function() onAssessmentRequired;
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) => _request(
    path,
    wireBody: body == null ? null : jsonEncode(body),
    method: method ?? (body == null ? 'GET' : 'POST'),
    poll: poll,
    retryAuth: retryAuth,
  );

  /// Freeze the bytes before token refresh or network I/O. Retries retain the
  /// exact idempotency key and payload; this never falls back to avatar routes.
  Future<Map<String, dynamic>> requestBytes(
    String path, {
    required Uint8List bytes,
    required String mediaType,
    required String idempotencyKey,
  }) => _request(
    path,
    wireBody: List<int>.unmodifiable(bytes),
    method: 'POST',
    headers: {'Content-Type': mediaType, 'Idempotency-Key': idempotencyKey},
    timeout: const Duration(seconds: 35),
  );

  Future<Map<String, dynamic>> _request(
    String path, {
    Object? wireBody,
    required String method,
    Map<String, String> headers = const {},
    bool poll = false,
    bool retryAuth = true,
    Duration? timeout,
  }) async {
    final access = await token();
    if (access == null || access.isEmpty) {
      throw exception(401, 'authentication_required');
    }
    final requestHeaders = {
      'Authorization': 'Bearer $access',
      'Content-Type': 'application/json',
      ...headers,
    };
    final uri = Uri.parse('$base$apiPath$path');
    final response = await (switch (method) {
      'DELETE' => client.delete(uri, headers: requestHeaders, body: wireBody),
      'PUT' => client.put(uri, headers: requestHeaders, body: wireBody),
      'POST' => client.post(uri, headers: requestHeaders, body: wireBody),
      'GET' => client.get(uri, headers: requestHeaders),
      _ => throw ArgumentError.value(method, 'method'),
    }).timeout(timeout ?? Duration(seconds: poll ? 32 : 20));
    if (response.statusCode == 401 && retryAuth) {
      try {
        await refresh();
      } catch (_) {
        throw exception(401, 'invalid_token');
      }
      return _request(
        path,
        wireBody: wireBody,
        headers: headers,
        poll: poll,
        retryAuth: false,
        method: method,
        timeout: timeout,
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    // 202 acknowledges work accepted for later human review.
    if (response.statusCode < 200 || response.statusCode > 202) {
      final pending = DocumentPrecondition.parse(response.statusCode, decoded);
      if (pending != null) onDocumentsRequired(pending);
      if (response.statusCode == 428 &&
          decoded['error'] == 'COMPA_ATTESTATION_REQUIRED') {
        onAssessmentRequired();
      }
      throw exception(
        response.statusCode,
        decoded['error'] as String? ?? 'api_unavailable',
      );
    }
    return decoded;
  }

  void close() => client.close();
}
