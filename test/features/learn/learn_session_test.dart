import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

VocabItem _vocab(int id) => VocabItem(id: id, term: 'term$id', meaning: 'meaning$id', level: 'N5');

Question _q(int vocabId) => Question(
      id: 'q$vocabId',
      type: QuestionType.multipleChoice,
      targetItem: _vocab(vocabId),
      questionText: 'term$vocabId',
      correctAnswer: 'meaning$vocabId',
    );

QuestionResult _result(Question q, {bool isCorrect = true}) => QuestionResult(
      question: q,
      userAnswer: isCorrect ? q.correctAnswer : 'wrong',
      isCorrect: isCorrect,
      timeTaken: const Duration(seconds: 2),
      answeredAt: DateTime(2025),
    );

LearnSession _session({List<Question>? questions}) {
  return LearnSession(
    sessionId: 'sess',
    lessonId: 1,
    startedAt: DateTime(2025),
    questions: questions ?? [_q(1), _q(2), _q(3)],
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── accuracy / progress ───────────────────────────────────────────────────

  test('accuracy is 0 when no answers', () {
    expect(_session().accuracy, 0.0);
  });

  test('accuracy is 1.0 when all correct', () {
    final s = _session();
    s.recordResult(_result(_q(1)));
    s.recordResult(_result(_q(2)));
    expect(s.accuracy, 1.0);
  });

  test('accuracy is 0.5 with half correct', () {
    final s = _session();
    s.recordResult(_result(_q(1)));
    s.recordResult(_result(_q(2), isCorrect: false));
    expect(s.accuracy, 0.5);
  });

  test('progress is 0 when no questions', () {
    expect(_session(questions: []).progress, 0.0);
  });

  test('progress = answeredCount / totalQuestions', () {
    final s = _session(questions: [_q(1), _q(2), _q(3), _q(4)]);
    s.recordResult(_result(_q(1)));
    s.recordResult(_result(_q(2)));
    expect(s.progress, 0.5);
  });

  // ── recordResult and mastery ──────────────────────────────────────────────

  test('isTermMastered requires 3 correct answers', () {
    final s = _session();
    final q = _q(1);
    s.recordResult(_result(q));
    s.recordResult(_result(q));
    expect(s.isTermMastered(1), isFalse);
    s.recordResult(_result(q));
    expect(s.isTermMastered(1), isTrue);
  });

  test('wrong answers do not count toward mastery', () {
    final s = _session();
    final q = _q(1);
    s.recordResult(_result(q, isCorrect: false));
    s.recordResult(_result(q, isCorrect: false));
    s.recordResult(_result(q, isCorrect: false));
    expect(s.isTermMastered(1), isFalse);
  });

  test('unmasteredTermIds excludes mastered terms', () {
    final s = _session(questions: [_q(1), _q(2)]);
    final q1 = _q(1);
    // Master term 1 with 3 correct
    s.recordResult(_result(q1));
    s.recordResult(_result(q1));
    s.recordResult(_result(q1));

    final unmastered = s.unmasteredTermIds;
    expect(unmastered, isNot(contains(1)));
    expect(unmastered, contains(2));
  });

  // ── weakTermIds ───────────────────────────────────────────────────────────

  test('weakTermIds includes terms answered wrong', () {
    final s = _session();
    s.recordResult(_result(_q(1)));
    s.recordResult(_result(_q(2), isCorrect: false));
    s.recordResult(_result(_q(2), isCorrect: false));

    final weak = s.weakTermIds;
    expect(weak, contains(2));
    expect(weak, isNot(contains(1)));
  });

  test('weakTermIds deduplicates repeated wrong answers', () {
    final s = _session();
    final q = _q(3);
    s.recordResult(_result(q, isCorrect: false));
    s.recordResult(_result(q, isCorrect: false));
    // Same term appears twice wrong, should be deduplicated
    expect(s.weakTermIds.where((id) => id == 3).length, 1);
  });

  // ── totalXP ───────────────────────────────────────────────────────────────

  test('totalXP sums xpEarned across results', () {
    final s = _session();
    // Correct multipleChoice fast (2s) = 5 + 2 speed + 1 diff = 8 each
    s.recordResult(_result(_q(1)));
    s.recordResult(_result(_q(2)));
    // All correct fast → 8 each = 16
    expect(s.totalXP, 16);
  });

  test('totalXP is 0 when no answers', () {
    expect(_session().totalXP, 0);
  });

  // ── isComplete ────────────────────────────────────────────────────────────

  test('isComplete false when completedAt is null', () {
    expect(_session().isComplete, isFalse);
  });

  test('isComplete true when completedAt is set', () {
    final s = _session();
    s.completedAt = DateTime(2025, 1, 2);
    expect(s.isComplete, isTrue);
  });

  // ── currentQuestion ───────────────────────────────────────────────────────

  test('currentQuestion returns question at current index', () {
    final s = _session(questions: [_q(1), _q(2), _q(3)]);
    s.currentQuestionIndex = 2;
    expect(s.currentQuestion!.targetItem.id, 3);
  });

  test('currentQuestion returns null when index out of bounds', () {
    final s = _session(questions: [_q(1)]);
    s.currentQuestionIndex = 5;
    expect(s.currentQuestion, isNull);
  });
}
