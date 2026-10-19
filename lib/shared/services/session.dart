import 'auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static AuthSession auth = OidcAuthSession();
  static Future<void> clearLegacyTokens() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [
      'access_token',
      'refresh_token',
      'internal_token',
      'user_role',
    ]) {
      await preferences.remove(key);
    }
  }

  static Future<String?> accessToken() => auth.accessToken();
  static Future<bool> isLoggedIn() async {
    try {
      return (await accessToken())?.isNotEmpty == true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clear() => auth.clear();
  static Future<String> role() async {
    if (!await isLoggedIn()) return 'cliente';
    return roleFromClaims(auth.claims);
  }

  static String roleFromClaims(Map<String, dynamic> claims) {
    final roles = (claims['realm_access'] as Map?)?['roles'] as List? ?? [];
    for (final role in ['admin', 'compa', 'cliente']) {
      if (roles.contains(role)) return role;
    }
    return 'cliente';
  }

  // Roles are issued by Keycloak; the profile UI cannot grant them.
  static Future<void> setRole(String value) async {
    if (value != await role()) {
      throw StateError(
        'El rol se gestiona mediante una solicitud de publicación',
      );
    }
  }
}
