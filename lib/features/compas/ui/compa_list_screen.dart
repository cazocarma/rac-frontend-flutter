import '../../../l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/public_profile.dart';
import '../../compas/data/compa_api.dart';
import '../../../shared/di/services.dart';
import '../../../shared/widgets/design.dart';
import 'compa_detail_screen.dart';
import '../../../shared/widgets/brand.dart';

class CompaListScreen extends StatefulWidget {
  const CompaListScreen({super.key, this.api});
  final CompaApi? api;
  @override
  State<CompaListScreen> createState() => _CompaListScreenState();
}

class _CompaListScreenState extends State<CompaListScreen> {
  final search = TextEditingController();
  List<CompaCard> items = [];
  List<String> skills = [];
  bool loading = true, more = true;
  bool failed = false;
  String filter = '';
  int request = 0;
  CompaApi get api => widget.api ?? Services.compas;
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
      final data = await api.listSkills(limit: 20);
      if (mounted) setState(() => skills = data);
    } catch (_) {}
  }

  Future<void> load({bool append = false}) async {
    final id = ++request;
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      final data = await api.list(
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
        setState(() => failed = true);
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
    final t = AppLocalizations.of(context)!;
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
                        Text(
                          t.exploreHeroEyebrow,
                          style: const TextStyle(
                            color: Color(0xFFC5E8AD),
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          t.exploreHeroTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 29 : 38,
                            height: 1.1,
                            letterSpacing: -1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.exploreHeroBody,
                          style: const TextStyle(
                            color: Color(0xFFCEE0D3),
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            const Icon(
                              Icons.explore_outlined,
                              color: Color(0xFFC5E8AD),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                t.exploreHeroHint,
                                style: const TextStyle(
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
            t.exploreQuestion,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(t.exploreQuestionHelp),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: compact
                        ? t.exploreSearchHintCompact
                        : t.exploreSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: t.exploreClearSearch,
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
                child: Text(t.exploreSearch),
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
                      label: Text(skill.isEmpty ? t.exploreAllSkills : skill),
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
                  t.exploreTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: t.exploreRefresh,
                onPressed: loading ? null : () => load(),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          if (!loading && items.isNotEmpty)
            Text(
              t.exploreCount(items.length, '${items.length}${more ? '+' : ''}'),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          const SizedBox(height: 16),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (failed)
            MaterialBanner(
              content: Text(t.exploreLoadFailed),
              actions: [
                TextButton(
                  onPressed: () => load(),
                  child: Text(t.exploreRetry),
                ),
              ],
            ),
          if (items.isEmpty && !loading && !failed)
            EmptyState(
              title: t.exploreEmptyTitle,
              message: t.exploreEmptyMessage,
              action: OutlinedButton(
                onPressed: () => applyFilter(''),
                child: Text(t.exploreShowAll),
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
          if (more && !loading && !failed)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: OutlinedButton(
                  onPressed: () => load(append: true),
                  child: Text(t.exploreShowMore),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            t.exploreFooter,
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
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    const tints = [
      Color(0xFFE0EFE7),
      Color(0xFFF3E3D2),
      Color(0xFFE8E5F5),
      Color(0xFFE2EAF1),
    ];
    final tint = tints[index % tints.length];
    void openProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompaDetailScreen(api: api, id: compa.id),
        ),
      );
    }

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: t.exploreCardSemantics(
        compa.nombre,
        compa.habilidades.join(', '),
        money(compa.tarifaHora),
        compa.ratingPromedio > 0
            ? t.exploreCardRating(compa.ratingPromedio.toStringAsFixed(1))
            : t.exploreNewInRac,
      ),
      onTap: openProfile,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: openProfile,
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
                    ProfileAvatar(
                      name: compa.nombre,
                      path: compa.fotoUrl,
                      radius: 30,
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
                                : t.exploreNewInRac,
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
                            ? t.exploreNoSkills
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
                            ? t.exploreNoDescription
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
                                    text: ' ${t.explorePerHour}',
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
      ),
    );
  }
}
