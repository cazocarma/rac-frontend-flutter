import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../../shared/services/session.dart';

class ChatException implements Exception {
  const ChatException(this.status, this.code);
  final int status;
  final String code;
  String get message => switch (status) {
    401 => 'Tu sesión venció. Vuelve a ingresar para continuar.',
    404 => 'Esta conversación ya no está disponible para tu cuenta.',
    409 => 'La reserva cambió de estado. Actualiza la conversación.',
    429 => 'Hay demasiadas conexiones. Reintentaremos en unos momentos.',
    _ => 'No pudimos conectar. Conservamos tu mensaje para reintentar aquí.',
  };
}

class ChatApi {
  ChatApi(
    this.base, {
    http.Client? client,
    Future<String?> Function()? token,
    Future<void> Function()? refresh,
  }) : client = client ?? http.Client(),
       token = token ?? Session.accessToken,
       refresh = refresh ?? Session.auth.refresh;
  final String base;
  final http.Client client;
  final Future<String?> Function() token;
  final Future<void> Function() refresh;

  static String newRequestId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final h = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    bool poll = false,
    bool retryAuth = true,
  }) async {
    final access = await token();
    if (access == null || access.isEmpty) {
      throw const ChatException(401, 'authentication_required');
    }
    final headers = {
      'Authorization': 'Bearer $access',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse('$base/api/chat$path');
    final response =
        await (body == null
                ? client.get(uri, headers: headers)
                : client.post(uri, headers: headers, body: jsonEncode(body)))
            .timeout(Duration(seconds: poll ? 32 : 20));
    if (response.statusCode == 401 && retryAuth) {
      try {
        await refresh();
      } catch (_) {
        throw const ChatException(401, 'invalid_token');
      }
      return request(path, body: body, poll: poll, retryAuth: false);
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ChatException(
        response.statusCode,
        decoded['error'] as String? ?? 'chat_unavailable',
      );
    }
    return decoded;
  }

  Future<Map<String, dynamic>> conversations({int offset = 0}) =>
      request('/conversations?offset=$offset');
  Future<Map<String, dynamic>> history(String id, {String? before}) => request(
    '/bookings/$id/messages${before == null ? '' : '?before=$before'}',
  );
  Future<Map<String, dynamic>> events(String id, String cursor) =>
      request('/bookings/$id/events?after=$cursor&wait=25', poll: true);
  Future<Map<String, dynamic>> send(String id, String key, String text) =>
      request(
        '/bookings/$id/messages',
        body: {'envio_id': key, 'contenido': text},
      );
  void close() => client.close();
}
