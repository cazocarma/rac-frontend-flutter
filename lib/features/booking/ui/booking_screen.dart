import '../../../l10n/generated/app_localizations.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rentacompa/features/match/data/match_api.dart';
import 'package:rentacompa/shared/di/services.dart';
import 'package:rentacompa/shared/widgets/design.dart';

enum _BookingFailure { load, past, taken, availability, submit }

/// MatchApi reports `HTTP <status>: <body>`; only exact codes change guidance.
_BookingFailure _submitFailure(Object error) {
  final match = RegExp(
    r'HTTP (\d{3}): (.*)$',
    dotAll: true,
  ).firstMatch('$error');
  if (match == null) return _BookingFailure.submit;
  if (match[1] == '409') return _BookingFailure.taken;
  Object? code;
  try {
    final body = jsonDecode(match[2]!);
    if (body is Map) code = body['error'];
  } on FormatException {
    return _BookingFailure.submit;
  }
  return switch (code) {
    'colision_horaria' => _BookingFailure.taken,
    'fuera_de_disponibilidad' ||
    'compa_sin_disponibilidad' => _BookingFailure.availability,
    _ => _BookingFailure.submit,
  };
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.compaId,
    required this.compaName,
    this.rate = 0,
    this.api,
  });
  final String compaId, compaName;
  final double rate;
  final MatchApi? api;
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime date = DateTime.now().add(const Duration(days: 1));
  DateTime? selected;
  int hours = 1;
  bool busy = false, loading = true;
  _BookingFailure? error;
  Map<String, dynamic> availability = {};
  List<DateTime> slots = [];
  String zone = "UTC";
  int requestVersion = 0;
  MatchApi get api => widget.api ?? Services.match;
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
        api.availability(widget.compaId),
        api.slots(widget.compaId, requestedDate, requestedHours),
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
        setState(() => error = _BookingFailure.load);
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
        error = _BookingFailure.past;
      });
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await api.createSession(
        compaId: widget.compaId,
        inicio: start,
        fin: start.add(Duration(hours: hours)),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.bookingSent)),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/match', ModalRoute.withName('/home'));
    } catch (e) {
      if (mounted) setState(() => error = _submitFailure(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String failureText(AppLocalizations t, _BookingFailure failure) =>
      switch (failure) {
        _BookingFailure.load => t.bookingLoadFailed,
        _BookingFailure.past => t.bookingSlotPast,
        _BookingFailure.taken => t.bookingSlotTaken,
        _BookingFailure.availability => t.bookingAvailabilityChanged,
        _BookingFailure.submit => t.bookingSubmitFailed,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.bookingTitle)),
      body: SingleChildScrollView(
        child: PageContent(
          width: 760,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.bookingWith(widget.compaName),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(t.bookingIntro),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.bookingStepDate,
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
                                      lastDate: now.add(
                                        const Duration(days: 90),
                                      ),
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
                              label: Text(t.bookingHours(h)),
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
                        t.bookingStepTime,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(t.bookingZones(DateTime.now().timeZoneName, zone)),
                      const SizedBox(height: 16),
                      if (loading)
                        const LinearProgressIndicator()
                      else if (slots.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            availability.isEmpty
                                ? t.bookingNoSchedule
                                : t.bookingNoSlots,
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
                        t.bookingStepReview,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selected == null
                            ? t.bookingSelectSlot
                            : '${dateLabel(selected!)} · ${clockLabel(selected!)} → ${dateLabel(selected!.add(Duration(hours: hours)))} ${clockLabel(selected!.add(Duration(hours: hours)))}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.bookingReferenceValue(money(widget.rate * hours)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(t.bookingNoCharge),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            failureText(t, error!),
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
                          label: Text(
                            busy ? t.bookingSending : t.bookingSubmit,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: busy ? null : load,
                        child: Text(t.bookingRefresh),
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
}
