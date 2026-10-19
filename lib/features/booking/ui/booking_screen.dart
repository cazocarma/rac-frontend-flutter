import 'package:flutter/material.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/widgets/design.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.compaId,
    required this.compaName,
    this.rate = 0,
  });
  final String compaId, compaName;
  final double rate;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime date = DateTime.now().add(const Duration(days: 1));
  DateTime? selected;
  int hours = 1;
  bool busy = false, loading = true;
  String? error;
  Map<String, dynamic> availability = {};
  List<DateTime> slots = [];
  String zone = "UTC";
  int requestVersion = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final version = ++requestVersion;
    final requestedDate = date;
    final requestedHours = hours;
    setState(() {
      selected = null;
      slots = [];
      loading = true;
      error = null;
    });
    try {
      final responses = await Future.wait([
        Services.match.availability(widget.compaId),
        Services.match.slots(widget.compaId, requestedDate, requestedHours),
      ]);
      final response = responses[0];
      if (!mounted || version != requestVersion) return;
      setState(() {
        availability = Map<String, dynamic>.from(
          response['availability'] as Map,
        );
        slots = (responses[1]['slots'] as List)
            .map((value) => DateTime.parse(value as String).toLocal())
            .toList();
        zone = responses[1]['zona_horaria'] as String;
        selected = null;
      });
    } catch (_) {
      if (mounted && version == requestVersion) {
        setState(
          () => error =
              'No pudimos consultar la disponibilidad. Vuelve a intentarlo.',
        );
      }
    } finally {
      if (mounted && version == requestVersion) setState(() => loading = false);
    }
  }

  Future<void> submit() async {
    final start = selected;
    if (start == null || !start.isAfter(DateTime.now())) {
      setState(() {
        selected = null;
        error = 'Ese horario ya pasó. Selecciona otro horario disponible.';
      });
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await Services.match.createSession(
        compaId: widget.compaId,
        inicio: start,
        fin: start.add(Duration(hours: hours)),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada. Puedes seguir su estado en Mis reservas.',
          ),
        ),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/match', ModalRoute.withName('/home'));
    } catch (e) {
      final message = e.toString();
      if (mounted) {
        setState(
          () => error = message.contains('colision') || message.contains('409')
              ? 'Ese horario acaba de ocuparse. Elige otro e inténtalo nuevamente.'
              : message.contains('disponibilidad')
              ? 'La disponibilidad cambió. Selecciona otro horario.'
              : 'No pudimos enviar la solicitud. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tu próxima experiencia')),
    body: SingleChildScrollView(
      child: PageContent(
        width: 760,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reserva con ${widget.compaName}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige cuándo y por cuánto tiempo. El compa debe aceptar tu solicitud.',
            ),
            const SizedBox(height: 24),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Fecha y duración',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(dateLabel(date)),
                          onPressed: busy
                              ? null
                              : () async {
                                  final now = DateTime.now();
                                  final value = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(
                                      now.year,
                                      now.month,
                                      now.day,
                                    ),
                                    lastDate: now.add(const Duration(days: 90)),
                                    initialDate: date.isBefore(now)
                                        ? now
                                        : date,
                                  );
                                  if (mounted && value != null) {
                                    setState(() {
                                      date = value;
                                      selected = null;
                                      error = null;
                                    });
                                    load();
                                  }
                                },
                        ),
                        for (final h in [1, 2, 3, 4])
                          ChoiceChip(
                            label: Text('$h ${h == 1 ? 'hora' : 'horas'}'),
                            selected: hours == h,
                            onSelected: busy
                                ? null
                                : (_) {
                                    setState(() {
                                      hours = h;
                                      selected = null;
                                      error = null;
                                    });
                                    load();
                                  },
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '2. Hora de inicio',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Horarios en tu zona local (${DateTime.now().timeZoneName}). Agenda del compa: $zone. Se confirma disponibilidad al enviar.',
                    ),
                    const SizedBox(height: 16),
                    if (loading)
                      const LinearProgressIndicator()
                    else if (slots.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          availability.isEmpty
                              ? 'Este compa aún no publicó horarios. Puedes explorar otros compas.'
                              : 'No hay horarios disponibles para esta fecha y duración. Prueba otro día o una duración menor.',
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final slot in slots)
                            ChoiceChip(
                              label: Text(
                                '${clockLabel(slot)} ${slot.timeZoneName}',
                              ),
                              selected: selected == slot,
                              onSelected: busy
                                  ? null
                                  : (_) => setState(() {
                                      selected = slot;
                                      error = null;
                                    }),
                            ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '3. Revisa tu solicitud',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selected == null
                          ? 'Selecciona un horario para continuar.'
                          : '${dateLabel(selected!)} · ${clockLabel(selected!)} → ${dateLabel(selected!.add(Duration(hours: hours)))} ${clockLabel(selected!.add(Duration(hours: hours)))}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Valor referencial: ${money(widget.rate * hours)} CLP',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No se realizará ningún cobro. Pagos en construcción.',
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: selected == null || busy || loading
                            ? null
                            : submit,
                        icon: Icon(
                          busy
                              ? Icons.hourglass_top
                              : Icons.check_circle_outline,
                        ),
                        label: Text(busy ? 'Enviando…' : 'Solicitar reserva'),
                      ),
                    ),
                    TextButton(
                      onPressed: busy ? null : load,
                      child: const Text('Actualizar disponibilidad'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
