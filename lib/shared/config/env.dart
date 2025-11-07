/// Config simple para apuntar al backend detrás de NGINX.
/// Usa --dart-define=API_BASE_URL=... para override. En dev, default: http://localhost
class Env {
  static const apiBase =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost');
}
