import 'package:flutter/material.dart';
import '../di/services.dart';
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

  Future<void> write() async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => ReviewDialog(
        submit: (score, comment) => api.saveReview(widget.id, score, comment),
      ),
    );
    if (mounted && sent == true) {
      setState(() => data = api.bookingReview(widget.id));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>?>(
    future: data,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: LinearProgressIndicator(),
        );
      }
      if (snapshot.hasError) {
        return TextButton.icon(
          onPressed: () => setState(() => data = api.bookingReview(widget.id)),
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar carga de reseña'),
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
                '★ ${review['puntuacion']}/5 · Reseña verificada',
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
          label: const Text('Dejar una reseña'),
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
  String? error;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (score == 0 || busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.submit(score, comment.text.trim());
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'No pudimos confirmar el envío. Reintenta o vuelve a la reserva para comprobar si se guardó.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('¿Cómo estuvo la experiencia?'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu reseña será pública y quedará vinculada a una reserva verificada. Se envía una sola vez y no se puede editar.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var n = 1; n <= 5; n++)
                    ChoiceChip(
                      label: Text('$n ★'),
                      tooltip: '$n de 5 estrellas',
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
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  helperText:
                      'Evita incluir datos de contacto o información privada.',
                ),
              ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
        FilledButton(
          onPressed: score == 0 || busy ? null : send,
          child: Text(busy ? 'Enviando…' : 'Publicar reseña'),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 28),
      const Divider(),
      const SizedBox(height: 16),
      Text(
        'Reseñas de reservas verificadas',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      if (!busy && !failed && items.isEmpty)
        const Text(
          'Todavía no hay reseñas. Solo pueden valorar quienes completaron una reserva.',
        ),
      for (final review in items)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '★ ${review['puntuacion']}/5 · Reserva verificada',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if ((review['comentario'] as String).isNotEmpty)
                Text(review['comentario'] as String),
            ],
          ),
        ),
      if (busy) const LinearProgressIndicator(),
      if (failed)
        TextButton(
          onPressed: load,
          child: const Text('No pudimos cargar las reseñas. Reintentar'),
        ),
      if (!busy && !failed && items.length < total)
        TextButton(onPressed: load, child: const Text('Ver más reseñas')),
    ],
  );
}
