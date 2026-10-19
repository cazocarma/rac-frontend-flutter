import 'package:flutter/material.dart';
import '../../compas/data/compa_api.dart';
import '../../../shared/di/services.dart';
import '../../../shared/widgets/design.dart';
import 'compa_detail_screen.dart';

class CompaListScreen extends StatefulWidget {
  const CompaListScreen({super.key});
  @override
  State<CompaListScreen> createState() => _CompaListScreenState();
}

class _CompaListScreenState extends State<CompaListScreen> {
  final search = TextEditingController();
  List<CompaCard> items = [];
  List<String> skills = [];
  bool loading = true, more = true;
  String? error;
  String filter = '';
  int request = 0;
  @override
  void initState() {
    super.initState();
    load();
    loadSkills();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> loadSkills() async {
    try {
      final data = await Services.compas.listSkills(limit: 20);
      if (mounted) setState(() => skills = data);
    } catch (_) {}
  }

  Future<void> load({bool append = false}) async {
    final id = ++request;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await Services.compas.list(
        skill: filter,
        limit: 12,
        offset: append ? items.length : 0,
      );
      if (!mounted || id != request) return;
      setState(() {
        items = append ? [...items, ...data] : data;
        more = data.length == 12;
      });
    } catch (_) {
      if (mounted && id == request) {
        setState(
          () => error = 'No pudimos cargar los compas. Inténtalo otra vez.',
        );
      }
    } finally {
      if (mounted && id == request) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Un buen plan empieza\ncon buena compañía.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        const Text('Descubre personas con quienes compartir lo que te gusta.'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: search,
                decoration: const InputDecoration(
                  hintText: 'Busca una habilidad: cine, running…',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (v) {
                  filter = v.trim();
                  load();
                },
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: loading
                  ? null
                  : () {
                      filter = search.text.trim();
                      load();
                    },
              child: const Text('Buscar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final skill in ['', ...skills])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(skill.isEmpty ? 'Todos' : skill),
                    selected: filter == skill,
                    onSelected: (_) {
                      search.text = skill;
                      filter = skill;
                      load();
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Encuentra tu compa',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Actualizar',
              onPressed: loading ? null : () => load(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (loading) const LinearProgressIndicator(),
        if (error != null)
          MaterialBanner(
            content: Text(error!),
            actions: [
              TextButton(
                onPressed: () => load(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        const SizedBox(height: 12),
        SizedBox(
          child: items.isEmpty && !loading
              ? const EmptyState(
                  title: 'No encontramos compas',
                  message: 'Prueba otra habilidad o selecciona Todos.',
                )
              : LayoutBuilder(
                  builder: (context, c) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: c.maxWidth >= 850
                          ? 3
                          : c.maxWidth >= 540
                          ? 2
                          : 1,
                      mainAxisExtent: 285,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length + (more && !loading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == items.length) {
                        return Center(
                          child: OutlinedButton(
                            onPressed: () => load(append: true),
                            child: const Text('Ver más compas'),
                          ),
                        );
                      }
                      final compa = items[i];
                      final colors = Theme.of(context).colorScheme;
                      return Card(
                        margin: EdgeInsets.zero,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CompaDetailScreen(
                                api: Services.compas,
                                id: compa.id,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: colors.primaryContainer,
                                      child: Text(
                                        compa.nombre.isEmpty
                                            ? '?'
                                            : compa.nombre[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.arrow_outward, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  compa.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  compa.habilidades.isEmpty
                                      ? 'Conoce su perfil'
                                      : compa.habilidades.join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colors.primary),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  compa.descripcion ??
                                      'Comparte una nueva experiencia.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      '${money(compa.tarifaHora)} CLP',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(' / hora'),
                                    const Spacer(),
                                    if (compa.ratingPromedio > 0) ...[
                                      const Icon(Icons.star_rounded, size: 16),
                                      Text(
                                        compa.ratingPromedio.toStringAsFixed(1),
                                      ),
                                    ] else
                                      const Text('Nuevo'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    ),
  );
}
