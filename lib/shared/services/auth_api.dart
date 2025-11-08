import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API hacia el microservicio de Auth (fachada de Keycloak).
class AuthApi {
  AuthApi({required this.baseUrl, required this.keycloakPublicUrl});
  final String baseUrl;            // p.ej. http://localhost/api/auth
  final String keycloakPublicUrl;  // p.ej. http://localhost:8081

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}));
    if (res.statusCode != 200) {
      throw Exception('Login falló: ${res.statusCode} ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();

    // Respuesta puede ser CombinedLoginResponse { keycloak, internal_jwt? }
    final kc = (data['keycloak'] ?? data) as Map<String, dynamic>;
    await prefs.setString('access_token', kc['access_token'] ?? '');
    await prefs.setString('refresh_token', kc['refresh_token'] ?? '');

    if (data['internal_jwt'] != null && data['internal_jwt'] is Map) {
      final internal = data['internal_jwt'] as Map<String, dynamic>;
      await prefs.setString('internal_token', internal['token'] ?? '');
    }
    return data;
  }

  Future<Map<String, dynamic>> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final rt = prefs.getString('refresh_token') ?? '';
    if (rt.isEmpty) throw Exception('No hay refresh_token');

    final uri = Uri.parse('$baseUrl/refresh');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': rt}));
    if (res.statusCode != 200) {
      throw Exception('Refresh falló: ${res.statusCode} ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final at = data['access_token'] ?? '';
    if (at.isNotEmpty) {
      await prefs.setString('access_token', at);
    }
    if ((data['refresh_token'] ?? '').toString().isNotEmpty) {
      await prefs.setString('refresh_token', data['refresh_token']);
    }
    return data;
  }

  Future<Map<String, dynamic>> userinfo() async {
    final prefs = await SharedPreferences.getInstance();
    final at = prefs.getString('access_token') ?? '';
    if (at.isEmpty) throw Exception('No hay access_token');
    final uri = Uri.parse('$baseUrl/userinfo');
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $at'});
    if (res.statusCode != 200) {
      throw Exception('userinfo falló: ${res.statusCode} ${res.body}');
    }
    return json.decode(res.body) as Map<String, dynamic>;
  }

  /// Si decides exponer /register en tu backend; si no, usa `keycloakPublicUrl` con OIDC registrations.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role, // 'cliente' | 'compa'
  }) async {
    final uri = Uri.parse('$baseUrl/register');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        }));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('register falló: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final rt = prefs.getString('refresh_token') ?? '';

    if (rt.isNotEmpty) {
      final uri = Uri.parse('$baseUrl/logout');
      await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refresh_token': rt}));
    }

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('internal_token');
  }
}
