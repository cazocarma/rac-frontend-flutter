import 'package:rentacompa/shared/config/env.dart';
import 'package:rentacompa/shared/services/auth_api.dart';
import 'package:rentacompa/features/compas/data/compa_api.dart';

/// Inicializador simple para exponer servicios en toda la app.
/// Llamar a `Services.init()` en main().
class Services {
  static late final AuthApi auth;
  static late final CompaApi compas;

  static bool _inited = false;

  static void init() {
    if (_inited) return;
    auth = AuthApi(
      baseUrl: Env.authBase,
      keycloakPublicUrl: Env.keycloakPublicUrl,
    );
    compas = CompaApi(Env.apiBase);
    _inited = true;
  }
}
