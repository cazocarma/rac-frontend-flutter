import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/design.dart';
import '../../../shared/di/services.dart';
import '../../../shared/services/session.dart';

class BecomeCompaScreen extends StatefulWidget {
  const BecomeCompaScreen({super.key});
  @override
  State<BecomeCompaScreen> createState() => _BecomeCompaScreenState();
}

class _BecomeCompaScreenState extends State<BecomeCompaScreen> {
  final form = GlobalKey<FormState>();
  final description = TextEditingController();
  final rate = TextEditingController();
  final skills = TextEditingController();
  static const days = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miércoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };
  final windows = {for (final day in days.keys) day: TextEditingController()};
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
  String? success;

  Future<void> load() async {
    await Services.user.me();
    final data = await Services.user.ownCompa();
    if (!mounted || data == null) return;
    zone = data['zona_horaria'] as String? ?? 'UTC';
    final profile = data['profile'] as Map;
    description.text = profile['descripcion'] as String? ?? '';
    rate.text = '${profile['tarifa_hora']}';
    skills.text = (profile['habilidades'] as List).join(', ');
    final availability = data['availability'] as Map;
    for (final day in days.keys) {
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
    skills.dispose();
    for (final controller in windows.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
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
      setState(
        () => error = 'Agrega al menos un horario para recibir reservas.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
      success = null;
    });
    bool saved = false;
    try {
      await Services.user.saveCompa({
        'descripcion': description.text.trim(),
        'tarifa_hora': double.parse(rate.text.trim().replaceAll(',', '.')),
        'habilidades': skills.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        'availability': availability,
        'zona_horaria': zone,
      });
      saved = true;
      await Session.auth.refresh();
      final me = await Services.user.me();
      if (me['role'] != 'compa' && me['role'] != 'admin') {
        throw StateError('La sesión aún no refleja tu rol compa');
      }
      if (mounted) {
        setState(() {
          published = true;
          needsSession = false;
          success =
              '¡Tu perfil compa está publicado! Ya puedes recibir solicitudes. Tu plan gratuito incluye 3 reservas confirmadas por semana.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (saved) {
            published = true;
            needsSession = true;
            error =
                'Tu perfil se guardó, pero no pudimos actualizar los permisos de tu sesión. Pulsa Actualizar sesión para continuar.';
          } else {
            error =
                'No pudimos guardar tu perfil. Revisa tu conexión e inténtalo nuevamente. Tus cambios anteriores se conservan.';
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
    if (parts.length > 3) return 'Hasta 3 franjas por día.';
    String? previous;
    for (final part in parts) {
      if (!RegExp(
        r'^(?:[01]\d|2[0-3]):[0-5]\d-(?:[01]\d|2[0-3]):[0-5]\d$',
      ).hasMatch(part)) {
        return 'Usa HH:mm-HH:mm, por ejemplo 18:00-22:00.';
      }
      final times = part.split('-');
      if (times[0].compareTo(times[1]) >= 0 ||
          (previous != null && times[0].compareTo(previous) < 0)) {
        return 'Revisa el orden y evita horarios superpuestos.';
      }
      previous = times[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sé Compa')),
    body: FutureBuilder<void>(
      future: initial,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return EmptyState(
            title: 'No pudimos cargar tu perfil',
            message: 'Revisa tu conexión e inténtalo nuevamente.',
            action: OutlinedButton(
              onPressed: () => setState(() => initial = load()),
              child: const Text('Reintentar'),
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
                    published
                        ? 'Tu perfil como compa'
                        : 'Comparte lo que te gusta hacer',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Publicar es gratis, sin postulación ni aprobación. Recibe solicitudes y confirma hasta 3 reservas por semana. Para aceptar más necesitarás una suscripción.',
                  ),
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
                    decoration: const InputDecoration(
                      labelText: 'Cuéntanos sobre ti',
                      errorMaxLines: 3,
                      hintText:
                          'Qué actividades ofreces y cómo será compartir contigo',
                    ),
                    validator: (v) => (v?.trim().runes.length ?? 0) < 20
                        ? 'Cuéntanos un poco más: al menos 20 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: rate,
                    enabled: !busy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tarifa por hora (CLP)',
                      helperMaxLines: 3,
                      errorMaxLines: 3,
                      helperText:
                          'Valor referencial. Los cobros están en construcción.',
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
                          ? 'Ingresa un monto válido, con hasta 2 decimales.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: skills,
                    enabled: !busy,
                    maxLength: 350,
                    decoration: const InputDecoration(
                      labelText: 'Habilidades',
                      helperMaxLines: 3,
                      errorMaxLines: 3,
                      hintText: 'asado, cine, running',
                      helperText: 'Separa con comas. Entre 1 y 8 habilidades.',
                    ),
                    validator: (v) {
                      final values = (v ?? '')
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList();
                      return values.isEmpty ||
                              values.length > 8 ||
                              values.any(
                                (s) =>
                                    s.runes.length < 2 ||
                                    s.runes.length > 40 ||
                                    s.contains(RegExp(r'[\r\n\t]')),
                              )
                          ? 'Agrega de 1 a 8 habilidades, de 2 a 40 caracteres cada una.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu disponibilidad semanal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Escribe las horas de tu zona. Deja vacío un día si no estás disponible. Puedes agregar hasta 3 franjas separadas por comas; por ejemplo 15:00-18:00, 20:00-23:00. Las reservas existentes mantienen su fecha y hora.',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: zone,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Zona horaria',
                    ),
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
                  for (final day in days.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: windows[day.key],
                        enabled: !busy,
                        maxLength: 40,
                        decoration: InputDecoration(
                          labelText: day.value,
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
                              ? 'Guardando…'
                              : published
                              ? 'Guardar cambios'
                              : 'Activar mi perfil gratis',
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
                                        () => error =
                                            'No pudimos abrir el acceso. Inténtalo otra vez.',
                                      );
                                    }
                                  }
                                },
                          child: const Text('Actualizar sesión'),
                        ),
                      if (published && !needsSession)
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/match'),
                          child: const Text('Ir a mi agenda'),
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
