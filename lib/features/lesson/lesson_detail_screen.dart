import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/models/mistake_context.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/shared/widgets/widgets.dart';
import 'package:jpstudy/features/lesson/widgets/grammar_list_widget.dart';
import 'package:jpstudy/features/lesson/widgets/kanji_list_widget.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'lesson_detail_controls.dart';
part 'lesson_detail_card.dart';

enum _LessonMode { flashcards, review }

enum _MenuAction { reset, report }

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lessonId, this.levelCode});

  final int lessonId;
  final String? levelCode;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  bool _showHints = true;
  bool _trackProgress = false;
  final FsrsService _fsrsService = FsrsService();

  bool _shuffle = false;
  bool _isAutoPlay = false;

  final bool _focusMode = false;
  final Set<int> _flippedTermIds = {};
  final Set<int> _starredTermIds = {};
  final Set<int> _learnedTermIds = {};
  Set<int> _syncedTermIds = {};
  _LessonMode _mode = _LessonMode.flashcards;
  int _currentIndex = 0;
  final Random _random = Random();
  List<int>? _shuffledOrder;
  Timer? _autoTimer;

  SharedPreferences? _prefs;
  int _reviewedCount = 0;
  int _reviewAgainCount = 0;
  int _reviewHardCount = 0;
  int _reviewGoodCount = 0;
  int _reviewEasyCount = 0;

  static const _prefShowHints = 'lesson.showHints';
  static const _prefTrackProgress = 'lesson.trackProgress';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reducedMotionEnabled(context) && _isAutoPlay) {
      _stopAutoPlay(notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final level =
        StudyLevel.fromCode(widget.levelCode ?? '') ??
        ref.watch(studyLevelProvider) ??
        StudyLevel.n5;
    final sourceLessonId = LessonRepository.curriculumSourceLessonId(
      level.shortLabel,
      widget.lessonId,
    );
    final storageLessonId = LessonRepository.curriculumStorageLessonId(
      level.shortLabel,
      widget.lessonId,
    );
    final fallbackTitle = language.curriculumLessonTitle(
      level.shortLabel,
      sourceLessonId,
    );
    final titleAsync = ref.watch(
      lessonTitleProvider(LessonTitleArgs(storageLessonId, fallbackTitle)),
    );
    final termsAsync = ref.watch(
      lessonTermsProvider(
        LessonTermsArgs(
          storageLessonId,
          level.shortLabel,
          fallbackTitle,
          sourceLessonId: sourceLessonId,
        ),
      ),
    );

    final title = titleAsync.maybeWhen(
      data: (value) => value,
      orElse: () => fallbackTitle,
    );
    final terms = termsAsync.asData?.value ?? const <UserLessonTermData>[];
    final dueAsync = _mode == _LessonMode.review
        ? ref.watch(lessonDueTermsProvider(storageLessonId))
        : const AsyncValue.data(<UserLessonTermData>[]);
    final activeTermsAsync = _mode == _LessonMode.review
        ? dueAsync
        : termsAsync;
    final activeTerms =
        activeTermsAsync.asData?.value ?? const <UserLessonTermData>[];
    _maybeSyncTermFlags(terms);
    final displayTerms = _orderedTerms(activeTerms);
    final totalTerms = displayTerms.length;
    final currentIndex = totalTerms == 0
        ? 0
        : _currentIndex.clamp(0, totalTerms - 1);
    final currentTerm = totalTerms == 0
        ? null
        : displayTerms.elementAt(currentIndex);
    final isSaved = terms.isNotEmpty && _starredTermIds.length == terms.length;
    final learnedCount = terms.where((term) => term.isLearned).length;
    final dueCount = dueAsync.asData?.value.length ?? 0;
    final isStarred =
        currentTerm != null && _starredTermIds.contains(currentTerm.id);
    final isLearned =
        currentTerm != null && _learnedTermIds.contains(currentTerm.id);
    final srsStateAsync = currentTerm == null
        ? const AsyncValue<SrsStateData?>.data(null)
        : ref.watch(srsStateProvider(currentTerm.id));
    final srsState = srsStateAsync.value;
    final isFlipped =
        currentTerm != null && _flippedTermIds.contains(currentTerm.id);
    final canFlip = currentTerm?.definition.trim().isNotEmpty == true;
    final onFlip = canFlip ? () => _toggleFlip(currentTerm) : null;

    // _maybeAutoSpeak removed

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _focusMode
            ? null
            : AppBar(
                toolbarHeight: 64,
                automaticallyImplyLeading: false,
                titleSpacing: 16,
                title: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: language.backToLessonLabel,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${level.shortLabel} / $title',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  _SavedPill(
                    label: language.savedLabel,
                    active: isSaved,
                    onTap: totalTerms == 0
                        ? null
                        : () => _toggleSaved(terms, level, storageLessonId),
                  ),
                  const SizedBox(width: 8),
                  _OverflowMenu(
                    language: language,
                    onSelected: (action) =>
                        _handleMenu(action, language, level, title, terms),
                  ),
                  const SizedBox(width: 12),
                ],
                bottom: TabBar(
                  labelColor: palette.primary,
                  unselectedLabelColor: palette.ink.withValues(alpha: 0.55),
                  indicatorColor: palette.primary,
                  tabs: [
                    Tab(text: language.lessonVocabTabLabel),
                    Tab(text: language.grammarLabel),
                    Tab(text: language.kanjiLabel),
                  ],
                ),
              ),
        body: TabBarView(
          children: [
            FocusableActionDetector(
              autofocus: true,
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
              },
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    onFlip?.call();
                    return null;
                  },
                ),
              },
              child: LayoutBuilder(
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      _focusMode ? 20 : 12,
                      20,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!_focusMode) ...[
                          _ModeSwitcher(
                            language: language,
                            mode: _mode,
                            onModeChanged: (mode) {
                              setState(() {
                                _mode = mode;
                                _currentIndex = 0;
                                _shuffledOrder = null;
                                if (mode == _LessonMode.review) {
                                  _resetReviewStats();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          if (!termsAsync.isLoading)
                            _StatsRow(
                              language: language,
                              total: terms.length,
                              learned: learnedCount,
                              due: dueCount,
                            ),
                          if (_mode == _LessonMode.review) ...[
                            const SizedBox(height: 8),
                            Text(language.reviewCountLabel(totalTerms)),
                          ],
                          const SizedBox(height: 12),
                          _PracticeActions(
                            language: language,
                            lessonId: storageLessonId,
                            lessonTitle: title,
                          ),
                          const SizedBox(height: 20),
                        ],
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 960),
                            child: SizedBox(
                              height: _focusMode ? 520 : 460,
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
                                  return SlideTransition(
                                    position: offset,
                                    child: child,
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey(currentIndex),
                                  child: _LessonCard(
                                    language: language,
                                    termsAsync: activeTermsAsync,
                                    term: currentTerm,
                                    showHints: _showHints,
                                    compactHint: _mode == _LessonMode.review,
                                    isFlipped: isFlipped,
                                    trackProgress: _trackProgress,
                                    isStarred: isStarred,
                                    isLearned: isLearned,
                                    emptyLabel: _mode == _LessonMode.review
                                        ? language.reviewEmptyLabel
                                        : null,
                                    onShowHintsChanged: (value) =>
                                        _updateShowHints(value),
                                    onFlip: onFlip,
                                    onEdit: null,
                                    onStar: currentTerm == null
                                        ? null
                                        : () => _toggleStar(
                                            currentTerm,
                                            level,
                                            storageLessonId,
                                          ),
                                    onLearned:
                                        !_trackProgress || currentTerm == null
                                        ? null
                                        : () => _toggleLearned(
                                            currentTerm,
                                            level,
                                            storageLessonId,
                                          ),
                                    onStartLearning:
                                        (_mode == _LessonMode.review &&
                                            activeTerms.isEmpty &&
                                            terms.isNotEmpty &&
                                            learnedCount == 0)
                                        ? _startLearning
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (totalTerms > 0)
                          _FlashcardControls(
                            language: language,
                            isShuffle: _shuffle,
                            isAutoPlay: _isAutoPlay,
                            onShuffle: _toggleShuffle,
                            onAutoPlay: () => _toggleAutoPlay(totalTerms),
                            onPrev: () => _goPrev(totalTerms),
                            onNext: () => _goNext(totalTerms),
                          ),
                        if (_mode == _LessonMode.review) ...[
                          const SizedBox(height: 16),
                          if (srsState != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                language.retrievabilityPercentLabel(
                                  (_fsrsService.retrievability(
                                            stability: srsState.stability,
                                            lastReviewedAt:
                                                srsState.lastReviewedAt,
                                          ) *
                                          100)
                                      .round(),
                                ),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: context.appPalette.ink.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          _ReviewActions(
                            language: language,
                            enabled: currentTerm != null,
                            onRate: currentTerm == null
                                ? null
                                : (level) =>
                                      _reviewTerm(currentTerm, level.value),
                          ),
                          const SizedBox(height: 12),
                          _ReviewSummary(
                            language: language,
                            reviewed: _reviewedCount,
                            again: _reviewAgainCount,
                            hard: _reviewHardCount,
                            good: _reviewGoodCount,
                            easy: _reviewEasyCount,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            GrammarListWidget(
              lessonId: sourceLessonId,
              level: level.shortLabel,
              language: language,
            ),
            KanjiListWidget(lessonId: sourceLessonId),
          ],
        ),
      ),
    );
  }

  List<UserLessonTermData> _orderedTerms(List<UserLessonTermData> terms) {
    if (!_shuffle) {
      _shuffledOrder = null;
      return terms;
    }
    if (terms.isEmpty) {
      _shuffledOrder = null;
      return terms;
    }
    final ids = terms.map((term) => term.id).toSet();
    final order = _shuffledOrder;
    if (order == null ||
        order.length != ids.length ||
        !order.every(ids.contains)) {
      final nextOrder = ids.toList()..shuffle(_random);
      _shuffledOrder = nextOrder;
    }
    final lookup = {for (final term in terms) term.id: term};
    return _shuffledOrder!.map((id) => lookup[id]!).toList();
  }

  Future<void> _toggleSaved(
    List<UserLessonTermData> terms,
    StudyLevel level,
    int storageLessonId,
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
    await repo.setStarredForLesson(storageLessonId, shouldStarAll);
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _toggleStar(
    UserLessonTermData term,
    StudyLevel level,
    int storageLessonId,
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
      lessonId: storageLessonId,
      isStarred: nextValue,
    );
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _toggleLearned(
    UserLessonTermData term,
    StudyLevel level,
    int storageLessonId,
  ) async {
    final repo = ref.read(lessonRepositoryProvider);
    final nextValue = !_learnedTermIds.contains(term.id);
    setState(() {
      if (nextValue) {
        _learnedTermIds.add(term.id);
      } else {
        _learnedTermIds.remove(term.id);
      }
    });
    await repo.updateTermLearned(
      term.id,
      lessonId: storageLessonId,
      isLearned: nextValue,
    );
    if (nextValue) {
      final now = DateTime.now();
      await repo.upsertSrsState(
        termId: term.id,
        repetitions: 0,
        stability: 1.0,
        difficulty: 5.0,
        nextReviewAt: now.add(const Duration(days: 1)),
      );
    } else {
      await repo.deleteSrsState(term.id);
    }
    ref.invalidate(lessonMetaProvider(level.shortLabel));
    ref.invalidate(lessonDueTermsProvider(storageLessonId));
  }

  Future<void> _reviewTerm(UserLessonTermData term, int quality) async {
    final repo = ref.read(lessonRepositoryProvider);
    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    // Use the comprehensive saveTermReview method which handles SRS calculation
    final fsrsResult = await repo.saveTermReview(
      termId: term.id,
      quality: quality,
    );
    if (mounted && fsrsResult != null) {
      final language = ref.read(appLanguageProvider);
      final days = fsrsResult.nextReviewAt.difference(DateTime.now()).inDays;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (quality <= 2) {
      final language = ref.read(appLanguageProvider);
      final prompt = term.reading.isNotEmpty
          ? '${term.term} • ${term.reading}'
          : term.term;
      final correctAnswer = language == AppLanguage.en
          ? (term.definitionEn.isNotEmpty ? term.definitionEn : term.definition)
          : term.definition;
      await mistakeRepo.addMistake(
        type: 'vocab',
        itemId: term.id,
        context: MistakeContext(
          prompt: prompt,
          correctAnswer: correctAnswer,
          userAnswer: quality == 1 ? 'again' : 'hard',
          source: 'lesson_review',
          extra: {'confidence': quality},
        ),
      );
    } else {
      await mistakeRepo.markCorrect(type: 'vocab', itemId: term.id);
    }

    final level = ref.read(studyLevelProvider) ?? StudyLevel.n5;
    ref.invalidate(
      lessonDueTermsProvider(
        LessonRepository.curriculumStorageLessonId(
          level.shortLabel,
          widget.lessonId,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _incrementReviewStats(quality);
      _currentIndex = 0;
    });
  }

  Future<void> _startLearning() async {
    final repo = ref.read(lessonRepositoryProvider);
    final language = ref.read(appLanguageProvider);
    final level = ref.read(studyLevelProvider) ?? StudyLevel.n5;
    final sourceLessonId = LessonRepository.curriculumSourceLessonId(
      level.shortLabel,
      widget.lessonId,
    );
    final storageLessonId = LessonRepository.curriculumStorageLessonId(
      level.shortLabel,
      widget.lessonId,
    );
    await repo.initializeLessonSrs(storageLessonId);

    // Refresh providers to update UI
    ref.invalidate(lessonDueTermsProvider(storageLessonId));

    final fallbackTitle = language.curriculumLessonTitle(
      level.shortLabel,
      sourceLessonId,
    );

    ref.invalidate(
      lessonTermsProvider(
        LessonTermsArgs(
          storageLessonId,
          level.shortLabel,
          fallbackTitle,
          sourceLessonId: sourceLessonId,
        ),
      ),
    );
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  void _toggleFlip(UserLessonTermData? term) {
    if (term == null || term.definition.trim().isEmpty) {
      return;
    }
    setState(() {
      if (_flippedTermIds.contains(term.id)) {
        _flippedTermIds.remove(term.id);
      } else {
        _flippedTermIds.add(term.id);
      }
    });
  }

  void _resetReviewStats() {
    _reviewedCount = 0;
    _reviewAgainCount = 0;
    _reviewHardCount = 0;
    _reviewGoodCount = 0;
    _reviewEasyCount = 0;
  }

  void _incrementReviewStats(int quality) {
    _reviewedCount += 1;
    switch (quality) {
      case 1:
        _reviewAgainCount += 1;
        break;
      case 2:
        _reviewHardCount += 1;
        break;
      case 3:
        _reviewGoodCount += 1;
        break;
      case 4:
        _reviewEasyCount += 1;
        break;
    }
  }

  void _updateShowHints(bool value) {
    setState(() => _showHints = value);
    _saveBool(_prefShowHints, value);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _prefs = prefs;
      _showHints = prefs.getBool(_prefShowHints) ?? true;
      _trackProgress = prefs.getBool(_prefTrackProgress) ?? false;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs ??= prefs;
    await prefs.setBool(key, value);
  }

  void _maybeSyncTermFlags(List<UserLessonTermData> terms) {
    final ids = terms.map((term) => term.id).toSet();
    final starred = terms
        .where((term) => term.isStarred)
        .map((term) => term.id)
        .toSet();
    final learned = terms
        .where((term) => term.isLearned)
        .map((term) => term.id)
        .toSet();
    final needsSync =
        !_setsEqual(ids, _syncedTermIds) ||
        !_setsEqual(starred, _starredTermIds) ||
        !_setsEqual(learned, _learnedTermIds);
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
        _learnedTermIds
          ..clear()
          ..addAll(learned);
      });
    });
  }

  bool _setsEqual(Set<int> a, Set<int> b) {
    return a.length == b.length && a.containsAll(b);
  }

  void _goPrev(int total) {
    if (total == 0) {
      return;
    }
    setState(() {
      _currentIndex = (_currentIndex - 1).clamp(0, total - 1);
    });
  }

  void _goNext(int total) {
    if (total == 0) {
      return;
    }
    setState(() {
      if (_currentIndex >= total - 1) {
        // Loop back to start if auto-playing or just stay?
        // If auto-play, loop. If manual, maybe stop or loop?
        // Standard is usually stop or loop. Let's loop for auto-play, stop for manual?
        // Original code clamped.
        // Let's loop if auto-play.
        if (_isAutoPlay) {
          _currentIndex = 0;
        } else {
          // Standard next button behavior: stop at end or loop?
          // Quizlet stops at end usually. I'll stick to clamp for manual.
          _currentIndex = (_currentIndex + 1).clamp(0, total - 1);
        }
      } else {
        _currentIndex++;
      }
    });
  }

  void _toggleShuffle() {
    setState(() {
      _shuffle = !_shuffle;
      _shuffledOrder = null; // Will trigger re-shuffle in _orderedTerms
      _currentIndex = 0;
    });
  }

  void _toggleAutoPlay(int total) {
    if (_isAutoPlay) {
      _stopAutoPlay();
      return;
    }
    if (reducedMotionEnabled(context)) {
      return;
    }

    setState(() {
      _isAutoPlay = true;
    });

    _autoTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || reducedMotionEnabled(context)) {
        timer.cancel();
        if (mounted) {
          _stopAutoPlay();
        }
        return;
      }
      _goNext(total);
    });
  }

  void _stopAutoPlay({bool notify = true}) {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (!_isAutoPlay) {
      return;
    }
    if (notify && mounted) {
      setState(() {
        _isAutoPlay = false;
      });
    } else {
      _isAutoPlay = false;
    }
  }

  void _handleMenu(
    _MenuAction action,
    AppLanguage language,
    StudyLevel level,
    String title,
    List<UserLessonTermData> terms,
  ) {
    switch (action) {
      case _MenuAction.reset:
        _resetProgress(language, level);
        break;
      case _MenuAction.report:
        _reportLesson(language, level, title, terms);
        break;
    }
  }

  Future<void> _resetProgress(AppLanguage language, StudyLevel level) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.resetProgressTitle),
        content: Text(language.resetProgressBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(language.resetProgressConfirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      final repo = ref.read(lessonRepositoryProvider);
      final sourceLessonId = LessonRepository.curriculumSourceLessonId(
        level.shortLabel,
        widget.lessonId,
      );
      final storageLessonId = LessonRepository.curriculumStorageLessonId(
        level.shortLabel,
        widget.lessonId,
      );
      await repo.resetLessonProgress(storageLessonId);
      ref.invalidate(lessonMetaProvider(level.shortLabel));
      ref.invalidate(lessonDueTermsProvider(storageLessonId));
      ref.invalidate(
        lessonTermsProvider(
          LessonTermsArgs(
            storageLessonId,
            level.shortLabel,
            language.curriculumLessonTitle(level.shortLabel, sourceLessonId),
            sourceLessonId: sourceLessonId,
          ),
        ),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(language.resetProgressSuccessLabel)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.resetProgressErrorLabel)));
    }
  }

  Future<void> _reportLesson(
    AppLanguage language,
    StudyLevel level,
    String title,
    List<UserLessonTermData> terms,
  ) async {
    final buffer = StringBuffer()
      ..writeln('Lesson ID: ${widget.lessonId}')
      ..writeln('Level: ${level.shortLabel}')
      ..writeln('Title: $title')
      ..writeln('Terms: ${terms.length}')
      ..writeln('---')
      ..writeln('Sample:');
    final sampleCount = terms.length < 5 ? terms.length : 5;
    for (var i = 0; i < sampleCount; i++) {
      final term = terms[i];
      final def = language == AppLanguage.en && term.definitionEn.isNotEmpty
          ? term.definitionEn
          : term.definition;
      buffer.writeln('${i + 1}. ${term.term}\t${term.reading}\t$def');
    }
    final reportText = buffer.toString();
    final copied = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.reportLabel),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(child: SelectableText(reportText)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(MaterialLocalizations.of(context).copyButtonLabel),
          ),
        ],
      ),
    );
    if (copied != true) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: reportText));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(language.reportCopiedLabel)));
  }
}
