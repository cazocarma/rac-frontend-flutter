import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return (p.getString('access_token') ?? '').isNotEmpty;
  }

  static Future<String?> accessToken() async {
    final p = await SharedPreferences.getInstance();
    final at = p.getString('access_token');
    return (at != null && at.isNotEmpty) ? at : null;
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('access_token');
    await p.remove('refresh_token');
    await p.remove('internal_token');
  }
}
