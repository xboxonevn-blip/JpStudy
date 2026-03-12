import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../models/learn_config.dart';
import '../models/learn_session.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import '../providers/learn_session_provider.dart';
import '../widgets/contextual_hint_card.dart';
import '../widgets/fill_blank_widget.dart';
import '../widgets/multiple_choice_widget.dart';
import '../widgets/true_false_widget.dart';
import 'learn_summary_screen.dart';
import '../../../core/services/session_storage_provider.dart';
import '../../../core/services/session_storage.dart';

class LearnScreen extends ConsumerStatefulWidget {
  final List<VocabItem> items;
  final int lessonId;
  final String lessonTitle;
  final LearnConfig config;
  final LearnSessionSnapshot? resumeSnapshot;

  const LearnScreen({
    super.key,
    required this.items,
    required this.lessonId,
    required this.lessonTitle,
    required this.config,
    this.resumeSnapshot,
  });

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  String? _selectedAnswer;
  bool? _selectedTrueFalse;
  bool _showResult = false;
  bool _isCorrect = false;
  final Set<String> _contextHintsShown = {};
  final Set<String> _contextHintsRequeued = {};
  final Set<String> _wrongRequeued = {};

  @override
  void initState() {
    super.initState();
    if (widget.resumeSnapshot != null) {
      _restoreSession(widget.resumeSnapshot!);
    } else {
      _startSession();
    }
  }

  void _restoreSession(LearnSessionSnapshot snapshot) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = snapshot.buildSession(widget.items);
      ref.read(learnSessionProvider.notifier).restoreSession(session);
      final answeredResult = _answeredResultForCurrentIndex(session);
      setState(() {
        _contextHintsShown
          ..clear()
          ..addAll(snapshot.contextHintsShown);
        _contextHintsRequeued
          ..clear()
          ..addAll(snapshot.contextHintsRequeued);
        _wrongRequeued
          ..clear()
          ..addAll(snapshot.wrongRequeued);
        _restoreQuestionState(answeredResult);
      });
    });
  }

  void _startSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final language = ref.read(appLanguageProvider);
      ref
          .read(learnSessionProvider.notifier)
          .startSession(
            lessonId: widget.lessonId,
            items: widget.items,
            questionCount: widget.config.questionCount,
            shuffleQuestions: widget.config.shuffleQuestions,
            enabledTypes: widget.config.enabledTypes,
            language: language,
          );
      _persistSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final session = ref.watch(learnSessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = session.currentQuestion;

    if (question == null || session.isComplete) {
      _clearSavedSession();
      // Navigate to summary
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LearnSummaryScreen(
              session: session,
              lessonTitle: widget.lessonTitle,
              config: widget.config,
            ),
          ),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${language.learnModeLabel}: ${widget.lessonTitle}'),
        actions: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${session.answeredCount + 1}/${session.totalQuestions}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: session.progress,
              backgroundColor: Colors.grey[200],
            ),
          ),

          // Stats row
          _buildStatsRow(session, language),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Retry chip for requeued questions
                  if (_wrongRequeued.contains(question.id))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.refresh,
                              size: 16,
                              color: Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              language.requeueRetryChip,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
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
                ],
              ),
            ),
          ),

          // Continue button (after answering)
          if (_showResult)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isCorrect)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              size: 16,
                              color: Colors.orange[300],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              language.willRetryLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.orange[300],
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCorrect
                              ? Colors.green
                              : Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isCorrect
                              ? language.continueLabel
                              : language.gotItLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  QuestionResult? _answeredResultForCurrentIndex(LearnSession session) {
    if (session.currentQuestionIndex >= session.results.length) {
      return null;
    }
    final result = session.results[session.currentQuestionIndex];
    final currentQuestion = session.currentQuestion;
    if (currentQuestion == null || result.question.id != currentQuestion.id) {
      return null;
    }
    return result;
  }

  void _restoreQuestionState(QuestionResult? result) {
    _selectedAnswer = result?.userAnswer;
    _selectedTrueFalse = result?.userAnswer == 'true'
        ? true
        : result?.userAnswer == 'false'
        ? false
        : null;
    _showResult = result != null;
    _isCorrect = result?.isCorrect ?? false;
  }

  Widget _buildStatsRow(dynamic session, AppLanguage language) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            label: language.correctLabel,
            value: session.correctCount,
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.cancel,
            label: language.incorrectLabel,
            value: session.wrongCount,
            color: Colors.red,
          ),
          _buildStatItem(
            icon: Icons.percent,
            label: language.progressAccuracyLabel,
            value: '${(session.accuracy * 100).toInt()}%',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQuestionWidget(Question question, AppLanguage language) {
    final showContextHint =
        widget.config.enableHints && _contextHintsShown.contains(question.id);
    final revealCorrectAnswer =
        _showResult && (_isCorrect || widget.config.showCorrectAnswer);
    final content = switch (question.type) {
      QuestionType.multipleChoice => MultipleChoiceWidget(
        question: question,
        selectedAnswer: _selectedAnswer,
        showResult: _showResult,
        revealCorrectAnswer: revealCorrectAnswer,
        language: language,
        onSelect: _handleMultipleChoiceSelect,
      ),
      QuestionType.trueFalse => TrueFalseWidget(
        question: question,
        selectedAnswer: _selectedTrueFalse,
        showResult: _showResult,
        revealCorrectAnswer: revealCorrectAnswer,
        language: language,
        onSelect: _handleTrueFalseSelect,
      ),
      QuestionType.fillBlank => FillBlankWidget(
        question: question,
        showResult: _showResult,
        isCorrect: _isCorrect,
        revealCorrectAnswer: revealCorrectAnswer,
        allowHint: widget.config.enableHints,
        initialAnswer: _selectedAnswer,
        language: language,
        onSubmit: _handleFillBlankSubmit,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        const SizedBox(height: 12),
        if (widget.config.enableHints) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: showContextHint
                  ? null
                  : () {
                      setState(() {
                        _contextHintsShown.add(question.id);
                      });
                    },
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(
                showContextHint
                    ? language.contextualHintUsedLabel
                    : language.contextualHintButtonLabel,
              ),
            ),
          ),
          if (showContextHint)
            ContextualHintCard(item: question.targetItem, language: language),
        ],
      ],
    );
  }

  void _handleMultipleChoiceSelect(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
    _submitAnswer(answer);
  }

  void _handleTrueFalseSelect(bool answer) {
    setState(() {
      _selectedTrueFalse = answer;
    });
    _submitAnswer(answer ? 'true' : 'false');
  }

  void _handleFillBlankSubmit(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
    _submitAnswer(answer);
  }

  Future<void> _submitAnswer(String answer) async {
    final result = await ref
        .read(learnSessionProvider.notifier)
        .submitAnswer(answer);

    if (result != null) {
      final usedHint = _contextHintsShown.contains(result.question.id);
      if (usedHint &&
          result.isCorrect &&
          !_contextHintsRequeued.contains(result.question.id)) {
        ref
            .read(learnSessionProvider.notifier)
            .requeueQuestion(result.question);
        _contextHintsRequeued.add(result.question.id);
      }
      // Also requeue wrong answers for a second chance
      if (!result.isCorrect && !_wrongRequeued.contains(result.question.id)) {
        ref
            .read(learnSessionProvider.notifier)
            .requeueQuestion(result.question);
        _wrongRequeued.add(result.question.id);
      }
      setState(() {
        _showResult = true;
        _isCorrect = result.isCorrect;
      });
      await _persistSession();
    }
  }

  void _handleContinue() {
    ref.read(learnSessionProvider.notifier).nextQuestion();

    setState(() {
      _selectedAnswer = null;
      _selectedTrueFalse = null;
      _showResult = false;
      _isCorrect = false;
    });
    _persistSession();
  }

  Future<void> _persistSession() async {
    final session = ref.read(learnSessionProvider);
    if (session == null || session.isComplete) return;
    final storage = ref.read(sessionStorageProvider);
    await storage.saveLearnSession(
      snapshot: LearnSessionSnapshot(
        lessonId: session.lessonId,
        sessionId: session.sessionId,
        startedAt: session.startedAt,
        currentRound: session.currentRound,
        currentQuestionIndex: session.currentQuestionIndex,
        questions: session.questions,
        results: session.results,
        config: widget.config,
        contextHintsShown: _contextHintsShown,
        contextHintsRequeued: _contextHintsRequeued,
        wrongRequeued: _wrongRequeued,
        lastSavedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _clearSavedSession() async {
    final storage = ref.read(sessionStorageProvider);
    await storage.clearLearnSession(widget.lessonId);
  }

  @override
  void dispose() {
    // Session state is already persisted on start and after each interaction.
    // Avoid provider reads during dispose because Riverpod may already be torn down.
    super.dispose();
  }
}
