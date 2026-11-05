import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'editorial_api.dart';
import 'editorial_decision.dart';
import 'editorial_journal.dart';
import 'listing_photo_preview.dart';

/// P08 A4. Queue and detail come from the owner through the admin proxy;
/// signals only prioritize review. Approval sends one frozen command and an
/// uncertain result is retried with the same event, never a new one.
class ListingReviewConsole extends StatefulWidget {
  const ListingReviewConsole({
    super.key,
    required this.api,
    required this.permissions,
    this.journal,
  });
  final EditorialApi api;
  final Set<String> permissions;
  final EditorialJournal? journal;
  @override
  State<ListingReviewConsole> createState() => _ListingReviewConsoleState();
}

class _ListingReviewConsoleState extends State<ListingReviewConsole> {
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? detail;
  late final journal =
      widget.journal ?? EditorialJournal(managerId: 'rac-listing-recovery-v1');
  List<EditorialDecisionAttempt> pending = [];
  EditorialDecisionAttempt? frozen;
  bool recoveryFailed = false;
  bool needsAuthentication = false;
  late final subject = widget.api.session.claims['sub'] as String? ?? '';
  late final issuer = widget.api.session.claims['iss'] as String? ?? '';
  late final origin = widget.api.origin.origin;
  bool get sameAccount =>
      widget.api.session.claims['sub'] == subject &&
      widget.api.session.claims['iss'] == issuer &&
      widget.api.origin.origin == origin;
  bool busy = true, loadFailed = false, uncertain = false, approved = false;
  String? code;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      loadFailed = false;
    });
    try {
      if (subject.isEmpty || issuer.isEmpty) {
        throw StateError('Staff session required');
      }
      final commands = await journal.pending(
        subject: subject,
        issuer: issuer,
        origin: origin,
      );
      if (commands.any((command) => !command.isListing)) {
        throw StateError('Unexpected recovery operation');
      }
      if (!mounted || !sameAccount) return;
      pending = [
        for (final command in commands)
          EditorialDecisionAttempt.durable(
            command,
            journal: journal,
            subject: subject,
            issuer: issuer,
            origin: origin,
            recovered: true,
          ),
      ];
      recoveryFailed = false;
    } catch (_) {
      recoveryFailed = true;
    }
    try {
      final result = await widget.api.listingRead(
        '/api/admin/staff/listings/queue?limit=20',
      );
      if (!mounted || !sameAccount) return;
      setState(() {
        items = [
          for (final item in result['items'] as List)
            Map<String, dynamic>.from(item as Map),
        ];
      });
    } catch (_) {
      if (mounted) setState(() => loadFailed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> open(String id) async {
    setState(() {
      busy = true;
      code = null;
      approved = false;
      uncertain = false;
      frozen = null;
      for (final attempt in pending) {
        if (attempt.command.listingRevision == id) frozen = attempt;
      }
      uncertain = frozen?.uncertain ?? false;
    });
    try {
      final result = await widget.api.listingRead(
        '/api/admin/staff/listings/revisions/$id',
      );
      if (mounted && sameAccount) setState(() => detail = result);
    } on EditorialFailure catch (error) {
      if (mounted) setState(() => code = error.code ?? 'failed');
    } catch (_) {
      if (mounted) setState(() => code = 'failed');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> approve([EditorialDecisionAttempt? recovered]) async {
    if (!sameAccount ||
        recoveryFailed ||
        !widget.permissions.contains('listings.review')) {
      return;
    }
    final current = detail;
    final command =
        recovered ??
        frozen ??
        EditorialDecisionAttempt.durable(
          EditorialCommand('listings/revisions/${current!['id']}/approval', {
            'event_id': newEditorialReference(),
            'expected_version': current['listing_version'],
            'sha256': current['sha256'],
          }),
          journal: journal,
          subject: subject,
          issuer: issuer,
          origin: origin,
        );
    setState(() {
      busy = true;
      frozen = command;
      code = null;
      uncertain = false;
    });
    try {
      await command.submit(widget.api);
      if (!mounted || !sameAccount) return;
      setState(() {
        approved = true;
        needsAuthentication = false;
        frozen = null;
        detail = null;
      });
      await load();
    } on EditorialFailure catch (error) {
      if (!command.uncertain && !error.authenticationRequired) {
        try {
          await journal.resolve(
            command: command.command,
            subject: subject,
            issuer: issuer,
            origin: origin,
          );
        } catch (_) {
          command.uncertain = true;
        }
      }
      if (!mounted || !sameAccount) return;
      setState(() {
        uncertain = command.uncertain;
        needsAuthentication = error.authenticationRequired;
        if (!uncertain && !needsAuthentication) frozen = null;
        code = error.code ?? (error.uncertain ? null : 'failed');
      });
    } catch (_) {
      if (mounted && sameAccount) {
        setState(() {
          uncertain = command.uncertain;
          recoveryFailed = !command.uncertain;
          code = 'failed';
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? message(AppLocalizations t) => switch (code) {
    null => null,
    'listing_self_review' => t.staffListingSelf,
    'listing_review_conflict' => t.staffListingConflict,
    'listing_revision_not_found' => t.staffListingNotFound,
    'listing_owner_prerequisites_required' => t.staffListingPrerequisites,
    'listing_owner_restricted' => t.staffListingRestricted,
    'listing_activity_unavailable' => t.staffListingActivity,
    'listing_photo_unapproved' => t.staffListingPhoto,
    'listing_policy_changed' => t.staffListingPolicy,
    'listing_not_publishable' => t.staffListingNotPublishable,
    _ => t.staffListingFailed,
  };

  int signalCount(Map<String, dynamic> revision) {
    var count = 0;
    final fields = (revision['assessment'] as Map?)?['fields'] as List? ?? [];
    for (final field in fields) {
      count += ((field as Map)['result'] as Map?)?['signals'] is List
          ? ((field['result'] as Map)['signals'] as List).length
          : 0;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final error = message(t);
    final current = detail;
    if (!sameAccount) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.staffListingTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: t.staffListingRefresh,
                  onPressed: busy ? null : load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Text(t.staffListingSignalsNote),
            const SizedBox(height: 12),
            if (busy) const LinearProgressIndicator(),
            if (recoveryFailed)
              Text(
                t.staffListingLoadFailed,
                style: TextStyle(color: colors.error),
              ),
            if (needsAuthentication)
              TextButton(
                onPressed: busy
                    ? null
                    : () async {
                        try {
                          await widget.api.session.login();
                        } catch (_) {
                          return;
                        }
                        if (mounted && sameAccount) {
                          setState(() => needsAuthentication = false);
                          await load();
                        }
                      },
                child: Text(t.staffStepUpRequired),
              ),
            if (current == null &&
                widget.permissions.contains('listings.review'))
              for (final attempt in pending)
                ListTile(
                  title: Text(t.staffListingUncertain),
                  subtitle: Text(attempt.command.listingRevision ?? ''),
                  trailing: TextButton(
                    onPressed: busy || recoveryFailed
                        ? null
                        : () => approve(attempt),
                    child: Text(t.staffListingRetry),
                  ),
                ),
            if (approved)
              Semantics(liveRegion: true, child: Text(t.staffListingApproved)),
            if (uncertain)
              Text(
                t.staffListingUncertain,
                style: TextStyle(color: colors.error),
              ),
            if (error != null)
              Text(error, style: TextStyle(color: colors.error)),
            if (loadFailed)
              Text(
                t.staffListingLoadFailed,
                style: TextStyle(color: colors.error),
              )
            else if (current == null) ...[
              if (!busy && items.isEmpty) Text(t.staffListingEmpty),
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fact_check_outlined),
                  title: Text(t.staffListingRisk(item['risk_score'] as int)),
                  subtitle: Text(
                    t.staffListingSubmitted(item['submitted_at'] as String),
                  ),
                  onTap: busy ? null : () => open(item['id'] as String),
                ),
            ] else ...[
              _Detail(revision: current, signals: signalCount(current)),
              if (current['is_pending'] == true &&
                  ((current['payload'] as Map?)?['photo_version'] as String? ??
                          '')
                      .isNotEmpty)
                ListingPhotoPreview(
                  key: ValueKey(current['id']),
                  api: widget.api,
                  revision: current['id'] as String,
                ),
              const SizedBox(height: 12),
              if (current['is_self'] == true)
                Text(t.staffListingSelf)
              else if (((current['payload'] as Map?)?['photo_version']
                          as String? ??
                      '')
                  .isNotEmpty)
                Text(t.staffListingPhoto)
              else if (current['is_pending'] == true &&
                  widget.permissions.contains('listings.review'))
                FilledButton.icon(
                  onPressed: busy || recoveryFailed ? null : () => approve(),
                  icon: const Icon(Icons.check),
                  label: Text(
                    uncertain ? t.staffListingRetry : t.staffListingApprove,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                t.staffListingNegativePending,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: busy || uncertain
                    ? null
                    : () => setState(() {
                        detail = null;
                        code = null;
                      }),
                child: Text(t.staffListingBack),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.revision, required this.signals});
  final Map<String, dynamic> revision;
  final int signals;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final payload = Map<String, dynamic>.from(revision['payload'] as Map);
    final activities = [
      for (final activity in payload['activities'] as List? ?? const [])
        (activity as Map)['slug'] as String,
    ].join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          payload['display_name'] as String? ?? '',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(payload['description'] as String? ?? ''),
        if ((payload['biography'] as String? ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(payload['biography'] as String),
        ],
        const SizedBox(height: 8),
        Text(t.staffListingActivities(activities)),
        Text(t.staffListingPrice('${payload['price_clp_per_hour']}')),
        const SizedBox(height: 8),
        Text(
          signals == 0
              ? t.staffListingNoSignals
              : t.staffListingSignals(signals),
        ),
      ],
    );
  }
}
