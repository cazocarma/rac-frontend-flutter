import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rentacompa/shared/config/env.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/features/match/data/match_api.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with SingleTickerProviderStateMixin {
  late final MatchApi api;
  String? userId;
  String? compaIdHint; // en un futuro se obtendrá del perfil
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    api = MatchApi(Env.apiBase);
    _tab = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final at = await Session.accessToken();
    // En esta versión, el userId se pide por input si es necesario; demo
    setState(() {});
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match / Agenda'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Mis sesiones'),
            Tab(text: 'Como Compa'),
            Tab(text: 'Disponibilidad'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _clientSessions(),
          _compaSessions(),
          _availabilityEditor(),
        ],
      ),
    );
  }

  // --- CLIENTE: lista y creación de sesiones ---
  Widget _clientSessions() {
    final clientIdCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: clientIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mi usuario (UUID)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final id = clientIdCtrl.text.trim();
                  if (id.isEmpty) return;
                  final data = await api.listClient(id);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) =>
                        _SessionsDialog(data: data, title: 'Sesiones (cliente)'),
                  );
                },
                child: const Text('Listar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _CreateSessionCard(api: api),
        ],
      ),
    );
  }

  // --- COMPA: lista de sesiones ---
  Widget _compaSessions() {
    final compaCtrl = TextEditingController(text: compaIdHint);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: compaCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Perfil Compa (UUID)'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final id = compaCtrl.text.trim();
                  if (id.isEmpty) return;
                  final data = await api.listCompa(id);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) =>
                        _SessionsDialog(data: data, title: 'Sesiones (compa)'),
                  );
                },
                child: const Text('Listar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DISPONIBILIDAD: ver y editar ---
  Widget _availabilityEditor() {
    final compaCtrl = TextEditingController(text: compaIdHint);
    final jsonCtrl = TextEditingController(
      text: '{\n  "lunes": ["09:00-12:00", "14:00-18:00"]\n}',
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: compaCtrl,
            decoration:
                const InputDecoration(labelText: 'Perfil Compa (UUID)'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: jsonCtrl,
              maxLines: null,
              expands: true,
              decoration:
                  const InputDecoration(labelText: 'Disponibilidad (JSON)'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final id = compaCtrl.text.trim();
                  if (id.isEmpty) return;
                  final res = await api.availability(id);
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Disponibilidad'),
                      content: SingleChildScrollView(
                        child: Text(res.toString()),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Ver'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final id = compaCtrl.text.trim();
                  if (id.isEmpty) return;
                  try {
                    final map = _parseJson(jsonCtrl.text);
                    await api.setAvailability(id, map);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guardado')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _parseJson(String raw) {
    return (const JsonDecoder()).convert(raw) as Map<String, dynamic>;
  }
}

// --- WIDGET: Crear sesión ---
class _CreateSessionCard extends StatefulWidget {
  const _CreateSessionCard({required this.api});

  final MatchApi api;

  @override
  State<_CreateSessionCard> createState() => _CreateSessionCardState();
}

class _CreateSessionCardState extends State<_CreateSessionCard> {
  final _form = GlobalKey<FormState>();
  final _compaCtrl = TextEditingController();
  DateTime? _start;
  DateTime? _end;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear sesión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _compaCtrl,
                decoration:
                    const InputDecoration(labelText: 'Perfil Compa (UUID)'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (dt == null) return;

                        final tm = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                        if (tm == null) return;

                        setState(() => _start = DateTime(
                              dt.year,
                              dt.month,
                              dt.day,
                              tm.hour,
                              tm.minute,
                            ));
                      },
                      child: Text(
                        _start == null
                            ? 'Inicio'
                            : 'Inicio: ${_start!.toLocal()}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final dt = await showDatePicker(
                          context: context,
                          initialDate: _start ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (dt == null) return;

                        final tm = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 10, minute: 0),
                        );
                        if (tm == null) return;

                        setState(() => _end = DateTime(
                              dt.year,
                              dt.month,
                              dt.day,
                              tm.hour,
                              tm.minute,
                            ));
                      },
                      child: Text(
                        _end == null ? 'Fin' : 'Fin: ${_end!.toLocal()}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;

                  if (_start == null || _end == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecciona inicio y fin')),
                    );
                    return;
                  }

                  try {
                    final res = await widget.api.createSession(
                      compaId: _compaCtrl.text.trim(),
                      inicio: _start!,
                      fin: _end!,
                    );

                    if (!mounted) return;

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Sesión creada'),
                        content: Text(res.toString()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Reservar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DIALOG: listado de sesiones ---
class _SessionsDialog extends StatelessWidget {
  const _SessionsDialog({
    required this.data,
    required this.title,
  });

  final Map<String, dynamic> data;
  final String title;

  @override
  Widget build(BuildContext context) {
    final items = (data['items'] as List? ?? const []) as List;

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 480,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final s = items[i] as Map<String, dynamic>;
            return ListTile(
              title: Text('${s['estado']} — ${s['fecha_inicio']}'),
              subtitle: Text(
                'fin: ${s['fecha_fin']} — compa: ${s['compa_id']}',
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
