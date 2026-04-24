import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';
import '../../../core/accessibility/reduced_motion.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/services/recovery_pack_service.dart';
import '../../../core/services/session_storage.dart';
import '../../../core/services/session_storage_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/models/mistake_context.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../home/providers/recovery_pack_provider.dart';
import '../../learn/models/question.dart';
import '../../learn/models/question_type.dart';
import '../../learn/services/question_generator.dart';
import '../../learn/widgets/fill_blank_widget.dart';
import '../../learn/widgets/multiple_choice_widget.dart';
import '../../learn/widgets/true_false_widget.dart';
import '../../common/widgets/japanese_background.dart';
import '../models/test_config.dart';
import '../models/test_session.dart';
import '../providers/test_providers.dart';
import '../../mistakes/repositories/mistake_repository.dart';
import 'test_results_screen.dart';

class TestScreen extends ConsumerStatefulWidget {
  final List<VocabItem> items;
  final int lessonId;
  final String lessonTitle;
  final TestConfig config;
  final String sessionKey;
  final TestSessionSnapshot? resumeSnapshot;

  const TestScreen({
    super.key,
    required this.items,
    required this.lessonId,
    required this.lessonTitle,
    required this.config,
    required this.sessionKey,
    this.resumeSnapshot,
  });

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  final QuestionGenerator _questionGenerator = QuestionGenerator();
  final Random _random = Random();
  late TestSession _session;
  String? _selectedAnswer;
  bool? _selectedTrueFalse;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _isSubmitting = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  int _adaptiveAdded = 0;
  int _adaptiveMaxExtra = 0;
  final Map<int, Set<QuestionType>> _usedTypesByItem = {};
  final Map<int, int> _adaptiveRepeatCount = {};
  final Map<int, int> _adaptiveCorrectStreak = {};
  final Set<int> _adaptiveCompleted = {};

  @override
  void initState() {
    super.initState();
    if (widget.resumeSnapshot != null) {
      _restoreSession(widget.resumeSnapshot!);
    } else {
      _startTest();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Session state is already persisted on interactions/navigation actions.
    // Avoid provider reads during dispose to prevent invalid ref access.
    super.dispose();
  }

  void _startTest() {
    final language = ref.read(appLanguageProvider);
    final questions = _questionGenerator.generateQuestions(
      items: widget.items,
      enabledTypes: widget.config.enabledTypes,
      count: widget.config.questionCount,
      language: language,
      shuffleItems: widget.config.shuffleQuestions,
    );

    _adaptiveAdded = 0;
    _adaptiveRepeatCount.clear();
    _adaptiveCorrectStreak.clear();
    _adaptiveCompleted.clear();
    _usedTypesByItem.clear();
    for (final q in questions) {
      _usedTypesByItem
          .putIfAbsent(q.targetItem.id, () => <QuestionType>{})
          .add(q.type);
    }
    _adaptiveMaxExtra = (widget.config.questionCount * 0.3).floor().clamp(
      0,
      20,
    );

    _session = TestSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: widget.lessonId,
      startedAt: DateTime.now(),
      questions: questions,
      timeLimitMinutes: widget.config.timeLimitMinutes,
    );

    // Start timer if time limit exists
    if (widget.config.timeLimitMinutes != null) {
      _secondsRemaining = widget.config.timeLimitMinutes! * 60;
      _startTimer();
    }
    _persistSession();
  }

  void _restoreSession(TestSessionSnapshot snapshot) {
    final session = snapshot.buildSession(widget.items);
    setState(() {
      _session = session;
      _adaptiveAdded = snapshot.adaptiveAdded;
      _adaptiveMaxExtra = snapshot.adaptiveMaxExtra > 0
          ? snapshot.adaptiveMaxExtra
          : (widget.config.questionCount * 0.3).floor().clamp(0, 20);
      _adaptiveRepeatCount
        ..clear()
        ..addAll(snapshot.adaptiveRepeatCount);
      _adaptiveCorrectStreak
        ..clear()
        ..addAll(snapshot.adaptiveCorrectStreak);
      _adaptiveCompleted
        ..clear()
        ..addAll(snapshot.adaptiveCompleted);
      _usedTypesByItem
        ..clear()
        ..addAll(snapshot.usedTypesByItem);
      _resetQuestionState(_session.currentQuestionIndex);
    });

    if (widget.config.timeLimitMinutes != null) {
      final totalSeconds = widget.config.timeLimitMinutes! * 60;
      final elapsed = DateTime.now().difference(snapshot.startedAt).inSeconds;
      _secondsRemaining = (totalSeconds - elapsed).clamp(0, totalSeconds);
      if (_secondsRemaining > 0) {
        _startTimer();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_submitTest());
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
      });

      if (_secondsRemaining <= 0) {
        timer.cancel();
        unawaited(_submitTest());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final question = _session.currentQuestion;

    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('${language.testModeLabel}: ${widget.lessonTitle}'),
        actions: [
          // Timer display
          if (widget.config.timeLimitMinutes != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: _buildTimerDisplay()),
            ),
          // Flag button
          IconButton(
            icon: Icon(
              _session.isFlagged(_session.currentQuestionIndex)
                  ? Icons.flag
                  : Icons.flag_outlined,
              color: _session.isFlagged(_session.currentQuestionIndex)
                  ? context.appPalette.warning
                  : null,
            ),
            onPressed: () {
              setState(() {
                _session.toggleFlag(_session.currentQuestionIndex);
              });
              _persistSession();
            },
            tooltip: language.flagForReviewLabel,
          ),
        ],
      ),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1180;
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Column(
                      children: [
                        _buildSessionOverview(language, question),
                        const SizedBox(height: AppSpacing.md),
                        Expanded(
                          child: wide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 9,
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: _buildQuestionStage(
                                              question,
                                              language,
                                              wide: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    SizedBox(
                                      width: 320,
                                      child: _buildSidePanel(language),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildQuestionNavigatorCard(),
                                    const SizedBox(height: AppSpacing.md),
                                    Expanded(
                                      child: _buildQuestionStage(
                                        question,
                                        language,
                                        wide: false,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildNavigationButtons(language),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    final isLow = _secondsRemaining < 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isLow
            ? context.appPalette.error.withValues(alpha: 0.2)
            : context.appPalette.outline,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 18,
            color: isLow ? context.appPalette.error : null,
          ),
          const SizedBox(width: 4),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLow ? context.appPalette.error : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigatorCard() {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(
              ref.read(appLanguageProvider),
              'Question map',
              'Bản đồ câu hỏi',
              '問題マップ',
            ),
            style: TextStyle(fontWeight: FontWeight.w800, color: palette.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _session.totalQuestions,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) => _buildQuestionMapButton(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Question question, AppLanguage language) {
    final chips = <Widget>[
      _buildStageChip(
        icon: Icons.school_rounded,
        label: question.targetItem.level,
        color: context.appPalette.secondary,
      ),
    ];
    if (_session.isFlagged(_session.currentQuestionIndex)) {
      chips.add(
        _buildStageChip(
          icon: Icons.flag_rounded,
          label: _tr(
            language,
            'Flagged for review',
            'Đã gắn cờ ôn lại',
            '復習フラグあり',
          ),
          color: context.appPalette.warning,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: chips,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildQuestionContent(question, language),
      ],
    );
  }

  Widget _buildQuestionStage(
    Question question,
    AppLanguage language, {
    required bool wide,
  }) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wide ? 860 : 760),
            child: AnimatedSwitcher(
              duration: reducedMotionDuration(
                context,
                const Duration(milliseconds: 300),
              ),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.06),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(question.id),
                child: _buildQuestionWidget(question, language),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionOverview(AppLanguage language, Question question) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.testProgressLabel(
                        _session.currentQuestionIndex + 1,
                        _session.totalQuestions,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.ink.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _questionTypeLabel(language, question.type),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildMetricChip(
                    icon: Icons.check_circle_outline_rounded,
                    label: _tr(
                      language,
                      'Answered ${_session.answeredCount}',
                      'Đã làm ${_session.answeredCount}',
                      '回答済み ${_session.answeredCount}',
                    ),
                    color: palette.secondary,
                  ),
                  _buildMetricChip(
                    icon: Icons.flag_outlined,
                    label: _tr(
                      language,
                      'Flagged ${_session.flaggedQuestions.length}',
                      'Gắn cờ ${_session.flaggedQuestions.length}',
                      'フラグ ${_session.flaggedQuestions.length}',
                    ),
                    color: palette.warning,
                  ),
                  _buildMetricChip(
                    icon: Icons.insights_rounded,
                    label: _tr(
                      language,
                      'Correct ${_session.correctCount}',
                      'Đúng ${_session.correctCount}',
                      '正解 ${_session.correctCount}',
                    ),
                    color: palette.info,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: _session.progress,
              minHeight: 8,
              backgroundColor: palette.base,
              color: palette.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(AppLanguage language) {
    final palette = context.appPalette;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.elevated.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(language, 'Question map', 'Bản đồ câu hỏi', '問題マップ'),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: List.generate(
                    _session.totalQuestions,
                    _buildQuestionMapButton,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.elevated.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: palette.outlineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr(language, 'Run mode', 'Chế độ làm bài', '実行モード'),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildSideInfoRow(
                  _tr(language, 'Questions', 'Số câu', '問題数'),
                  '${widget.config.questionCount}',
                ),
                _buildSideInfoRow(
                  _tr(language, 'Types', 'Dạng câu', '形式'),
                  widget.config.enabledTypes
                      .map((type) => _questionTypeLabel(language, type))
                      .join(', '),
                ),
                _buildSideInfoRow(
                  _tr(language, 'Timer', 'Thời gian', '時間'),
                  widget.config.timeLimitMinutes == null
                      ? _tr(language, 'Off', 'Tắt', 'オフ')
                      : '${widget.config.timeLimitMinutes} min',
                ),
                _buildSideInfoRow(
                  _tr(language, 'Review', 'Phản hồi', '復習'),
                  widget.config.showCorrectAfterWrong
                      ? _tr(
                          language,
                          'Show after wrong',
                          'Hiện sau câu sai',
                          '誤答後に表示',
                        )
                      : _tr(language, 'Exam style', 'Kiểu thi', '試験スタイル'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionMapButton(int index) {
    final palette = context.appPalette;
    final isAnswered =
        index < _session.answers.length &&
        _session.answers[index].userAnswer != null;
    final isCurrent = index == _session.currentQuestionIndex;
    final isFlagged = _session.isFlagged(index);
    return GestureDetector(
      onTap: () => _goToQuestion(index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCurrent
              ? palette.primary
              : isAnswered
              ? palette.secondary.withValues(alpha: 0.12)
              : palette.base,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isFlagged
                ? palette.warning
                : isCurrent
                ? palette.primary
                : palette.outlineSoft,
            width: isFlagged ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isCurrent
                ? Colors.white
                : isAnswered
                ? palette.secondary
                : palette.ink.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildSideInfoRow(String label, String value) {
    final palette = context.appPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.ink.withValues(alpha: 0.56),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: palette.ink,
            ),
          ),
        ],
      ),
    );
  }

  String _questionTypeLabel(AppLanguage language, QuestionType type) {
    return switch (type) {
      QuestionType.multipleChoice => _tr(
        language,
        'Multiple choice',
        'Trắc nghiệm',
        '選択問題',
      ),
      QuestionType.trueFalse => _tr(
        language,
        'True / False',
        'Đúng / Sai',
        '正誤問題',
      ),
      QuestionType.fillBlank => _tr(
        language,
        'Fill in the blank',
        'Điền chỗ trống',
        '穴埋め',
      ),
    };
  }

  Widget _buildQuestionContent(Question question, AppLanguage language) {
    final revealCorrectAnswer =
        _showResult && (_isCorrect || widget.config.showCorrectAfterWrong);
    switch (question.type) {
      case QuestionType.multipleChoice:
        return MultipleChoiceWidget(
          question: question,
          selectedAnswer: _selectedAnswer,
          showResult: _showResult,
          revealCorrectAnswer: revealCorrectAnswer,
          language: language,
          onSelect: _handleMultipleChoiceSelect,
        );

      case QuestionType.trueFalse:
        return TrueFalseWidget(
          question: question,
          selectedAnswer: _selectedTrueFalse,
          showResult: _showResult,
          revealCorrectAnswer: revealCorrectAnswer,
          language: language,
          onSelect: _handleTrueFalseSelect,
        );

      case QuestionType.fillBlank:
        return FillBlankWidget(
          question: question,
          showResult: _showResult,
          isCorrect: _isCorrect,
          revealCorrectAnswer: revealCorrectAnswer,
          initialAnswer: _selectedAnswer,
          language: language,
          onSubmit: _handleFillBlankSubmit,
        );
    }
  }

  Widget _buildNavigationButtons(AppLanguage language) {
    final palette = context.appPalette;
    final isFirst = _session.currentQuestionIndex == 0;
    final isLast = _session.currentQuestionIndex == _session.totalQuestions - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.elevated.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFirst ? null : _previousQuestion,
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(language.previousLabel),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: isLast ? _showSubmitDialog : _nextQuestion,
              icon: Icon(
                isLast ? Icons.verified_rounded : Icons.arrow_forward_rounded,
              ),
              label: Text(
                isLast ? language.submitTestLabel : language.nextLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMultipleChoiceSelect(String answer) {
    _session.submitAnswer(answer);
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _isCorrect = _session.currentQuestion!.checkAnswer(answer);
    });

    _maybeQueueAdaptiveQuestion(_session.currentQuestion!, _isCorrect);
    _persistSession();
  }

  void _handleTrueFalseSelect(bool answer) {
    _session.submitAnswer(answer ? 'true' : 'false');
    setState(() {
      _selectedTrueFalse = answer;
      _showResult = true;
      _isCorrect = _session.currentQuestion!.checkAnswer(
        answer ? 'true' : 'false',
      );
    });

    _maybeQueueAdaptiveQuestion(_session.currentQuestion!, _isCorrect);
    _persistSession();
  }

  void _handleFillBlankSubmit(String answer) {
    _session.submitAnswer(answer);
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _isCorrect = _session.currentQuestion!.checkAnswer(answer);
    });

    _maybeQueueAdaptiveQuestion(_session.currentQuestion!, _isCorrect);
    _persistSession();
  }

  void _maybeQueueAdaptiveQuestion(Question question, bool isCorrect) {
    if (!widget.config.adaptiveTesting) return;

    final item = question.targetItem;
    final currentStreak = _adaptiveCorrectStreak[item.id] ?? 0;
    if (isCorrect) {
      final nextStreak = currentStreak + 1;
      _adaptiveCorrectStreak[item.id] = nextStreak;
      if (nextStreak >= 2) {
        _adaptiveCompleted.add(item.id);
      }
      return;
    }

    _adaptiveCorrectStreak[item.id] = 0;
    if (_adaptiveCompleted.contains(item.id)) return;
    if (_adaptiveAdded >= _adaptiveMaxExtra) return;
    if (widget.config.enabledTypes.length < 2) return;
    final currentRepeats = _adaptiveRepeatCount[item.id] ?? 0;
    if (currentRepeats >= 2) return;
    final repeatChance = currentRepeats == 0 ? 1.0 : 0.6;
    if (_random.nextDouble() > repeatChance) return;

    final usedTypes = _usedTypesByItem.putIfAbsent(
      item.id,
      () => <QuestionType>{},
    )..add(question.type);

    final availableTypes = widget.config.enabledTypes
        .where((type) => !usedTypes.contains(type))
        .toList();
    if (availableTypes.isEmpty) return;

    final nextType = availableTypes[_random.nextInt(availableTypes.length)];
    final newQuestion = _questionGenerator.generateQuestionForItem(
      item: item,
      type: nextType,
      allItems: widget.items,
      language: ref.read(appLanguageProvider),
    );
    if (newQuestion == null) return;

    _session.questions.add(newQuestion);
    usedTypes.add(nextType);
    _adaptiveAdded++;
    _adaptiveRepeatCount.update(item.id, (v) => v + 1, ifAbsent: () => 1);
  }

  void _goToQuestion(int index) {
    setState(() {
      _session.currentQuestionIndex = index;
      _resetQuestionState(index);
    });
    _persistSession();
  }

  void _previousQuestion() {
    if (_session.currentQuestionIndex > 0) {
      setState(() {
        _session.currentQuestionIndex--;
        _resetQuestionState(_session.currentQuestionIndex);
      });
      _persistSession();
    }
  }

  void _nextQuestion() {
    if (_session.currentQuestionIndex < _session.totalQuestions - 1) {
      setState(() {
        _session.currentQuestionIndex++;
        _resetQuestionState(_session.currentQuestionIndex);
      });
      _persistSession();
    }
  }

  void _resetQuestionState(int index) {
    final answer = _session.getAnswer(index);
    _selectedAnswer = answer?.userAnswer;
    _selectedTrueFalse = answer?.userAnswer == 'true'
        ? true
        : answer?.userAnswer == 'false'
        ? false
        : null;
    _showResult = answer?.userAnswer != null;
    _isCorrect = answer?.isCorrect ?? false;
  }

  void _showSubmitDialog() {
    final unanswered = _session.totalQuestions - _session.answeredCount;
    final language = ref.read(appLanguageProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.submitTestTitle),
        content: unanswered > 0
            ? Text(language.unansweredSubmitLabel(unanswered))
            : Text(language.submitTestTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTest();
            },
            child: Text(language.submitTestConfirmLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest() async {
    if (_isSubmitting) {
      return;
    }
    _isSubmitting = true;
    _timer?.cancel();
    _session.completedAt = DateTime.now();
    final vocabSource = widget.lessonId < 0 ? 'content' : 'lesson';

    final mistakeRepo = ref.read(mistakeRepositoryProvider);
    for (int i = 0; i < _session.questions.length; i++) {
      final question = _session.questions[i];
      final answer = _session.getAnswer(i);
      if (answer == null || !answer.isCorrect) {
        await mistakeRepo.addMistake(
          type: 'vocab',
          itemId: question.targetItem.id,
          context: MistakeContext(
            prompt: question.questionText,
            correctAnswer: question.correctAnswer,
            userAnswer: answer?.userAnswer,
            source: 'test',
            extra: {'type': question.type.name, 'vocabSource': vocabSource},
          ),
        );
      } else {
        await mistakeRepo.markCorrect(
          type: 'vocab',
          itemId: question.targetItem.id,
        );
      }
    }

    final weakTermIds = _session.weakTermIds.toSet().toList(growable: false);
    if (weakTermIds.isEmpty) {
      await RecoveryPackService.clear();
    } else {
      await RecoveryPackService.saveExamPack(
        lessonTitle: widget.lessonTitle,
        termIds: weakTermIds,
      );
    }
    refreshRecoveryPack(ref);

    // Save to database
    await ref.read(testHistoryServiceProvider).saveTest(_session);
    await ref
        .read(lessonRepositoryProvider)
        .recordStudyActivity(xpDelta: _session.xpEarned);

    await _clearSavedSession();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(
          session: _session,
          lessonTitle: widget.lessonTitle,
        ),
      ),
    );
  }

  Future<void> _persistSession() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.saveTestSession(
      snapshot: TestSessionSnapshot(
        sessionKey: widget.sessionKey,
        sessionId: _session.sessionId,
        lessonId: _session.lessonId,
        startedAt: _session.startedAt,
        currentQuestionIndex: _session.currentQuestionIndex,
        questions: _session.questions,
        answers: _session.answers,
        flaggedQuestions: _session.flaggedQuestions,
        config: widget.config,
        adaptiveAdded: _adaptiveAdded,
        adaptiveMaxExtra: _adaptiveMaxExtra,
        usedTypesByItem: _usedTypesByItem,
        adaptiveRepeatCount: _adaptiveRepeatCount,
        adaptiveCorrectStreak: _adaptiveCorrectStreak,
        adaptiveCompleted: _adaptiveCompleted,
        lastSavedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _clearSavedSession() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.clearTestSession(widget.sessionKey);
  }

  String _tr(AppLanguage language, String en, String vi, String ja) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}
