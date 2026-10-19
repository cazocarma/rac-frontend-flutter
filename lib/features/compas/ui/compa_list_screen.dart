import 'package:flutter/material.dart';
import '../../compas/data/compa_api.dart';
import '../../../shared/di/services.dart';
import '../../../shared/widgets/design.dart';
import 'compa_detail_screen.dart';
import '../../../shared/widgets/brand.dart';

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

  void applyFilter(String value) {
    setState(() {
      filter = value.trim();
      search.text = filter;
    });
    load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 24 : 36),
            decoration: BoxDecoration(
              color: const Color(0xFF183F31),
              borderRadius: BorderRadius.circular(26),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HAZ ESPACIO PARA UN BUEN PLAN',
                          style: TextStyle(
                            color: Color(0xFFC5E8AD),
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Un buen plan empieza\ncon buena compañía.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 29 : 38,
                            height: 1.1,
                            letterSpacing: -1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Descubre personas con quienes compartir lo que te gusta.',
                          style: TextStyle(
                            color: Color(0xFFCEE0D3),
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Row(
                          children: [
                            Icon(
                              Icons.explore_outlined,
                              color: Color(0xFFC5E8AD),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Tú eliges el plan. Encuentra tu compa.',
                                style: TextStyle(
                                  color: Color(0xFFC5E8AD),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (constraints.maxWidth > 720) ...[
                    const SizedBox(width: 20),
                    const ActivityArtwork(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '¿Qué te gustaría hacer?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text('Busca por habilidad o explora algo diferente.'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: compact
                        ? 'Cine, running, café…'
                        : 'Busca una habilidad: cine, running, café…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () => applyFilter(''),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: applyFilter,
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: loading ? null : () => applyFilter(search.text),
                child: const Text('Buscar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final skill in ['', ...skills])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(skill.isEmpty ? 'Todos' : skill),
                      selected: filter == skill,
                      onSelected: (_) => applyFilter(skill),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Encuentra tu compa',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: loading ? null : () => load(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (!loading && items.isNotEmpty)
            Text(
              '${items.length}${more ? '+' : ''} ${items.length == 1 ? 'compa para conocer' : 'compas para conocer'}',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
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
          if (items.isEmpty && !loading && error == null)
            EmptyState(
              title: 'No encontramos compas',
              message: 'Prueba otra habilidad o selecciona Todos.',
              action: OutlinedButton(
                onPressed: () => applyFilter(''),
                child: const Text('Ver todos los compas'),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 560
                      ? 2
                      : 1,
                  mainAxisExtent: 326,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _compaCard(context, items[index], index),
              ),
            ),
          if (more && !loading && error == null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: OutlinedButton(
                  onPressed: () => load(append: true),
                  child: const Text('Ver más compas'),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Encuentra un interés en común. Revisa el perfil y acuerda tu próxima experiencia.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _compaCard(BuildContext context, CompaCard compa, int index) {
    final colors = Theme.of(context).colorScheme;
    const tints = [
      Color(0xFFE0EFE7),
      Color(0xFFF3E3D2),
      Color(0xFFE8E5F5),
      Color(0xFFE2EAF1),
    ];
    final tint = tints[index % tints.length];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                CompaDetailScreen(api: Services.compas, id: compa.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 104,
              padding: const EdgeInsets.all(20),
              color: tint,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: .8),
                    child: Text(
                      compa.nombre.isEmpty
                          ? '?'
                          : compa.nombre[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        color: Color(0xFF183F31),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (compa.ratingPromedio > 0)
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFF99641E),
                          ),
                        Text(
                          compa.ratingPromedio > 0
                              ? compa.ratingPromedio.toStringAsFixed(1)
                              : 'Nuevo en RAC',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF183F31),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compa.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      compa.habilidades.isEmpty
                          ? 'Conoce sus intereses'
                          : compa.habilidades.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (compa.descripcion ?? '').isEmpty
                          ? 'Comparte una nueva experiencia.'
                          : compa.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${money(compa.tarifaHora)} CLP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / hora',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: colors.primary,
                          size: 21,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
