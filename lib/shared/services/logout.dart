import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';

/// Cierra la sesión del usuario.
///
/// Intenta revocar los tokens en el Auth Service, limpia la sesión local
/// y redirige al usuario a la pantalla de login.
Future<void> performLogout(BuildContext context) async {
  try {
    await Services.auth.logout();
  } catch (_) {
    // En entorno de desarrollo, si falla la revocación,
    // no bloqueamos el cierre de sesión local.
  } finally {
    await Session.clear();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
}
