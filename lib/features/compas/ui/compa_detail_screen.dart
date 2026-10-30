import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/reviews.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/widgets/public_profile.dart';
import '../../booking/ui/booking_screen.dart';
import '../data/compa_api.dart';

class CompaDetailScreen extends StatefulWidget {
  const CompaDetailScreen({super.key, required this.api, required this.id});
  final CompaApi api;
  final String id;
  @override
  State<CompaDetailScreen> createState() => _CompaDetailScreenState();
}

class _CompaDetailScreenState extends State<CompaDetailScreen> {
  late Future<CompaCard> data;
  @override
  void initState() {
    super.initState();
    data = widget.api.getById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.compaDetailTitle)),
      body: FutureBuilder<CompaCard>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyState(
              title: t.compaDetailLoadFailed,
              message: t.compaDetailLoadHelp,
              action: OutlinedButton(
                onPressed: () => setState(() {
                  data = widget.api.getById(widget.id);
                }),
                child: Text(t.compaDetailRetry),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = snapshot.data!;
          return SingleChildScrollView(
            child: PageContent(
              width: 800,
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PublicProfilePresentation(
                        name: c.nombre,
                        biography: c.biografia,
                        interests: c.intereses,
                        photoPath: c.fotoUrl,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        c.ratingPromedio > 0
                            ? t.compaDetailRating(
                                c.ratingPromedio.toStringAsFixed(1),
                                c.cantidadResenas,
                              )
                            : t.compaDetailUnrated,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final skill in c.habilidades)
                            Chip(
                              label: Text(skill),
                              avatar: const Icon(
                                Icons.auto_awesome_outlined,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.compaDetailActivities,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (c.descripcion ?? '').isEmpty
                            ? t.compaDetailNoDescription
                            : c.descripcion!,
                      ),
                      PublicReviews(api: widget.api, id: c.id),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(
                        t.compaDetailRate(money(c.tarifaHora)),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(t.compaDetailBookingHelp),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(
                                compaId: c.id,
                                compaName: c.nombre,
                                rate: c.tarifaHora,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(t.compaDetailBook),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
