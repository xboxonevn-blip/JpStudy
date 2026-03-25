import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_session.dart';

// ── Fixtures ─────────────────────────────────────────────────

const _vocab1 = VocabItem(
  id: 1, term: '水', reading: 'みず', meaning: 'nước', meaningEn: 'water', level: 'N5',
);
const _vocab2 = VocabItem(
  id: 2, term: '火', reading: 'ひ', meaning: 'lửa', meaningEn: 'fire', level: 'N5',
);
const _vocab3 = VocabItem(
  id: 3, term: '山', reading: 'やま', meaning: 'núi', meaningEn: 'mountain', level: 'N5',
);

const _mcQ1 = Question(
  id: 'q1', type: QuestionType.multipleChoice,
  targetItem: _vocab1, questionText: 'What is 水?',
  correctAnswer: 'water', options: ['water', 'fire'],
);
const _mcQ2 = Question(
  id: 'q2', type: QuestionType.multipleChoice,
  targetItem: _vocab2, questionText: 'What is 火?',
  correctAnswer: 'fire', options: ['water', 'fire'],
);
const _tfQ = Question(
  id: 'q3', type: QuestionType.trueFalse,
  targetItem: _vocab3, questionText: '山 means mountain',
  correctAnswer: 'true', isStatementTrue: true,
);
const _fbQ = Question(
  id: 'q4', type: QuestionType.fillBlank,
  targetItem: _vocab1, questionText: 'Water in Japanese is ___',
  correctAnswer: 'みず',
);

TestSession _session({
  List<Question> questions = const [],
  List<TestAnswer>? answers,
  int? timeLimitMinutes,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  return TestSession(
    sessionId: 'test-1',
    lessonId: 1,
    startedAt: startedAt ?? DateTime(2024, 1, 1, 10, 0),
    completedAt: completedAt,
    questions: questions,
    answers: answers,
    timeLimitMinutes: timeLimitMinutes,
  );
}

TestAnswer _correct(int index) => TestAnswer(
  questionIndex: index, userAnswer: 'answer', isCorrect: true,
  answeredAt: DateTime(2024, 1, 1, 10, 1),
);

TestAnswer _wrong(int index) => TestAnswer(
  questionIndex: index, userAnswer: 'wrong', isCorrect: false,
  answeredAt: DateTime(2024, 1, 1, 10, 1),
);

TestAnswer _unanswered(int index) => TestAnswer(questionIndex: index);

// ── Tests ────────────────────────────────────────────────────

void main() {
  group('TestSession — basic counters', () {
    test('empty session has zero counts', () {
      final s = _session(questions: [_mcQ1, _mcQ2]);
      expect(s.totalQuestions, 2);
      expect(s.answeredCount, 0);
      expect(s.correctCount, 0);
      expect(s.wrongCount, 2);
    });

    test('counts correct and wrong answers', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2, _tfQ],
        answers: [_correct(0), _wrong(1), _correct(2)],
      );
      expect(s.answeredCount, 3);
      expect(s.correctCount, 2);
      expect(s.wrongCount, 1);
    });

    test('unanswered questions counted as wrong', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_unanswered(0), _correct(1)],
      );
      // unanswered has isCorrect=false, userAnswer=null
      expect(s.answeredCount, 1); // only non-null userAnswer
      expect(s.correctCount, 1);
      expect(s.wrongCount, 1);
    });
  });

  group('TestSession.score', () {
    test('returns 0 for empty question list', () {
      final s = _session(questions: []);
      expect(s.score, 0.0);
    });

    test('returns 100 for all correct', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_correct(0), _correct(1)],
      );
      expect(s.score, 100.0);
    });

    test('returns 50 for half correct', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_correct(0), _wrong(1)],
      );
      expect(s.score, 50.0);
    });

    test('returns 0 for all wrong', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_wrong(0), _wrong(1)],
      );
      expect(s.score, 0.0);
    });
  });

  group('TestSession.grade', () {
    test('A for 90%+', () {
      // 9/10 = 90%
      final questions = List.generate(10, (i) => _mcQ1);
      final answers = [
        for (int i = 0; i < 9; i++) _correct(i),
        _wrong(9),
      ];
      final s = _session(questions: questions, answers: answers);
      expect(s.grade, 'A');
    });

    test('B for 80-89%', () {
      // 8/10 = 80%
      final questions = List.generate(10, (i) => _mcQ1);
      final answers = [
        for (int i = 0; i < 8; i++) _correct(i),
        _wrong(8),
        _wrong(9),
      ];
      final s = _session(questions: questions, answers: answers);
      expect(s.grade, 'B');
    });

    test('C for 70-79%', () {
      // 7/10 = 70%
      final questions = List.generate(10, (i) => _mcQ1);
      final answers = [
        for (int i = 0; i < 7; i++) _correct(i),
        for (int i = 7; i < 10; i++) _wrong(i),
      ];
      final s = _session(questions: questions, answers: answers);
      expect(s.grade, 'C');
    });

    test('D for 60-69%', () {
      // 6/10 = 60%
      final questions = List.generate(10, (i) => _mcQ1);
      final answers = [
        for (int i = 0; i < 6; i++) _correct(i),
        for (int i = 6; i < 10; i++) _wrong(i),
      ];
      final s = _session(questions: questions, answers: answers);
      expect(s.grade, 'D');
    });

    test('F for below 60%', () {
      // 5/10 = 50%
      final questions = List.generate(10, (i) => _mcQ1);
      final answers = [
        for (int i = 0; i < 5; i++) _correct(i),
        for (int i = 5; i < 10; i++) _wrong(i),
      ];
      final s = _session(questions: questions, answers: answers);
      expect(s.grade, 'F');
    });

    test('boundary: exactly 90% is A, not B', () {
      final s = _session(
        questions: List.generate(10, (_) => _mcQ1),
        answers: [for (int i = 0; i < 9; i++) _correct(i), _wrong(9)],
      );
      expect(s.score, 90.0);
      expect(s.grade, 'A');
    });

    test('boundary: 89% is B', () {
      // 89/100 — use 8/9 ≈ 88.9%
      final questions = List.generate(9, (_) => _mcQ1);
      final answers = [for (int i = 0; i < 8; i++) _correct(i), _wrong(8)];
      final s = _session(questions: questions, answers: answers);
      expect(s.score, closeTo(88.9, 0.1));
      expect(s.grade, 'B');
    });
  });

  group('TestSession.xpEarned', () {
    test('5 XP per correct answer', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2, _tfQ],
        answers: [_correct(0), _wrong(1), _correct(2)],
      );
      // 2 correct * 5 = 10, score = 66.7% → no bonus
      expect(s.xpEarned, 10);
    });

    test('adds +50 bonus for score >= 90%', () {
      final questions = List.generate(10, (_) => _mcQ1);
      final answers = [for (int i = 0; i < 10; i++) _correct(i)];
      final s = _session(questions: questions, answers: answers);
      // 10*5 = 50 base + 50 bonus = 100
      expect(s.xpEarned, 100);
    });

    test('adds +30 bonus for score 80-89%', () {
      final questions = List.generate(10, (_) => _mcQ1);
      final answers = [
        for (int i = 0; i < 8; i++) _correct(i),
        _wrong(8), _wrong(9),
      ];
      final s = _session(questions: questions, answers: answers);
      // 8*5 = 40 base + 30 bonus = 70
      expect(s.xpEarned, 70);
    });

    test('adds +20 bonus for score 70-79%', () {
      final questions = List.generate(10, (_) => _mcQ1);
      final answers = [
        for (int i = 0; i < 7; i++) _correct(i),
        for (int i = 7; i < 10; i++) _wrong(i),
      ];
      final s = _session(questions: questions, answers: answers);
      // 7*5 = 35 base + 20 bonus = 55
      expect(s.xpEarned, 55);
    });

    test('no score bonus below 70%', () {
      final questions = List.generate(10, (_) => _mcQ1);
      final answers = [
        for (int i = 0; i < 6; i++) _correct(i),
        for (int i = 6; i < 10; i++) _wrong(i),
      ];
      final s = _session(questions: questions, answers: answers);
      // 6*5 = 30 base, no bonus
      expect(s.xpEarned, 30);
    });

    test('adds +10 speed bonus when completed under time limit', () {
      final now = DateTime(2024, 1, 1, 10, 0);
      final s = _session(
        questions: List.generate(10, (_) => _mcQ1),
        answers: [for (int i = 0; i < 10; i++) _correct(i)],
        timeLimitMinutes: 30,
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 25)),
      );
      // 10*5 + 50 (score bonus) + 10 (speed) = 110
      expect(s.xpEarned, 110);
    });

    test('no speed bonus when over time limit', () {
      final now = DateTime(2024, 1, 1, 10, 0);
      final s = _session(
        questions: List.generate(10, (_) => _mcQ1),
        answers: [for (int i = 0; i < 10; i++) _correct(i)],
        timeLimitMinutes: 10,
        startedAt: now,
        completedAt: now.add(const Duration(minutes: 15)),
      );
      // 10*5 + 50 = 100 (no speed bonus)
      expect(s.xpEarned, 100);
    });

    test('no speed bonus without time limit', () {
      final s = _session(
        questions: List.generate(10, (_) => _mcQ1),
        answers: [for (int i = 0; i < 10; i++) _correct(i)],
      );
      // 10*5 + 50 = 100
      expect(s.xpEarned, 100);
    });
  });

  group('TestSession.breakdownByType', () {
    test('groups questions by type with correct counts', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2, _tfQ, _fbQ],
        answers: [_correct(0), _wrong(1), _correct(2), _wrong(3)],
      );
      final bd = s.breakdownByType;

      expect(bd[QuestionType.multipleChoice]!.total, 2);
      expect(bd[QuestionType.multipleChoice]!.correct, 1);
      expect(bd[QuestionType.multipleChoice]!.accuracy, 50.0);

      expect(bd[QuestionType.trueFalse]!.total, 1);
      expect(bd[QuestionType.trueFalse]!.correct, 1);
      expect(bd[QuestionType.trueFalse]!.accuracy, 100.0);

      expect(bd[QuestionType.fillBlank]!.total, 1);
      expect(bd[QuestionType.fillBlank]!.correct, 0);
      expect(bd[QuestionType.fillBlank]!.accuracy, 0.0);
    });

    test('handles unanswered questions (no answer in list)', () {
      final s = _session(
        questions: [_mcQ1, _tfQ, _fbQ],
        answers: [_correct(0)], // only first answered
      );
      final bd = s.breakdownByType;

      expect(bd[QuestionType.multipleChoice]!.correct, 1);
      // trueFalse and fillBlank have 0 correct since answers list is short
      expect(bd[QuestionType.trueFalse]!.correct, 0);
      expect(bd[QuestionType.fillBlank]!.correct, 0);
    });

    test('empty session produces empty breakdown', () {
      final s = _session(questions: []);
      expect(s.breakdownByType, isEmpty);
    });
  });

  group('TestSession.weakTermIds', () {
    test('returns IDs of wrong answers', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2, _tfQ],
        answers: [_correct(0), _wrong(1), _correct(2)],
      );
      expect(s.weakTermIds, [_vocab2.id]);
    });

    test('includes unanswered question IDs', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2, _tfQ],
        answers: [_correct(0)], // q2, q3 unanswered
      );
      expect(s.weakTermIds, containsAll([_vocab2.id, _vocab3.id]));
    });

    test('includes null-answer entries', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_unanswered(0), _correct(1)],
      );
      expect(s.weakTermIds, [_vocab1.id]);
    });

    test('all correct returns empty list', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_correct(0), _correct(1)],
      );
      expect(s.weakTermIds, isEmpty);
    });
  });

  group('TestSession — submitAnswer', () {
    test('records correct answer', () {
      final s = _session(questions: [_mcQ1]);
      s.submitAnswer('water');
      expect(s.answers.length, 1);
      expect(s.answers.first.isCorrect, true);
    });

    test('records wrong answer', () {
      final s = _session(questions: [_mcQ1]);
      s.submitAnswer('fire');
      expect(s.answers.first.isCorrect, false);
    });

    test('records null answer as wrong', () {
      final s = _session(questions: [_mcQ1]);
      s.submitAnswer(null);
      expect(s.answers.first.isCorrect, false);
      expect(s.answers.first.userAnswer, isNull);
    });

    test('pads answer list to current question index', () {
      final s = _session(questions: [_mcQ1, _mcQ2, _tfQ]);
      s.currentQuestionIndex = 2;
      s.submitAnswer('true');
      expect(s.answers.length, 3);
      expect(s.answers[2].isCorrect, true);
    });
  });

  group('TestSession — flagging', () {
    test('toggleFlag adds and removes', () {
      final s = _session(questions: [_mcQ1, _mcQ2]);
      expect(s.isFlagged(0), false);
      s.toggleFlag(0);
      expect(s.isFlagged(0), true);
      s.toggleFlag(0);
      expect(s.isFlagged(0), false);
    });
  });

  group('TestSession — progress and completion', () {
    test('progress tracks answered fraction', () {
      final s = _session(
        questions: [_mcQ1, _mcQ2],
        answers: [_correct(0)],
      );
      expect(s.progress, 0.5);
    });

    test('isComplete is true when completedAt is set', () {
      final s = _session(
        questions: [_mcQ1],
        completedAt: DateTime(2024, 1, 1, 11, 0),
      );
      expect(s.isComplete, true);
    });

    test('isComplete is false when completedAt is null', () {
      final s = _session(questions: [_mcQ1]);
      expect(s.isComplete, false);
    });
  });

  group('TypeBreakdown.accuracy', () {
    test('returns 0 when total is 0', () {
      final tb = TypeBreakdown(type: QuestionType.multipleChoice);
      expect(tb.accuracy, 0.0);
    });

    test('calculates correct percentage', () {
      final tb = TypeBreakdown(
        type: QuestionType.multipleChoice, total: 4, correct: 3,
      );
      expect(tb.accuracy, 75.0);
    });
  });
}
