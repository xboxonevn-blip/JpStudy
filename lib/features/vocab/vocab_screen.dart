import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

class _SeriesManifestSummary {
  const _SeriesManifestSummary({
    required this.routeCount,
    required this.readyRouteCount,
    required this.importedTermCount,
  });

  const _SeriesManifestSummary.empty()
    : routeCount = 0,
      readyRouteCount = 0,
      importedTermCount = 0;

  final int routeCount;
  final int readyRouteCount;
  final int importedTermCount;
}

Future<_SeriesManifestSummary> _loadShinkanzenManifestSummary(
  String levelCode,
) async {
  final levelLower = levelCode.toLowerCase();
  final indexPath =
      'assets/data/content/vocab/$levelLower/ShinKanzen/index.json';

  try {
    final raw = await rootBundle
        .loadString(indexPath)
        .timeout(const Duration(seconds: 1));
    final payload = json.decode(raw);
    if (payload is! Map) {
      return const _SeriesManifestSummary.empty();
    }

    final lessons = payload['lessons'];
    if (lessons is! List) {
      return const _SeriesManifestSummary.empty();
    }

    var readyRouteCount = 0;
    var importedTermCount = 0;
    for (final rawLesson in lessons) {
      if (rawLesson is! Map) continue;
      final lesson = rawLesson.map((k, v) => MapEntry(k.toString(), v));
      final fileName = (lesson['file'] ?? '').toString().trim();
      if (fileName.isEmpty) continue;
      readyRouteCount += 1;
      importedTermCount += await _loadShinkanzenEntryCount(
        'assets/data/content/vocab/$levelLower/ShinKanzen/$fileName',
      );
    }

    return _SeriesManifestSummary(
      routeCount: lessons.length,
      readyRouteCount: readyRouteCount,
      importedTermCount: importedTermCount,
    );
  } catch (_) {
    return const _SeriesManifestSummary.empty();
  }
}

Future<int> _loadShinkanzenEntryCount(String path) async {
  try {
    final raw = await rootBundle
        .loadString(path)
        .timeout(const Duration(seconds: 1));
    final payload = json.decode(raw);
    if (payload is! Map) return 0;
    final entryCount = payload['entryCount'];
    if (entryCount is int) return entryCount;
    final entries = payload['entries'];
    return entries is List ? entries.length : 0;
  } catch (_) {
    return 0;
  }
}

final vocabCatalogProvider = FutureProvider<List<_VocabCatalogSection>>((
  ref,
) async {
  final repo = ref.read(lessonRepositoryProvider);
  final dueTerms = await ref.watch(allDueTermsProvider.future);
  final nextReview = await ref.watch(nextVocabReviewProvider.future);

  Future<List<VocabItem>> loadCore(String level) =>
      repo.getVocabByLevelAndSeries(level, 'hajimete');

  final n5 = await loadCore('N5');
  final n4 = await loadCore('N4');
  final n3 = await loadCore('N3');
  final n2 = await loadCore('N2');
  final n1 = await loadCore('N1');
  final shinkanzenN3 = await repo.getVocabByLevelAndSeries('N3', 'ShinKanzen');
  final shinkanzenN3Summary = await _loadShinkanzenManifestSummary('N3');
  final shinkanzenN2Summary = await _loadShinkanzenManifestSummary('N2');
  final shinkanzenN1Summary = await _loadShinkanzenManifestSummary('N1');
  final minnaN5 = await repo.getVocabByLessonRange(
    'N5',
    startLesson: 1,
    endLesson: 25,
    series: 'minna',
  );
  final minnaN4 = await repo.getVocabByLessonRange(
    'N4',
    startLesson: 26,
    endLesson: 50,
    series: 'minna',
  );

  return [
    _buildJlptSection(
      levelCode: 'N5',
      items: n5,
      dueCount: dueTerms.length,
      nextReview: nextReview,
      accent: const Color(0xFFF5BE1D),
      companionTitle: 'Minna no Nihongo I',
      companionSubtitle: _courseSubtitle(
        AppLanguage.vi,
        _VocabProgramType.minna,
        'N5',
      ),
      companionType: _VocabProgramType.minna,
      companionCountOverride: minnaN5.length,
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N4',
      items: n4,
      dueCount: dueTerms.length,
      nextReview: nextReview,
      accent: const Color(0xFFB428F4),
      companionTitle: 'Minna no Nihongo II',
      companionSubtitle: _courseSubtitle(
        AppLanguage.vi,
        _VocabProgramType.minna,
        'N4',
      ),
      companionType: _VocabProgramType.minna,
      companionCountOverride: minnaN4.length,
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N3',
      items: n3,
      dueCount: dueTerms.length,
      nextReview: nextReview,
      accent: const Color(0xFF06CF56),
      companionTitle: 'Shin Kanzen Master',
      companionSubtitle: _courseSubtitle(
        AppLanguage.vi,
        _VocabProgramType.shinkanzen,
        'N3',
      ),
      companionType: _VocabProgramType.shinkanzen,
      companionCountOverride: shinkanzenN3Summary.importedTermCount > 0
          ? shinkanzenN3Summary.importedTermCount
          : shinkanzenN3.length,
      companionStructureCount: shinkanzenN3Summary.routeCount > 0
          ? shinkanzenN3Summary.routeCount
          : 25,
      companionPreviewBody:
          'Official 3A category route mapped for N3. ${shinkanzenN3Summary.readyRouteCount}/${shinkanzenN3Summary.routeCount > 0 ? shinkanzenN3Summary.routeCount : 25} route blocks are already imported with ${shinkanzenN3Summary.importedTermCount > 0 ? shinkanzenN3Summary.importedTermCount : shinkanzenN3.length} seeded terms in JP Study.',
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N2',
      items: n2,
      dueCount: dueTerms.length,
      nextReview: nextReview,
      accent: const Color(0xFFFF606A),
      companionTitle: 'Shin Kanzen Master',
      companionSubtitle: _courseSubtitle(
        AppLanguage.vi,
        _VocabProgramType.shinkanzen,
        'N2',
      ),
      companionType: _VocabProgramType.shinkanzen,
      companionStructureCount: shinkanzenN2Summary.routeCount > 0
          ? shinkanzenN2Summary.routeCount
          : 51,
      companionPreviewBody:
          'Official 3A confirmation-test route mapped for N2. ${shinkanzenN2Summary.readyRouteCount}/${shinkanzenN2Summary.routeCount > 0 ? shinkanzenN2Summary.routeCount : 51} tests are already imported with ${shinkanzenN2Summary.importedTermCount} seeded terms in JP Study.',
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N1',
      items: n1,
      dueCount: dueTerms.length,
      nextReview: nextReview,
      accent: const Color(0xFF4095F2),
      companionTitle: 'Shin Kanzen Master',
      companionSubtitle: _courseSubtitle(
        AppLanguage.vi,
        _VocabProgramType.shinkanzen,
        'N1',
      ),
      companionType: _VocabProgramType.shinkanzen,
      companionStructureCount: shinkanzenN1Summary.routeCount > 0
          ? shinkanzenN1Summary.routeCount
          : 51,
      companionPreviewBody:
          'Official 3A confirmation-test route mapped for N1. ${shinkanzenN1Summary.readyRouteCount}/${shinkanzenN1Summary.routeCount > 0 ? shinkanzenN1Summary.routeCount : 51} tests are imported with ${shinkanzenN1Summary.importedTermCount} seeded terms so far.',
      extraPrograms: const [
        _VocabCatalogProgram(
          key: 'advanced_n1',
          titleTop: 'Advanced Vocabulary Lab',
          titleMain: 'N1+',
          termCount: 0,
          subtitle:
              'Extended nuance, formal usage, and dense reading support are planned next.',
          type: _VocabProgramType.advanced,
          isInteractive: false,
          isComingSoon: true,
          badgeText: 'Advanced',
        ),
      ],
      isInteractive: true,
    ),
    const _VocabCatalogSection(
      key: 'se',
      levelCode: 'SE',
      subtitle: 'Specialized Japanese for software teams',
      accent: Color(0xFF6B7280),
      programs: [
        _VocabCatalogProgram(
          key: 'se_track',
          titleTop: 'Tech Japanese Track',
          titleMain: 'SE',
          termCount: 0,
          subtitle:
              'Product, engineering, meetings, specs, and workplace Japanese.',
          type: _VocabProgramType.specialized,
          isInteractive: false,
          isComingSoon: true,
          badgeText: 'Specialized',
        ),
      ],
    ),
  ];
});

class VocabScreen extends ConsumerWidget {
  const VocabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final catalogAsync = ref.watch(vocabCatalogProvider);

    return Scaffold(
      body: AppPageShell(
        topPadding: AppSpacing.md,
        child: catalogAsync.when(
          data: (sections) =>
              _VocabCatalogBody(language: language, sections: sections),
          loading: () => const Padding(
            key: ValueKey('vocab_catalog_loading'),
            padding: EdgeInsets.only(top: 120),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => AppFeatureCard(
            key: const ValueKey('vocab_catalog_error'),
            icon: Icons.error_outline_rounded,
            title: _catalogErrorTitle(language),
            subtitle: error.toString(),
            secondaryLabel: _catalogRetryLabel(language),
            onSecondaryTap: () => ref.invalidate(vocabCatalogProvider),
          ),
        ),
      ),
    );
  }
}

class _VocabCatalogBody extends ConsumerWidget {
  const _VocabCatalogBody({required this.language, required this.sections});

  final AppLanguage language;
  final List<_VocabCatalogSection> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(studyLevelProvider);
    final totalPrograms = sections.fold<int>(
      0,
      (sum, section) => sum + section.programs.length,
    );
    final livePrograms = sections
        .expand((section) => section.programs)
        .where((program) => program.isInteractive)
        .length;
    final totalTerms = sections
        .expand((section) => section.programs)
        .where((program) => program.termCount > 0)
        .fold<int>(0, (sum, program) => sum + program.termCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VocabHero(
          key: const ValueKey('vocab_catalog_hero'),
          language: language,
          selectedLevel: selectedLevel,
          totalPrograms: totalPrograms,
          livePrograms: livePrograms,
          totalTerms: totalTerms,
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final section in sections) ...[
          _VocabSection(
            key: ValueKey('section_${section.key}'),
            section: section,
            language: language,
            onProgramTap: (program) =>
                _openProgram(context, ref, section, program),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }

  void _openProgram(
    BuildContext context,
    WidgetRef ref,
    _VocabCatalogSection section,
    _VocabCatalogProgram program,
  ) {
    final language = ref.read(appLanguageProvider);
    if (!program.isInteractive) {
      if (!program.isPreviewOnly) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_previewDialogTitle(language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${program.titleTop} ? ${program.titleMain}',
                style: Theme.of(
                  dialogContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(_programCountLabel(program, language)),
              if (program.chapterCount != null) ...[
                const SizedBox(height: 6),
                Text(_chapterSummaryLabel(program.chapterCount!, language)),
              ],
              const SizedBox(height: 12),
              Text(_previewDialogBody(language, program)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_previewDialogClose(language)),
            ),
          ],
        ),
      );
      return;
    }
    final level = _studyLevelFromCode(section.levelCode);
    if (level == null) return;
    ref.read(studyLevelProvider.notifier).state = level;

    final minnaRange = _minnaLessonRange(section.levelCode, program.type);
    if (minnaRange != null) {
      final uri = Uri(
        path: '/vocab/minna',
        queryParameters: {
          'level': section.levelCode,
          'title': program.titleTop,
          'subtitle': _localizedProgramSubtitle(program, language),
          'lessonStart': '${minnaRange.$1}',
          'lessonEnd': '${minnaRange.$2}',
        },
      );
      context.push(uri.toString());
      return;
    }

    context.push('/vocab/review');
  }
}

class _VocabHero extends StatelessWidget {
  const _VocabHero({
    super.key,
    required this.language,
    required this.selectedLevel,
    required this.totalPrograms,
    required this.livePrograms,
    required this.totalTerms,
  });

  final AppLanguage language;
  final StudyLevel? selectedLevel;
  final int totalPrograms;
  final int livePrograms;
  final int totalTerms;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;
    final palette = context.appPalette;

    return AppSectionCard(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _HeroCopy(
                    language: language,
                    selectedLevel: selectedLevel,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  flex: 4,
                  child: _HeroMetricsPanel(
                    language: language,
                    totalPrograms: totalPrograms,
                    livePrograms: livePrograms,
                    totalTerms: totalTerms,
                    palette: palette,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(language: language, selectedLevel: selectedLevel),
                const SizedBox(height: AppSpacing.lg),
                _HeroMetricsPanel(
                  language: language,
                  totalPrograms: totalPrograms,
                  livePrograms: livePrograms,
                  totalTerms: totalTerms,
                  palette: palette,
                ),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.language, required this.selectedLevel});

  final AppLanguage language;
  final StudyLevel? selectedLevel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
            children: [
              TextSpan(
                text: _heroHighlight(language),
                style: TextStyle(
                  color: palette.primary,
                  backgroundColor: palette.primary.withValues(alpha: 0.15),
                ),
              ),
              TextSpan(text: _heroTitle(language)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _heroSubtitle(language),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: palette.ink.withValues(alpha: 0.82),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _heroDescription(language),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.ink.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusChip(
              label: selectedLevel == null
                  ? _heroScopeAllLabel(language)
                  : _heroScopeLevelLabel(language, selectedLevel!.shortLabel),
              tone: AppStatusTone.primary,
            ),
            AppStatusChip(
              label: _heroMemoryLabel(language),
              tone: AppStatusTone.success,
            ),
            AppStatusChip(
              label: _heroUsageLabel(language),
              tone: AppStatusTone.neutral,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroMetricsPanel extends StatelessWidget {
  const _HeroMetricsPanel({
    required this.language,
    required this.totalPrograms,
    required this.livePrograms,
    required this.totalTerms,
    required this.palette,
  });

  final AppLanguage language;
  final int totalPrograms;
  final int livePrograms;
  final int totalTerms;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            palette.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline.withValues(alpha: 0.95)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _heroPanelTitle(language),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _heroPanelSubtitle(language),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeroMetricTile(
                  label: _heroMetricPrograms(language),
                  value: '$totalPrograms',
                  accent: palette.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroMetricTile(
                  label: _heroMetricLive(language),
                  value: '$livePrograms',
                  accent: palette.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _HeroMetricStrip(
            label: _heroMetricTerms(language),
            value: _formatNumber(totalTerms),
            accent: palette.warning,
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricStrip extends StatelessWidget {
  const _HeroMetricStrip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabSection extends StatelessWidget {
  const _VocabSection({
    super.key,
    required this.section,
    required this.language,
    required this.onProgramTap,
  });

  final _VocabCatalogSection section;
  final AppLanguage language;
  final ValueChanged<_VocabCatalogProgram> onProgramTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1040;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(section: section, language: language),
        const SizedBox(height: AppSpacing.md),
        if (isWide)
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final program in section.programs)
                SizedBox(
                  width: _cardWidth(section.programs.length),
                  child: _ProgramCard(
                    section: section,
                    program: program,
                    language: language,
                    onTap: () => onProgramTap(program),
                  ),
                ),
            ],
          )
        else
          Column(
            children: [
              for (final program in section.programs) ...[
                _ProgramCard(
                  section: section,
                  program: program,
                  language: language,
                  onTap: () => onProgramTap(program),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
      ],
    );
  }
}

double _cardWidth(int count) {
  if (count == 1) return 460;
  if (count == 2) return 432;
  return 286;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section, required this.language});

  final _VocabCatalogSection section;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final liveCount = section.programs
        .where((program) => program.isInteractive)
        .length;
    final palette = context.appPalette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 44,
          decoration: BoxDecoration(
            color: section.accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    section.levelCode,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppStatusChip(
                    label: liveCount > 0
                        ? _availableNowLabel(language)
                        : _comingSoonLabel(language),
                    tone: liveCount > 0
                        ? AppStatusTone.success
                        : AppStatusTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _localizedSectionSubtitle(section, language),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.ink.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (program.type) {
      _VocabProgramType.core => _CoreProgramCard(
        section: section,
        program: program,
        language: language,
        onTap: onTap,
      ),
      _VocabProgramType.minna ||
      _VocabProgramType.shinkanzen ||
      _VocabProgramType.listening => _CompanionProgramCard(
        section: section,
        program: program,
        language: language,
        onTap: onTap,
      ),
      _VocabProgramType.advanced ||
      _VocabProgramType.specialized => _GlassProgramCard(
        section: section,
        program: program,
        language: language,
        onTap: onTap,
      ),
    };
  }
}

class _CoreProgramCard extends StatelessWidget {
  const _CoreProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = program.isInteractive || program.isPreviewOnly;

    return InkWell(
      key: ValueKey('program_${section.key}_${program.key}'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.9,
        duration: const Duration(milliseconds: 180),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [section.accent, section.accent.withValues(alpha: 0.82)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: section.accent.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ProgramTypeBadge(
                      label: _trackLabel(language),
                      accent: section.accent,
                    ),
                    const Spacer(),
                    AppStatusChip(
                      label: _badgeLabel(program, language),
                      tone: enabled
                          ? AppStatusTone.primary
                          : AppStatusTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  program.titleTop,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      program.titleMain,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: palette.primary,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _programCountLabel(program, language),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: palette.ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _localizedProgramSubtitle(program, language),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(
                      icon: Icons.auto_awesome_rounded,
                      label: _meaningFirstLabel(language),
                    ),
                    _MetaPill(
                      icon: Icons.route_rounded,
                      label: _usageFlowLabel(language),
                    ),
                    _MetaPill(
                      icon: Icons.memory_rounded,
                      label: _programAvailabilityPill(program, language),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: enabled ? onTap : null,
                        icon: Icon(
                          program.isInteractive
                              ? Icons.play_arrow_rounded
                              : program.isPreviewOnly
                              ? Icons.visibility_rounded
                              : Icons.lock_clock_rounded,
                        ),
                        label: Text(
                          program.isInteractive
                              ? _openLaneLabel(language)
                              : _previewLabel(language),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionProgramCard extends StatelessWidget {
  const _CompanionProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = program.isInteractive || program.isPreviewOnly;
    final footerColor = program.type == _VocabProgramType.listening
        ? const Color(0xFF2F9A8F)
        : const Color(0xFF67C778);

    return InkWell(
      key: ValueKey('program_${section.key}_${program.key}'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.9,
        duration: const Duration(milliseconds: 180),
        child: Container(
          decoration: BoxDecoration(
            color: palette.elevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: palette.outline.withValues(alpha: 0.95),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.ink.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ProgramTypeBadge(
                          label: _programTypeLabel(program.type, language),
                          accent: section.accent,
                        ),
                        const Spacer(),
                        AppStatusChip(
                          label: _badgeLabel(program, language),
                          tone: program.isComingSoon
                              ? AppStatusTone.neutral
                              : program.isPreviewOnly
                              ? AppStatusTone.primary
                              : AppStatusTone.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: footerColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            program.type == _VocabProgramType.listening
                                ? Icons.headphones_rounded
                                : Icons.menu_book_rounded,
                            color: footerColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.titleTop,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: palette.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _localizedProgramSubtitle(program, language),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: palette.ink.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: footerColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _programCountLabel(program, language),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Text(
                          program.titleMain,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _programFooterHint(program.type, language),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: enabled ? onTap : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      icon: Icon(
                        program.isInteractive
                            ? Icons.north_east_rounded
                            : program.isPreviewOnly
                            ? Icons.visibility_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      label: Text(
                        program.isInteractive
                            ? _joinTrackLabel(language)
                            : _previewLabel(language),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassProgramCard extends StatelessWidget {
  const _GlassProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = program.isInteractive || program.isPreviewOnly;

    return InkWell(
      key: ValueKey('program_${section.key}_${program.key}'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.74),
              section.accent.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: palette.outline.withValues(alpha: 0.9),
            width: 1.4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProgramTypeBadge(
                    label: _programTypeLabel(program.type, language),
                    accent: section.accent,
                  ),
                  const Spacer(),
                  AppStatusChip(
                    label: _badgeLabel(program, language),
                    tone: program.isComingSoon
                        ? AppStatusTone.neutral
                        : program.isPreviewOnly
                        ? AppStatusTone.primary
                        : AppStatusTone.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                program.titleTop,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.ink.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                program.titleMain,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: section.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _programCountLabel(program, language),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _localizedProgramSubtitle(program, language),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.ink.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                  height: 1.48,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: palette.outline.withValues(alpha: 0.8), height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: section.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _programFooterHint(program.type, language),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.ink.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgramTypeBadge extends StatelessWidget {
  const _ProgramTypeBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.outlineSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.ink.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabCatalogSection {
  const _VocabCatalogSection({
    required this.key,
    required this.levelCode,
    required this.subtitle,
    required this.accent,
    required this.programs,
  });

  final String key;
  final String levelCode;
  final String subtitle;
  final Color accent;
  final List<_VocabCatalogProgram> programs;
}

enum _VocabProgramType {
  core,
  minna,
  shinkanzen,
  listening,
  advanced,
  specialized,
}

class _VocabCatalogProgram {
  const _VocabCatalogProgram({
    required this.key,
    required this.titleTop,
    required this.titleMain,
    required this.termCount,
    required this.subtitle,
    required this.type,
    required this.isInteractive,
    this.chapterCount,
    this.previewBody,
    this.isComingSoon = false,
    this.badgeText,
  });

  final String key;
  final String titleTop;
  final String titleMain;
  final int termCount;
  final int? chapterCount;
  final String subtitle;
  final String? previewBody;
  final _VocabProgramType type;
  final bool isInteractive;
  final bool isComingSoon;
  final String? badgeText;

  bool get hasData => termCount > 0;
  bool get isPreviewOnly => hasData && !isInteractive;
}

_VocabCatalogSection _buildJlptSection({
  required String levelCode,
  required List<VocabItem> items,
  required int dueCount,
  required DateTime? nextReview,
  required Color accent,
  required String companionTitle,
  required String companionSubtitle,
  required _VocabProgramType companionType,
  int? companionCountOverride,
  int? companionStructureCount,
  String? companionPreviewBody,
  required bool isInteractive,
  List<_VocabCatalogProgram> extraPrograms = const [],
}) {
  final liveCount = items.length;
  final chapterCount = _chapterCountForLevel(levelCode);
  final coreInteractive =
      isInteractive && _studyLevelFromCode(levelCode) != null && liveCount > 0;
  final coreBadge = dueCount > 0
      ? '$dueCount due ? ${_formatReviewTiming(nextReview)}'
      : _formatReviewTiming(nextReview);
  final companionTermCount = companionCountOverride ?? 0;
  final companionInteractive =
      isInteractive &&
      companionTermCount > 0 &&
      (companionType == _VocabProgramType.shinkanzen ||
          _minnaLessonRange(levelCode, companionType) != null);

  return _VocabCatalogSection(
    key: levelCode.toLowerCase(),
    levelCode: levelCode,
    subtitle: 'JLPT $levelCode vocabulary lane',
    accent: accent,
    programs: [
      _VocabCatalogProgram(
        key: '${levelCode.toLowerCase()}_core',
        titleTop: 'Hajimete no Nihongo Tango',
        titleMain: levelCode,
        termCount: liveCount,
        chapterCount: chapterCount,
        subtitle:
            'Chapter-based Hajimete track for $levelCode with seeded catalog data.',
        type: _VocabProgramType.core,
        isInteractive: coreInteractive,
        isComingSoon: liveCount == 0,
        badgeText: coreInteractive ? coreBadge : null,
      ),
      _VocabCatalogProgram(
        key: '${levelCode.toLowerCase()}_companion',
        titleTop: companionTitle,
        titleMain: levelCode,
        termCount: companionTermCount,
        chapterCount: companionStructureCount,
        subtitle: companionSubtitle,
        previewBody: companionPreviewBody,
        type: companionType,
        isInteractive: companionInteractive,
        isComingSoon: companionTermCount == 0,
        badgeText: companionTermCount > 0 ? _programBadge(companionType) : null,
      ),
      ...extraPrograms,
    ],
  );
}

String _programBadge(_VocabProgramType type) => switch (type) {
  _VocabProgramType.minna => 'Companion',
  _VocabProgramType.shinkanzen => 'Shin Kanzen',
  _VocabProgramType.listening => 'Listening',
  _VocabProgramType.advanced => 'Advanced',
  _VocabProgramType.specialized => 'Specialized',
  _ => 'Track',
};

int? _chapterCountForLevel(String levelCode) => switch (levelCode) {
  'N5' => 14,
  'N4' => 20,
  'N3' => 28,
  'N2' => 38,
  'N1' => 50,
  _ => null,
};

StudyLevel? _studyLevelFromCode(String code) => switch (code) {
  'N5' => StudyLevel.n5,
  'N4' => StudyLevel.n4,
  'N3' => StudyLevel.n3,
  _ => null,
};

(int, int)? _minnaLessonRange(String levelCode, _VocabProgramType type) {
  if (type != _VocabProgramType.minna) return null;
  return switch (levelCode) {
    'N5' => (1, 25),
    'N4' => (26, 50),
    _ => null,
  };
}

String _formatNumber(int value) {
  if (value >= 1000) {
    final compact = (value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1);
    return '${compact}k';
  }
  return '$value';
}

String _formatExactNumber(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    buffer.write(digits[index]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String _programCountLabel(_VocabCatalogProgram program, AppLanguage language) {
  if (program.termCount <= 0) return _roadmapLabel(language);
  final count = _formatExactNumber(program.termCount);
  return switch (language) {
    AppLanguage.en => '$count terms',
    AppLanguage.vi => '$count t?',
    AppLanguage.ja => '$count?',
  };
}

String _chapterSummaryLabel(int chapterCount, AppLanguage language) =>
    switch (language) {
      AppLanguage.en => '$chapterCount chapters seeded',
      AppLanguage.vi => '?? seed $chapterCount ch?ng',
      AppLanguage.ja => '$chapterCount ???????',
    };

String _formatReviewTiming(DateTime? nextReview) {
  if (nextReview == null) return 'Ready now';
  final now = DateTime.now();
  final difference = nextReview.difference(now);
  final hours = difference.inHours;
  if (hours <= 0) return 'Today';
  if (hours < 24) return 'in ${hours}h';
  final days = difference.inDays;
  return 'in ${days}d';
}

String _localizedSectionSubtitle(
  _VocabCatalogSection section,
  AppLanguage language,
) => switch (language) {
  AppLanguage.en => section.subtitle,
  AppLanguage.vi =>
    section.levelCode == 'SE'
        ? 'Tiếng Nhật chuyên ngành cho kỹ sư phần mềm'
        : 'Lane từ vựng JLPT ${section.levelCode}',
  AppLanguage.ja =>
    section.levelCode == 'SE'
        ? 'エンジニア向け専門日本語トラック'
        : 'JLPT ${section.levelCode} 語彙レーン',
};

String _localizedProgramSubtitle(
  _VocabCatalogProgram program,
  AppLanguage language,
) => switch (language) {
  AppLanguage.en => program.subtitle,
  AppLanguage.vi => _courseSubtitle(language, program.type, program.titleMain),
  AppLanguage.ja => _courseSubtitle(language, program.type, program.titleMain),
};

String _courseSubtitle(
  AppLanguage language,
  _VocabProgramType type,
  String levelCode,
) {
  return switch ((language, type)) {
    (AppLanguage.en, _VocabProgramType.minna) =>
      'Companion course that follows textbook pacing and lesson order.',
    (AppLanguage.vi, _VocabProgramType.minna) =>
      levelCode == 'N5'
          ? 'Track đồng hành theo giáo trình, bám nhịp bài học 1–25 và thứ tự từ vựng.'
          : levelCode == 'N4'
          ? 'Track đồng hành theo giáo trình, bám nhịp bài học 26–50 và thứ tự từ vựng.'
          : 'Track đồng hành theo giáo trình, bám nhịp bài học và thứ tự từ vựng.',
    (AppLanguage.ja, _VocabProgramType.minna) =>
      levelCode == 'N5'
          ? '教科書の第1課〜25課に沿って語彙順で学ぶ補助トラックです。'
          : levelCode == 'N4'
          ? '教科書の第26課〜50課に沿って語彙順で学ぶ補助トラックです。'
          : '教科書の進度と語彙順に合わせた補助トラックです。',
    (AppLanguage.en, _VocabProgramType.listening) =>
      'Listening-first training to reinforce vocabulary through audio context.',
    (AppLanguage.vi, _VocabProgramType.listening) =>
      'Luyện nghe để khóa từ vựng theo ngữ cảnh âm thanh.',
    (AppLanguage.ja, _VocabProgramType.listening) =>
      '音声コンテキストで語彙を定着させるリスニング特化トラックです。',
    (AppLanguage.en, _VocabProgramType.advanced) =>
      'Advanced expansion pack for dense N1 reading, nuance, and formal usage.',
    (AppLanguage.vi, _VocabProgramType.advanced) =>
      'Gói mở rộng nâng cao cho N1: sắc thái, văn viết và đọc khó.',
    (AppLanguage.ja, _VocabProgramType.advanced) =>
      'N1の高難度読解・ニュアンス・書き言葉に対応する上級パックです。',
    (AppLanguage.en, _VocabProgramType.specialized) =>
      'Technical Japanese for product, engineering, meetings, and documentation.',
    (AppLanguage.vi, _VocabProgramType.specialized) =>
      'Tiếng Nhật chuyên ngành cho sản phẩm, kỹ thuật, meeting và tài liệu.',
    (AppLanguage.ja, _VocabProgramType.specialized) =>
      'プロダクト・開発・会議・仕様書向けの専門日本語です。',
    (AppLanguage.en, _) =>
      'Usage-first vocabulary track for $levelCode with review-ready structure.',
    (AppLanguage.vi, _) =>
      'Track từ vựng ưu tiên cách dùng cho $levelCode, sẵn để vào review.',
    (AppLanguage.ja, _) => '$levelCode の語彙を用法重視で学び、そのまま復習へつなげます。',
  };
}

String _heroHighlight(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Learn the core',
  AppLanguage.vi => 'Học phần cốt lõi',
  AppLanguage.ja => '核を学ぶ',
};

String _heroTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => ' — not just translations',
  AppLanguage.vi => ' — không chỉ học nghĩa',
  AppLanguage.ja => ' — 訳語だけでは終わらない',
};

String _heroSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'A catalog-style workspace for JLPT and companion vocab tracks.',
  AppLanguage.vi =>
    'Một workspace kiểu catalog cho lane JLPT và các track bổ trợ.',
  AppLanguage.ja => 'JLPTと補助トラックを一つにまとめたカタログ型ワークスペースです。',
};

String _heroDescription(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Browse by lane, compare tracks side-by-side, and jump straight into review when a level is live.',
  AppLanguage.vi =>
    'Duyệt theo từng lane, so sánh các track song song, rồi nhảy thẳng vào review khi level đã mở.',
  AppLanguage.ja => 'レーンごとに比較しながら選び、利用可能なレベルはそのまま復習に入れます。',
};

String _heroScopeAllLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'All lanes',
  AppLanguage.vi => 'Toàn bộ lane',
  AppLanguage.ja => 'すべてのレーン',
};

String _heroScopeLevelLabel(AppLanguage language, String level) =>
    switch (language) {
      AppLanguage.en => 'Focused on $level',
      AppLanguage.vi => 'Đang tập trung $level',
      AppLanguage.ja => '$level を優先中',
    };

String _heroMemoryLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Spaced repetition ready',
  AppLanguage.vi => 'Sẵn cho spaced repetition',
  AppLanguage.ja => '間隔反復に対応',
};

String _heroUsageLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Usage-first catalog',
  AppLanguage.vi => 'Catalog ưu tiên cách dùng',
  AppLanguage.ja => '用法重視カタログ',
};

String _heroPanelTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Catalog overview',
  AppLanguage.vi => 'Tổng quan catalog',
  AppLanguage.ja => 'カタログ概要',
};

String _heroPanelSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'A quick snapshot of how many vocab paths are already ready inside JP Study.',
  AppLanguage.vi =>
    'Ảnh chụp nhanh số lane và track từ vựng đã sẵn sàng trong JP Study.',
  AppLanguage.ja => 'JP Study 内で利用できる語彙トラックの状況をすばやく確認できます。',
};

String _heroMetricPrograms(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Programs',
  AppLanguage.vi => 'Chương trình',
  AppLanguage.ja => 'プログラム数',
};

String _heroMetricLive(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Live now',
  AppLanguage.vi => 'Đang mở',
  AppLanguage.ja => '利用可能',
};

String _heroMetricTerms(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Visible vocab volume',
  AppLanguage.vi => 'Tổng lượng từ hiển thị',
  AppLanguage.ja => '表示語彙量',
};

String _trackLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Core track',
  AppLanguage.vi => 'Track lõi',
  AppLanguage.ja => 'コアトラック',
};

String _programTypeLabel(_VocabProgramType type, AppLanguage language) =>
    switch ((type, language)) {
      (_VocabProgramType.minna, AppLanguage.en) => 'Companion',
      (_VocabProgramType.minna, AppLanguage.vi) => 'Bổ trợ',
      (_VocabProgramType.minna, AppLanguage.ja) => '補助',
      (_VocabProgramType.listening, AppLanguage.en) => 'Listening',
      (_VocabProgramType.listening, AppLanguage.vi) => 'Luyện nghe',
      (_VocabProgramType.listening, AppLanguage.ja) => 'リスニング',
      (_VocabProgramType.advanced, AppLanguage.en) => 'Advanced',
      (_VocabProgramType.advanced, AppLanguage.vi) => 'Nâng cao',
      (_VocabProgramType.advanced, AppLanguage.ja) => '上級',
      (_VocabProgramType.specialized, AppLanguage.en) => 'Specialized',
      (_VocabProgramType.specialized, AppLanguage.vi) => 'Chuyên ngành',
      (_VocabProgramType.specialized, AppLanguage.ja) => '専門',
      (_, AppLanguage.en) => 'Track',
      (_, AppLanguage.vi) => 'Track',
      (_, AppLanguage.ja) => 'トラック',
    };

String _badgeLabel(_VocabCatalogProgram program, AppLanguage language) {
  if (program.isComingSoon) return _comingSoonLabel(language);
  if (program.isPreviewOnly) return _previewReadyLabel(language);
  return program.badgeText ?? _availableNowLabel(language);
}

String _availableNowLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Available now',
  AppLanguage.vi => 'Đã mở',
  AppLanguage.ja => '利用可能',
};

String _comingSoonLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Coming soon',
  AppLanguage.vi => 'Sắp ra mắt',
  AppLanguage.ja => '近日公開',
};

String _previewReadyLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Preview ready',
  AppLanguage.vi => '?? c? d? li?u',
  AppLanguage.ja => '???????',
};

String _roadmapLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Roadmap',
  AppLanguage.vi => 'L? tr?nh',
  AppLanguage.ja => '??????',
};

String _programAvailabilityPill(
  _VocabCatalogProgram program,
  AppLanguage language,
) {
  if (program.isInteractive) return _reviewReadyLabel(language);
  if (program.isPreviewOnly) return _previewReadyLabel(language);
  return _roadmapLabel(language);
}

String _previewDialogTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Track preview',
  AppLanguage.vi => 'Xem tr??c track',
  AppLanguage.ja => '??????????',
};

String _previewDialogClose(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Close',
  AppLanguage.vi => '??ng',
  AppLanguage.ja => '???',
};

String _previewDialogBody(AppLanguage language, _VocabCatalogProgram program) {
  if (program.previewBody != null && program.previewBody!.trim().isNotEmpty) {
    return switch (language) {
      AppLanguage.en => program.previewBody!,
      AppLanguage.vi => program.previewBody!,
      AppLanguage.ja => program.previewBody!,
    };
  }
  return switch (language) {
    AppLanguage.en =>
      'This track already has seeded vocabulary data inside JP Study. Review flow for this lane is not wired yet, but the catalog volume and content are ready for preview.',
    AppLanguage.vi =>
      'Track n?y ?? c? d? li?u t? v?ng trong JP Study. Flow review cho lane n?y ch?a n?i xong, nh?ng d? li?u v? c?u tr?c catalog ?? s?n s?ng ?? xem tr??c.',
    AppLanguage.ja => '????????JP Study????????????????????????????????????',
  };
}

String _meaningFirstLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Meaning + reading',
  AppLanguage.vi => 'Nghĩa + cách đọc',
  AppLanguage.ja => '意味 + 読み',
};

String _usageFlowLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Usage flow',
  AppLanguage.vi => 'Luồng cách dùng',
  AppLanguage.ja => '用法フロー',
};

String _reviewReadyLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review-ready',
  AppLanguage.vi => 'Sẵn để review',
  AppLanguage.ja => '復習対応',
};

String _openLaneLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open lane',
  AppLanguage.vi => 'Mở lane',
  AppLanguage.ja => 'レーンを開く',
};

String _joinTrackLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open track',
  AppLanguage.vi => 'Mở track',
  AppLanguage.ja => 'トラックを開く',
};

String _previewLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Preview',
  AppLanguage.vi => 'Xem trước',
  AppLanguage.ja => 'プレビュー',
};

String _programFooterHint(_VocabProgramType type, AppLanguage language) =>
    switch ((type, language)) {
      (_VocabProgramType.minna, AppLanguage.en) => 'Textbook-paced path',
      (_VocabProgramType.minna, AppLanguage.vi) => 'Đi theo nhịp giáo trình',
      (_VocabProgramType.minna, AppLanguage.ja) => '教科書の進度で学ぶ',
      (_VocabProgramType.listening, AppLanguage.en) =>
        'Audio-context reinforcement',
      (_VocabProgramType.listening, AppLanguage.vi) =>
        'Củng cố bằng ngữ cảnh nghe',
      (_VocabProgramType.listening, AppLanguage.ja) => '音声コンテキストで定着',
      (_VocabProgramType.advanced, AppLanguage.en) =>
        'Dense reading and nuance pack',
      (_VocabProgramType.advanced, AppLanguage.vi) => 'Gói đọc khó và sắc thái',
      (_VocabProgramType.advanced, AppLanguage.ja) => '高難度読解とニュアンス',
      (_VocabProgramType.specialized, AppLanguage.en) =>
        'Domain-specific language pack',
      (_VocabProgramType.specialized, AppLanguage.vi) =>
        'Gói ngôn ngữ theo chuyên ngành',
      (_VocabProgramType.specialized, AppLanguage.ja) => '専門領域向けパック',
      (_, AppLanguage.en) => 'Usage-first review path',
      (_, AppLanguage.vi) => 'Track review ưu tiên cách dùng',
      (_, AppLanguage.ja) => '用法重視の復習導線',
    };

String _catalogErrorTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Could not load vocab catalog',
  AppLanguage.vi => 'Không tải được catalog từ vựng',
  AppLanguage.ja => '語彙カタログを読み込めませんでした',
};

String _catalogRetryLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Retry',
  AppLanguage.vi => 'Tải lại',
  AppLanguage.ja => '再試行',
};
