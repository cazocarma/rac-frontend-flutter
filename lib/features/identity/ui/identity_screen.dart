import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/config/env.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';
import '../data/identity_api.dart';

enum _IdentityFailure { load, start, open }

/// S3. Shows only the verification state; the provider collects documents.
class IdentityScreen extends StatefulWidget {
  const IdentityScreen({
    super.key,
    this.purpose = 'client_booking',
    this.api,
    this.open,
  });
  final String purpose;
  final IdentityApi? api;
  final Future<bool> Function(Uri)? open;
  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  late final api = widget.api ?? IdentityApi(Env.apiBase);
  String? status;
  bool loading = true, busy = false, unavailable = false;
  _IdentityFailure? failure;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    if (widget.api == null) api.close();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      failure = null;
    });
    try {
      final value = await api.status();
      if (mounted) {
        setState(() {
          status = value;
          unavailable = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          unavailable = e is ApiException && e.status == 503;
          failure = unavailable ? null : _IdentityFailure.load;
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> start() async {
    setState(() {
      busy = true;
      failure = null;
    });
    try {
      final result = await api.start(widget.purpose);
      if (!mounted) return;
      setState(() => status = result.status);
      final url = result.url;
      if (url != null) {
        final open =
            widget.open ??
            (Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!await open(Uri.parse(url)) && mounted) {
          setState(() => failure = _IdentityFailure.open);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          unavailable = e is ApiException && e.status == 503;
          failure = unavailable ? null : _IdentityFailure.start;
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final canStart =
        !unavailable &&
        const {'none', 'rejected', 'expired', 'pending'}.contains(status);
    final message = switch (status) {
      'pending' => t.identityPending,
      'approved' => t.identityApproved,
      'rejected' => t.identityRejected,
      'needs_review' => t.identityReview,
      'expired' => t.identityExpired,
      _ => null,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(t.identityTitle),
        actions: [
          IconButton(
            tooltip: t.identityRefresh,
            onPressed: loading || busy ? null : load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: PageContent(
          width: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, size: 44),
              const SizedBox(height: 16),
              Text(
                t.identityWhy,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(t.identityStored),
              const SizedBox(height: 8),
              Text(t.identityProcessor),
              const SizedBox(height: 8),
              Text(t.identityDuration),
              const SizedBox(height: 8),
              Text(
                t.identityNoGuarantee,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (loading)
                const LinearProgressIndicator()
              else if (unavailable)
                Text(t.identityUnavailable)
              else ...[
                if (message != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (status == 'pending') ...[
                  const SizedBox(height: 8),
                  Text(t.identityPendingHelp),
                ],
                if (failure != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(switch (failure!) {
                      _IdentityFailure.load => t.identityLoadFailed,
                      _IdentityFailure.start => t.identityStartFailed,
                      _IdentityFailure.open => t.identityOpenFailed,
                    }, style: TextStyle(color: colors.error)),
                  ),
                const SizedBox(height: 16),
                if (failure == _IdentityFailure.load)
                  OutlinedButton(onPressed: load, child: Text(t.identityRetry))
                else if (canStart)
                  FilledButton.icon(
                    onPressed: busy ? null : start,
                    icon: const Icon(Icons.badge_outlined),
                    label: Text(
                      status == 'rejected' || status == 'expired'
                          ? t.identityRetry
                          : t.identityStart,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
