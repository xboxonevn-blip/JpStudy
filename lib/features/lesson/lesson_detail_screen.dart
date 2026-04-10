import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

enum _LessonMode { flashcards, review }

enum _MenuAction { edit, addTerm, reset, combine, report }

class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  static final _whitespaceRe = RegExp(r'\s+');

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
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final fallbackTitle = language.lessonTitle(widget.lessonId);
    final titleAsync = ref.watch(
      lessonTitleProvider(LessonTitleArgs(widget.lessonId, fallbackTitle)),
    );
    final termsAsync = ref.watch(
      lessonTermsProvider(
        LessonTermsArgs(widget.lessonId, level.shortLabel, fallbackTitle),
      ),
    );

    final title = titleAsync.maybeWhen(
      data: (value) => value,
      orElse: () => fallbackTitle,
    );
    final terms = termsAsync.asData?.value ?? const <UserLessonTermData>[];
    final dueAsync = _mode == _LessonMode.review
        ? ref.watch(lessonDueTermsProvider(widget.lessonId))
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
    final srsState = srsStateAsync.valueOrNull;
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
                        : () => _toggleSaved(terms, level),
                  ),
                  const SizedBox(width: 8),
                  _OverflowMenu(
                    language: language,
                    onSelected: (action) => _handleMenu(
                      action,
                      context,
                      language,
                      level,
                      title,
                      terms,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                bottom: TabBar(
                  labelColor: const Color(0xFF4255FF),
                  unselectedLabelColor: const Color(0xFF6B7390),
                  indicatorColor: const Color(0xFF4255FF),
                  tabs: [
                    Tab(
                      text: language.flashcardsAction,
                    ), // Reuse Flashcards label for Vocab for now
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
                            lessonId: widget.lessonId,
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
                                duration: const Duration(milliseconds: 300),
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
                                    onEdit: () =>
                                        context.openLessonEdit(widget.lessonId),
                                    onStar: currentTerm == null
                                        ? null
                                        : () => _toggleStar(currentTerm, level),
                                    onLearned:
                                        !_trackProgress || currentTerm == null
                                        ? null
                                        : () => _toggleLearned(
                                            currentTerm,
                                            level,
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
                                      color: Colors.grey[700],
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
              lessonId: widget.lessonId,
              level: level.shortLabel,
              language: language,
            ),
            KanjiListWidget(lessonId: widget.lessonId),
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
    await repo.setStarredForLesson(widget.lessonId, shouldStarAll);
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _toggleStar(UserLessonTermData term, StudyLevel level) async {
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
      lessonId: widget.lessonId,
      isStarred: nextValue,
    );
    ref.invalidate(lessonMetaProvider(level.shortLabel));
  }

  Future<void> _toggleLearned(UserLessonTermData term, StudyLevel level) async {
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
      lessonId: widget.lessonId,
      isLearned: nextValue,
    );
    if (nextValue) {
      final now = DateTime.now();
      await repo.upsertSrsState(
        termId: term.id,
        box: 1,
        repetitions: 0,
        ease: 2.5,
        stability: 1.0,
        difficulty: 5.0,
        lastReviewedAt: now,
        nextReviewAt: now.add(const Duration(days: 1)),
      );
    } else {
      await repo.deleteSrsState(term.id);
    }
    ref.invalidate(lessonMetaProvider(level.shortLabel));
    ref.invalidate(lessonDueTermsProvider(widget.lessonId));
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
          backgroundColor: quality <= 2 ? Colors.orange : Colors.green,
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

    ref.invalidate(lessonDueTermsProvider(widget.lessonId));
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
    await repo.initializeLessonSrs(widget.lessonId);

    // Refresh providers to update UI
    ref.invalidate(lessonDueTermsProvider(widget.lessonId));

    final language = ref.read(appLanguageProvider);
    final level = ref.read(studyLevelProvider) ?? StudyLevel.n5;
    final fallbackTitle = language.lessonTitle(widget.lessonId);

    ref.invalidate(
      lessonTermsProvider(
        LessonTermsArgs(widget.lessonId, level.shortLabel, fallbackTitle),
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

  String _termKey(String term, String reading, String definition) {
    final cleanTerm = _normalizeKeyPart(term);
    final cleanReading = _normalizeKeyPart(reading);
    final cleanDefinition = _normalizeKeyPart(definition);
    return '$cleanTerm|$cleanReading|$cleanDefinition';
  }

  String _normalizeKeyPart(String value) {
    return value.trim().replaceAll(_whitespaceRe, ' ').toLowerCase();
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
    setState(() {
      _isAutoPlay = !_isAutoPlay;
    });

    if (_isAutoPlay) {
      _autoTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        _goNext(total);
      });
    } else {
      _autoTimer?.cancel();
      _autoTimer = null;
    }
  }

  void _handleMenu(
    _MenuAction action,
    BuildContext context,
    AppLanguage language,
    StudyLevel level,
    String title,
    List<UserLessonTermData> terms,
  ) {
    switch (action) {
      case _MenuAction.edit:
        context.openLessonEdit(widget.lessonId);
        break;
      case _MenuAction.addTerm:
        _showQuickAddTerm(language, level);
        break;
      case _MenuAction.reset:
        _resetProgress(language, level);
        break;
      case _MenuAction.combine:
        _combineLesson(language, level, terms);
        break;
      case _MenuAction.report:
        _reportLesson(language, level, title, terms);
        break;
    }
  }

  Future<void> _showQuickAddTerm(AppLanguage language, StudyLevel level) async {
    final termController = TextEditingController();
    final readingController = TextEditingController();
    final definitionController = TextEditingController();
    var canSave = false;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(language.addTermLabel),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: termController,
                      decoration: InputDecoration(
                        labelText: language.termLabel,
                      ),
                      onChanged: (value) {
                        final next = value.trim().isNotEmpty;
                        if (next != canSave) {
                          setDialogState(() => canSave = next);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: readingController,
                      decoration: InputDecoration(
                        labelText: language.readingLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: definitionController,
                      decoration: InputDecoration(
                        labelText: language.definitionLabel,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                ),
                ElevatedButton(
                  onPressed: canSave
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved != true || !context.mounted) {
      termController.dispose();
      readingController.dispose();
      definitionController.dispose();
      return;
    }
    final term = termController.text.trim();
    final reading = readingController.text.trim();
    final definition = definitionController.text.trim();
    termController.dispose();
    readingController.dispose();
    definitionController.dispose();
    if (term.isEmpty) {
      return;
    }
    final repo = ref.read(lessonRepositoryProvider);
    await repo.appendTerms(widget.lessonId, [
      LessonTermDraft(
        term: term,
        reading: reading,
        definition: definition,
        kanjiMeaning: '',
      ),
    ]);
    ref.invalidate(lessonMetaProvider(level.shortLabel));
    ref.invalidate(
      lessonTermsProvider(
        LessonTermsArgs(
          widget.lessonId,
          level.shortLabel,
          language.lessonTitle(widget.lessonId),
        ),
      ),
    );
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
      await repo.resetLessonProgress(widget.lessonId);
      ref.invalidate(lessonMetaProvider(level.shortLabel));
      ref.invalidate(lessonDueTermsProvider(widget.lessonId));
      ref.invalidate(
        lessonTermsProvider(
          LessonTermsArgs(
            widget.lessonId,
            level.shortLabel,
            language.lessonTitle(widget.lessonId),
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

  Future<void> _combineLesson(
    AppLanguage language,
    StudyLevel level,
    List<UserLessonTermData> terms,
  ) async {
    if (terms.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.combineEmptyLabel)));
      return;
    }
    final repo = ref.read(lessonRepositoryProvider);
    final lessons = await ref.read(lessonMetaProvider(level.shortLabel).future);
    if (!mounted) {
      return;
    }
    final options = lessons
        .where((lesson) => lesson.id != widget.lessonId)
        .toList();
    final targetId = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              Text(
                language.combineSetLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: Text(language.combineNewLessonLabel),
                onTap: () => Navigator.of(context).pop(-1),
              ),
              if (options.isNotEmpty) const Divider(),
              for (final lesson in options)
                ListTile(
                  title: Text(lesson.title),
                  subtitle: Text(language.termsCountLabel(lesson.termCount)),
                  onTap: () => Navigator.of(context).pop(lesson.id),
                ),
            ],
          ),
        );
      },
    );
    if (targetId == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    int destinationId = targetId;
    if (targetId == -1) {
      final nextId = await repo.nextLessonId();
      if (!mounted) {
        return;
      }
      final defaultTitle = language.lessonTitle(nextId);
      final controller = TextEditingController(text: defaultTitle);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(language.combineNewLessonLabel),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: defaultTitle),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(language.createLessonLabel),
            ),
          ],
        ),
      );
      if (confirmed != true) {
        controller.dispose();
        return;
      }
      final resolvedTitle = controller.text.trim().isEmpty
          ? defaultTitle
          : controller.text.trim();
      final isCustomTitle = resolvedTitle != defaultTitle;
      controller.dispose();
      destinationId = await repo.createLesson(
        level: level.shortLabel,
        title: resolvedTitle,
        isPublic: true,
        isCustomTitle: isCustomTitle,
      );
    }
    final drafts = terms
        .map(
          (term) => LessonTermDraft(
            term: term.term,
            reading: term.reading,
            definition: term.definition,
            kanjiMeaning: term.kanjiMeaning,
          ),
        )
        .toList();
    try {
      final existing = await repo.fetchTerms(destinationId);
      if (!mounted) {
        return;
      }
      final existingKeys = existing
          .map((term) => _termKey(term.term, term.reading, term.definition))
          .toSet();
      final filteredDrafts = <LessonTermDraft>[];
      var skipped = 0;
      for (final draft in drafts) {
        final key = _termKey(draft.term, draft.reading, draft.definition);
        if (existingKeys.add(key)) {
          filteredDrafts.add(draft);
        } else {
          skipped += 1;
        }
      }
      if (filteredDrafts.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.combineNoNewLabel)));
        return;
      }
      await repo.appendTerms(destinationId, filteredDrafts);
      ref.invalidate(lessonMetaProvider(level.shortLabel));
      if (!mounted) {
        return;
      }
      final message = skipped == 0
          ? language.combineSuccessLabel
          : language.combineSkippedLabel(skipped);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.combineErrorLabel)));
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
      runSpacing: 8,
      children: [
        _StatChip(label: language.statsTotalLabel, value: total.toString()),
        _StatChip(label: language.statsLearnedLabel, value: learned.toString()),
        _StatChip(label: language.statsDueLabel, value: due.toString()),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7390)),
          ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
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

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({
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
        _SummaryChip(label: language.reviewedLabel, value: reviewed.toString()),
        _SummaryChip(label: language.reviewAgainLabel, value: again.toString()),
        _SummaryChip(label: language.reviewHardLabel, value: hard.toString()),
        _SummaryChip(label: language.reviewGoodLabel, value: good.toString()),
        _SummaryChip(label: language.reviewEasyLabel, value: easy.toString()),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1E6F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7390)),
          ),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEFF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFFD6DDFF) : const Color(0xFFE1E6F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.star : Icons.star_border,
              size: 16,
              color: active ? const Color(0xFF4255FF) : null,
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  const _OverflowMenu({required this.language, required this.onSelected});

  final AppLanguage language;
  final ValueChanged<_MenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      onSelected: onSelected,
      icon: const Icon(Icons.more_horiz),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MenuAction.edit,
          child: Text(language.copySetLabel),
        ),
        PopupMenuItem(
          value: _MenuAction.addTerm,
          child: Text(language.addTermLabel),
        ),
        PopupMenuItem(
          value: _MenuAction.reset,
          child: Text(language.resetProgressLabel),
        ),
        PopupMenuItem(
          value: _MenuAction.combine,
          child: Text(language.combineSetLabel),
        ),
        PopupMenuItem(
          value: _MenuAction.report,
          child: Text(language.reportLabel),
        ),
      ],
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.language,
    required this.mode,
    required this.onModeChanged,
  });

  final AppLanguage language;
  final _LessonMode mode;
  final ValueChanged<_LessonMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<_LessonMode>(
          segments: [
            ButtonSegment(
              value: _LessonMode.flashcards,
              label: Text(language.flashcardsAction),
            ),
            ButtonSegment(
              value: _LessonMode.review,
              label: Text(language.reviewAction),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) {
              onModeChanged(selection.first);
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF4255FF);
              }
              return Colors.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return const Color(0xFF1C2440);
            }),
            side: WidgetStateProperty.all(
              const BorderSide(color: Color(0xFFE1E6F0)),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _PracticeActions extends StatelessWidget {
  const _PracticeActions({
    required this.language,
    required this.lessonId,
    required this.lessonTitle,
  });

  final AppLanguage language;
  final int lessonId;
  final String lessonTitle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _PracticeButton(
          label: language.learnModeLabel,
          onTap: () => context.openLessonLearn(lessonId, title: lessonTitle),
        ),
        _PracticeButton(
          label: language.testModeLabel,
          onTap: () => context.openLessonTest(lessonId, title: lessonTitle),
        ),
        _PracticeButton(
          label: language.matchModeLabel,
          onTap: () => context.openLessonMatch(lessonId, title: lessonTitle),
        ),
        _PracticeButton(
          label: language.writeModeLabel,
          onTap: () => context.openLessonWrite(lessonId, title: lessonTitle),
        ),
        _PracticeButton(
          label: language.flashcardsAction,
          onTap: () =>
              context.openLessonFlashcards(lessonId, title: lessonTitle),
        ),
      ],
    );
  }
}

class _PracticeButton extends StatelessWidget {
  const _PracticeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1C2440),
        side: const BorderSide(color: Color(0xFFE1E6F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.language,
    required this.termsAsync,
    required this.term,
    required this.showHints,
    required this.compactHint,
    required this.isFlipped,
    required this.trackProgress,
    required this.isStarred,
    required this.isLearned,
    required this.onShowHintsChanged,
    required this.onFlip,
    required this.onEdit,
    required this.onStar,
    required this.onLearned,
    this.onStartLearning,
    this.emptyLabel,
  });

  final AppLanguage language;
  final AsyncValue<List<UserLessonTermData>> termsAsync;
  final UserLessonTermData? term;
  final bool showHints;
  final bool compactHint;
  final bool isFlipped;
  final bool trackProgress;
  final bool isStarred;
  final bool isLearned;
  final ValueChanged<bool> onShowHintsChanged;
  final VoidCallback? onFlip;
  final VoidCallback onEdit;
  final VoidCallback? onStar;
  final VoidCallback? onLearned;
  final VoidCallback? onStartLearning;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E3A59),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18),
                    const SizedBox(width: 6),
                    Text(language.showHintsLabel),
                    const SizedBox(width: 8),
                    Switch(value: showHints, onChanged: onShowHintsChanged),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onLearned != null)
                      IconButton(
                        onPressed: onLearned,
                        icon: Icon(
                          isLearned
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: isLearned
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF8F9BB3),
                        ),
                        tooltip: language.learnedLabel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: onStar,
                      icon: Icon(
                        isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isStarred
                            ? const Color(0xFFFFC107)
                            : const Color(0xFF8F9BB3),
                        size: 26,
                      ),
                      tooltip: language.starLabel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF8F9BB3),
                        size: 22,
                      ),
                      tooltip: language.editLabel,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: onFlip,
                child: _CardContent(
                  language: language,
                  termsAsync: termsAsync,
                  term: term,
                  showHints: showHints,
                  compactHint: compactHint,
                  isFlipped: isFlipped,
                  emptyLabel: emptyLabel,
                  onStartLearning: onStartLearning,
                ),
              ),
            ),
          ),
          if (trackProgress) _ShortcutBar(language: language),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  static final _whitespaceRe = RegExp(r'\s+');

  const _CardContent({
    required this.language,
    required this.termsAsync,
    required this.term,
    required this.showHints,
    required this.compactHint,
    required this.isFlipped,
    required this.emptyLabel,
    this.onStartLearning,
  });

  final AppLanguage language;
  final AsyncValue<List<UserLessonTermData>> termsAsync;
  final UserLessonTermData? term;
  final bool showHints;
  final bool compactHint;
  final bool isFlipped;
  final String? emptyLabel;
  final VoidCallback? onStartLearning;

  @override
  Widget build(BuildContext context) {
    if (termsAsync.isLoading) {
      return const CircularProgressIndicator();
    }
    if (termsAsync.hasError) {
      return Text(language.loadErrorLabel);
    }
    final resolvedTerm = term;
    if (resolvedTerm == null) {
      if (onStartLearning != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emptyLabel ?? '',
              style: const TextStyle(color: Color(0xFF6B7390)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onStartLearning,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4255FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(language.startLearningLabel),
            ),
          ],
        );
      }
      final label = emptyLabel;
      if (label == null || label.isEmpty) {
        return const SizedBox.shrink();
      }
      return Text(
        label,
        style: const TextStyle(color: Color(0xFF6B7390)),
        textAlign: TextAlign.center,
      );
    }

    final showBack = isFlipped && resolvedTerm.definition.trim().isNotEmpty;
    final hintMeaning = switch (language) {
      AppLanguage.en => resolvedTerm.definitionEn,
      AppLanguage.vi => resolvedTerm.definition,
      AppLanguage.ja => resolvedTerm.definition,
    };
    final frontHint = compactHint
        ? _compactHint(hintMeaning, resolvedTerm.id)
        : hintMeaning;
    final showReading = shouldShowReading(
      term: resolvedTerm.term,
      reading: resolvedTerm.reading,
    );

    final front = _CardFace(
      key: const ValueKey(false),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            language.termLabel,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8F9BB3),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resolvedTerm.term,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C2440),
            ),
            textAlign: TextAlign.center,
          ),
          if (showReading) ...[
            const SizedBox(height: 20),
            Text(
              language.readingLabel,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8F9BB3),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              resolvedTerm.reading.trim(),
              style: const TextStyle(fontSize: 18, color: Color(0xFF6B7390)),
              textAlign: TextAlign.center,
            ),
          ],
          if (showHints && frontHint.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              language.meaningLabel,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8F9BB3),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              frontHint,
              style: const TextStyle(fontSize: 16, color: Color(0xFF4D5877)),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );

    final backMeaning = hintMeaning;

    final backContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          language == AppLanguage.en
              ? language.meaningEnLabel
              : language.meaningLabel,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8F9BB3),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          backMeaning.trim().isEmpty ? '-' : backMeaning,
          style: const TextStyle(fontSize: 18, color: Color(0xFF1C2440)),
          textAlign: TextAlign.center,
        ),
        if (language == AppLanguage.vi &&
            resolvedTerm.kanjiMeaning.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            language.kanjiMeaningLabel,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8F9BB3),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resolvedTerm.kanjiMeaning,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4D5877),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    final back = _CardFace(key: const ValueKey(true), child: backContent);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final isUnder = child?.key != ValueKey(showBack);
            var value = rotate.value;
            if (isUnder) {
              value = min(rotate.value, pi / 2);
            }
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value);
            return Transform(
              transform: transform,
              alignment: Alignment.center,
              child: child,
            );
          },
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: showBack ? back : front,
    );
  }

  String _compactHint(String meaning, int seed) {
    final clean = meaning.replaceAll('\n', ' ').trim();
    if (clean.isEmpty) return '';
    final compact = clean.replaceAll(_whitespaceRe, '');
    if (compact.isEmpty) return '';

    var take = compact.length <= 2 ? compact.length : (seed.abs() % 2) + 2;
    if (take > compact.length) take = compact.length;
    final maxStart = compact.length - take;
    final start = maxStart <= 0 ? 0 : ((seed.abs() ~/ 11) % (maxStart + 1));
    return compact.substring(start, start + take);
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _ShortcutBar extends StatelessWidget {
  const _ShortcutBar({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFE9EBFF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.keyboard, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            language.shortcutLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              language.shortcutInstruction,
              style: const TextStyle(color: Color(0xFF4D5877)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashcardControls extends StatelessWidget {
  const _FlashcardControls({
    required this.language,
    required this.isShuffle,
    required this.isAutoPlay,
    required this.onShuffle,
    required this.onAutoPlay,
    required this.onPrev,
    required this.onNext,
  });

  final AppLanguage language;
  final bool isShuffle;
  final bool isAutoPlay;
  final VoidCallback onShuffle;
  final VoidCallback onAutoPlay;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E6F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Wrap content so it doesn't stretch
        children: [
          IconButton(
            onPressed: onShuffle,
            icon: Icon(
              isShuffle ? Icons.shuffle_on_outlined : Icons.shuffle,
              color: isShuffle
                  ? const Color(0xFF4255FF)
                  : const Color(0xFF6B7390),
            ),
            tooltip: language.shuffleLabel,
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 24, color: const Color(0xFFE1E6F0)),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            color: const Color(0xFF1C2440),
            tooltip: language.previousLabel,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onAutoPlay,
            icon: Icon(
              isAutoPlay ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: const Color(0xFF4255FF),
              size: 52,
            ),
            padding: EdgeInsets.zero,
            tooltip: isAutoPlay ? language.pauseLabel : language.autoPlayLabel,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded, size: 28),
            color: const Color(0xFF1C2440),
            tooltip: language.nextLabel,
          ),
        ],
      ),
    );
  }
}
