import 'package:flutter/foundation.dart';
import 'package:oidc/oidc.dart';
import 'auth_store_native.dart'
    if (dart.library.js_interop) 'auth_store_web.dart';
import '../config/env.dart';

abstract class AuthSession {
  Future<void> login();
  Future<void> logout();
  Future<void> clear();
  Future<void> refresh();
  Future<String?> accessToken();
  Map<String, dynamic> get claims;
}

class OidcAuthSession implements AuthSession {
  OidcUserManager? _manager;
  Future<void>? _initializing;
  OidcUserManager get manager => _manager ??= OidcUserManager.lazy(
    discoveryDocumentUri: Uri.parse(
      '${Env.issuer}/.well-known/openid-configuration',
    ),
    clientCredentials: OidcClientAuthentication.none(clientId: Env.clientId),
    store: createAuthStore(),
    settings: OidcUserManagerSettings(
      redirectUri: Uri.parse(Env.redirectUri),
      postLogoutRedirectUri: Uri.parse(Env.redirectUri),
      scope: const ['openid', 'profile', 'email'],
      allowedIdTokenAlgorithms: const ['RS256'],
      expectedIssuer: Uri.parse(Env.issuer),
      supportOfflineAuth: false,
      options: const OidcPlatformSpecificOptions(
        web: OidcPlatformSpecificOptions_Web(
          navigationMode:
              OidcPlatformSpecificOptions_Web_NavigationMode.samePage,
        ),
      ),
    ),
  );
  Future<void> _init() async {
    try {
      await (_initializing ??= manager.init()).timeout(
        const Duration(seconds: 30),
      );
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  @override
  Future<void> login() async {
    debugPrint('RAC OIDC: preparando acceso en la misma pestaña');
    await _init();
    debugPrint('RAC OIDC: iniciando autorización');
    final user = await manager
        .loginAuthorizationCodeFlow(
          originalUri: kIsWeb ? Uri.base.resolve('/') : null,
        )
        .timeout(const Duration(seconds: 30));
    if (user == null && kIsWeb) {
      // The old document unloads; only the returning app may provision the user.
      await Future<void>.delayed(const Duration(seconds: 15));
      throw StateError('No se pudo abrir la página de acceso');
    }
    if (user == null) throw StateError('Inicio de sesión cancelado');
  }

  @override
  Future<String?> accessToken() async {
    await _init();
    return manager.getAccessToken();
  }

  @override
  Future<void> refresh() async {
    await _init();
    final token = await manager.getAccessToken(forceRefresh: true);
    if (token == null) throw StateError('Actualiza tu sesión para continuar');
  }

  @override
  Map<String, dynamic> get claims =>
      manager.currentUser?.aggregatedClaims ?? {};
  @override
  Future<void> logout() async {
    await _init();
    try {
      await manager.logout(originalUri: kIsWeb ? Uri.base.resolve('/') : null);
    } finally {
      await manager.forgetUser();
    }
  }

  @override
  Future<void> clear() async {
    if (_manager != null) await manager.forgetUser();
  }
}
