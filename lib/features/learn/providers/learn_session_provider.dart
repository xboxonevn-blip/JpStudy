import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/database_provider.dart';
import '../../../data/daos/learn_dao.dart';
import '../../../data/daos/achievement_dao.dart';
import '../../../data/models/vocab_item.dart';
import '../../mistakes/repositories/mistake_repository.dart';
import '../../../data/models/mistake_context.dart';
import '../../../core/app_language.dart';
import '../models/learn_session.dart';
import '../models/question.dart';
import '../models/question_type.dart';
import '../services/question_generator.dart';
import '../services/learn_session_service.dart';

/// Provider for managing Learn Mode sessions
class LearnSessionNotifier extends StateNotifier<LearnSession?> {
  final QuestionGenerator _questionGenerator = QuestionGenerator();
  final LearnSessionService _learnService;
  final MistakeRepository _mistakeRepo;

  LearnSessionNotifier(this._learnService, this._mistakeRepo) : super(null);

  void restoreSession(LearnSession session) {
    state = session;
  }

  /// Start a new learn session
  void startSession({
    required int lessonId,
    required List<VocabItem> items,
    int questionCount = 20,
    bool shuffleQuestions = true,
    AppLanguage language = AppLanguage.en,
    List<QuestionType> enabledTypes = const [
      QuestionType.multipleChoice,
      QuestionType.trueFalse,
      QuestionType.fillBlank,
    ],
  }) {
    final questions = _questionGenerator.generateQuestions(
      items: items,
      enabledTypes: enabledTypes,
      count: questionCount,
      language: language,
      shuffleItems: shuffleQuestions,
    );

    state = LearnSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: lessonId,
      startedAt: DateTime.now(),
      questions: questions,
    );
  }

  /// Start an adaptive round based on previous performance
  void startAdaptiveRound({
    required List<VocabItem> items,
    required int round,
    AppLanguage language = AppLanguage.en,
  }) {
    if (state == null) return;

    final questions = _questionGenerator.generateAdaptiveRound(
      items: items,
      round: round,
      weakTermIds: state!.weakTermIds,
      language: language,
    );

    state = state!.copyWith(
      questions: questions,
      currentRound: round,
      currentQuestionIndex: 0,
    );
  }

  /// Submit answer for current question
  Future<QuestionResult?> submitAnswer(String answer) async {
    if (state == null || state!.currentQuestion == null) return null;

    final session = state!;
    final sessionId = session.sessionId;
    final questionIndex = session.currentQuestionIndex;
    final resultCount = session.results.length;
    final question = session.currentQuestion!;
    final startTime = DateTime.now().subtract(
      const Duration(seconds: 5),
    ); // Approximate

    final isCorrect = question.checkAnswer(answer);
    final result = QuestionResult(
      question: question,
      userAnswer: answer,
      isCorrect: isCorrect,
      timeTaken: DateTime.now().difference(startTime),
      answeredAt: DateTime.now(),
    );

    // Record mistake if wrong
    if (!isCorrect) {
      await _mistakeRepo.addMistake(
        type: 'vocab',
        itemId: question.targetItem.id,
        context: MistakeContext(
          prompt: question.questionText,
          correctAnswer: question.correctAnswer,
          userAnswer: answer,
          source: 'learn',
          extra: {'type': question.type.name},
        ),
      );
    } else {
      await _mistakeRepo.markCorrect(
        type: 'vocab',
        itemId: question.targetItem.id,
      );
    }

    if (!mounted) {
      return null;
    }
    final activeSession = state;
    if (activeSession == null ||
        activeSession.sessionId != sessionId ||
        activeSession.currentQuestionIndex != questionIndex ||
        activeSession.results.length != resultCount) {
      return null;
    }

    activeSession.recordResult(result);

    // Notify listeners.
    state = activeSession.copyWith();

    return result;
  }

  /// Move to next question. At the final question this awaits session
  /// persistence so callers can rely on the DB write completing before
  /// the future resolves.
  Future<void> nextQuestion() async {
    if (state == null) return;

    if (state!.currentQuestionIndex < state!.questions.length - 1) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex + 1,
      );
    } else {
      await _completeSession();
    }
  }

  void requeueQuestion(Question question) {
    if (state == null) return;
    final nextQuestions = List<Question>.from(state!.questions)..add(question);
    state = state!.copyWith(questions: nextQuestions);
  }

  /// Complete the session.
  ///
  /// Persist-then-mutate: the DB row is written before state flips to
  /// completed, so a save failure leaves the in-memory session in its
  /// pre-completion shape instead of showing a "done" summary that has
  /// no matching row to resume from.
  Future<void> _completeSession() async {
    if (state == null) return;

    final session = state!;
    final sessionId = session.sessionId;
    final questionIndex = session.currentQuestionIndex;
    final completedSession = session.copyWith(completedAt: DateTime.now());
    await _learnService.saveSession(completedSession);
    if (!mounted) {
      return;
    }
    final activeSession = state;
    if (activeSession == null ||
        activeSession.sessionId != sessionId ||
        activeSession.currentQuestionIndex != questionIndex) {
      return;
    }
    state = completedSession;
  }

  /// Reset session
  void reset() {
    state = null;
  }
}

/// Provider instance
final learnSessionProvider =
    StateNotifierProvider<LearnSessionNotifier, LearnSession?>((ref) {
      final db = ref.watch(databaseProvider);
      final mistakeRepo = ref.watch(mistakeRepositoryProvider);

      final learnDao = LearnDao(db);
      final achievementDao = AchievementDao(db);
      final service = LearnSessionService(learnDao, achievementDao);

      return LearnSessionNotifier(service, mistakeRepo);
    });

/// Provider for question timing
final questionStartTimeProvider = StateProvider<DateTime?>((ref) => null);
