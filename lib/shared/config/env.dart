/// Config de entorno centralizada.
/// Puedes override con --dart-define (ej: flutter run -d chrome --dart-define=API_BASE_URL=http://localhost)
class Env {
  /// NGINX que enruta a los microservicios (en dev suele ser http://localhost)
  static const apiBase =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost');

  /// URL pública de Keycloak (en dev por docker-compose: 8081)
  static const keycloakPublicUrl = String.fromEnvironment(
    'KEYCLOAK_PUBLIC_URL',
    defaultValue: 'http://localhost:8081',
  );

  /// Base del Auth Service detrás de NGINX
  static String get authBase => '$apiBase/api/auth';
}
