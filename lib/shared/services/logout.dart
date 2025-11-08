import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/services/session.dart';

Future<void> performLogout(BuildContext context) async {
  try {
    await Services.auth.logout();
  } catch (_) {
    // en dev, si falla la revocación no bloqueamos el logout local
  } finally {
    await Session.clear();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}
