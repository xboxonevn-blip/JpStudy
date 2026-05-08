import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/radical_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/repositories/radical_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/widgets/foundations_soft_suggest_gate.dart';
import 'package:jpstudy/features/foundations/widgets/han_viet_inline_panel.dart';
import 'package:jpstudy/features/kanji_hub/kanji_copy.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/kanji_hub/models/radical_detail_support.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';
import 'package:jpstudy/features/write/services/handwriting_template_matcher.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';
import 'package:jpstudy/features/write/widgets/handwriting_canvas.dart';

part 'kanji_hub_screen_parts.dart';

enum _KanjiCollection { n5, n4, n3, radicals }

class KanjiHubScreen extends ConsumerStatefulWidget {
  const KanjiHubScreen({super.key, this.initialKanjiId});

  final int? initialKanjiId;

  @override
  ConsumerState<KanjiHubScreen> createState() => _KanjiHubScreenState();
}

class _KanjiHubScreenState extends ConsumerState<KanjiHubScreen> {
  StudyLevel _selectedLevel = StudyLevel.n5;
  _KanjiCollection _selectedCollection = _KanjiCollection.n5;
  Future<List<KanjiItem>>? _kanjiFuture;
  late final Future<List<RadicalItem>> _radicalFuture;
  Future<List<KanjiItem>>? _allKanjiFuture;
  bool _didOpenInitialKanji = false;

  // Realtime filter state
  String _searchQuery = '';
  List<String> _candidateKanji = [];
  final GlobalKey<_SearchDrawPanelState> _searchDrawKey =
      GlobalKey<_SearchDrawPanelState>();
  final GlobalKey _gridPanelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _radicalFuture = const RadicalRepository().loadAll();
    if (widget.initialKanjiId != null) {
      _allKanjiFuture = _loadAllKanji();
    }
    _maybeOpenInitialKanji();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initLevel = ref.read(studyLevelProvider) ?? StudyLevel.n5;
      setState(() {
        _selectedLevel = initLevel;
        _selectedCollection = _collectionFromLevel(initLevel);
        _kanjiFuture = _fetchKanji(initLevel);
      });
    });
  }

  void _maybeOpenInitialKanji() {
    final initialKanjiId = widget.initialKanjiId;
    if (initialKanjiId == null || _didOpenInitialKanji) return;
    _didOpenInitialKanji = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final allKanji = await _allKanjiFuture!;
      if (!mounted) return;
      KanjiItem? item;
      for (final entry in allKanji) {
        if (entry.id == initialKanjiId) {
          item = entry;
          break;
        }
      }
      if (item == null) return;
      final resolvedItem = item;
      final level = StudyLevel.fromCode(resolvedItem.jlptLevel);
      if (level != null && mounted) {
        _activateLevel(level, refreshKanji: true);
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _KanjiDetailDialog(
          item: resolvedItem,
          language: ref.read(appLanguageProvider),
        ),
      );
    });
  }

  Future<List<KanjiItem>> _fetchKanji(StudyLevel level) async {
    return ref
        .read(lessonRepositoryProvider)
        .fetchKanjiByLevel(level.shortLabel);
  }

  Future<List<KanjiItem>> _loadAllKanji() async {
    final repo = ref.read(lessonRepositoryProvider);
    final buckets = await Future.wait([
      repo.fetchKanjiByLevel(StudyLevel.n5.shortLabel),
      repo.fetchKanjiByLevel(StudyLevel.n4.shortLabel),
      repo.fetchKanjiByLevel(StudyLevel.n3.shortLabel),
      repo.fetchKanjiByLevel(StudyLevel.n2.shortLabel),
      repo.fetchKanjiByLevel(StudyLevel.n1.shortLabel),
    ]);
    return [for (final bucket in buckets) ...bucket];
  }

  _KanjiCollection _collectionFromLevel(StudyLevel level) {
    switch (level) {
      case StudyLevel.n5:
        return _KanjiCollection.n5;
      case StudyLevel.n4:
        return _KanjiCollection.n4;
      case StudyLevel.n3:
        return _KanjiCollection.n3;
      case StudyLevel.n2:
        return _KanjiCollection.n3;
      case StudyLevel.n1:
        return _KanjiCollection.n3;
    }
  }

  void _onCollectionSelected(_KanjiCollection collection) {
    if (collection == _KanjiCollection.radicals) {
      // Lazily start loading all kanji the first time radicals are browsed.
      _allKanjiFuture ??= _loadAllKanji();
      setState(() {
        _selectedCollection = collection;
        _candidateKanji.clear();
      });
      return;
    }
    final level = switch (collection) {
      _KanjiCollection.n5 => StudyLevel.n5,
      _KanjiCollection.n4 => StudyLevel.n4,
      _KanjiCollection.n3 => StudyLevel.n3,
      _KanjiCollection.radicals => StudyLevel.n5,
    };
    _activateLevel(level);
  }

  void _activateLevel(StudyLevel level, {bool refreshKanji = false}) {
    ref.read(studyLevelProvider.notifier).state = level;
    setState(() {
      final levelChanged = _selectedLevel != level;
      _selectedLevel = level;
      _selectedCollection = _collectionFromLevel(level);
      if (levelChanged || refreshKanji || _kanjiFuture == null) {
        _kanjiFuture = _fetchKanji(level);
      }
    });
  }

  void _onLevelSelected(StudyLevel level) {
    _activateLevel(level, refreshKanji: _kanjiFuture == null);
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _candidateKanji.clear();
      }
    });
  }

  void _onCandidatesFound(List<String> kanji) {
    _focusCandidateKanji(kanji);
  }

  void _focusCandidateKanji(List<String> kanji) {
    final normalized = kanji
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    setState(() {
      _candidateKanji = normalized;
    });

    if (normalized.isNotEmpty && _searchQuery.isEmpty) {
      unawaited(_tryJumpToLevelOfKanji(normalized.first));
    }
  }

  void _onRelatedKanjiSelected(List<String> kanji) {
    _focusCandidateKanji(kanji);
  }

  void _onClearRequested() {
    _searchDrawKey.currentState?._clearCanvas();
  }

  Future<void> _tryJumpToLevelOfKanji(String character) async {
    final repo = ref.read(lessonRepositoryProvider);
    final currentItems = await repo.fetchKanjiByLevel(
      _selectedLevel.shortLabel,
    );
    if (currentItems.any((k) => k.character == character)) {
      if (mounted) {
        _activateLevel(_selectedLevel, refreshKanji: _kanjiFuture == null);
      }
      return;
    }

    for (final level in StudyLevel.values) {
      if (level == _selectedLevel) continue;
      final items = await repo.fetchKanjiByLevel(level.shortLabel);
      if (items.any((k) => k.character == character)) {
        if (mounted) {
          _activateLevel(level, refreshKanji: true);
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final homeSummary = ref.watch(kanjiHomeSummaryProvider);
    final isDesktop =
        MediaQuery.of(context).size.width >= AppBreakpoints.desktop;
    final isTablet = MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
    final twoColumns = isDesktop || isTablet;

    return FoundationsSoftSuggestGate(
      surface: FoundationsSoftSuggestSurface.kanji,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppPageShell(
          topPadding: AppSpacing.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, language),
                const SizedBox(height: AppSpacing.lg),
                homeSummary.when(
                  data: (summary) => _KanjiTodayPanel(
                    key: const ValueKey('kanji_today_panel'),
                    language: language,
                    summary: summary,
                    onReviewDue: () => _openPracticeHub(
                      context,
                      KanjiPracticeArgs(
                        mode: KanjiPracticeMode.both,
                        source: 'due',
                        levelCode: _selectedLevel.shortLabel,
                      ),
                    ),
                    onLearnNew: () => _openPracticeHub(
                      context,
                      KanjiPracticeArgs(
                        mode: KanjiPracticeMode.both,
                        source: 'new',
                        levelCode: _selectedLevel.shortLabel,
                      ),
                    ),
                    onExplore: () {
                      _onClearRequested();
                      _onCollectionSelected(
                        _collectionFromLevel(_selectedLevel),
                      );
                      final ctx = _gridPanelKey.currentContext;
                      if (ctx != null) {
                        Scrollable.ensureVisible(
                          ctx,
                          duration: reducedMotionDuration(
                            context,
                            const Duration(milliseconds: 350),
                          ),
                          curve: Curves.easeOut,
                          alignmentPolicy:
                              ScrollPositionAlignmentPolicy.keepVisibleAtStart,
                        );
                      }
                    },
                  ),
                  loading: () => AppFeatureCard(
                    key: const ValueKey('kanji_today_loading'),
                    icon: Icons.auto_awesome_rounded,
                    title: _kanjiSummaryLoadingTitle(language),
                    subtitle: _kanjiSummaryLoadingSubtitle(language),
                    status: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    compact: true,
                  ),
                  error: (error, stackTrace) => AppFeatureCard(
                    key: const ValueKey('kanji_today_error'),
                    icon: Icons.error_outline_rounded,
                    title: _kanjiSummaryErrorTitle(language),
                    subtitle: _kanjiSummaryErrorSubtitle(language),
                    primaryLabel: _kanjiSummaryRetryLabel(language),
                    onPrimaryTap: () =>
                        ref.invalidate(kanjiHomeSummaryProvider),
                    secondaryLabel: _kanjiExploreActionLabel(language),
                    onSecondaryTap: () {
                      _onCollectionSelected(
                        _collectionFromLevel(_selectedLevel),
                      );
                    },
                    compact: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (twoColumns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SearchDrawPanel(
                              key: _searchDrawKey,
                              language: language,
                              onSearchQueryChanged: _onSearchQueryChanged,
                              onCandidatesFound: _onCandidatesFound,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _KanjiMindmapPanel(language: language),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        flex: 6,
                        child: _KanjiGridPanel(
                          key: _gridPanelKey,
                          selectedLevel: _selectedLevel,
                          selectedCollection: _selectedCollection,
                          onLevelSelected: _onLevelSelected,
                          onCollectionSelected: _onCollectionSelected,
                          kanjiFuture: _kanjiFuture,
                          radicalFuture: _radicalFuture,
                          allKanjiFuture: _allKanjiFuture,
                          language: language,
                          searchQuery: _searchQuery,
                          candidateKanji: _candidateKanji,
                          onClearRequested: _onClearRequested,
                          onRelatedKanjiSelected: _onRelatedKanjiSelected,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _KanjiGridPanel(
                        key: _gridPanelKey,
                        selectedLevel: _selectedLevel,
                        selectedCollection: _selectedCollection,
                        onLevelSelected: _onLevelSelected,
                        onCollectionSelected: _onCollectionSelected,
                        kanjiFuture: _kanjiFuture,
                        radicalFuture: _radicalFuture,
                        allKanjiFuture: _allKanjiFuture,
                        language: language,
                        searchQuery: _searchQuery,
                        candidateKanji: _candidateKanji,
                        onClearRequested: _onClearRequested,
                        onRelatedKanjiSelected: _onRelatedKanjiSelected,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SearchDrawPanel(
                        key: _searchDrawKey,
                        language: language,
                        onSearchQueryChanged: _onSearchQueryChanged,
                        onCandidatesFound: _onCandidatesFound,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _KanjiMindmapPanel(language: language),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPracticeHub(BuildContext context, KanjiPracticeArgs args) {
    context.openKanjiPractice(extra: args);
  }

  Widget _buildHeader(BuildContext context, AppLanguage language) {
    return AppSectionHeader(
      title: language.kanjiHubTitle(),
      caption: language.kanjiHubCaption(),
    );
  }
}

String _previewMeaning(KanjiItem item) {
  final meaningEn = item.meaningEn?.trim();
  if (meaningEn != null && meaningEn.isNotEmpty) {
    return meaningEn;
  }
  return item.meaning;
}

void _launchLevelPractice(
  BuildContext context,
  String levelCode,
  KanjiPracticeMode mode,
) {
  final level = StudyLevel.fromCode(levelCode);
  if (level == null) return;
  ProviderScope.containerOf(
    context,
    listen: false,
  ).read(studyLevelProvider.notifier).state = level;
  Navigator.of(context).pop();
  context.push(
    '/kanji/practice',
    extra: KanjiPracticeArgs(
      mode: mode,
      source: 'level_group',
      levelCode: levelCode,
    ),
  );
}

void _launchKanjiUtility(BuildContext context, KanjiItem item, String route) {
  final level = StudyLevel.fromCode(item.jlptLevel);
  if (level != null) {
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(studyLevelProvider.notifier).state = level;
  }
  Navigator.of(context).pop();
  if (route == '/practice/handwriting') {
    context.push(
      '/kanji/practice',
      extra: KanjiPracticeArgs(
        mode: KanjiPracticeMode.write,
        source: 'focus',
        levelCode: item.jlptLevel,
        kanjiIds: [item.id],
        preferredKanjiId: item.id,
      ),
    );
    return;
  }
  context.push(route);
}

void _launchKanjiPractice(BuildContext context, KanjiItem item) {
  final level = StudyLevel.fromCode(item.jlptLevel);
  if (level != null) {
    ProviderScope.containerOf(
      context,
      listen: false,
    ).read(studyLevelProvider.notifier).state = level;
  }
  Navigator.of(context).pop();
  context.push(
    '/kanji/practice',
    extra: KanjiPracticeArgs(
      mode: KanjiPracticeMode.both,
      source: 'focus',
      levelCode: item.jlptLevel,
      kanjiIds: [item.id],
      preferredKanjiId: item.id,
    ),
  );
}

String _formatKanjiExample(KanjiExample example) {
  final word = example.word.trim();
  final reading = example.reading.trim();
  final meaning = (example.meaningEn?.trim().isNotEmpty ?? false)
      ? example.meaningEn!.trim()
      : example.meaning.trim();
  final parts = <String>[];
  if (word.isNotEmpty) parts.add(word);
  if (reading.isNotEmpty) parts.add('($reading)');
  if (meaning.isNotEmpty) parts.add('? $meaning');
  return parts.join(' ');
}

String _kanjiHubClearLabel(AppLanguage language) => language.kanjiClearLabel();

String _srsFilterLabel(
  AppLanguage lang,
  _KanjiSrsFilter filter,
  int total,
  Set<int> dueIds,
  Set<int> seenIds,
) {
  final dueCount = dueIds.length;
  final unseenCount = total - seenIds.length - dueIds.length < 0
      ? 0
      : total - seenIds.length;
  final studiedCount = seenIds.length - dueIds.length < 0
      ? 0
      : seenIds.length - dueIds.length;
  return switch (filter) {
    _KanjiSrsFilter.all => lang.kanjiSrsFilterAllLabel(total),
    _KanjiSrsFilter.due => lang.kanjiSrsFilterDueLabel(dueCount),
    _KanjiSrsFilter.unseen => lang.kanjiSrsFilterUnseenLabel(unseenCount),
    _KanjiSrsFilter.studied => lang.kanjiSrsFilterStudiedLabel(studiedCount),
  };
}

Color _srsFilterColor(_KanjiSrsFilter filter, AppThemePalette palette) =>
    switch (filter) {
      _KanjiSrsFilter.all => palette.ink.withValues(alpha: 0.55),
      _KanjiSrsFilter.due => palette.warning,
      _KanjiSrsFilter.unseen => palette.accent,
      _KanjiSrsFilter.studied => palette.success,
    };

String _kanjiHubStrokeChipLabel(AppLanguage language, int count) =>
    language.kanjiStrokeChipLabel(count);

String _kanjiHubClearFiltersLabel(AppLanguage language) =>
    language.kanjiClearFiltersLabel();

String _kanjiHubStudyWord(AppLanguage language) =>
    language.kanjiStudyWordLabel();

String _kanjiHubSearchLabel(AppLanguage language) =>
    language.kanjiSearchLabel();

String _kanjiHubFlashcardLabel(AppLanguage language) =>
    language.kanjiPracticeThisLabel();

String _kanjiTodayTitle(AppLanguage language) => language.kanjiTodayTitle();

String _kanjiTodayCaption(AppLanguage language, String levelCode) =>
    language.kanjiTodayCaption(levelCode);

String _kanjiDueActionLabel(AppLanguage language) =>
    language.kanjiDueActionLabel();

String _kanjiDueActionSubtitle(AppLanguage language, int count) =>
    language.kanjiDueActionSubtitle(count);

String _kanjiNewActionLabel(AppLanguage language) =>
    language.kanjiNewActionLabel();

String _kanjiNewActionSubtitle(AppLanguage language, int count) =>
    language.kanjiNewActionSubtitle(count);

String _kanjiExploreActionLabel(AppLanguage language) =>
    language.kanjiExploreActionLabel();

String _kanjiExploreActionSubtitle(AppLanguage language, int count) =>
    language.kanjiExploreActionSubtitle(count);

String _kanjiHubWriteLabel(AppLanguage language) => language.kanjiWriteLabel();

String _kanjiSummaryLoadingTitle(AppLanguage language) =>
    language.kanjiSummaryLoadingTitle();

String _kanjiSummaryLoadingSubtitle(AppLanguage language) =>
    language.kanjiSummaryLoadingSubtitle();

String _kanjiSummaryErrorTitle(AppLanguage language) =>
    language.kanjiSummaryErrorTitle();

String _kanjiSummaryErrorSubtitle(AppLanguage language) =>
    language.kanjiSummaryErrorSubtitle();

String _kanjiSummaryRetryLabel(AppLanguage language) =>
    language.kanjiSummaryRetryLabel();

AppLanguage _kanjiHubDialogLanguage(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return switch (code) {
    'ja' => AppLanguage.ja,
    'en' => AppLanguage.en,
    _ => AppLanguage.vi,
  };
}

String _radicalNumberLabel(BuildContext context, int id) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiRadicalNumberLabel(id);
}

String _hanVietLabel(BuildContext context) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiHubHanVietLabel();
}

String _strokeLabel(BuildContext context, int strokes) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiStrokeLabel(strokes);
}

String _radicalShortLabel(BuildContext context, int id) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiRadicalShortLabel(id);
}

String _relatedKanjiLabel(BuildContext context) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiRelatedKanjiLabel();
}

String _relatedCountLabel(BuildContext context) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiRelatedCountLabel();
}

String _openAllRelatedLabel(BuildContext context, int count) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiOpenAllRelatedLabel(count);
}

String _openLevelRelatedLabel(BuildContext context, String level) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiOpenLevelRelatedLabel(level);
}

String _flashcardLaneLabel(BuildContext context, String level) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiFlashcardLaneLabel(level);
}

String _writeLaneLabel(BuildContext context, String level) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiWriteLaneLabel(level);
}

String _relatedLevelSectionLabel(
  BuildContext context,
  String level,
  int count,
) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiRelatedLevelSectionLabel(level, count);
}

String _rawMeaningLabel(BuildContext context, String raw) {
  final language = _kanjiHubDialogLanguage(context);
  return language.kanjiRawMeaningLabel(raw);
}
