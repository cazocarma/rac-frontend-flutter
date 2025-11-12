import 'package:flutter/material.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/widgets/modal_shell.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  String _role = 'cliente';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = await Session.role();
    if (!mounted) return;
    setState(() => _role = r);
  }

  @override
  Widget build(BuildContext context) {
    // Sin drawer aquí: pantalla dedicada.
    return ModalShell(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Match / Agenda'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _role == 'compa'
              ? const _CompaAgendaView()
              : const _ClienteAgendaView(),
        ),
      ),
    );
  }
}

class _ClienteAgendaView extends StatelessWidget {
  const _ClienteAgendaView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tus reservas', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Aún no hay reservas. Busca un compa y solicita una.'),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          icon: const Icon(Icons.search),
          label: const Text('Buscar compas'),
        ),
      ],
    );
  }
}

class _CompaAgendaView extends StatelessWidget {
  const _CompaAgendaView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Solicitudes recibidas', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: 0, // stub aún sin backend
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              return ListTile(
                title: const Text('Solicitud demo'),
                subtitle: const Text('Cliente demo • Hoy 18:00'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Rechazar'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Aceptar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
