import 'package:flutter/material.dart';
import '../../compas/data/compa_api.dart';
import '../../../shared/di/services.dart';
import 'compa_detail_screen.dart';

class CompaListScreen extends StatefulWidget {
  const CompaListScreen({super.key});

  @override
  State<CompaListScreen> createState() => _CompaListScreenState();
}

class _CompaListScreenState extends State<CompaListScreen> {
  final _skillCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<CompaCard> items = [];
  bool loading = false;
  bool loadingMore = false;
  bool endReached = false;
  String? error;
  int limit = 10;
  int offset = 0;

  List<String> skillOptions = [];
  bool loadingSkills = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollCtrl.addListener(_onScroll);
    _fetchSkills('');
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      loading = true;
      error = null;
      items = [];
      offset = 0;
      endReached = false;
    });
    try {
      final data = await Services.compas.list(
        skill: _skillCtrl.text.trim(),
        limit: limit,
        offset: 0,
      );
      setState(() {
        items = data;
        offset = data.length;
        endReached = data.length < limit;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (loadingMore || loading || endReached) return;
    setState(() => loadingMore = true);
    try {
      final data = await Services.compas.list(
        skill: _skillCtrl.text.trim(),
        limit: limit,
        offset: offset,
      );
      setState(() {
        items.addAll(data);
        offset += data.length;
        if (data.length < limit) endReached = true;
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchSkills(String q) async {
    setState(() => loadingSkills = true);
    try {
      final list = await Services.compas.listSkills(q: q, limit: 20);
      setState(() => skillOptions = list);
    } catch (_) {
      // ignora errores silenciosamente
    } finally {
      setState(() => loadingSkills = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue v) {
                  final q = v.text.trim();
                  _fetchSkills(q);
                  final lc = q.toLowerCase();
                  final filtered = skillOptions.where((s) => s.toLowerCase().startsWith(lc)).toList();
                  return filtered;
                },
                onSelected: (s) {
                  _skillCtrl.text = s;
                },
                fieldViewBuilder: (ctx, textCtrl, focus, onFieldSubmitted) {
                  textCtrl.text = _skillCtrl.text;
                  textCtrl.addListener(() {
                    _skillCtrl.text = textCtrl.text;
                  });
                  return TextField(
                    controller: textCtrl,
                    focusNode: focus,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por skill',
                      hintText: 'Ej: karaoke',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: loadingSkills
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _loadInitial(),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loadInitial,
              child: const Text('Buscar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (loading) const LinearProgressIndicator(),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            controller: _scrollCtrl,
            itemCount: items.length + (loadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              if (i >= items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompaDetailScreen(api: Services.compas, id: c.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (endReached && items.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No hay más resultados', style: TextStyle(color: Colors.grey)),
          ),
        if (items.isEmpty && !loading && error == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('Sin resultados'),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}
