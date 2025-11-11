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

  /// Obtiene el rol guardado; por defecto 'cliente' si no existe.
  static Future<String> role() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? 'cliente';
  }
}
