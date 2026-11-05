import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/config/env.dart';
import '../../../shared/di/services.dart';
import '../../../shared/services/json_api.dart';
import '../../../shared/widgets/design.dart';
import '../data/listing_api.dart';

enum _ListingFailure {
  load,
  contact,
  invalid,
  conflict,
  needsProfile,
  identity,
  unavailable,
  submit,
}

/// P08. Sending the saved profile asks for a human review; it never publishes
/// directly and no review time is promised while D07 has no commitment.
class ListingReviewScreen extends StatefulWidget {
  const ListingReviewScreen({super.key, this.api, this.draft});
  final ListingApi? api;
  final Future<Map<String, dynamic>> Function()? draft;
  @override
  State<ListingReviewScreen> createState() => _ListingReviewScreenState();
}

class _ListingReviewScreenState extends State<ListingReviewScreen> {
  late final api = widget.api ?? ListingApi(Env.apiBase);
  OwnListing? listing;
  bool loading = true, busy = false, sent = false;
  _ListingFailure? failure;

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

  Future<Map<String, dynamic>> savedDraft() async {
    final me = await Services.user.me();
    final compa = await Services.user.ownCompa();
    if (compa == null) throw const ApiException(404, 'compa_profile_required');
    return listingDraft(me, compa);
  }

  Future<void> load({bool keepFailure = false}) async {
    setState(() {
      loading = true;
      if (!keepFailure) failure = null;
    });
    try {
      final value = await api.state();
      if (mounted) setState(() => listing = value);
    } catch (_) {
      if (mounted) setState(() => failure = _ListingFailure.load);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      failure = null;
      sent = false;
    });
    try {
      final draft = await (widget.draft ?? savedDraft)();
      await api.submit(listing?.version ?? '0', draft);
      if (!mounted) return;
      setState(() => sent = true);
      await load();
    } catch (e) {
      final code = e is ApiException ? e.code : '';
      final status = e is ApiException ? e.status : 0;
      if (!mounted) return;
      setState(() {
        failure = switch (code) {
          'public_contact_not_allowed' => _ListingFailure.contact,
          'invalid_listing' => _ListingFailure.invalid,
          'listing_version_conflict' => _ListingFailure.conflict,
          'compa_profile_required' => _ListingFailure.needsProfile,
          'IDENTITY_VERIFICATION_REQUIRED' => _ListingFailure.identity,
          'listing_submission_unavailable' => _ListingFailure.unavailable,
          _ when status == 503 => _ListingFailure.unavailable,
          _ => _ListingFailure.submit,
        };
      });
      // A concurrent submission changed the version: show the current state.
      if (failure == _ListingFailure.conflict) await load(keepFailure: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final current = listing;
    final state = current == null
        ? t.listingReviewNone
        : current.pending
        ? t.listingReviewPending
        : switch (current.decision) {
            'approved' => t.listingReviewApproved,
            'rejected' => t.listingReviewRejected,
            'changes_requested' => t.listingReviewChanges,
            _ => t.listingReviewNone,
          };
    return Scaffold(
      appBar: AppBar(
        title: Text(t.listingReviewTitle),
        actions: [
          IconButton(
            tooltip: t.listingReviewRefresh,
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
              const Icon(Icons.fact_check_outlined, size: 44),
              const SizedBox(height: 16),
              Text(
                t.listingReviewWhy,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(t.listingReviewWhat),
              const SizedBox(height: 8),
              Text(
                t.listingReviewNoDeadline,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (loading)
                const LinearProgressIndicator()
              else if (failure == _ListingFailure.load) ...[
                Text(
                  t.listingReviewLoadFailed,
                  style: TextStyle(color: colors.error),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: load,
                  child: Text(t.listingReviewRetry),
                ),
              ] else ...[
                Semantics(
                  liveRegion: true,
                  child: Text(
                    sent ? t.listingReviewSent : state,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (current?.published ?? false) ...[
                  const SizedBox(height: 8),
                  Text(t.listingReviewHasApproved),
                ],
                if (failure != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(switch (failure!) {
                      _ListingFailure.contact => t.listingReviewContact,
                      _ListingFailure.invalid => t.listingReviewInvalid,
                      _ListingFailure.conflict => t.listingReviewConflict,
                      _ListingFailure.needsProfile =>
                        t.listingReviewNeedsProfile,
                      _ListingFailure.identity => t.listingReviewIdentity,
                      _ListingFailure.unavailable => t.listingReviewUnavailable,
                      _ => t.listingReviewSubmitFailed,
                    }, style: TextStyle(color: colors.error)),
                  ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushNamed('/photo-review'),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(t.photoUploadOpen),
                    ),
                    if (failure == _ListingFailure.identity)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed('/identity', arguments: 'compa_onboarding'),
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(t.identityGo),
                      ),
                    if (failure == _ListingFailure.needsProfile)
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/become-compa'),
                        child: Text(t.listingReviewEditProfile),
                      ),
                    if (failure != _ListingFailure.unavailable)
                      FilledButton.icon(
                        onPressed: busy ? null : submit,
                        icon: const Icon(Icons.send_outlined),
                        label: Text(
                          current?.pending ?? false
                              ? t.listingReviewResubmit
                              : t.listingReviewSubmit,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
