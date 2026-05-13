import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/north_star_eval.dart';

void main() {
  group('NorthStarEvaluator', () {
    test('qualifies only users who pass all three gates', () {
      final report = NorthStarEvaluator.evaluate(const [
        NorthStarUserSnapshot(
          userId: 'qualified',
          srsReviewsCompleted14d: 20,
          n5MicroQuizCorrect: 7,
          n5MicroQuizTotal: 10,
          sessionQualityRating: 4,
        ),
        NorthStarUserSnapshot(
          userId: 'too_few_reviews',
          srsReviewsCompleted14d: 19,
          n5MicroQuizCorrect: 10,
          n5MicroQuizTotal: 10,
          sessionQualityRating: 5,
        ),
        NorthStarUserSnapshot(
          userId: 'quiz_below_threshold',
          srsReviewsCompleted14d: 20,
          n5MicroQuizCorrect: 6,
          n5MicroQuizTotal: 10,
          sessionQualityRating: 5,
        ),
        NorthStarUserSnapshot(
          userId: 'low_quality',
          srsReviewsCompleted14d: 20,
          n5MicroQuizCorrect: 10,
          n5MicroQuizTotal: 10,
          sessionQualityRating: 3,
        ),
      ], expectedCohortSize: 50);

      expect(report.qualifiedUsers, 1);
      expect(report.northStarPercent, 2.0);
      expect(report.reviewGatePasses, 3);
      expect(report.quizGatePasses, 3);
      expect(report.qualityGatePasses, 3);
      expect(report.qualifiedUserIds, ['qualified']);
    });

    test('treats missing quiz attempts and ratings as failed gates', () {
      final report = NorthStarEvaluator.evaluate(const [
        NorthStarUserSnapshot(
          userId: 'missing_quiz',
          srsReviewsCompleted14d: 30,
          n5MicroQuizCorrect: 0,
          n5MicroQuizTotal: 0,
          sessionQualityRating: 5,
        ),
        NorthStarUserSnapshot(
          userId: 'missing_quality',
          srsReviewsCompleted14d: 30,
          n5MicroQuizCorrect: 9,
          n5MicroQuizTotal: 10,
        ),
      ]);

      expect(report.qualifiedUsers, 0);
      expect(report.quizGatePasses, 1);
      expect(report.qualityGatePasses, 1);
      expect(report.usersMissingMicroQuiz, ['missing_quiz']);
      expect(report.usersMissingQualityRating, ['missing_quality']);
    });

    test('synthetic cohort is deterministic and has 50 users', () {
      final first = SyntheticNorthStarCohort.generate(
        seed: 'jpstudy-phase0-ns-v1',
      );
      final second = SyntheticNorthStarCohort.generate(
        seed: 'jpstudy-phase0-ns-v1',
      );

      expect(first, hasLength(50));
      expect(
        first.map((user) => user.toJson()).toList(),
        second.map((user) => user.toJson()).toList(),
      );
    });

    test('renders a compact markdown report with reproducibility metadata', () {
      final report = NorthStarEvaluator.evaluate(const [
        NorthStarUserSnapshot(
          userId: 'u1',
          srsReviewsCompleted14d: 25,
          n5MicroQuizCorrect: 8,
          n5MicroQuizTotal: 10,
          sessionQualityRating: 5,
        ),
      ]);

      final markdown = report.toMarkdown(
        seed: 'jpstudy-phase0-ns-v1',
        commitHash: 'abc123',
      );

      expect(markdown, contains('Commit: `abc123`'));
      expect(markdown, contains('Seed: `jpstudy-phase0-ns-v1`'));
      expect(markdown, contains('NS: 2.00%'));
      expect(markdown, contains('Qualified users: 1 / 50'));
    });
  });
}
