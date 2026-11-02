import '../../../shared/services/json_api.dart';
import '../../../shared/services/user_api.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/di/services.dart';
import '../../../shared/services/session.dart';
import '../../compas/data/compa_api.dart';
import '../../compas/ui/activity_labels.dart';

class BecomeCompaScreen extends StatefulWidget {
  const BecomeCompaScreen({super.key, this.api, this.catalogApi});
  final UserApi? api;
  final CompaApi? catalogApi;
  @override
  State<BecomeCompaScreen> createState() => _BecomeCompaScreenState();
}

class _BecomeCompaScreenState extends State<BecomeCompaScreen> {
  UserApi get api => widget.api ?? Services.user;
  AppLocalizations get t => AppLocalizations.of(context)!;
  final form = GlobalKey<FormState>();
  final description = TextEditingController();
  final rate = TextEditingController();
  // Closed catalog: only these activities can be offered (P06).
  ActivityCatalog? catalog;
  final selected = <String>{};
  final notes = <String, String>{};
  bool activitiesInvalid = false;
  static const days = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];
  Map<String, String> get dayLabels => {
    'lunes': t.compaMonday,
    'martes': t.compaTuesday,
    'miercoles': t.compaWednesday,
    'jueves': t.compaThursday,
    'viernes': t.compaFriday,
    'sabado': t.compaSaturday,
    'domingo': t.compaSunday,
  };
  final windows = {for (final day in days) day: TextEditingController()};
  late Future<void> initial = load();
  String zone = 'America/Santiago';
  static const zones = [
    'America/Santiago',
    'America/Punta_Arenas',
    'Pacific/Easter',
    'America/Argentina/Buenos_Aires',
    'America/Lima',
    'America/Bogota',
    'America/Mexico_City',
    'Europe/Madrid',
    'UTC',
  ];
  bool busy = false;
  bool published = false;
  bool needsSession = false;
  String? error;
  bool identityRequired = false;
  String? success;

  Future<void> load() async {
    catalog = await (widget.catalogApi ?? Services.compas).listActivities();
    await api.me();
    final data = await api.ownCompa();
    if (!mounted || data == null) return;
    zone = data['zona_horaria'] as String? ?? 'UTC';
    final profile = data['profile'] as Map;
    description.text = profile['descripcion'] as String? ?? '';
    rate.text = '${profile['tarifa_hora']}';
    selected.clear();
    for (final raw in profile['actividades'] as List? ?? const []) {
      final activity = CompaActivity.fromJson(
        Map<String, dynamic>.from(raw as Map),
      );
      selected.add(activity.slug);
      // Existing notes are kept when the selection is saved again.
      if (activity.note != null) notes[activity.slug] = activity.note!;
    }
    final availability = data['availability'] as Map;
    for (final day in days) {
      windows[day]!.text = (availability[day] as List? ?? []).join(', ');
    }
    published = true;
    final role = await Session.role();
    needsSession = role != 'compa' && role != 'admin';
  }

  @override
  void dispose() {
    description.dispose();
    rate.dispose();
    for (final controller in windows.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    final maximum = catalog?.maxPerCompa ?? 0;
    setState(
      () => activitiesInvalid = selected.isEmpty || selected.length > maximum,
    );
    if (busy || !form.currentState!.validate() || activitiesInvalid) return;
    final availability = <String, List<String>>{};
    for (final entry in windows.entries) {
      final values = entry.value.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (values.isNotEmpty) availability[entry.key] = values;
    }
    if (availability.isEmpty) {
      setState(() => error = t.compaAddAvailability);
      return;
    }
    setState(() {
      busy = true;
      error = null;
      identityRequired = false;
      success = null;
    });
    bool saved = false;
    try {
      await api.saveCompa({
        'descripcion': description.text.trim(),
        'tarifa_hora': double.parse(rate.text.trim().replaceAll(',', '.')),
        'actividades': [
          for (final slug in selected)
            {'slug': slug, if (notes[slug] != null) 'nota': notes[slug]},
        ],
        'availability': availability,
        'zona_horaria': zone,
      });
      saved = true;
      await Session.auth.refresh();
      final me = await api.me();
      if (me['role'] != 'compa' && me['role'] != 'admin') {
        throw StateError('La sesión aún no refleja tu rol compa');
      }
      if (mounted) {
        setState(() {
          published = true;
          needsSession = false;
          success = t.compaPublished;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (saved) {
            published = true;
            needsSession = true;
            error = t.compaSessionPending;
          } else if (e is ApiException &&
              e.code == 'public_contact_not_allowed') {
            error = t.publicContactNotAllowed;
          } else if (e is ApiException &&
              e.status == 428 &&
              e.code == 'IDENTITY_VERIFICATION_REQUIRED') {
            identityRequired = true;
            error = t.identityRequiredCompa;
          } else if (e is ApiException && e.status == 428) {
            error = AppLocalizations.of(context)!.compaPrerequisitesPending;
          } else {
            error = t.compaSaveFailed;
          }
        });
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? validateWindows(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final parts = input.split(',').map((s) => s.trim()).toList()..sort();
    if (parts.length > 3) return t.compaWindowsLimit;
    String? previous;
    for (final part in parts) {
      if (!RegExp(
        r'^(?:[01]\d|2[0-3]):[0-5]\d-(?:[01]\d|2[0-3]):[0-5]\d$',
      ).hasMatch(part)) {
        return t.compaWindowFormat;
      }
      final times = part.split('-');
      if (times[0].compareTo(times[1]) >= 0 ||
          (previous != null && times[0].compareTo(previous) < 0)) {
        return t.compaWindowsOverlap;
      }
      previous = times[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(t.compaTitle)),
    body: FutureBuilder<void>(
      future: initial,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            title: t.compaLoadFailed,
            message: t.compaConnectionRetry,
            action: OutlinedButton(
              onPressed: () => setState(() => initial = load()),
              child: Text(t.compaRetry),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: PageContent(
            width: 760,
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    published ? t.compaProfileHeading : t.compaStartHeading,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(t.compaPublishingInfo),
                  OutlinedButton.icon(
                    onPressed: busy
                        ? null
                        : () => Navigator.of(context).pushNamed('/compa-rules'),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(AppLocalizations.of(context)!.compaRulesReview),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: description,
                    enabled: !busy,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 1500,
                    decoration: InputDecoration(
                      labelText: t.compaAboutLabel,
                      errorMaxLines: 3,
                      hintText: t.compaAboutHint,
                    ),
                    validator: (v) => (v?.trim().runes.length ?? 0) < 20
                        ? t.compaAboutShort
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: rate,
                    enabled: !busy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: t.compaRateLabel,
                      helperMaxLines: 3,
                      errorMaxLines: 3,
                      helperText: t.compaRateHelp,
                    ),
                    validator: (v) {
                      final amount = double.tryParse(
                        (v ?? '').trim().replaceAll(',', '.'),
                      );
                      return amount == null ||
                              !amount.isFinite ||
                              amount < 0 ||
                              amount > 99999999.99 ||
                              (amount * 100 - (amount * 100).round()).abs() >
                                  0.00001
                          ? t.compaRateInvalid
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.compaActivitiesLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(t.compaActivitiesHelp(catalog?.maxPerCompa ?? 0)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final activity
                          in catalog?.items ?? <CompaActivity>[])
                        FilterChip(
                          label: Text(activityName(t, activity.nameKey)),
                          tooltip: activityDescription(t, activity.nameKey),
                          selected: selected.contains(activity.slug),
                          onSelected: busy
                              ? null
                              : (value) => setState(() {
                                  if (value) {
                                    selected.add(activity.slug);
                                  } else {
                                    selected.remove(activity.slug);
                                  }
                                  activitiesInvalid = false;
                                }),
                        ),
                    ],
                  ),
                  if (activitiesInvalid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        t.compaActivitiesInvalid(catalog?.maxPerCompa ?? 0),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    t.compaAvailabilityHeading,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(t.compaAvailabilityHelp),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: zone,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: t.compaTimeZone),
                    items: {zone, ...zones}
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: busy
                        ? null
                        : (value) {
                            if (value != null) setState(() => zone = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  for (final day in days)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: windows[day],
                        enabled: !busy,
                        maxLength: 40,
                        decoration: InputDecoration(
                          labelText: dayLabels[day],
                          errorMaxLines: 3,
                          hintText: '18:00-22:00',
                          counterText: '',
                        ),
                        validator: validateWindows,
                      ),
                    ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (identityRequired && error == t.identityRequiredCompa)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamed('/identity', arguments: 'compa_onboarding'),
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(t.identityGo),
                      ),
                    ),
                  if (success != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(success!),
                      ),
                    ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: busy ? null : save,
                        icon: Icon(
                          busy
                              ? Icons.hourglass_top
                              : Icons.check_circle_outline,
                        ),
                        label: Text(
                          busy
                              ? t.compaSaving
                              : published
                              ? t.compaSaveChanges
                              : t.compaActivateProfile,
                        ),
                      ),
                      if (needsSession)
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () async {
                                  try {
                                    await Session.auth.login();
                                  } catch (_) {
                                    if (mounted) {
                                      setState(
                                        () => error = t.compaLoginFailed,
                                      );
                                    }
                                  }
                                },
                          child: Text(t.compaRefreshSession),
                        ),
                      if (published && !needsSession)
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/match'),
                          child: Text(t.compaOpenAgenda),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
