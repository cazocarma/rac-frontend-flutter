import 'package:flutter/material.dart';
import '../../compas/data/compa_api.dart';

class CompaListScreen extends StatefulWidget {
  final CompaApi api;
  const CompaListScreen({super.key, required this.api});

  @override
  State<CompaListScreen> createState() => _CompaListScreenState();
}

class _CompaListScreenState extends State<CompaListScreen> {
  List<CompaCard> items = [];
  bool loading = true;
  String? error;
  final _skillCtrl = TextEditingController();

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await widget.api.list(skill: _skillCtrl.text.trim());
      setState(() => items = data);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _skillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compas')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por skill (ej: karaoke)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (loading) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child:
                    Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = items[i];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(c.nombre.isNotEmpty ? c.nombre[0] : '?'),
                    ),
                    title: Text('${c.nombre} — \$${c.tarifaHora.toStringAsFixed(0)}/h'),
                    subtitle: Text(
                      [
                        if (c.habilidades.isNotEmpty) c.habilidades.join(', '),
                        if ((c.descripcion ?? '').isNotEmpty) c.descripcion!,
                      ].where((e) => e.isNotEmpty).join('\n'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Próximo paso: navegar a detalle
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
