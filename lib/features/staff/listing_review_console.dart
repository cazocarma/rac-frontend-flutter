import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'editorial_api.dart';
import 'editorial_decision.dart';

/// P08 A4. Queue and detail come from the owner through the admin proxy;
/// signals only prioritize review. Approval sends one frozen command and an
/// uncertain result is retried with the same event, never a new one.
class ListingReviewConsole extends StatefulWidget {
  const ListingReviewConsole({
    super.key,
    required this.api,
    required this.permissions,
  });
  final EditorialApi api;
  final Set<String> permissions;
  @override
  State<ListingReviewConsole> createState() => _ListingReviewConsoleState();
}

class _ListingReviewConsoleState extends State<ListingReviewConsole> {
  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? detail;
  ({String revision, String body})? frozen;
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
      final result = await widget.api.listingRead(
        '/api/admin/staff/listings/queue?limit=20',
      );
      if (!mounted) return;
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
    });
    try {
      final result = await widget.api.listingRead(
        '/api/admin/staff/listings/revisions/$id',
      );
      if (mounted) setState(() => detail = result);
    } on EditorialFailure catch (error) {
      if (mounted) setState(() => code = error.code ?? 'failed');
    } catch (_) {
      if (mounted) setState(() => code = 'failed');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> approve() async {
    final current = detail!;
    final revision = current['id'] as String;
    // Reuse the frozen command for this revision after an uncertain result.
    final command = frozen?.revision == revision
        ? frozen!
        : (
            revision: revision,
            body: jsonEncode({
              'event_id': newEditorialReference(),
              'expected_version': current['listing_version'],
              'sha256': current['sha256'],
            }),
          );
    setState(() {
      busy = true;
      frozen = command;
      code = null;
      uncertain = false;
    });
    try {
      await widget.api.listingWrite(
        '/api/admin/staff/listings/revisions/$revision/approval',
        command.body,
      );
      if (!mounted) return;
      setState(() {
        approved = true;
        frozen = null;
        detail = null;
      });
      await load();
    } on EditorialFailure catch (error) {
      if (!mounted) return;
      setState(() {
        uncertain = error.uncertain;
        if (!error.uncertain) frozen = null;
        code = error.code ?? (error.uncertain ? null : 'failed');
      });
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
                  onPressed: busy ? null : approve,
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
