import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../l10n/generated/app_localizations.dart';
import '../../shared/config/env.dart';
import '../../shared/services/auth_session.dart';
import 'editorial_api.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key, required this.api});
  factory StaffScreen.connected() => StaffScreen(
    api: EditorialApi(
      session: OidcAuthSession.staff(
        issuer: Uri.parse(Env.issuer),
        appOrigin: Uri.base.resolve('/'),
      ),
      client: http.Client(),
      origin: Uri.parse(Env.apiBase),
    ),
  );
  final EditorialApi api;
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  bool busy = true;
  bool verified = false;
  int? failure;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool login = false}) async {
    setState(() {
      busy = true;
      failure = null;
      verified = false;
    });
    try {
      if (login) await widget.api.session.login();
      final result = await widget.api.sessionInfo();
      if (result['permissions'] is! List ||
          !(result['permissions'] as List).contains('staff.session.read')) {
        throw const EditorialFailure(403, uncertain: false);
      }
      if (mounted) setState(() => verified = true);
    } on EditorialFailure catch (error) {
      if (mounted) setState(() => failure = error.status ?? 503);
    } catch (_) {
      if (mounted) setState(() => failure = 503);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> logout() async {
    setState(() {
      busy = true;
      verified = false;
    });
    try {
      await widget.api.session.logout();
    } catch (_) {
      await widget.api.session.clear();
    } finally {
      if (mounted)
        setState(() {
          busy = false;
          failure = 401;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.staffTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Icon(
                verified
                    ? Icons.verified_user_outlined
                    : Icons.admin_panel_settings_outlined,
                size: 52,
              ),
              const SizedBox(height: 20),
              Text(
                verified ? t.staffReady : t.staffAccess,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(t.staffAccessHelp),
              const SizedBox(height: 20),
              if (busy)
                const Center(child: CircularProgressIndicator())
              else if (verified) ...[
                Text(t.staffPending),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: logout, child: Text(t.staffSignOut)),
              ] else ...[
                if (failure != null && failure != 401)
                  Text(
                    failure == 403 ? t.staffDenied : t.staffUnavailable,
                    semanticsLabel: failure == 403
                        ? t.staffDenied
                        : t.staffUnavailable,
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => load(login: true),
                  child: Text(t.staffSignIn),
                ),
                TextButton(onPressed: load, child: Text(t.staffRetry)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
