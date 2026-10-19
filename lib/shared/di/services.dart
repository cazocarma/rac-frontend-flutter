import 'package:rentacompa/shared/config/env.dart';
import 'package:rentacompa/shared/services/auth_api.dart';
import 'package:rentacompa/features/compas/data/compa_api.dart';
import 'package:rentacompa/features/match/data/match_api.dart';
import 'package:rentacompa/shared/services/user_api.dart';

/// Inicializador centralizado para exponer los servicios globales de la app.
///
/// Llamar a `Services.init()` en `main()` antes de usar cualquier servicio.
/// Esto asegura que las instancias de API estén configuradas con las URLs de entorno.
class Services {
  static late final AuthApi auth;
  static late final CompaApi compas;
  static late final MatchApi match;
  static late final UserApi user;

  static bool _inited = false;

  /// Inicializa todos los servicios compartidos una sola vez.
  static void init() {
    if (_inited) return;

    auth = AuthApi(
      baseUrl: Env.authBase,
      keycloakPublicUrl: Env.keycloakPublicUrl,
    );

    compas = CompaApi(Env.apiBase);
    match = MatchApi(Env.apiBase);
    user = UserApi(Env.apiBase);

    _inited = true;
  }
}
