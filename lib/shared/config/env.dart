/// Configuración centralizada de entorno.
///
/// Puedes sobrescribir valores usando `--dart-define`,
/// por ejemplo:
/// ```bash
/// flutter run -d chrome --dart-define=API_BASE_URL=http://localhost
/// ```
class Env {
  /// NGINX que enruta a los microservicios.
  ///
  /// En desarrollo suele ser `http://localhost`.
  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost',
  );

  /// URL pública de Keycloak (en desarrollo corre en el puerto 8081 por docker-compose).
  static const keycloakPublicUrl = String.fromEnvironment(
    'KEYCLOAK_PUBLIC_URL',
    defaultValue: 'http://localhost:8081',
  );

  /// Base del Auth Service detrás del NGINX.
  static String get authBase => '$apiBase/api/auth';
}
