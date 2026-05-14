import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/utils/kana_romaji.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/foundations/widgets/foundations_soft_suggest_gate.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';
import 'package:jpstudy/features/vocab/providers/vocab_home_provider.dart';

part 'vocab_screen_parts.dart';

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
  final language = ref.watch(appLanguageProvider);

  // Subscribe only to vocabDue — streak/XP ticks won't re-fire all 13 queries.
  final dueCount = ref.watch(
    dashboardProvider.select((v) => v.value?.vocabDue ?? 0),
  );
  // Use current stream value; null while stream hasn't emitted yet (fine since
  // nextReview is nullable). Provider re-runs when stream emits a new value.
  final nextReview = ref.watch(nextVocabReviewProvider).value;

  // Catalog cards need availability/counts, not full vocab row hydration.
  // Count all real tracks so data-backed programs do not look locked merely
  // because another JLPT level is selected.
  Future<int> hajimeteCount(String levelCode) async {
    final storedCount = await repo.countVocabByLevelAndSeries(
      levelCode,
      'hajimete',
    );
    if (storedCount > 0) return storedCount;

    try {
      final catalog = await loadHajimeteChapterCatalog(
        levelCode,
      ).timeout(const Duration(seconds: 1));
      return catalog.totalTerms;
    } catch (_) {
      return storedCount;
    }
  }

  Future<int> shinkanzenCount(String levelCode) =>
      repo.countVocabByLevelAndSeries(levelCode, 'ShinKanzen');

  Future<_SeriesManifestSummary> shinkanzenSummary(String levelCode) =>
      _loadShinkanzenManifestSummary(levelCode);

  final n5CountFuture = hajimeteCount('N5');
  final n4CountFuture = hajimeteCount('N4');
  final n3CountFuture = hajimeteCount('N3');
  final n2CountFuture = hajimeteCount('N2');
  final n1CountFuture = hajimeteCount('N1');
  final shinkanzenN3CountFuture = shinkanzenCount('N3');
  final shinkanzenN2CountFuture = shinkanzenCount('N2');
  final shinkanzenN1CountFuture = shinkanzenCount('N1');
  final shinkanzenN3SummaryFuture = shinkanzenSummary('N3');
  final shinkanzenN2SummaryFuture = shinkanzenSummary('N2');
  final shinkanzenN1SummaryFuture = shinkanzenSummary('N1');
  final minnaN5CountFuture = repo
      .getVocabByLessonRange(
        'N5',
        startLesson: 1,
        endLesson: 25,
        series: 'minna',
      )
      .then((items) => items.length);
  final minnaN4CountFuture = repo
      .getVocabByLessonRange(
        'N4',
        startLesson: 26,
        endLesson: 50,
        series: 'minna',
      )
      .then((items) => items.length);

  final n5Count = await n5CountFuture;
  final n4Count = await n4CountFuture;
  final n3Count = await n3CountFuture;
  final n2Count = await n2CountFuture;
  final n1Count = await n1CountFuture;
  final shinkanzenN3Count = await shinkanzenN3CountFuture;
  final shinkanzenN2Count = await shinkanzenN2CountFuture;
  final shinkanzenN1Count = await shinkanzenN1CountFuture;
  final shinkanzenN3Summary = await shinkanzenN3SummaryFuture;
  final shinkanzenN2Summary = await shinkanzenN2SummaryFuture;
  final shinkanzenN1Summary = await shinkanzenN1SummaryFuture;
  final minnaN5Count = await minnaN5CountFuture;
  final minnaN4Count = await minnaN4CountFuture;
  final shinkanzenN3TermCount = shinkanzenN3Summary.importedTermCount > 0
      ? shinkanzenN3Summary.importedTermCount
      : shinkanzenN3Count;
  final shinkanzenN2TermCount = shinkanzenN2Summary.importedTermCount > 0
      ? shinkanzenN2Summary.importedTermCount
      : shinkanzenN2Count;
  final shinkanzenN1TermCount = shinkanzenN1Summary.importedTermCount > 0
      ? shinkanzenN1Summary.importedTermCount
      : shinkanzenN1Count;

  int shinkanzenRouteCount(_SeriesManifestSummary summary) =>
      summary.routeCount > 0 ? summary.routeCount : 25;

  return [
    _buildJlptSection(
      levelCode: 'N5',
      liveCount: n5Count,
      dueCount: dueCount,
      nextReview: nextReview,
      accent: AppThemePalette.light.warning,
      companionTitle: 'Minna no Nihongo I',
      companionSubtitle: _courseSubtitle(
        language,
        _VocabProgramType.minna,
        'N5',
      ),
      companionType: _VocabProgramType.minna,
      companionCountOverride: minnaN5Count,
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N4',
      liveCount: n4Count,
      dueCount: dueCount,
      nextReview: nextReview,
      accent: AppThemePalette.light.primary,
      companionTitle: 'Minna no Nihongo II',
      companionSubtitle: _courseSubtitle(
        language,
        _VocabProgramType.minna,
        'N4',
      ),
      companionType: _VocabProgramType.minna,
      companionCountOverride: minnaN4Count,
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N3',
      liveCount: n3Count,
      dueCount: dueCount,
      nextReview: nextReview,
      accent: AppThemePalette.light.success,
      companionTitle: 'Shin Kanzen Master',
      companionSubtitle: _courseSubtitle(
        language,
        _VocabProgramType.shinkanzen,
        'N3',
      ),
      companionType: _VocabProgramType.shinkanzen,
      companionCountOverride: shinkanzenN3TermCount,
      companionStructureCount: shinkanzenRouteCount(shinkanzenN3Summary),
      companionPreviewBody:
          'Official 3A category route mapped for N3. ${shinkanzenN3Summary.readyRouteCount}/${shinkanzenRouteCount(shinkanzenN3Summary)} route blocks are already imported with $shinkanzenN3TermCount seeded terms in JP Study.',
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N2',
      liveCount: n2Count,
      dueCount: dueCount,
      nextReview: nextReview,
      accent: AppThemePalette.light.error,
      companionTitle: 'Shin Kanzen Master',
      companionSubtitle: _courseSubtitle(
        language,
        _VocabProgramType.shinkanzen,
        'N2',
      ),
      companionType: _VocabProgramType.shinkanzen,
      companionCountOverride: shinkanzenN2TermCount,
      companionStructureCount: shinkanzenRouteCount(shinkanzenN2Summary),
      companionPreviewBody:
          'Official 3A confirmation-test route mapped for N2. ${shinkanzenN2Summary.readyRouteCount}/${shinkanzenRouteCount(shinkanzenN2Summary)} tests are already imported with $shinkanzenN2TermCount seeded terms in JP Study.',
      isInteractive: true,
    ),
    _buildJlptSection(
      levelCode: 'N1',
      liveCount: n1Count,
      dueCount: dueCount,
      nextReview: nextReview,
      accent: AppThemePalette.light.info,
      companionTitle: 'Shin Kanzen Master',
      companionSubtitle: _courseSubtitle(
        language,
        _VocabProgramType.shinkanzen,
        'N1',
      ),
      companionType: _VocabProgramType.shinkanzen,
      companionCountOverride: shinkanzenN1TermCount,
      companionStructureCount: shinkanzenRouteCount(shinkanzenN1Summary),
      companionPreviewBody:
          'Official 3A confirmation-test route mapped for N1. ${shinkanzenN1Summary.readyRouteCount}/${shinkanzenRouteCount(shinkanzenN1Summary)} tests are imported with $shinkanzenN1TermCount seeded terms so far.',
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
    _VocabCatalogSection(
      key: 'se',
      levelCode: 'SE',
      subtitle: 'Specialized Japanese for software teams',
      accent: AppThemePalette.light.ink,
      programs: const [
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
    final homeAsync = ref.watch(vocabHomeSectionProvider);

    return FoundationsSoftSuggestGate(
      surface: FoundationsSoftSuggestSurface.vocab,
      child: Scaffold(
        body: AppPageShell(
          topPadding: AppSpacing.md,
          child: catalogAsync.when(
            data: (sections) => homeAsync.when(
              data: (home) => _VocabCatalogBody(
                language: language,
                sections: sections,
                home: home,
              ),
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
                onSecondaryTap: () {
                  ref.invalidate(vocabCatalogProvider);
                  ref.invalidate(vocabHomeSectionProvider);
                },
              ),
            ),
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
      ),
    );
  }
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
  if (program.termCount <= 0) return language.vocabRoadmapLabel();
  final count = _formatExactNumber(program.termCount);
  return language.vocabProgramCountLabel(count);
}

String _todayTitle(AppLanguage language) => language.vocabTodayTitle();

String _todayCaption(AppLanguage language) => language.vocabTodayCaption();

String _dueNowLabel(AppLanguage language) => language.vocabDueNowLabel();

String _activeLaneLabel(AppLanguage language) =>
    language.vocabActiveLaneLabel();

String _nextWindowLabel(AppLanguage language) =>
    language.vocabNextWindowLabel();

String _reviewNowLabel(AppLanguage language) => language.vocabReviewNowLabel();

String _todayReviewTitle(AppLanguage language, String levelCode) =>
    language.vocabReviewTitle(levelCode);

String _todayReviewSubtitle(
  AppLanguage language,
  int dueCount,
  DateTime? nextReview,
) => language.vocabReviewSubtitle(dueCount, _formatReviewTiming(nextReview));

String _currentTrackLine(AppLanguage language, VocabTrackSummary track) =>
    language.vocabCurrentTrackLine(track.title, track.termCount);

String _liveCatalogTitle(AppLanguage language) =>
    language.vocabLiveCatalogTitle();

String _liveCatalogCaption(AppLanguage language) =>
    language.vocabLiveCatalogCaption();

String _previewCatalogTitle(AppLanguage language) =>
    language.vocabPreviewCatalogTitle();

String _previewCatalogCaption(AppLanguage language) =>
    language.vocabPreviewCatalogCaption();

String _chapterSummaryLabel(int chapterCount, AppLanguage language) =>
    language.vocabChapterSummaryLabel(chapterCount);

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
) =>
    language.vocabLocalizedSectionSubtitle(section.levelCode, section.subtitle);

String _localizedProgramSubtitle(
  _VocabCatalogProgram program,
  AppLanguage language,
) => language.vocabLocalizedProgramSubtitle(
  program.type.name,
  program.titleMain,
  program.subtitle,
);

String _courseSubtitle(
  AppLanguage language,
  _VocabProgramType type,
  String levelCode,
) => language.vocabCourseSubtitle(type.name, levelCode);

String _heroHighlight(AppLanguage language) => language.vocabHeroHighlight();

String _heroTitle(AppLanguage language) => language.vocabHeroTitle();

String _heroSubtitle(AppLanguage language) => language.vocabHeroSubtitle();

String _heroDescription(AppLanguage language) =>
    language.vocabHeroDescription();

String _heroScopeAllLabel(AppLanguage language) =>
    language.vocabHeroScopeAllLabel();

String _heroScopeLevelLabel(AppLanguage language, String level) =>
    language.vocabHeroScopeLevelLabel(level);

String _heroMemoryLabel(AppLanguage language) =>
    language.vocabHeroMemoryLabel();

String _heroUsageLabel(AppLanguage language) => language.vocabHeroUsageLabel();

String _heroPanelTitle(AppLanguage language) => language.vocabHeroPanelTitle();

String _heroPanelSubtitle(AppLanguage language) =>
    language.vocabHeroPanelSubtitle();

String _heroMetricPrograms(AppLanguage language) =>
    language.vocabHeroMetricPrograms();

String _heroMetricLive(AppLanguage language) => language.vocabHeroMetricLive();

String _heroMetricTerms(AppLanguage language) =>
    language.vocabHeroMetricTerms();

String _trackLabel(AppLanguage language) => language.vocabTrackLabel();

String _programTypeLabel(_VocabProgramType type, AppLanguage language) =>
    language.vocabProgramTypeLabel(type.name);

String _badgeLabel(_VocabCatalogProgram program, AppLanguage language) {
  if (program.isComingSoon) return _comingSoonLabel(language);
  if (program.isPreviewOnly) return _previewReadyLabel(language);
  return program.badgeText ?? _availableNowLabel(language);
}

String _availableNowLabel(AppLanguage language) =>
    language.vocabAvailableNowLabel();

String _comingSoonLabel(AppLanguage language) =>
    language.vocabComingSoonLabel();

String _previewReadyLabel(AppLanguage language) =>
    language.vocabPreviewReadyLabel();

String _roadmapLabel(AppLanguage language) => language.vocabRoadmapLabel();

String _programAvailabilityPill(
  _VocabCatalogProgram program,
  AppLanguage language,
) {
  if (program.isInteractive) return _reviewReadyLabel(language);
  if (program.isPreviewOnly) return _previewReadyLabel(language);
  return _roadmapLabel(language);
}

String _previewDialogTitle(AppLanguage language) =>
    language.vocabPreviewDialogTitle();

String _previewDialogClose(AppLanguage language) =>
    language.vocabPreviewDialogClose();

String _previewDialogBody(AppLanguage language, _VocabCatalogProgram program) {
  if (program.previewBody != null && program.previewBody!.trim().isNotEmpty) {
    return program.previewBody!;
  }
  return language.vocabDefaultPreviewDialogBody();
}

String _meaningFirstLabel(AppLanguage language) =>
    language.vocabMeaningFirstLabel();

String _usageFlowLabel(AppLanguage language) => language.vocabUsageFlowLabel();

String _reviewReadyLabel(AppLanguage language) =>
    language.vocabReviewReadyLabel();

String _openLaneLabel(AppLanguage language) => language.vocabOpenLaneLabel();

String _joinTrackLabel(AppLanguage language) => language.vocabJoinTrackLabel();

String _previewLabel(AppLanguage language) => language.vocabPreviewLabel();

String _programFooterHint(_VocabProgramType type, AppLanguage language) =>
    language.vocabProgramFooterHint(type.name);

String? _programScopeNote(_VocabProgramType type, AppLanguage language) =>
    switch (type) {
      _VocabProgramType.minna => language.vocabCatalogMinnaNote,
      _VocabProgramType.shinkanzen => language.vocabCatalogShinKanzenNote,
      _ => null,
    };

String _catalogErrorTitle(AppLanguage language) =>
    language.vocabCatalogErrorTitle();

String _catalogRetryLabel(AppLanguage language) =>
    language.vocabCatalogRetryLabel();
