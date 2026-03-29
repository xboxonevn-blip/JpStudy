import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_session.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

VocabItem _vocab(int id) => VocabItem(id: id, term: 'term$id', meaning: 'meaning$id', level: 'N5');

Question _mc(int vocabId) => Question(
      id: 'q$vocabId',
      type: QuestionType.multipleChoice,
      targetItem: _vocab(vocabId),
      questionText: 'term$vocabId',
      correctAnswer: 'meaning$vocabId',
      options: ['meaning$vocabId', 'other1', 'other2'],
    );

Question _tf(int vocabId) => Question(
      id: 'q$vocabId',
      type: QuestionType.trueFalse,
      targetItem: _vocab(vocabId),
      questionText: 'term$vocabId',
      correctAnswer: 'true',
      isStatementTrue: true,
    );

TestSession _session({
  List<Question>? questions,
  List<TestAnswer>? answers,
  int? timeLimitMinutes,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  return TestSession(
    sessionId: 'sess',
    lessonId: 1,
    startedAt: startedAt ?? DateTime(2025, 1, 1, 10),
    completedAt: completedAt,
    questions: questions ?? [_mc(1), _mc(2), _mc(3), _mc(4)],
    answers: answers,
    timeLimitMinutes: timeLimitMinutes,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── score / grade ─────────────────────────────────────────────────────────

  test('score is 0 when no questions', () {
    final s = _session(questions: []);
    expect(s.score, 0.0);
  });

  test('score is 100 when all correct', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'meaning1', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'meaning2', isCorrect: true),
    ];
    final s = _session(questions: [_mc(1), _mc(2)], answers: answers);
    expect(s.score, 100.0);
  });

  test('score is 50 when half correct', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'meaning1', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'wrong', isCorrect: false),
    ];
    final s = _session(questions: [_mc(1), _mc(2)], answers: answers);
    expect(s.score, 50.0);
  });

  test('grade A for score >= 90', () {
    final answers = List.generate(
      10,
      (i) => TestAnswer(questionIndex: i, userAnswer: 'a', isCorrect: true),
    );
    final s = _session(
      questions: List.generate(10, (i) => _mc(i + 1)),
      answers: answers,
    );
    expect(s.grade, 'A');
  });

  test('grade F for score < 60', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'meaning1', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'wrong', isCorrect: false),
      const TestAnswer(questionIndex: 2, userAnswer: 'wrong', isCorrect: false),
    ];
    final s = _session(questions: [_mc(1), _mc(2), _mc(3)], answers: answers);
    expect(s.grade, 'F');
  });

  // ── counts ────────────────────────────────────────────────────────────────

  test('correctCount and wrongCount are complementary', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'a', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'b', isCorrect: false),
      const TestAnswer(questionIndex: 2, userAnswer: 'c', isCorrect: true),
    ];
    final s = _session(
      questions: [_mc(1), _mc(2), _mc(3)],
      answers: answers,
    );
    expect(s.correctCount, 2);
    expect(s.wrongCount, 1);
    expect(s.correctCount + s.wrongCount, s.totalQuestions);
  });

  test('answeredCount excludes null userAnswer', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'a'),
      const TestAnswer(questionIndex: 1, userAnswer: null),
    ];
    final s = _session(questions: [_mc(1), _mc(2)], answers: answers);
    expect(s.answeredCount, 1);
  });

  // ── flag / currentQuestion ────────────────────────────────────────────────

  test('toggleFlag adds then removes a question index', () {
    final s = _session();
    s.toggleFlag(2);
    expect(s.isFlagged(2), isTrue);
    s.toggleFlag(2);
    expect(s.isFlagged(2), isFalse);
  });

  test('currentQuestion returns null when index out of bounds', () {
    final s = _session(questions: [_mc(1)]);
    s.currentQuestionIndex = 99;
    expect(s.currentQuestion, isNull);
  });

  test('currentQuestion returns correct question', () {
    final s = _session(questions: [_mc(1), _mc(2)]);
    s.currentQuestionIndex = 1;
    expect(s.currentQuestion!.id, 'q2');
  });

  // ── submitAnswer ──────────────────────────────────────────────────────────

  test('submitAnswer records correct answer', () {
    final s = _session(questions: [_mc(1)]);
    s.currentQuestionIndex = 0;
    s.submitAnswer('meaning1');
    expect(s.answers.first.isCorrect, isTrue);
    expect(s.answeredCount, 1);
  });

  test('submitAnswer records wrong answer', () {
    final s = _session(questions: [_mc(1)]);
    s.currentQuestionIndex = 0;
    s.submitAnswer('wrong');
    expect(s.answers.first.isCorrect, isFalse);
  });

  // ── weakTermIds ───────────────────────────────────────────────────────────

  test('weakTermIds includes wrong answers and unanswered', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'meaning1', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'wrong', isCorrect: false),
    ];
    final s = _session(questions: [_mc(1), _mc(2), _mc(3)], answers: answers);
    final weak = s.weakTermIds;
    // q2 (wrong) and q3 (unanswered) are weak
    expect(weak, contains(2));
    expect(weak, contains(3));
    expect(weak, isNot(contains(1)));
  });

  // ── xpEarned ─────────────────────────────────────────────────────────────

  test('xpEarned = correctCount * 5 when score < 70', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'a', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'wrong', isCorrect: false),
      const TestAnswer(questionIndex: 2, userAnswer: 'wrong', isCorrect: false),
    ];
    final s = _session(questions: [_mc(1), _mc(2), _mc(3)], answers: answers);
    // score=33%, 1 correct * 5 = 5, no bonus
    expect(s.xpEarned, 5);
  });

  test('xpEarned includes +50 bonus for score >= 90', () {
    final answers = List.generate(
      10,
      (i) => TestAnswer(questionIndex: i, userAnswer: 'a', isCorrect: true),
    );
    final s = _session(
      questions: List.generate(10, (i) => _mc(i + 1)),
      answers: answers,
    );
    // 10 correct * 5 = 50, score=100% → +50 bonus = 100
    expect(s.xpEarned, 100);
  });

  test('xpEarned includes speed bonus when completed under time limit', () {
    final startedAt = DateTime(2025, 1, 1, 10);
    final completedAt = startedAt.add(const Duration(minutes: 3));
    // 2 correct out of 4 = 50% score → no high-score bonus
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'a', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'a', isCorrect: true),
      const TestAnswer(questionIndex: 2, userAnswer: 'x', isCorrect: false),
      const TestAnswer(questionIndex: 3, userAnswer: 'x', isCorrect: false),
    ];
    final s = _session(
      questions: [_mc(1), _mc(2), _mc(3), _mc(4)],
      answers: answers,
      timeLimitMinutes: 5,
      startedAt: startedAt,
      completedAt: completedAt,
    );
    // 2 correct * 5 = 10, score=50% → no high-score bonus, completed 3min < 5min → +10
    expect(s.xpEarned, 20);
  });

  // ── breakdownByType ───────────────────────────────────────────────────────

  test('breakdownByType tracks totals and correct per type', () {
    final answers = [
      const TestAnswer(questionIndex: 0, userAnswer: 'meaning1', isCorrect: true),
      const TestAnswer(questionIndex: 1, userAnswer: 'true', isCorrect: true),
      const TestAnswer(questionIndex: 2, userAnswer: 'wrong', isCorrect: false),
    ];
    final s = _session(
      questions: [_mc(1), _tf(2), _mc(3)],
      answers: answers,
    );
    final breakdown = s.breakdownByType;
    expect(breakdown[QuestionType.multipleChoice]!.total, 2);
    expect(breakdown[QuestionType.multipleChoice]!.correct, 1);
    expect(breakdown[QuestionType.trueFalse]!.total, 1);
    expect(breakdown[QuestionType.trueFalse]!.correct, 1);
  });
}
