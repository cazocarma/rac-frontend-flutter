import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import 'auth_session.dart';
import 'session.dart';

class AuthApi {
  AuthApi({
    AuthSession? session,
    http.Client? client,
    String? apiBase,
    String? baseUrl,
    String? keycloakPublicUrl,
  }) : session = session ?? Session.auth,
       client = client ?? http.Client(),
       apiBase = apiBase ?? Env.apiBase;
  final AuthSession session;
  final http.Client client;
  final String apiBase;
  Future<void> login() async {
    await session.login();
    try {
      final token = await session.accessToken();
      final response = await client.get(
        Uri.parse('$apiBase/api/user/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        throw StateError(
          'No se pudo preparar tu perfil (${response.statusCode})',
        );
      }
    } catch (_) {
      await session.clear();
      rethrow;
    }
  }

  Future<void> logout() => session.logout();
  Future<Map<String, dynamic>> userinfo() async {
    final token = await session.accessToken();
    final response = await client.get(
      Uri.parse('$apiBase/api/auth/userinfo'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw StateError('Sesión inválida');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
