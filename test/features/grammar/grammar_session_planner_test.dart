import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';

void main() {
  group('GrammarSessionPlanner', () {
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
  });
}

GeneratedQuestion _question(int id, GrammarQuestionType type) {
  return _questionForPoint(id, id, type);
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
