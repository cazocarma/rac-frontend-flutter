import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session.dart';

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
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
    String? method,
  }) async {
    final access = await token();
    if (access == null || access.isEmpty) {
      throw exception(401, 'authentication_required');
    }
    final headers = {
      'Authorization': 'Bearer $access',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$base$apiPath$path');
    final response =
        await (method == 'PUT'
                ? client.put(
                    uri,
                    headers: headers,
                    body: body == null ? null : jsonEncode(body),
                  )
                : body == null
                ? client.get(uri, headers: headers)
                : client.post(uri, headers: headers, body: jsonEncode(body)))
            .timeout(Duration(seconds: poll ? 32 : 20));
    if (response.statusCode == 401 && retryAuth) {
      try {
        await refresh();
      } catch (_) {
        throw exception(401, 'invalid_token');
      }
      return request(
        path,
        body: body,
        poll: poll,
        retryAuth: false,
        method: method,
      );
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw exception(
        response.statusCode,
        decoded['error'] as String? ?? 'api_unavailable',
      );
    }
    return decoded;
  }

  void close() => client.close();
}
