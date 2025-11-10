import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API de autenticación centralizada.
///
/// Maneja login, registro, refresh tokens y flujo OAuth social.
/// Todos los endpoints deben responder con el formato unificado `{ok, data, error}`.
class AuthApi {
  AuthApi({
    required this.baseUrl,
    required this.keycloakPublicUrl,
  });

  /// Base del Auth Service — ej: `http://localhost/api/auth`
  final String baseUrl;

  /// URL pública de Keycloak — no se usa directamente, pero se conserva por compatibilidad.
  final String keycloakPublicUrl;

  // ===========================================================================
  // Envelope helpers
  // ===========================================================================

  dynamic _parseData(http.Response res) {
    final map = json.decode(res.body) as Map<String, dynamic>;
    if (map['ok'] == true) return map['data'];

    final err = map['error'] ?? {};
    throw Exception(
      '${err['code'] ?? 'ERR'}: ${err['message'] ?? res.body}',
    );
  }

  // ===========================================================================
  // Autenticación básica
  // ===========================================================================

  /// Inicia sesión usando username/password y guarda tokens localmente.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = _parseData(res) as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();

    final kc = (data['keycloak'] ?? data) as Map<String, dynamic>;
    await prefs.setString('access_token', kc['access_token'] ?? '');
    await prefs.setString('refresh_token', kc['refresh_token'] ?? '');

    if (data['internal_jwt'] != null && data['internal_jwt'] is Map) {
      await prefs.setString(
        'internal_token',
        data['internal_jwt']['token'] ?? '',
      );
    }

    return data;
  }

  /// Registra un nuevo usuario de tipo `cliente`.
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/register');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'role': 'cliente',
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    _parseData(res); // valida ok/err
  }

  /// Refresca el `access_token` usando el `refresh_token` almacenado.
  Future<Map<String, dynamic>> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    final rt = prefs.getString('refresh_token') ?? '';

    if (rt.isEmpty) throw Exception('No hay refresh_token');

    final res = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh_token': rt}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = _parseData(res) as Map<String, dynamic>;

    if ((data['access_token'] ?? '').toString().isNotEmpty) {
      await prefs.setString('access_token', data['access_token']);
    }
    if ((data['refresh_token'] ?? '').toString().isNotEmpty) {
      await prefs.setString('refresh_token', data['refresh_token']);
    }

    return data;
  }

  /// Obtiene la información del usuario autenticado (`/userinfo`).
  Future<Map<String, dynamic>> userinfo() async {
    final prefs = await SharedPreferences.getInstance();
    final at = prefs.getString('access_token') ?? '';

    if (at.isEmpty) throw Exception('No hay access_token');

    final res = await http.get(
      Uri.parse('$baseUrl/userinfo'),
      headers: {'Authorization': 'Bearer $at'},
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    return _parseData(res) as Map<String, dynamic>;
  }

  /// Cierra sesión y revoca los tokens.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final rt = prefs.getString('refresh_token') ?? '';

    if (rt.isNotEmpty) {
      final res = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': rt}),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      _parseData(res);
    }

    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('internal_token');
  }

  // ===========================================================================
  // Social OAuth (start -> popup -> consume)
  // ===========================================================================

  /// Inicia el flujo OAuth con el proveedor indicado (Google, GitHub, etc).
  Future<Map<String, String>> oauthStart(String provider) async {
    final res = await http.post(Uri.parse('$baseUrl/oauth/$provider/start'));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = _parseData(res) as Map<String, dynamic>;
    return {
      'auth_url': data['auth_url'] as String,
      'state': data['state'] as String,
    };
  }

  /// Consume el flujo OAuth después de que el usuario autoriza.
  Future<Map<String, dynamic>> oauthConsume(
    String provider,
    String state,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/oauth/$provider/consume'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'state': state}),
    );

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = _parseData(res) as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();

    final kc = (data['keycloak'] ?? data) as Map<String, dynamic>;
    await prefs.setString('access_token', kc['access_token'] ?? '');
    await prefs.setString('refresh_token', kc['refresh_token'] ?? '');

    if (data['internal_jwt'] != null && data['internal_jwt'] is Map) {
      await prefs.setString(
        'internal_token',
        data['internal_jwt']['token'] ?? '',
      );
    }

    return data;
  }
}
