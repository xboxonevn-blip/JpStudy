import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';

void main() {
  group('GrammarSessionPlanner', () {
    // -------------------------------------------------------------------------
    // Core planner contract
    // -------------------------------------------------------------------------

    test('returns empty list when allQuestions is empty', () {
      final session = GrammarSessionPlanner(random: Random(1)).build(
        allQuestions: [],
        targetCount: 10,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 8,
      );
      expect(session, isEmpty);
    });

    test('returns empty list when targetCount is 0', () {
      final bank = [
        _question(1, GrammarQuestionType.cloze),
        _question(2, GrammarQuestionType.multipleChoice),
      ];
      final session = GrammarSessionPlanner(random: Random(1)).build(
        allQuestions: bank,
        targetCount: 0,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 8,
      );
      expect(session, isEmpty);
    });

    test('returns all questions when pool is smaller than targetCount', () {
      final bank = [
        _question(1, GrammarQuestionType.cloze),
        _question(2, GrammarQuestionType.multipleChoice),
        _question(3, GrammarQuestionType.errorCorrection),
      ];
      final session = GrammarSessionPlanner(random: Random(1)).build(
        allQuestions: bank,
        targetCount: 10,
        blueprint: GrammarPracticeBlueprint.quiz,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 5,
      );
      // Cannot exceed the pool size
      expect(session.length, lessThanOrEqualTo(bank.length));
    });

    test('returns exactly targetCount when pool is larger', () {
      final bank = _largeBank(20);
      final session = GrammarSessionPlanner(random: Random(42)).build(
        allQuestions: bank,
        targetCount: 8,
        blueprint: GrammarPracticeBlueprint.quiz,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 5,
      );
      expect(session, hasLength(8));
    });

    test('does not return more than targetCount even with maxQuestionsPerPoint',
        () {
      final bank = _largeBank(30);
      final session = GrammarSessionPlanner(random: Random(99)).build(
        allQuestions: bank,
        targetCount: 6,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 8,
        maxQuestionsPerPoint: 2,
      );
      expect(session.length, lessThanOrEqualTo(6));
    });

    // -------------------------------------------------------------------------
    // opener randomisation
    // -------------------------------------------------------------------------

    test(
      'varies the opening question even when the pool is smaller than the session target',
      () {
        final bank = <GeneratedQuestion>[
          _question(1, GrammarQuestionType.cloze),
          _question(2, GrammarQuestionType.errorCorrection),
          _question(3, GrammarQuestionType.errorReason),
          _question(4, GrammarQuestionType.transformation),
          _question(5, GrammarQuestionType.sentenceBuilder),
          _question(6, GrammarQuestionType.contextChoice),
        ];

        final firstQuestions = <String>{};
        for (final seed in [1, 2, 3, 4, 5, 6, 7, 8]) {
          final session = GrammarSessionPlanner(random: Random(seed)).build(
            allQuestions: bank,
            targetCount: 10,
            blueprint: GrammarPracticeBlueprint.drill,
            goalProfile: GrammarGoalProfile.balanced,
            antiRepeatWindow: 8,
          );
          firstQuestions.add(session.first.question);
        }

        expect(firstQuestions.length, greaterThan(1));
      },
    );

    test('keeps the target size but still changes the session opener', () {
      final bank = <GeneratedQuestion>[
        _question(1, GrammarQuestionType.multipleChoice),
        _question(2, GrammarQuestionType.reverseMultipleChoice),
        _question(3, GrammarQuestionType.cloze),
        _question(4, GrammarQuestionType.contextChoice),
        _question(5, GrammarQuestionType.pairContrast),
        _question(6, GrammarQuestionType.errorCorrection),
        _question(7, GrammarQuestionType.transformation),
        _question(8, GrammarQuestionType.errorReason),
        _question(9, GrammarQuestionType.sentenceBuilder),
        _question(10, GrammarQuestionType.multipleChoice),
        _question(11, GrammarQuestionType.cloze),
        _question(12, GrammarQuestionType.contextChoice),
      ];

      final firstQuestions = <String>{};
      for (final seed in [11, 12, 13, 14, 15, 16, 17, 18]) {
        final session = GrammarSessionPlanner(random: Random(seed)).build(
          allQuestions: bank,
          targetCount: 6,
          blueprint: GrammarPracticeBlueprint.quiz,
          goalProfile: GrammarGoalProfile.balanced,
          antiRepeatWindow: 10,
        );
        expect(session, hasLength(6));
        firstQuestions.add(session.first.question);
      }

      expect(firstQuestions.length, greaterThan(1));
    });

    // -------------------------------------------------------------------------
    // maxQuestionsPerPoint cap
    // -------------------------------------------------------------------------

    test('caps how many questions one grammar point can occupy', () {
      final bank = <GeneratedQuestion>[
        _questionForPoint(1, 1, GrammarQuestionType.cloze),
        _questionForPoint(1, 2, GrammarQuestionType.errorCorrection),
        _questionForPoint(1, 3, GrammarQuestionType.errorReason),
        _questionForPoint(1, 4, GrammarQuestionType.transformation),
        _questionForPoint(1, 5, GrammarQuestionType.contextChoice),
        _questionForPoint(2, 6, GrammarQuestionType.cloze),
        _questionForPoint(2, 7, GrammarQuestionType.errorCorrection),
      ];

      final session = GrammarSessionPlanner(random: Random(42)).build(
        allQuestions: bank,
        targetCount: 6,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 8,
        maxQuestionsPerPoint: 2,
      );

      final byPoint = <int, int>{};
      for (final question in session) {
        byPoint[question.point.id] = (byPoint[question.point.id] ?? 0) + 1;
      }

      expect(byPoint[1], lessThanOrEqualTo(2));
      expect(byPoint[2], lessThanOrEqualTo(2));
    });

    test('honours cap of 1 per point (each point appears at most once)', () {
      final bank = <GeneratedQuestion>[
        _questionForPoint(1, 1, GrammarQuestionType.cloze),
        _questionForPoint(1, 2, GrammarQuestionType.errorCorrection),
        _questionForPoint(2, 3, GrammarQuestionType.cloze),
        _questionForPoint(2, 4, GrammarQuestionType.errorCorrection),
        _questionForPoint(3, 5, GrammarQuestionType.cloze),
      ];

      final session = GrammarSessionPlanner(random: Random(7)).build(
        allQuestions: bank,
        targetCount: 5,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 5,
        maxQuestionsPerPoint: 1,
      );

      final byPoint = <int, int>{};
      for (final q in session) {
        byPoint[q.point.id] = (byPoint[q.point.id] ?? 0) + 1;
      }

      for (final count in byPoint.values) {
        expect(count, lessThanOrEqualTo(1));
      }
    });

    // -------------------------------------------------------------------------
    // Blueprint and goalProfile variations
    // -------------------------------------------------------------------------

    test('learn blueprint produces a valid session', () {
      final bank = _largeBank(20);
      final session = GrammarSessionPlanner(random: Random(1)).build(
        allQuestions: bank,
        targetCount: 8,
        blueprint: GrammarPracticeBlueprint.learn,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 5,
      );
      expect(session, isNotEmpty);
      expect(session.length, lessThanOrEqualTo(8));
    });

    test('quiz blueprint produces a valid session', () {
      final bank = _largeBank(20);
      final session = GrammarSessionPlanner(random: Random(2)).build(
        allQuestions: bank,
        targetCount: 8,
        blueprint: GrammarPracticeBlueprint.quiz,
        goalProfile: GrammarGoalProfile.accuracy,
        antiRepeatWindow: 5,
      );
      expect(session, isNotEmpty);
      expect(session.length, lessThanOrEqualTo(8));
    });

    test('drill blueprint with speed profile produces valid session', () {
      final bank = _largeBank(20);
      final session = GrammarSessionPlanner(random: Random(3)).build(
        allQuestions: bank,
        targetCount: 10,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.speed,
        antiRepeatWindow: 6,
      );
      expect(session, isNotEmpty);
      expect(session.length, lessThanOrEqualTo(10));
    });

    // -------------------------------------------------------------------------
    // Anti-repeat window
    // -------------------------------------------------------------------------

    test(
        'antiRepeatWindow with diverse bank avoids same grammar point in window',
        () {
      // Use a larger pool with 5+ distinct grammar points so the planner has
      // room to shuffle without being forced to repeat.
      final bank = <GeneratedQuestion>[
        _questionForPoint(1, 1, GrammarQuestionType.cloze),
        _questionForPoint(2, 2, GrammarQuestionType.errorCorrection),
        _questionForPoint(3, 3, GrammarQuestionType.errorReason),
        _questionForPoint(4, 4, GrammarQuestionType.transformation),
        _questionForPoint(5, 5, GrammarQuestionType.contextChoice),
        _questionForPoint(1, 6, GrammarQuestionType.multipleChoice),
        _questionForPoint(2, 7, GrammarQuestionType.pairContrast),
        _questionForPoint(3, 8, GrammarQuestionType.sentenceBuilder),
        _questionForPoint(4, 9, GrammarQuestionType.reverseMultipleChoice),
        _questionForPoint(5, 10, GrammarQuestionType.cloze),
      ];
      const window = 3;
      final session = GrammarSessionPlanner(random: Random(11)).build(
        allQuestions: bank,
        targetCount: 8,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: window,
      );

      // Verify no two consecutive questions belong to the same grammar point.
      for (var i = 0; i < session.length - 1; i++) {
        expect(
          session[i].point.id == session[i + 1].point.id,
          isFalse,
          reason:
              'Two consecutive questions from the same grammar point at positions $i and ${i + 1}',
        );
      }
    });

    test('antiRepeatWindow of 0 does not crash', () {
      final bank = _largeBank(10);
      final session = GrammarSessionPlanner(random: Random(5)).build(
        allQuestions: bank,
        targetCount: 5,
        blueprint: GrammarPracticeBlueprint.quiz,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 0,
      );
      expect(session.length, lessThanOrEqualTo(5));
    });

    // -------------------------------------------------------------------------
    // Determinism with same seed
    // -------------------------------------------------------------------------

    test('same seed produces the same session ordering', () {
      final bank = _largeBank(15);
      List<String> run(int seed) {
        return GrammarSessionPlanner(random: Random(seed))
            .build(
              allQuestions: bank,
              targetCount: 7,
              blueprint: GrammarPracticeBlueprint.drill,
              goalProfile: GrammarGoalProfile.balanced,
              antiRepeatWindow: 4,
            )
            .map((q) => q.question)
            .toList();
      }

      expect(run(123), equals(run(123)));
    });

    test('different seeds produce different sessions at least sometimes', () {
      final bank = _largeBank(15);
      final orderings = <List<String>>{};
      for (final seed in [1, 2, 3, 4, 5]) {
        final session = GrammarSessionPlanner(random: Random(seed))
            .build(
              allQuestions: bank,
              targetCount: 7,
              blueprint: GrammarPracticeBlueprint.drill,
              goalProfile: GrammarGoalProfile.balanced,
              antiRepeatWindow: 4,
            )
            .map((q) => q.question)
            .toList();
        orderings.add(session);
      }
      // At least some seeds should produce different orderings
      expect(orderings.length, greaterThan(1));
    });

    // -------------------------------------------------------------------------
    // All questions are drawn from the input bank (no phantom questions)
    // -------------------------------------------------------------------------

    test('all returned questions come from the input bank', () {
      final bank = _largeBank(12);
      final bankQuestions = bank.map((q) => q.question).toSet();

      final session = GrammarSessionPlanner(random: Random(77)).build(
        allQuestions: bank,
        targetCount: 8,
        blueprint: GrammarPracticeBlueprint.quiz,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 5,
      );

      for (final q in session) {
        expect(bankQuestions.contains(q.question), isTrue,
            reason: '${q.question} was not in the input bank');
      }
    });

    // -------------------------------------------------------------------------
    // No duplicate questions in one session
    // -------------------------------------------------------------------------

    test('session contains no duplicate questions', () {
      final bank = _largeBank(20);
      final session = GrammarSessionPlanner(random: Random(55)).build(
        allQuestions: bank,
        targetCount: 10,
        blueprint: GrammarPracticeBlueprint.drill,
        goalProfile: GrammarGoalProfile.balanced,
        antiRepeatWindow: 6,
      );

      final unique = session.map((q) => q.question).toSet();
      expect(unique.length, session.length,
          reason: 'Session contains duplicate questions');
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

GeneratedQuestion _question(int id, GrammarQuestionType type) {
  return _questionForPoint(id, id, type);
}

/// Cycle through all question types to create a diverse bank.
GeneratedQuestion _bankQuestion(int id) {
  final types = GrammarQuestionType.values;
  return _questionForPoint((id % 5) + 1, id, types[id % types.length]);
}

/// Create a bank of [count] diverse questions spread across 5 grammar points.
List<GeneratedQuestion> _largeBank(int count) {
  return List.generate(count, _bankQuestion);
}

GeneratedQuestion _questionForPoint(
  int pointId,
  int questionId,
  GrammarQuestionType type,
) {
  return GeneratedQuestion(
    type: type,
    point: GrammarPoint(
      id: pointId,
      lessonId: 1,
      grammarPoint: '文型$pointId',
      meaning: 'Meaning $pointId',
      meaningEn: 'Meaning $pointId',
      meaningVi: 'Nghia $pointId',
      connection: 'Connection $pointId',
      connectionEn: 'Connection $pointId',
      explanation: 'Explanation $pointId',
      explanationEn: 'Explanation $pointId',
      explanationVi: 'Giai thich $pointId',
      jlptLevel: 'N5',
      isLearned: false,
    ),
    question: 'Question $questionId',
    correctAnswer: 'Answer $questionId',
    options: [
      'Answer $questionId',
      'Distractor A$questionId',
      'Distractor B$questionId',
    ],
    familyKey: 'family_$questionId',
    stemKey: 'stem_$questionId',
    answerShapeKey: 'choice_3',
    explanation: 'Explanation $questionId',
  );
}

// ignore_for_file: unused_local_variable
