import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Env {
  static String apiBase = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost',
  );
  static String issuer = const String.fromEnvironment(
    'OIDC_ISSUER',
    defaultValue: 'http://localhost:8081/realms/rentacompa',
  );
  static String clientId = kIsWeb ? 'rac-web' : 'rac-mobile';
  static String redirectUri = kIsWeb
      ? Uri.base.resolve('/redirect.html').toString()
      : 'cl.rentacompa.app://oauth2redirect';
  static String get authBase => '$apiBase/api/auth';
  static String get keycloakPublicUrl => issuer.split('/realms/').first;
  static Future<void> load() async {
    if (!kIsWeb) return;
    final response = await http.get(Uri.base.resolve('/config.json'));
    if (response.statusCode != 200) {
      throw StateError('No se pudo cargar la configuración');
    }
    final config = jsonDecode(response.body) as Map<String, dynamic>;
    apiBase = config['apiBase'] as String;
    issuer = config['issuer'] as String;
    clientId = config['clientId'] as String;
    redirectUri = config['redirectUri'] as String;
  }
}
