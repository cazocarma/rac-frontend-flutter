import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Maneja la sesión local del usuario.
///
/// Encapsula el acceso a `SharedPreferences` para guardar y limpiar tokens
/// (`access_token`, `refresh_token`, `internal_token`).
class Session {
  /// Verifica si el usuario tiene una sesión activa.
  ///
  /// Retorna `true` si existe un `access_token` guardado.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('access_token') ?? '').isNotEmpty;
  }

  /// Obtiene el `access_token` actual, o `null` si no existe.
  static Future<String?> accessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final at = prefs.getString('access_token');
    return (at != null && at.isNotEmpty) ? at : null;
  }

  /// Limpia todos los tokens almacenados (logout local).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('internal_token');
    await prefs.remove('user_role');
  }

  /// Guarda el rol del usuario ('cliente' o 'compa').
  static Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  /// Obtiene el rol desde el token JWT.
  ///
  /// Si no puede derivarse, usa el rol cacheado y finalmente "cliente".
  static Future<String> role() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null && token.isNotEmpty) {
      final payload = _decodeJwtPayload(token);
      final resolved = _roleFromPayload(payload);
      if (resolved != null) {
        await prefs.setString('user_role', resolved);
        return resolved;
      }
    }
    return prefs.getString('user_role') ?? 'cliente';
  }

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    final segments = token.split('.');
    if (segments.length < 2) return null;
    try {
      final normalized = base64Url.normalize(segments[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String? _roleFromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    final realm = payload['realm_access'];
    if (realm is Map<String, dynamic>) {
      final roles = realm['roles'];
      if (roles is List) {
        final lowered = roles.map((e) => e.toString().toLowerCase()).toList();
        if (lowered.contains('compa')) return 'compa';
        if (lowered.contains('cliente')) return 'cliente';
      }
    }
    return null;
  }
}
