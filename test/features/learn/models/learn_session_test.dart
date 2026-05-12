import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart';

// ── Fixtures ─────────────────────────────────────────────────

const _vocab1 = VocabItem(
  id: 1,
  term: '水',
  reading: 'みず',
  meaning: 'nước',
  meaningEn: 'water',
  level: 'N5',
);
const _vocab2 = VocabItem(
  id: 2,
  term: '火',
  reading: 'ひ',
  meaning: 'lửa',
  meaningEn: 'fire',
  level: 'N5',
);
const _vocab3 = VocabItem(
  id: 3,
  term: '山',
  reading: 'やま',
  meaning: 'núi',
  meaningEn: 'mountain',
  level: 'N5',
);

const _q1 = Question(
  id: 'q1',
  type: QuestionType.multipleChoice,
  targetItem: _vocab1,
  questionText: 'What is 水?',
  correctAnswer: 'water',
  options: ['water', 'fire'],
);
const _q2 = Question(
  id: 'q2',
  type: QuestionType.multipleChoice,
  targetItem: _vocab2,
  questionText: 'What is 火?',
  correctAnswer: 'fire',
  options: ['water', 'fire'],
);
const _q3 = Question(
  id: 'q3',
  type: QuestionType.fillBlank,
  targetItem: _vocab3,
  questionText: '山 means ___',
  correctAnswer: 'mountain',
);

QuestionResult _result(Question q, {required bool correct, int seconds = 5}) {
  return QuestionResult(
    question: q,
    userAnswer: correct ? q.correctAnswer : 'wrong',
    isCorrect: correct,
    timeTaken: Duration(seconds: seconds),
    answeredAt: DateTime(2024, 1, 1, 10, 0),
  );
}

LearnSession _session({
  List<Question> questions = const [],
  List<QuestionResult>? results,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  return LearnSession(
    sessionId: 'learn-1',
    lessonId: 1,
    startedAt: startedAt ?? DateTime(2024, 1, 1, 10, 0),
    completedAt: completedAt,
    questions: questions,
    results: results,
  );
}

// ── Tests ────────────────────────────────────────────────────

void main() {
  group('LearnSession — basic counters', () {
    test('empty session has zero counts', () {
      final s = _session(questions: [_q1, _q2]);
      expect(s.totalQuestions, 2);
      expect(s.answeredCount, 0);
      expect(s.correctCount, 0);
      expect(s.wrongCount, 0);
    });

    test('counts correct and wrong from results', () {
      final s = _session(
        questions: [_q1, _q2, _q3],
        results: [
          _result(_q1, correct: true),
          _result(_q2, correct: false),
          _result(_q3, correct: true),
        ],
      );
      expect(s.answeredCount, 3);
      expect(s.correctCount, 2);
      expect(s.wrongCount, 1);
    });
  });

  group('LearnSession.accuracy', () {
    test('returns 0 when no answers', () {
      final s = _session(questions: [_q1]);
      expect(s.accuracy, 0.0);
    });

    test('returns ratio of correct to answered', () {
      final s = _session(
        questions: [_q1, _q2, _q3],
        results: [
          _result(_q1, correct: true),
          _result(_q2, correct: false),
          _result(_q3, correct: true),
        ],
      );
      expect(s.accuracy, closeTo(0.667, 0.001));
    });

    test('returns 1.0 for all correct', () {
      final s = _session(
        questions: [_q1, _q2],
        results: [_result(_q1, correct: true), _result(_q2, correct: true)],
      );
      expect(s.accuracy, 1.0);
    });
  });

  group('LearnSession.progress', () {
    test('returns 0 with no questions', () {
      final s = _session(questions: []);
      expect(s.progress, 0.0);
    });

    test('returns fraction of answered questions', () {
      final s = _session(
        questions: [_q1, _q2, _q3],
        results: [_result(_q1, correct: true)],
      );
      expect(s.progress, closeTo(0.333, 0.001));
    });

    test('returns 1.0 when all answered', () {
      final s = _session(
        questions: [_q1],
        results: [_result(_q1, correct: true)],
      );
      expect(s.progress, 1.0);
    });
  });

  group('LearnSession.totalXP', () {
    test('returns 0 for empty results', () {
      final s = _session(questions: [_q1]);
      expect(s.totalXP, 0);
    });

    test('sums XP from all results', () {
      final s = _session(
        questions: [_q1, _q2],
        results: [
          _result(_q1, correct: true, seconds: 5),
          _result(_q2, correct: true, seconds: 5),
        ],
      );
      // Each correct MC: base 5 + difficulty 1 = 6 XP
      expect(s.totalXP, 12);
    });

    test('wrong answers earn 0 XP', () {
      final s = _session(
        questions: [_q1, _q2],
        results: [
          _result(_q1, correct: true, seconds: 5),
          _result(_q2, correct: false, seconds: 5),
        ],
      );
      // Only first correct: 5 + 1 = 6
      expect(s.totalXP, 6);
    });

    test('speed bonus adds +2 for answers under 3s', () {
      final s = _session(
        questions: [_q1],
        results: [_result(_q1, correct: true, seconds: 2)],
      );
      // base 5 + speed 2 + difficulty 1 = 8
      expect(s.totalXP, 8);
    });

    test('fillBlank difficulty bonus is higher', () {
      final s = _session(
        questions: [_q3],
        results: [_result(_q3, correct: true, seconds: 5)],
      );
      // base 5 + difficulty 3 (fillBlank) = 8
      expect(s.totalXP, 8);
    });
  });

  group('LearnSession.weakTermIds', () {
    test('returns IDs of wrong answers', () {
      final s = _session(
        questions: [_q1, _q2, _q3],
        results: [
          _result(_q1, correct: true),
          _result(_q2, correct: false),
          _result(_q3, correct: false),
        ],
      );
      expect(s.weakTermIds, containsAll([_vocab2.id, _vocab3.id]));
      expect(s.weakTermIds, isNot(contains(_vocab1.id)));
    });

    test('deduplicates repeated wrong answers for same term', () {
      final s = _session(
        questions: [_q1, _q1],
        results: [_result(_q1, correct: false), _result(_q1, correct: false)],
      );
      expect(s.weakTermIds, [_vocab1.id]); // deduplicated via toSet()
    });

    test('returns empty list when all correct', () {
      final s = _session(
        questions: [_q1],
        results: [_result(_q1, correct: true)],
      );
      expect(s.weakTermIds, isEmpty);
    });
  });

  group('LearnSession — mastery tracking', () {
    test('term not mastered before 3 correct answers', () {
      final s = _session(questions: [_q1]);
      s.recordResult(_result(_q1, correct: true));
      s.recordResult(_result(_q1, correct: true));
      expect(s.isTermMastered(_vocab1.id), false);
    });

    test('term mastered after 3 correct answers', () {
      final s = _session(questions: [_q1]);
      for (int i = 0; i < 3; i++) {
        s.recordResult(_result(_q1, correct: true));
      }
      expect(s.isTermMastered(_vocab1.id), true);
    });

    test('wrong answers do not increment mastery count', () {
      final s = _session(questions: [_q1]);
      s.recordResult(_result(_q1, correct: false));
      s.recordResult(_result(_q1, correct: true));
      s.recordResult(_result(_q1, correct: true));
      expect(s.isTermMastered(_vocab1.id), false);
    });

    test('unmasteredTermIds returns terms below 3 correct', () {
      final s = _session(questions: [_q1, _q2]);
      for (int i = 0; i < 3; i++) {
        s.recordResult(_result(_q1, correct: true));
      }
      s.recordResult(_result(_q2, correct: true));
      expect(s.unmasteredTermIds, contains(_vocab2.id));
      expect(s.unmasteredTermIds, isNot(contains(_vocab1.id)));
    });

    test('all terms mastered returns empty unmasteredTermIds', () {
      final s = _session(questions: [_q1]);
      for (int i = 0; i < 3; i++) {
        s.recordResult(_result(_q1, correct: true));
      }
      expect(s.unmasteredTermIds, isEmpty);
    });
  });

  group('LearnSession — completion', () {
    test('isComplete is true when completedAt is set', () {
      final s = _session(completedAt: DateTime(2024, 1, 1, 11, 0));
      expect(s.isComplete, true);
    });

    test('isComplete is false when completedAt is null', () {
      final s = _session();
      expect(s.isComplete, false);
    });

    test('totalTime uses completedAt when available', () {
      final start = DateTime(2024, 1, 1, 10, 0);
      final end = DateTime(2024, 1, 1, 10, 30);
      final s = _session(startedAt: start, completedAt: end);
      expect(s.totalTime, const Duration(minutes: 30));
    });
  });

  group('LearnSession — currentQuestion', () {
    test('returns question at current index', () {
      final s = _session(questions: [_q1, _q2]);
      expect(s.currentQuestion, _q1);
      s.currentQuestionIndex = 1;
      expect(s.currentQuestion, _q2);
    });

    test('returns null when index is past end', () {
      final s = _session(questions: [_q1]);
      s.currentQuestionIndex = 5;
      expect(s.currentQuestion, isNull);
    });
  });

  group('QuestionResult.xpEarned', () {
    test('correct MC answer earns base + difficulty', () {
      final r = _result(_q1, correct: true, seconds: 5);
      // base 5 + MC difficulty 1 = 6
      expect(r.xpEarned, 6);
    });

    test('correct fillBlank earns base + higher difficulty', () {
      final r = _result(_q3, correct: true, seconds: 5);
      // base 5 + fillBlank difficulty 3 = 8
      expect(r.xpEarned, 8);
    });

    test('fast correct answer earns speed bonus', () {
      final r = _result(_q1, correct: true, seconds: 2);
      // base 5 + speed 2 + difficulty 1 = 8
      expect(r.xpEarned, 8);
    });

    test('wrong answer earns 0 XP regardless of speed', () {
      final r = _result(_q1, correct: false, seconds: 1);
      expect(r.xpEarned, 0);
    });

    test('exactly 3s does not trigger speed bonus', () {
      final r = _result(_q1, correct: true, seconds: 3);
      // base 5 + difficulty 1 = 6 (no speed bonus at exactly 3s)
      expect(r.xpEarned, 6);
    });
  });
}
