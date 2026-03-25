import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';

void main() {
  group('WeeklyChallenge.generate', () {
    test('produces valid challenge for a given date', () {
      final challenge = WeeklyChallenge.generate(DateTime(2026, 3, 12));

      expect(challenge.id, matches(RegExp(r'^\d{4}-W\d{2}$')));
      expect(challenge.target, greaterThan(0));
      expect(challenge.current, 0);
      expect(challenge.isComplete, isFalse);
    });

    test('weekStart is always Monday', () {
      final challenge = WeeklyChallenge.generate(DateTime(2026, 3, 12)); // Thursday
      expect(challenge.weekStart.weekday, DateTime.monday);
    });

    test('id uses ISO-like padded week number format', () {
      final challenge = WeeklyChallenge.generate(DateTime(2026, 1, 5));
      expect(challenge.id, matches(RegExp(r'^2026-W\d{2}$')));
    });

    test('reviewCount target is one of expected rotation values', () {
      final seen = <int>{};
      for (int w = 0; w < 30; w++) {
        final challenge = WeeklyChallenge.generate(DateTime(2026, 1, 5 + w * 7));
        if (challenge.type == ChallengeType.reviewCount) {
          seen.add(challenge.target);
        }
      }
      expect(seen, {50, 75, 100});
    });

    test('accuracy target is one of expected rotation values', () {
      final seen = <int>{};
      for (int w = 0; w < 30; w++) {
        final challenge = WeeklyChallenge.generate(DateTime(2026, 1, 5 + w * 7));
        if (challenge.type == ChallengeType.accuracy) {
          seen.add(challenge.target);
        }
      }
      expect(seen, {75, 80, 85});
    });

    test('streakDays target is one of expected rotation values', () {
      final seen = <int>{};
      for (int w = 0; w < 30; w++) {
        final challenge = WeeklyChallenge.generate(DateTime(2026, 1, 5 + w * 7));
        if (challenge.type == ChallengeType.streakDays) {
          seen.add(challenge.target);
        }
      }
      expect(seen, {5, 6, 7});
    });

    test('xpTarget target is one of expected rotation values', () {
      final seen = <int>{};
      for (int w = 0; w < 30; w++) {
        final challenge = WeeklyChallenge.generate(DateTime(2026, 1, 5 + w * 7));
        if (challenge.type == ChallengeType.xpTarget) {
          seen.add(challenge.target);
        }
      }
      expect(seen, {200, 300, 500});
    });

    test('lessonCount target is one of expected rotation values', () {
      final seen = <int>{};
      for (int w = 0; w < 30; w++) {
        final challenge = WeeklyChallenge.generate(DateTime(2026, 1, 5 + w * 7));
        if (challenge.type == ChallengeType.lessonCount) {
          seen.add(challenge.target);
        }
      }
      expect(seen, {2, 3, 5});
    });

    test('all 5 ChallengeTypes are covered by rotation', () {
      final seenTypes = <ChallengeType>{};
      for (int w = 0; w < 10; w++) {
        final date = DateTime(2026, 1, 5 + w * 7);
        final challenge = WeeklyChallenge.generate(date);
        seenTypes.add(challenge.type);
      }
      expect(seenTypes, ChallengeType.values.toSet());
    });
  });

  group('completion and progress', () {
    test('isComplete is true when current >= target', () {
      final challenge = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.reviewCount,
        target: 50,
        current: 50,
        weekStart: DateTime(2026, 3, 9),
      );

      expect(challenge.isComplete, isTrue);
      expect(challenge.progress, 1.0);
    });

    test('progress is correct fraction under target', () {
      final under = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.accuracy,
        target: 80,
        current: 40,
        weekStart: DateTime(2026, 3, 9),
      );
      expect(under.progress, 0.5);
    });

    test('progress is clamped to 1.0 when over target', () {
      final over = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.accuracy,
        target: 80,
        current: 100,
        weekStart: DateTime(2026, 3, 9),
      );
      expect(over.progress, 1.0);
    });

    test('progress is 0.0 when target is 0', () {
      final zeroTarget = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.accuracy,
        target: 0,
        current: 100,
        weekStart: DateTime(2026, 3, 9),
      );
      expect(zeroTarget.progress, 0.0);
    });
  });

  group('copyWith', () {
    test('preserves unchanged fields', () {
      final original = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.streakDays,
        target: 5,
        current: 3,
        weekStart: DateTime(2026, 3, 9),
      );

      final updated = original.copyWith(current: 5, completed: true);

      expect(updated.id, '2026-W11');
      expect(updated.type, ChallengeType.streakDays);
      expect(updated.target, 5);
      expect(updated.current, 5);
      expect(updated.completed, isTrue);
      expect(updated.bonusAwarded, isFalse);
    });

    test('can update bonusAwarded independently', () {
      final original = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.streakDays,
        target: 5,
        current: 3,
        weekStart: DateTime(2026, 3, 9),
      );

      final updated = original.copyWith(bonusAwarded: true);
      expect(updated.bonusAwarded, isTrue);
      expect(updated.current, original.current);
      expect(updated.completed, original.completed);
    });
  });

  group('daysLeft', () {
    test('is between 0 and 7', () {
      final challenge = WeeklyChallenge(
        id: '2026-W11',
        type: ChallengeType.xpTarget,
        target: 200,
        current: 0,
        weekStart: DateTime.now().subtract(const Duration(days: 3)),
      );

      expect(challenge.daysLeft, greaterThanOrEqualTo(0));
      expect(challenge.daysLeft, lessThanOrEqualTo(7));
    });

    test('clamps to 0 after the week has passed', () {
      final challenge = WeeklyChallenge(
        id: '2026-W01',
        type: ChallengeType.xpTarget,
        target: 200,
        current: 0,
        weekStart: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(challenge.daysLeft, 0);
    });
  });

  group('constants and ordering', () {
    test('bonusXp constant is 50', () {
      expect(WeeklyChallenge.bonusXp, 50);
    });

    test('challenge type enum order is stable', () {
      expect(ChallengeType.values, [
        ChallengeType.reviewCount,
        ChallengeType.accuracy,
        ChallengeType.streakDays,
        ChallengeType.xpTarget,
        ChallengeType.lessonCount,
      ]);
    });
  });
}
