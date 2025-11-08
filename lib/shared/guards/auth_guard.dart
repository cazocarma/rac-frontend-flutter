import 'package:flutter/material.dart';
import 'package:rentacompa/shared/services/session.dart';

/// Widget sencillo que protege secciones que requieren sesión.
/// Si no hay access_token, empuja al /login.
class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key, required this.child});
  final Widget child;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool? _logged;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await Session.isLoggedIn();
    if (!mounted) return;
    if (!ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    } else {
      setState(() => _logged = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_logged != true) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
