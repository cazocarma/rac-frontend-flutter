import 'package:flutter/material.dart';
import 'package:rentacompa/shared/services/session.dart';
import 'package:rentacompa/shared/widgets/modal_shell.dart';

class BookingScreen extends StatefulWidget {
  final String compaId;
  final String compaName;

  const BookingScreen({
    super.key,
    required this.compaId,
    required this.compaName,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _date;
  TimeOfDay? _time;
  int _hours = 1;
  String _role = 'cliente';
  bool _loadingRole = true;
  bool _submitting = false;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final value = await Session.role();
    if (!mounted) return;
    setState(() {
      _role = value;
      _loadingRole = false;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      initialDate: _date ?? now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (_date == null || _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fecha y hora')),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solicitud enviada por $_hours h')),
    );
    Navigator.of(context).pushReplacementNamed('/match');
  }

  DateTime? get _endDateTime {
    if (_date == null || _time == null) return null;
    final start = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    return start.add(Duration(hours: _hours));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const ModalShell(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final isCompa = _role == 'compa';
    return ModalShell(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            isCompa ? 'Administrar citas' : 'Reservar con ${widget.compaName}',
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: isCompa
              ? _CompaAgendaAdmin(compaName: widget.compaName)
              : _buildClientBooking(context),
        ),
      ),
    );
  }

  Widget _buildClientBooking(BuildContext context) {
    final end = _endDateTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Define fecha, hora y duración de la experiencia.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event),
                label: Text(
                  _date == null
                      ? 'Fecha'
                      : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTime,
                icon: const Icon(Icons.schedule),
                label: Text(
                  _time == null
                      ? 'Hora de inicio'
                      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer),
              const SizedBox(width: 8),
              const Text('Horas contratadas'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _hours > 1 ? () => setState(() => _hours--) : null,
              ),
              Text(
                _hours.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _hours++),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (end != null)
          Text(
            'Termina: ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')} del ${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 16),
        TextField(
          controller: _notesCtrl,
          decoration: const InputDecoration(
            labelText: 'Notas (opcional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar solicitud'),
          ),
        ),
      ],
    );
  }
}

class _CompaAgendaAdmin extends StatelessWidget {
  const _CompaAgendaAdmin({required this.compaName});
  final String compaName;

  @override
  Widget build(BuildContext context) {
    final pending = [
      const _AgendaItem('Cliente Demo', 'Hoy 18:00', '3 h • Karaoke'),
      const _AgendaItem('Valentina', 'Mañana 12:30', '2 h • City tour'),
    ];
    final confirmed = [
      const _AgendaItem('Pedro', '14 Dic 10:00', '4 h • Road trip'),
    ];
    return ListView(
      children: [
        Text(
          'Hola $compaName, aquí están tus solicitudes.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text('Solicitudes pendientes',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ...pending.map((item) => _PendingCard(item: item)),
        const SizedBox(height: 16),
        Text('Próximas confirmadas',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ...confirmed.map(
          (item) => Card(
            child: ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(item.name),
              subtitle: Text('${item.when} • ${item.details}'),
              trailing: IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgendaItem {
  final String name;
  final String when;
  final String details;
  const _AgendaItem(this.name, this.when, this.details);
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.item});
  final _AgendaItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('${item.when} • ${item.details}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
