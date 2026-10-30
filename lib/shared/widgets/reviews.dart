import '../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../di/services.dart';
import '../services/json_api.dart';
import '../services/user_api.dart';
import '../../features/compas/data/compa_api.dart';

class BookingReview extends StatefulWidget {
  const BookingReview({
    super.key,
    required this.id,
    required this.canWrite,
    this.api,
  });
  final String id;
  final bool canWrite;
  final UserApi? api;
  @override
  State<BookingReview> createState() => _BookingReviewState();
}

class _BookingReviewState extends State<BookingReview> {
  late Future<Map<String, dynamic>?> data;
  UserApi get api => widget.api ?? Services.user;
  @override
  void initState() {
    super.initState();
    data = api.bookingReview(widget.id);
  }

  void reload() => setState(() {
    data = api.bookingReview(widget.id);
  });

  Future<void> write() async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => ReviewDialog(
        submit: (score, comment) => api.saveReview(widget.id, score, comment),
      ),
    );
    if (mounted && sent == true) reload();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>?>(
    future: data,
    builder: (context, snapshot) {
      final t = AppLocalizations.of(context)!;
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: LinearProgressIndicator(),
        );
      }
      if (snapshot.hasError) {
        return TextButton.icon(
          onPressed: reload,
          icon: const Icon(Icons.refresh),
          label: Text(t.reviewRetryLoad),
        );
      }
      final review = snapshot.data;
      if (review != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.reviewVerified('${review['puntuacion']}'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if ((review['comentario'] as String).isNotEmpty)
                Text(review['comentario'] as String),
            ],
          ),
        );
      }
      if (!widget.canWrite) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: OutlinedButton.icon(
          onPressed: write,
          icon: const Icon(Icons.rate_review_outlined),
          label: Text(t.reviewWrite),
        ),
      );
    },
  );
}

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key, required this.submit});
  final Future<void> Function(int score, String comment) submit;
  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final comment = TextEditingController();
  int score = 0;
  bool busy = false;
  // null: no failure; true: 409 (not reviewable or already reviewed).
  bool? conflict;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (score == 0 || busy) return;
    setState(() {
      busy = true;
      conflict = null;
    });
    try {
      await widget.submit(score, comment.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => conflict = e is ApiException && e.status == 409);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        title: Text(t.reviewDialogTitle),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.reviewDialogIntro),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var n = 1; n <= 5; n++)
                      ChoiceChip(
                        label: Text('$n ★'),
                        tooltip: t.reviewStars(n),
                        selected: score == n,
                        onSelected: busy
                            ? null
                            : (_) => setState(() => score = n),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: comment,
                  enabled: !busy,
                  maxLength: 1000,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: t.reviewComment,
                    helperText: t.reviewCommentHelp,
                  ),
                ),
                if (conflict != null)
                  Text(
                    conflict! ? t.reviewConflict : t.reviewSendFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: Text(t.reviewBack),
          ),
          FilledButton(
            onPressed: score == 0 || busy ? null : send,
            child: Text(busy ? t.reviewSending : t.reviewPublish),
          ),
        ],
      ),
    );
  }
}

class PublicReviews extends StatefulWidget {
  const PublicReviews({super.key, required this.api, required this.id});
  final CompaApi api;
  final String id;
  @override
  State<PublicReviews> createState() => _PublicReviewsState();
}

class _PublicReviewsState extends State<PublicReviews> {
  final items = <Map<String, dynamic>>[];
  int total = 0;
  bool busy = true;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      failed = false;
    });
    try {
      final result = await widget.api.reviews(widget.id, offset: items.length);
      if (!mounted) return;
      setState(() {
        items.addAll((result['items'] as List).cast<Map<String, dynamic>>());
        total = (result['total'] as num).toInt();
      });
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          t.reviewsPublicTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (!busy && !failed && items.isEmpty) Text(t.reviewsPublicEmpty),
        for (final review in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.reviewsPublicItem('${review['puntuacion']}'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if ((review['comentario'] as String).isNotEmpty)
                  Text(review['comentario'] as String),
              ],
            ),
          ),
        if (busy) const LinearProgressIndicator(),
        if (failed)
          TextButton(onPressed: load, child: Text(t.reviewsPublicLoadFailed)),
        if (!busy && !failed && items.length < total)
          TextButton(onPressed: load, child: Text(t.reviewsPublicMore)),
      ],
    );
  }
}
