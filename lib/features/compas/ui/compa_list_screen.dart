import 'dart:async';
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
  final _scrollCtrl = ScrollController();
  String _currentSkill = '';
  Timer? _debounce;

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
    _debounce?.cancel();
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
        skill: _currentSkill,
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
        skill: _currentSkill,
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
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
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

  void _onSkillChanged(String text) {
    _currentSkill = text.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchSkills(_currentSkill);
    });
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
                  final q = v.text.trim().toLowerCase();
                  final filtered = skillOptions
                      .where((s) => s.toLowerCase().startsWith(q))
                      .toList();
                  return filtered;
                },
                onSelected: (s) {
                  _currentSkill = s;
                },
                fieldViewBuilder:
                    (ctx, textCtrl, focus, onFieldSubmitted) {
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
                              child: SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : null,
                    ),
                    onChanged: _onSkillChanged,
                    onSubmitted: (_) {
                      _currentSkill = textCtrl.text.trim();
                      _loadInitial();
                    },
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
            child: Text(
              error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
  child: LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;

      // breakpoints
      late final int crossAxisCount;
      late final SliverGridDelegate gridDelegate;

      if (w >= 1600) {
        // gigante: 3 columnas
        crossAxisCount = 4;
        gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          // altura fija y compacta para grandes
          //mainAxisExtent: 500,
          childAspectRatio: 3,
        );
      } else if (w >= 1200) {
        // grande: 3 columnas
        crossAxisCount = 3;
        gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          // altura fija y compacta para grandes
          //mainAxisExtent: 500,
          childAspectRatio: 3,
        );
      } else if (w >= 600) {
        // medio: 2 columnas
        crossAxisCount = 2;
        gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          // un poco más de alto que en grande si quieres
          //mainAxisExtent: 500,
          childAspectRatio: 3,
        );
      } else {
        // pequeño: 1 columna
        crossAxisCount = 1;
        gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          // en móviles suele ir mejor por ratio para que respire
          childAspectRatio: 1.8,
        );
      }

      return GridView.builder(
        controller: _scrollCtrl,
        gridDelegate: gridDelegate,
        itemCount: items.length + (loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final c = items[i];

          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CompaDetailScreen(
                      api: Services.compas,
                      id: c.id,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const SizedBox(width: 2),
                    CircleAvatar(
                      radius: 20,
                      child: Text(c.nombre.isNotEmpty ? c.nombre[0] : '?'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.nombre} – \$${c.tarifaHora.toStringAsFixed(0)}/h',
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (c.habilidades.isNotEmpty) c.habilidades.join(', '),
                              if ((c.descripcion ?? '').isNotEmpty) c.descripcion!,
                            ].where((e) => e.isNotEmpty).join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
            child: Text(
              'No hay más resultados',
              style: TextStyle(color: Colors.grey),
            ),
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
