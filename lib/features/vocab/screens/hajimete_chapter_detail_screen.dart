import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_detail_support.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/shared/widgets/confidence_rating.dart';
import 'package:jpstudy/features/flashcards/widgets/enhanced_flashcard.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/vocab/models/vocab_match_session_args.dart';

class HajimeteChapterDetailScreen extends ConsumerStatefulWidget {
  const HajimeteChapterDetailScreen({
    super.key,
    required this.levelCode,
    required this.chapterId,
    required this.laneTitle,
  });

  final String levelCode;
  final int chapterId;
  final String laneTitle;

  @override
  ConsumerState<HajimeteChapterDetailScreen> createState() =>
      _HajimeteChapterDetailScreenState();
}

class _HajimeteChapterDetailScreenState
    extends ConsumerState<HajimeteChapterDetailScreen> {
  _ChapterStudyMode _mode = _ChapterStudyMode.flashcards;
  bool _showHints = true;
  bool _shuffle = false;
  bool _autoPlay = false;
  int _currentIndex = 0;
  int _reviewIndex = 0;
  int _reviewedCount = 0;
  int _againCount = 0;
  int _hardCount = 0;
  int _goodCount = 0;
  int _easyCount = 0;
  Timer? _autoTimer;
  List<int>? _shuffledOrder;
  final Random _random = Random();
  Set<int> _syncedTermIds = <int>{};
  final Set<int> _starredTermIds = <int>{};

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducedMotionEnabled(context) && _autoPlay) {
      _stopAutoPlay(notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final args = HajimeteChapterDetailArgs(
      levelCode: widget.levelCode,
      chapterId: widget.chapterId,
      laneTitle: widget.laneTitle,
    );
    final detailAsync = ref.watch(hajimeteChapterDetailProvider(args));
    final kanjiAsync = ref.watch(hajimeteKanjiChapterProvider(args));
    final itemsAsync = ref.watch(hajimeteChapterItemsProvider(args));
    final dueItemsAsync = ref.watch(hajimeteChapterDueItemsProvider(args));
    final srsStatesAsync = ref.watch(hajimeteChapterSrsStatesProvider(args));
    final userTermsAsync = ref.watch(hajimeteChapterUserTermsProvider(args));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${widget.levelCode} / ${widget.laneTitle}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            userTermsAsync.when(
              data: (userTerms) {
                _maybeSyncStarFlags(userTerms);
                final isSaved =
                    userTerms.isNotEmpty &&
                    _starredTermIds.length == userTerms.length;
                return _SavedPill(
                  label: _savedLabel(language),
                  active: isSaved,
                  onTap: userTerms.isEmpty
                      ? null
                      : () => _toggleSaved(userTerms, args),
                );
              },
              loading: () => _SavedPill(
                label: _savedLabel(language),
                active: false,
                onTap: null,
              ),
              error: (_, _) => _SavedPill(
                label: _savedLabel(language),
                active: false,
                onTap: null,
              ),
            ),
            const SizedBox(width: 12),
          ],
          bottom: TabBar(
            labelColor: palette.primary,
            unselectedLabelColor: palette.ink.withValues(alpha: 0.55),
            indicatorColor: palette.primary,
            tabs: [
              Tab(text: _vocabTabLabel(language)),
              Tab(text: _kanjiTabLabel(language)),
            ],
          ),
        ),
        body: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return _EmptyState(language: language);
            }
            final rawItems = itemsAsync.value ?? _toVocabItems(detail);
            final items = _orderedItems(rawItems);
            final dueItems = dueItemsAsync.value ?? const <VocabItem>[];
            final srsStates =
                srsStatesAsync.value ?? const <int, SrsStateData>{};
            final userTerms =
                userTermsAsync.value ?? const <UserLessonTermData>[];
            _maybeSyncStarFlags(userTerms);
            final userTermsByItemId = mapHajimeteUserTermsByItemId(
              items,
              userTerms,
            );
            final learnedCount = srsStates.length;
            final total = items.length;
            final currentIndex = total == 0
                ? 0
                : _currentIndex.clamp(0, total - 1);
            final currentItem = total == 0 ? null : items[currentIndex];
            final dueCount = dueItems.length;
            final reviewIndex = dueCount == 0
                ? 0
                : _reviewIndex.clamp(0, dueCount - 1);
            final currentDueItem = dueCount == 0 ? null : dueItems[reviewIndex];
            final currentUserTerm = currentItem == null
                ? null
                : userTermsByItemId[currentItem.id];
            final currentDueUserTerm = currentDueItem == null
                ? null
                : userTermsByItemId[currentDueItem.id];
            final currentRetrievability = currentDueItem == null
                ? null
                : hajimeteRetrievabilityForItem(currentDueItem, srsStates);
            return TabBarView(
              children: [
                _VocabTabView(
                  language: language,
                  mode: _mode,
                  total: total,
                  learnedCount: learnedCount,
                  dueCount: dueCount,
                  detailTitle: detail.title,
                  items: items,
                  rawItems: rawItems,
                  currentItem: currentItem,
                  currentDueItem: currentDueItem,
                  currentUserTerm: currentUserTerm,
                  currentDueUserTerm: currentDueUserTerm,
                  currentRetrievability: currentRetrievability,
                  starredTermIds: _starredTermIds,
                  showHints: _showHints,
                  shuffle: _shuffle,
                  autoPlay: _autoPlay,
                  reviewedCount: _reviewedCount,
                  againCount: _againCount,
                  hardCount: _hardCount,
                  goodCount: _goodCount,
                  easyCount: _easyCount,
                  onModeChanged: (mode) => setState(() => _mode = mode),
                  onLearn: () => _openLearn(items, detail.title),
                  onTest: () => _openTest(items, detail.title),
                  onMatch: () => _openMatch(items, detail.title),
                  onWrite: () => _openWrite(items, detail.title),
                  onToggleCurrentStar:
                      (_mode == _ChapterStudyMode.review
                              ? currentDueUserTerm
                              : currentUserTerm) ==
                          null
                      ? null
                      : () => _toggleStar(
                          _mode == _ChapterStudyMode.review
                              ? currentDueUserTerm!
                              : currentUserTerm!,
                          args,
                        ),
                  onShowHintsChanged: (value) =>
                      setState(() => _showHints = value),
                  onToggleShuffle: _toggleShuffle,
                  onToggleAutoPlay: () => _toggleAutoPlay(total),
                  onPrev: () => _goPrev(total),
                  onNext: () => _goNext(total),
                  onStartLearning: () => _startReviewLearning(rawItems, args),
                  onReviewRate: currentDueItem == null
                      ? null
                      : (level) => _handleReviewRating(
                          currentDueItem,
                          level.value,
                          args,
                        ),
                ),
                _KanjiTab(
                  language: language,
                  chapterTitle: detail.title,
                  levelCode: detail.levelCode,
                  kanjiAsync: kanjiAsync,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              _ErrorState(language: language, message: error.toString()),
        ),
      ),
    );
  }

  List<VocabItem> _toVocabItems(HajimeteChapterDetail detail) {
    return [
      for (var index = 0; index < detail.entries.length; index++)
        VocabItem(
          id: detail.chapterId * 1000 + index + 1,
          term: detail.entries[index].term,
          reading: detail.entries[index].reading,
          meaning: detail.entries[index].meaningVi,
          meaningEn: detail.entries[index].meaningEn,
          level: detail.levelCode,
        ),
    ];
  }

  List<VocabItem> _orderedItems(List<VocabItem> items) {
    if (!_shuffle || items.isEmpty) {
      _shuffledOrder = null;
      return items;
    }
    final ids = items.map((item) => item.id).toSet();
    final order = _shuffledOrder;
    if (order == null ||
        order.length != ids.length ||
        !order.every(ids.contains)) {
      _shuffledOrder = ids.toList()..shuffle(_random);
    }
    final byId = {for (final item in items) item.id: item};
    return _shuffledOrder!.map((id) => byId[id]!).toList();
  }

  void _toggleShuffle() {
    setState(() {
      _shuffle = !_shuffle;
      _currentIndex = 0;
      _shuffledOrder = null;
    });
  }

  void _toggleAutoPlay(int total) {
    if (_autoPlay) {
      _stopAutoPlay();
      return;
    }
    if (reducedMotionEnabled(context)) {
      return;
    }
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || reducedMotionEnabled(context)) {
        _stopAutoPlay();
        return;
      }
      _goNext(total);
    });
    setState(() => _autoPlay = true);
  }

  void _stopAutoPlay({bool notify = true}) {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (!_autoPlay) {
      return;
    }
    if (notify && mounted) {
      setState(() => _autoPlay = false);
    } else {
      _autoPlay = false;
    }
  }

  void _goPrev(int total) {
    if (total == 0) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + total) % total;
    });
  }

  void _goNext(int total) {
    if (total == 0) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % total;
    });
  }

  void _openLearn(List<VocabItem> items, String chapterTitle) {
    context.openLearnSession(
      LearnSessionArgs(
        items: items,
        lessonId: -widget.chapterId,
        lessonTitle: chapterTitle,
      ),
    );
  }

  void _openTest(List<VocabItem> items, String chapterTitle) {
    context.openLearnSession(
      LearnSessionArgs(
        items: items,
        lessonId: -widget.chapterId,
        lessonTitle: '$chapterTitle - Test',
        enabledTypes: const [
          QuestionType.multipleChoice,
          QuestionType.trueFalse,
          QuestionType.fillBlank,
        ],
      ),
    );
  }

  void _openWrite(List<VocabItem> items, String chapterTitle) {
    context.openLearnSession(
      LearnSessionArgs(
        items: items,
        lessonId: -widget.chapterId,
        lessonTitle: '$chapterTitle - Write',
        enabledTypes: const [QuestionType.fillBlank],
      ),
    );
  }

  void _openMatch(List<VocabItem> items, String chapterTitle) {
    context.push(
      '/vocab/match-session',
      extra: VocabMatchSessionArgs(items: items, title: chapterTitle),
    );
  }

  void _maybeSyncStarFlags(List<UserLessonTermData> terms) {
    final ids = terms.map((term) => term.id).toSet();
    final starred = terms
        .where((term) => term.isStarred)
        .map((term) => term.id)
        .toSet();
    final needsSync =
        !_setsEqual(ids, _syncedTermIds) ||
        !_setsEqual(starred, _starredTermIds);
    if (!needsSync) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _syncedTermIds = ids;
        _starredTermIds
          ..clear()
          ..addAll(starred);
      });
    });
  }

  bool _setsEqual(Set<int> a, Set<int> b) {
    return a.length == b.length && a.containsAll(b);
  }

  Future<void> _toggleSaved(
    List<UserLessonTermData> terms,
    HajimeteChapterDetailArgs args,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    final shouldStarAll = _starredTermIds.length != terms.length;
    setState(() {
      if (shouldStarAll) {
        _starredTermIds
          ..clear()
          ..addAll(terms.map((term) => term.id));
      } else {
        _starredTermIds.clear();
      }
    });
    final lessonId = await repo.ensureHajimeteChapterLesson(
      level: args.levelCode,
      chapterId: args.chapterId,
      title: args.laneTitle,
    );
    await repo.setStarredForLesson(lessonId, shouldStarAll);
    ref.invalidate(hajimeteChapterUserTermsProvider(args));
  }

  Future<void> _toggleStar(
    UserLessonTermData term,
    HajimeteChapterDetailArgs args,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    final nextValue = !_starredTermIds.contains(term.id);
    setState(() {
      if (nextValue) {
        _starredTermIds.add(term.id);
      } else {
        _starredTermIds.remove(term.id);
      }
    });
    await repo.updateTermStar(
      term.id,
      lessonId: term.lessonId,
      isStarred: nextValue,
    );
    ref.invalidate(hajimeteChapterUserTermsProvider(args));
  }

  void _showNextReviewToast(DateTime? nextReviewAt, int quality) {
    if (nextReviewAt == null || !mounted) return;
    final language = ref.read(appLanguageProvider);
    final days = nextReviewAt.difference(DateTime.now()).inDays;
    final label = days == 0
        ? language.todayLabel
        : days == 1
        ? language.tomorrowLabel
        : language.inDaysLabel(days);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(language.nextReviewToastLabel(label)),
        backgroundColor: quality <= 2
            ? context.appPalette.warning
            : context.appPalette.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _startReviewLearning(
    List<VocabItem> items,
    HajimeteChapterDetailArgs args,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    await repo.initializeSrsForTermIds(items.map((item) => item.id).toList());
    ref.invalidate(hajimeteChapterDueItemsProvider(args));
    ref.invalidate(hajimeteChapterSrsStatesProvider(args));
    setState(() {
      _reviewIndex = 0;
      _reviewedCount = 0;
      _againCount = 0;
      _hardCount = 0;
      _goodCount = 0;
      _easyCount = 0;
      _mode = _ChapterStudyMode.review;
    });
  }

  Future<void> _handleReviewRating(
    VocabItem item,
    int quality,
    HajimeteChapterDetailArgs args,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    final fsrsResult = await repo.saveTermReview(
      termId: item.id,
      quality: quality,
    );
    _showNextReviewToast(fsrsResult?.nextReviewAt, quality);
    ref.invalidate(hajimeteChapterDueItemsProvider(args));
    ref.invalidate(hajimeteChapterSrsStatesProvider(args));
    setState(() {
      _reviewedCount += 1;
      switch (quality) {
        case 1:
          _againCount += 1;
          break;
        case 2:
          _hardCount += 1;
          break;
        case 3:
          _goodCount += 1;
          break;
        case 4:
          _easyCount += 1;
          break;
      }
      _reviewIndex = 0;
    });
  }
}

class _VocabTabView extends StatelessWidget {
  const _VocabTabView({
    required this.language,
    required this.mode,
    required this.total,
    required this.learnedCount,
    required this.dueCount,
    required this.detailTitle,
    required this.items,
    required this.rawItems,
    required this.currentItem,
    required this.currentDueItem,
    required this.currentUserTerm,
    required this.currentDueUserTerm,
    required this.currentRetrievability,
    required this.starredTermIds,
    required this.showHints,
    required this.shuffle,
    required this.autoPlay,
    required this.reviewedCount,
    required this.againCount,
    required this.hardCount,
    required this.goodCount,
    required this.easyCount,
    required this.onModeChanged,
    required this.onLearn,
    required this.onTest,
    required this.onMatch,
    required this.onWrite,
    required this.onToggleCurrentStar,
    required this.onShowHintsChanged,
    required this.onToggleShuffle,
    required this.onToggleAutoPlay,
    required this.onPrev,
    required this.onNext,
    required this.onStartLearning,
    required this.onReviewRate,
  });

  final AppLanguage language;
  final _ChapterStudyMode mode;
  final int total;
  final int learnedCount;
  final int dueCount;
  final String detailTitle;
  final List<VocabItem> items;
  final List<VocabItem> rawItems;
  final VocabItem? currentItem;
  final VocabItem? currentDueItem;
  final UserLessonTermData? currentUserTerm;
  final UserLessonTermData? currentDueUserTerm;
  final double? currentRetrievability;
  final Set<int> starredTermIds;
  final bool showHints;
  final bool shuffle;
  final bool autoPlay;
  final int reviewedCount;
  final int againCount;
  final int hardCount;
  final int goodCount;
  final int easyCount;
  final ValueChanged<_ChapterStudyMode> onModeChanged;
  final VoidCallback onLearn;
  final VoidCallback onTest;
  final VoidCallback onMatch;
  final VoidCallback onWrite;
  final VoidCallback? onToggleCurrentStar;
  final ValueChanged<bool> onShowHintsChanged;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleAutoPlay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onStartLearning;
  final ValueChanged<ConfidenceLevel>? onReviewRate;

  @override
  Widget build(BuildContext context) {
    final activeTerm = mode == _ChapterStudyMode.review
        ? currentDueUserTerm
        : currentUserTerm;
    final isStarred =
        activeTerm != null && starredTermIds.contains(activeTerm.id);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ModeSwitcher(
            language: language,
            mode: mode,
            onModeChanged: onModeChanged,
          ),
          const SizedBox(height: 12),
          _StatsRow(
            language: language,
            total: total,
            learned: learnedCount,
            due: dueCount,
          ),
          if (mode == _ChapterStudyMode.review) ...[
            const SizedBox(height: 8),
            Text(language.reviewCountLabel(dueCount)),
          ],
          const SizedBox(height: 12),
          _PracticeActionRow(
            language: language,
            onLearn: onLearn,
            onTest: onTest,
            onMatch: onMatch,
            onWrite: onWrite,
          ),
          const SizedBox(height: 16),
          _CurrentTermActionBar(
            language: language,
            term: activeTerm,
            starred: isStarred,
            onToggleStar: onToggleCurrentStar,
          ),
          const SizedBox(height: 20),
          _StudyStagePanel(
            language: language,
            mode: mode,
            showHints: showHints,
            currentItem: currentItem,
            currentDueItem: currentDueItem,
            currentRetrievability: currentRetrievability,
            onShowHintsChanged: onShowHintsChanged,
            onStartLearning: onStartLearning,
          ),
          const SizedBox(height: 24),
          if (mode == _ChapterStudyMode.flashcards) ...[
            if (total > 0)
              _FlashcardControls(
                onShuffle: onToggleShuffle,
                onAutoPlay: onToggleAutoPlay,
                onPrev: onPrev,
                onNext: onNext,
                isShuffle: shuffle,
                isAutoPlay: autoPlay,
              ),
          ] else ...[
            if (currentDueItem != null)
              _ReviewActions(
                language: language,
                enabled: true,
                onRate: onReviewRate,
              ),
            const SizedBox(height: 12),
            _ReviewSummaryRow(
              language: language,
              reviewed: reviewedCount,
              again: againCount,
              hard: hardCount,
              good: goodCount,
              easy: easyCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _StudyStagePanel extends StatelessWidget {
  const _StudyStagePanel({
    required this.language,
    required this.mode,
    required this.showHints,
    required this.currentItem,
    required this.currentDueItem,
    required this.currentRetrievability,
    required this.onShowHintsChanged,
    required this.onStartLearning,
  });

  final AppLanguage language;
  final _ChapterStudyMode mode;
  final bool showHints;
  final VocabItem? currentItem;
  final VocabItem? currentDueItem;
  final double? currentRetrievability;
  final ValueChanged<bool> onShowHintsChanged;
  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SizedBox(
          key: const ValueKey('hajimete_review_stage'),
          height: 460,
          child: AnimatedSwitcher(
            duration: reducedMotionDuration(
              context,
              const Duration(milliseconds: 300),
            ),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(position: offset, child: child);
            },
            child: KeyedSubtree(
              key: ValueKey(
                'hajimete_card_${mode.name}_${mode == _ChapterStudyMode.review ? currentDueItem?.id : currentItem?.id}_${showHints ? 'hint' : 'clean'}',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _StageHintRow(
                    language: language,
                    showHints: showHints,
                    onShowHintsChanged: onShowHintsChanged,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child:
                            mode == _ChapterStudyMode.review &&
                                currentDueItem == null
                            ? _ReviewEmptyState(
                                language: language,
                                onStartLearning: onStartLearning,
                              )
                            : mode == _ChapterStudyMode.review
                            ? EnhancedFlashcard(
                                item: showHints
                                    ? currentDueItem!
                                    : _maskHintsForStage(currentDueItem!),
                                language: language,
                                retrievability: currentRetrievability,
                              )
                            : currentItem != null
                            ? EnhancedFlashcard(
                                item: showHints
                                    ? currentItem!
                                    : _maskHintsForStage(currentItem!),
                                language: language,
                              )
                            : _EmptyCard(language: language),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageHintRow extends StatelessWidget {
  const _StageHintRow({
    required this.language,
    required this.showHints,
    required this.onShowHintsChanged,
  });

  final AppLanguage language;
  final bool showHints;
  final ValueChanged<bool> onShowHintsChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: context.appPalette.ink.withValues(alpha: 0.65),
          ),
          const SizedBox(width: 8),
          Text(
            _showHintsLabel(language),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.appPalette.ink.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(value: showHints, onChanged: onShowHintsChanged),
        ],
      ),
    );
  }
}

VocabItem _maskHintsForStage(VocabItem item) {
  return VocabItem(
    id: item.id,
    term: item.term,
    reading: '',
    meaning: '',
    meaningEn: '',
    level: item.level,
  );
}

enum _ChapterStudyMode { flashcards, review }

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.language,
    required this.mode,
    required this.onModeChanged,
  });

  final AppLanguage language;
  final _ChapterStudyMode mode;
  final ValueChanged<_ChapterStudyMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return SegmentedButton<_ChapterStudyMode>(
      segments: [
        ButtonSegment(
          value: _ChapterStudyMode.flashcards,
          label: Text(_flashcardsLabel(language)),
        ),
        ButtonSegment(
          value: _ChapterStudyMode.review,
          label: Text(_reviewNowLabel(language)),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onModeChanged(selection.first);
        }
      },
      showSelectedIcon: true,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return palette.elevated;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return palette.ink;
        }),
        side: WidgetStateProperty.all(BorderSide(color: palette.outline)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _ReviewEmptyState extends StatelessWidget {
  const _ReviewEmptyState({
    required this.language,
    required this.onStartLearning,
  });

  final AppLanguage language;
  final VoidCallback onStartLearning;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      height: 460,
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            left: 18,
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: palette.ink.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 8),
                Text(
                  _showHintsLabel(language),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.ink.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Row(
              children: [
                Icon(
                  Icons.star_border_rounded,
                  color: palette.ink.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.edit_outlined,
                  color: palette.ink.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _noReviewsNowLabel(language),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.ink.withValues(alpha: 0.62),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onStartLearning,
                  child: Text(_startLearningLabel(language)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentTermActionBar extends StatelessWidget {
  const _CurrentTermActionBar({
    required this.language,
    required this.term,
    required this.starred,
    required this.onToggleStar,
  });

  final AppLanguage language;
  final UserLessonTermData? term;
  final bool starred;
  final VoidCallback? onToggleStar;

  @override
  Widget build(BuildContext context) {
    if (term == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.tonalIcon(
        onPressed: onToggleStar,
        icon: Icon(starred ? Icons.star_rounded : Icons.star_border_rounded),
        label: Text(
          starred ? _savedLabel(language) : _saveThisWordLabel(language),
        ),
      ),
    );
  }
}

class _ReviewSummaryRow extends StatelessWidget {
  const _ReviewSummaryRow({
    required this.language,
    required this.reviewed,
    required this.again,
    required this.hard,
    required this.good,
    required this.easy,
  });

  final AppLanguage language;
  final int reviewed;
  final int again;
  final int hard;
  final int good;
  final int easy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _SummaryChip(label: language.reviewedLabel, value: '$reviewed'),
        _SummaryChip(label: language.reviewAgainLabel, value: '$again'),
        _SummaryChip(label: language.reviewHardLabel, value: '$hard'),
        _SummaryChip(label: language.reviewGoodLabel, value: '$good'),
        _SummaryChip(label: language.reviewEasyLabel, value: '$easy'),
      ],
    );
  }
}

class _ReviewActions extends StatelessWidget {
  const _ReviewActions({
    required this.language,
    required this.enabled,
    required this.onRate,
  });

  final AppLanguage language;
  final bool enabled;
  final ValueChanged<ConfidenceLevel>? onRate;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? ConfidenceRatingWidget(
            language: language,
            onSelect: (level) => onRate?.call(level),
          )
        : const SizedBox.shrink();
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.language,
    required this.total,
    required this.learned,
    required this.due,
  });

  final AppLanguage language;
  final int total;
  final int learned;
  final int due;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _StatPill(label: _totalLabel(language), value: '$total'),
        _StatPill(label: _learnedLabel(language), value: '$learned'),
        _StatPill(label: _dueLabel(language), value: '$due'),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PracticeActionRow extends StatelessWidget {
  const _PracticeActionRow({
    required this.language,
    required this.onLearn,
    required this.onTest,
    required this.onMatch,
    required this.onWrite,
  });

  final AppLanguage language;
  final VoidCallback onLearn;
  final VoidCallback onTest;
  final VoidCallback onMatch;
  final VoidCallback onWrite;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _ActionChip(label: _learnAction(language), onTap: onLearn),
        _ActionChip(label: _testAction(language), onTap: onTest),
        _ActionChip(label: _matchAction(language), onTap: onMatch),
        _ActionChip(label: _writeAction(language), onTap: onWrite),
        _ActionChip(label: _flashcardsLabel(language), active: true),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, this.active = false, this.onTap});

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? palette.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.outline),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: palette.ink),
        ),
      ),
    );
  }
}

class _FlashcardControls extends StatelessWidget {
  const _FlashcardControls({
    required this.onShuffle,
    required this.onAutoPlay,
    required this.onPrev,
    required this.onNext,
    required this.isShuffle,
    required this.isAutoPlay,
  });

  final VoidCallback onShuffle;
  final VoidCallback onAutoPlay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isShuffle;
  final bool isAutoPlay;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onShuffle,
            icon: Icon(
              Icons.shuffle_rounded,
              color: isShuffle ? palette.primary : palette.ink,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onAutoPlay,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAutoPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _KanjiTab extends StatelessWidget {
  const _KanjiTab({
    required this.language,
    required this.chapterTitle,
    required this.levelCode,
    required this.kanjiAsync,
  });

  final AppLanguage language;
  final String chapterTitle;
  final String levelCode;
  final AsyncValue<HajimeteKanjiChapterDetail?> kanjiAsync;

  @override
  Widget build(BuildContext context) {
    return kanjiAsync.when(
      data: (detail) {
        if (detail == null || detail.entries.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KanjiContractCard(
                  language: language,
                  chapterTitle: chapterTitle,
                  levelCode: levelCode,
                ),
                const SizedBox(height: 16),
                AppFeatureCard(
                  icon: Icons.grid_view_rounded,
                  title: _kanjiComingSoonTitle(language),
                  subtitle: _kanjiComingSoonSubtitle(
                    language,
                    levelCode,
                    chapterTitle,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KanjiSummaryCard(language: language, detail: detail),
              const SizedBox(height: 20),
              ListView.separated(
                key: const ValueKey('hajimete_kanji_list'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: detail.entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = detail.entries[index];
                  return AppSectionCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 72,
                          child: Text(
                            entry.character.isEmpty ? '—' : entry.character,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (entry.reading.isNotEmpty)
                                Text(
                                  entry.reading,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.appPalette.info,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              if (entry.meaningVi.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(entry.meaningVi),
                              ],
                              if (entry.meaningEn.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry.meaningEn,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: context.appPalette.ink
                                            .withValues(alpha: 0.65),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AppFeatureCard(
          icon: Icons.error_outline_rounded,
          title: _kanjiLoadErrorTitle(language),
          subtitle: error.toString(),
        ),
      ),
    );
  }
}

class _KanjiContractCard extends StatelessWidget {
  const _KanjiContractCard({
    required this.language,
    required this.chapterTitle,
    required this.levelCode,
  });

  final AppLanguage language;
  final String chapterTitle;
  final String levelCode;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _kanjiContractTitle(language),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(_kanjiContractSubtitle(language, levelCode, chapterTitle)),
          const SizedBox(height: 12),
          Text(
            'assets/data/content/kanji/${levelCode.toLowerCase()}/hajimete/hajimete_ch${chapterTitle.isNotEmpty ? '' : ''}XX.json',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appPalette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _KanjiSummaryCard extends StatelessWidget {
  const _KanjiSummaryCard({required this.language, required this.detail});

  final AppLanguage language;
  final HajimeteKanjiChapterDetail detail;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kanjiLiveTitle(language),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(_kanjiLiveSubtitle(language, detail.entries.length)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: context.appPalette.surface,
              border: Border.all(color: context.appPalette.outline),
            ),
            child: Text(
              '${detail.entries.length}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppFeatureCard(
        icon: Icons.hourglass_empty_rounded,
        title: _emptyTitle(language),
        subtitle: _emptySubtitle(language),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.language, required this.message});

  final AppLanguage language;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppFeatureCard(
        icon: Icons.error_outline_rounded,
        title: _errorTitle(language),
        subtitle: message,
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppFeatureCard(
      icon: Icons.style_rounded,
      title: _noVocabTitle(language),
      subtitle: _noVocabSubtitle(language),
    );
  }
}

class _SavedPill extends StatelessWidget {
  const _SavedPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? palette.elevated : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.outline),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.star_rounded : Icons.star_border_rounded,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

String _saveThisWordLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Lưu từ này',
  AppLanguage.ja => 'この語を保存',
  AppLanguage.en => 'Save this word',
};

String _savedLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Đã lưu',
  AppLanguage.ja => '保存済み',
  AppLanguage.en => 'Saved',
};

String _vocabTabLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Từ vựng',
  AppLanguage.ja => '語彙',
  AppLanguage.en => 'Vocab',
};

String _kanjiTabLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Kanji',
  AppLanguage.ja => '漢字',
  AppLanguage.en => 'Kanji',
};

String _flashcardsLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Flashcards',
  AppLanguage.ja => 'フラッシュカード',
  AppLanguage.en => 'Flashcards',
};

String _reviewNowLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Review ngay',
  AppLanguage.ja => '今すぐ復習',
  AppLanguage.en => 'Review now',
};

String _noReviewsNowLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Hiện chưa có mục nào đến hạn để review.',
  AppLanguage.ja => '今は復習期限の項目がありません。',
  AppLanguage.en => 'No reviews due right now.',
};

String _startLearningLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Bắt đầu học',
  AppLanguage.ja => '学習を始める',
  AppLanguage.en => 'Start Learning',
};

String _totalLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Tổng',
  AppLanguage.ja => '合計',
  AppLanguage.en => 'Total',
};

String _learnedLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Đã học',
  AppLanguage.ja => '学習済み',
  AppLanguage.en => 'Learned',
};

String _dueLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Đến hạn',
  AppLanguage.ja => '期限',
  AppLanguage.en => 'Due',
};

String _learnAction(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Learn',
  AppLanguage.ja => '学ぶ',
  AppLanguage.en => 'Learn',
};

String _testAction(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Test',
  AppLanguage.ja => 'テスト',
  AppLanguage.en => 'Test',
};

String _matchAction(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Match',
  AppLanguage.ja => 'マッチ',
  AppLanguage.en => 'Match',
};

String _writeAction(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Write',
  AppLanguage.ja => '書く',
  AppLanguage.en => 'Write',
};

String _showHintsLabel(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Hiện gợi ý',
  AppLanguage.ja => 'ヒントを表示',
  AppLanguage.en => 'Show hints',
};

String _kanjiComingSoonTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Tab Kanji sẽ nối sau',
  AppLanguage.ja => '漢字タブは後で接続します',
  AppLanguage.en => 'Kanji tab will be connected later',
};

String _kanjiLoadErrorTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Không tải được tab Kanji',
  AppLanguage.ja => '漢字タブを読み込めませんでした',
  AppLanguage.en => 'Could not load the Kanji tab',
};

String _kanjiContractTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Contract data Kanji đã sẵn sàng',
  AppLanguage.ja => '漢字データの契約は準備済みです',
  AppLanguage.en => 'The Kanji data contract is ready',
};

String _kanjiContractSubtitle(
  AppLanguage language,
  String levelCode,
  String chapterTitle,
) => switch (language) {
  AppLanguage.vi =>
    'Tab Kanji của $levelCode / $chapterTitle đang chờ asset Hajimete. Chỉ cần thêm file đúng format là UI này sẽ dùng ngay.',
  AppLanguage.ja =>
    '$levelCode / $chapterTitle の漢字タブは Hajimete のアセット待ちです。正しい形式のファイルを追加すればこの UI にそのまま表示されます。',
  AppLanguage.en =>
    'The Kanji tab for $levelCode / $chapterTitle is waiting for Hajimete assets. Once you add a file in the expected format, this UI can use it directly.',
};

String _kanjiLiveTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Kanji chapter đã sẵn sàng',
  AppLanguage.ja => 'このチャプターの漢字が利用可能です',
  AppLanguage.en => 'Kanji for this chapter is live',
};

String _kanjiLiveSubtitle(AppLanguage language, int count) =>
    switch (language) {
      AppLanguage.vi => '$count mục Kanji đã được nạp vào tab này.',
      AppLanguage.ja => '$count 件の漢字がこのタブに読み込まれました。',
      AppLanguage.en => '$count Kanji entries are loaded into this tab.',
    };

String _kanjiComingSoonSubtitle(
  AppLanguage language,
  String levelCode,
  String chapterTitle,
) => switch (language) {
  AppLanguage.vi =>
    'Mình đã chừa sẵn tab Kanji cho $levelCode / $chapterTitle. Khi bạn bổ sung data kanji của Hajimete, mình sẽ nối vào đây.',
  AppLanguage.ja =>
    '$levelCode / $chapterTitle 用に漢字タブを準備しています。Hajimete の漢字データが追加されたらここへ接続します。',
  AppLanguage.en =>
    'The Kanji tab is reserved for $levelCode / $chapterTitle. Once you add Hajimete kanji data, it can plug in here directly.',
};

String _emptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Không tìm thấy chapter',
  AppLanguage.ja => 'チャプターが見つかりません',
  AppLanguage.en => 'Chapter not found',
};

String _emptySubtitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Chapter này chưa có dữ liệu để hiển thị.',
  AppLanguage.ja => 'このチャプターの表示データはまだありません。',
  AppLanguage.en => 'This chapter does not have display data yet.',
};

String _errorTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Không tải được chapter',
  AppLanguage.ja => 'チャプターを読み込めませんでした',
  AppLanguage.en => 'Could not load chapter',
};

String _noVocabTitle(AppLanguage language) => switch (language) {
  AppLanguage.vi => 'Chưa có từ vựng để hiển thị',
  AppLanguage.ja => '表示できる語彙がまだありません',
  AppLanguage.en => 'No vocab is ready to display yet',
};

String _noVocabSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.vi =>
    'Khi chapter này có dữ liệu vocab, flashcard sẽ hiện ở đây.',
  AppLanguage.ja => 'このチャプターの語彙データが入ると、ここにフラッシュカードが表示されます。',
  AppLanguage.en =>
    'Flashcards will appear here once this chapter has vocab data.',
};
