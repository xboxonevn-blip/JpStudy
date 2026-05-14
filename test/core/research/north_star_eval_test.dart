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

  group('NorthStarEventMapper', () {
    test('builds user snapshots from normalized event export rows', () {
      final windowStart = DateTime.utc(2026, 5, 1);
      final windowEnd = windowStart.add(const Duration(days: 14));
      final events = [
        for (var index = 0; index < 20; index++)
          NorthStarEvent(
            userId: 'u1',
            name: 'srs_review_completed',
            occurredAt: windowStart.add(Duration(hours: index)),
            parameters: const {'rating': 3},
          ),
        NorthStarEvent(
          userId: 'u1',
          name: 'n5_micro_quiz_completed',
          occurredAt: windowStart.add(const Duration(days: 2)),
          parameters: const {'correct_count': 6, 'total_count': 10},
        ),
        NorthStarEvent(
          userId: 'u1',
          name: 'n5_micro_quiz_completed',
          occurredAt: windowStart.add(const Duration(days: 3)),
          parameters: const {'correct_count': 8, 'total_count': 10},
        ),
        NorthStarEvent(
          userId: 'u1',
          name: 'session_quality_rated',
          occurredAt: windowStart.add(const Duration(days: 4)),
          parameters: const {'rating': 4},
        ),
        NorthStarEvent(
          userId: 'u1',
          name: 'srs_review_completed',
          occurredAt: windowEnd.add(const Duration(minutes: 1)),
          parameters: const {'rating': 3},
        ),
      ];

      final snapshots = NorthStarEventMapper.toUserSnapshots(
        events,
        windowStart: windowStart,
        windowEnd: windowEnd,
      );

      expect(snapshots, hasLength(1));
      expect(snapshots.single.srsReviewsCompleted14d, 20);
      expect(snapshots.single.n5MicroQuizCorrect, 8);
      expect(snapshots.single.n5MicroQuizTotal, 10);
      expect(snapshots.single.sessionQualityRating, 4);
      final report = NorthStarEvaluator.evaluate(snapshots);
      expect(report.qualifiedUsers, 1);
    });

    test('parses normalized event json', () {
      final event = NorthStarEvent.fromJson({
        'userId': 'u1',
        'name': 'session_quality_rated',
        'occurredAt': '2026-05-01T00:00:00.000Z',
        'parameters': {'rating': 5},
      });

      expect(event.userId, 'u1');
      expect(event.name, 'session_quality_rated');
      expect(event.occurredAt, DateTime.parse('2026-05-01T00:00:00.000Z'));
      expect(event.parameters, {'rating': 5});
    });
  });

  group('NorthStarGa4EventMapper', () {
    test('normalizes GA4 BigQuery export rows into North Star events', () {
      final rows = [
        {
          'user_pseudo_id': 'pseudo-1',
          'event_name': 'n5_micro_quiz_completed',
          'event_timestamp': 1777593600123456,
          'event_params': [
            {
              'key': 'correct_count',
              'value': {'int_value': 8},
            },
            {
              'key': 'total_count',
              'value': {'int_value': 10},
            },
            {
              'key': 'mode',
              'value': {'string_value': 'test'},
            },
          ],
        },
        {
          'user_id': 'signed-in-1',
          'user_pseudo_id': 'pseudo-2',
          'event_name': 'session_quality_rated',
          'event_timestamp': '1777680000000000',
          'event_params': [
            {
              'key': 'rating',
              'value': {'double_value': 4.0},
            },
          ],
        },
      ];

      final events = NorthStarGa4EventMapper.toEvents(rows);

      expect(events, hasLength(2));
      expect(events.first.userId, 'pseudo-1');
      expect(events.first.name, 'n5_micro_quiz_completed');
      expect(
        events.first.occurredAt,
        DateTime.utc(2026, 5, 1, 0, 0, 0, 123, 456),
      );
      expect(events.first.parameters, {
        'correct_count': 8,
        'total_count': 10,
        'mode': 'test',
      });
      expect(events.last.userId, 'signed-in-1');
      expect(events.last.parameters, {'rating': 4.0});
    });
  });

  group('SyntheticNorthStarEventSimulator', () {
    test(
      'generates deterministic persona-tagged telemetry for requested users',
      () {
        final windowStart = DateTime.utc(2026, 5, 1);
        final first = SyntheticNorthStarEventSimulator.generate(
          seed: 'jpstudy-phase0-ns-v1',
          userCount: 10,
          windowStart: windowStart,
        );
        final second = SyntheticNorthStarEventSimulator.generate(
          seed: 'jpstudy-phase0-ns-v1',
          userCount: 10,
          windowStart: windowStart,
        );

        expect(first.map((event) => event.userId).toSet(), hasLength(10));
        expect(first.map((event) => event.name).toSet(), {
          'srs_review_completed',
          'n5_micro_quiz_completed',
          'session_quality_rated',
        });
        expect(
          first.map((event) => event.parameters['jlpt_level']).toSet(),
          containsAll(['N5', 'N4', 'N3', 'N2', 'N1']),
        );
        expect(
          first
              .map(
                (event) => {
                  'userId': event.userId,
                  'name': event.name,
                  'occurredAt': event.occurredAt.toIso8601String(),
                  'parameters': event.parameters,
                },
              )
              .toList(),
          second
              .map(
                (event) => {
                  'userId': event.userId,
                  'name': event.name,
                  'occurredAt': event.occurredAt.toIso8601String(),
                  'parameters': event.parameters,
                },
              )
              .toList(),
        );

        final snapshots = NorthStarEventMapper.toUserSnapshots(
          first,
          windowStart: windowStart,
          windowEnd: windowStart.add(const Duration(days: 14)),
        );
        expect(snapshots, hasLength(10));
      },
    );
  });

  group('NorthStarFunnelEvaluator', () {
    test('counts open to onboarding to first SRS funnel stages', () {
      final windowStart = DateTime.utc(2026, 5, 1);
      final events = [
        NorthStarEvent(
          userId: 'u1',
          name: 'app_open',
          occurredAt: windowStart,
          parameters: const {},
        ),
        NorthStarEvent(
          userId: 'u1',
          name: 'onboarding_completed',
          occurredAt: windowStart.add(const Duration(minutes: 2)),
          parameters: const {'level': 'N5', 'goal': 'jlpt'},
        ),
        NorthStarEvent(
          userId: 'u1',
          name: 'srs_review_completed',
          occurredAt: windowStart.add(const Duration(minutes: 5)),
          parameters: const {'item_type': 'vocab'},
        ),
        NorthStarEvent(
          userId: 'u2',
          name: 'app_open',
          occurredAt: windowStart,
          parameters: const {},
        ),
        NorthStarEvent(
          userId: 'u2',
          name: 'onboarding_completed',
          occurredAt: windowStart.add(const Duration(minutes: 3)),
          parameters: const {'level': 'N4', 'goal': 'reading'},
        ),
        NorthStarEvent(
          userId: 'u3',
          name: 'app_open',
          occurredAt: windowStart,
          parameters: const {},
        ),
        NorthStarEvent(
          userId: 'outside',
          name: 'app_open',
          occurredAt: windowStart.subtract(const Duration(minutes: 1)),
          parameters: const {},
        ),
      ];

      final report = NorthStarFunnelEvaluator.evaluate(
        events,
        windowStart: windowStart,
        windowEnd: windowStart.add(const Duration(days: 14)),
      );

      expect(report.observedUsers, 3);
      expect(report.openedUsers, 3);
      expect(report.onboardedUsers, 2);
      expect(report.firstSrsUsers, 1);
      expect(report.openToOnboardingPercent, closeTo(66.666, 0.01));
      expect(report.onboardingToFirstSrsPercent, 50.0);
      expect(report.toMarkdown(), contains('Open -> onboarding: 66.67%'));
    });
  });
}
