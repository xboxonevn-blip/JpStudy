import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/models/kana_entry.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';

enum KanaScript { hiragana, katakana }

enum KanaView { base, compound }

class KanaTableScreen extends ConsumerStatefulWidget {
  const KanaTableScreen({
    super.key,
    required this.script,
    required this.initialView,
  });

  final KanaScript script;
  final KanaView initialView;

  @override
  ConsumerState<KanaTableScreen> createState() => _KanaTableScreenState();
}

class _KanaTableScreenState extends ConsumerState<KanaTableScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late KanaScript _script;
  bool _showRomaji = true;

  @override
  void initState() {
    super.initState();
    _script = widget.script;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialView == KanaView.compound ? 1 : 0,
    );
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final chartAsync = ref.watch(kanaChartProvider);
    final title = _script == KanaScript.hiragana
        ? language.foundationsHiraganaLabel
        : language.foundationsKatakanaLabel;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: language.kanaShowRomajiLabel,
            onPressed: () => setState(() => _showRomaji = !_showRomaji),
            icon: Icon(_showRomaji ? Icons.visibility : Icons.visibility_off),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cơ bản'),
            Tab(text: 'Âm ghép'),
          ],
        ),
      ),
      body: chartAsync.when(
        data: (chart) {
          final selected = _script == KanaScript.hiragana
              ? chart.hiragana
              : chart.katakana;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SegmentedButton<KanaScript>(
                  segments: const [
                    ButtonSegment(
                      value: KanaScript.hiragana,
                      label: Text('Hiragana'),
                    ),
                    ButtonSegment(
                      value: KanaScript.katakana,
                      label: Text('Katakana'),
                    ),
                  ],
                  selected: {_script},
                  onSelectionChanged: (value) {
                    setState(() => _script = value.first);
                  },
                ),
              ),
              Expanded(
                child: _tabController.index == 0
                    ? _KanaGrid(
                        key: const ValueKey('kana_base_grid'),
                        mode: KanaView.base,
                        entries: selected.entries
                            .map(_KanaCellData.fromEntry)
                            .toList(),
                        showRomaji: _showRomaji,
                      )
                    : _KanaGrid(
                        key: const ValueKey('kana_compound_grid'),
                        mode: KanaView.compound,
                        entries: selected.compounds
                            .map(_KanaCellData.fromCompound)
                            .toList(),
                        showRomaji: _showRomaji,
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _KanaGrid extends ConsumerWidget {
  const _KanaGrid({
    super.key,
    required this.mode,
    required this.entries,
    required this.showRomaji,
  });

  final KanaView mode;
  final List<_KanaCellData> entries;
  final bool showRomaji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(foundationsProgressProvider);
    final countKey = ValueKey(
      mode == KanaView.base
          ? 'kana_base_count_${entries.length}'
          : 'kana_compound_count_${entries.length}',
    );
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text(
            '${entries.length}',
            key: countKey,
            style: const TextStyle(fontSize: 0, height: 0),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GridView.count(
              crossAxisCount: _columnsForWidth(
                MediaQuery.sizeOf(context).width,
              ),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.9,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final entry in entries)
                  _KanaCell(
                    key: ValueKey(
                      mode == KanaView.base
                          ? 'kana_cell_base_${entry.kana}'
                          : 'kana_cell_compound_${entry.kana}',
                    ),
                    entry: entry,
                    mode: mode,
                    showRomaji: showRomaji,
                    studied: progress.isStudied(entry.kana),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _columnsForWidth(double width) {
    if (width >= 900) return 10;
    if (width >= 600) return 8;
    return 5;
  }
}

class _KanaCell extends ConsumerWidget {
  const _KanaCell({
    super.key,
    required this.entry,
    required this.mode,
    required this.showRomaji,
    required this.studied,
  });

  final _KanaCellData entry;
  final KanaView mode;
  final bool showRomaji;
  final bool studied;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final containerKey = ValueKey(
      mode == KanaView.base
          ? 'kana_cell_base_${entry.kana}_container'
          : 'kana_cell_compound_${entry.kana}_container',
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showKanaSheet(context, ref, entry),
        child: Container(
          key: containerKey,
          decoration: BoxDecoration(
            color: studied
                ? palette.success.withValues(alpha: 0.13)
                : palette.elevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: studied
                  ? palette.success.withValues(alpha: 0.55)
                  : palette.outline,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.kana,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: palette.ink,
                          ),
                    ),
                    if (showRomaji) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.romaji,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.ink.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.strokes != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Badge(label: Text('${entry.strokes}')),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKanaSheet(
    BuildContext context,
    WidgetRef ref,
    _KanaCellData entry,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final language = ref.watch(appLanguageProvider);
            final progress = ref.watch(foundationsProgressProvider);
            final studied = progress.isStudied(entry.kana);
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.kana,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${entry.romaji} · ${entry.row}.${entry.column}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () async {
                        final notifier = ref.read(
                          foundationsProgressProvider.notifier,
                        );
                        if (studied) {
                          await notifier.unmarkStudied(entry.kana);
                        } else {
                          await notifier.markStudied(entry.kana);
                        }
                      },
                      icon: Icon(
                        studied
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                      ),
                      label: Text(language.kanaIKnowItLabel),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (entry.strokes != null)
                          Chip(label: Text('${entry.strokes} strokes')),
                        Chip(label: Text(entry.mark ?? 'clear')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _KanaCellData {
  const _KanaCellData({
    required this.kana,
    required this.romaji,
    required this.row,
    required this.column,
    this.strokes,
    this.mark,
  });

  final String kana;
  final String romaji;
  final String row;
  final String column;
  final int? strokes;
  final String? mark;

  factory _KanaCellData.fromEntry(KanaEntry entry) {
    return _KanaCellData(
      kana: entry.kana,
      romaji: entry.romaji,
      row: entry.row,
      column: entry.column,
      strokes: entry.strokes,
      mark: entry.mark,
    );
  }

  factory _KanaCellData.fromCompound(KanaCompound entry) {
    return _KanaCellData(
      kana: entry.kana,
      romaji: entry.romaji,
      row: entry.row,
      column: entry.column,
      mark: 'yoon',
    );
  }
}
