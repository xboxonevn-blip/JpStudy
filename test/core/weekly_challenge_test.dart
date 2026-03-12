import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/models/weekly_challenge.dart';

void main() {
  test('generate produces valid challenge for a given date', () {
    final challenge = WeeklyChallenge.generate(DateTime(2026, 3, 12));

    expect(challenge.id, matches(RegExp(r'^\d{4}-W\d{2}$')));
    expect(challenge.target, greaterThan(0));
    expect(challenge.current, 0);
    expect(challenge.isComplete, isFalse);
  });

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

  test('progress is clamped between 0.0 and 1.0', () {
    final under = WeeklyChallenge(
      id: '2026-W11',
      type: ChallengeType.accuracy,
      target: 80,
      current: 40,
      weekStart: DateTime(2026, 3, 9),
    );
    expect(under.progress, 0.5);

    final over = WeeklyChallenge(
      id: '2026-W11',
      type: ChallengeType.accuracy,
      target: 80,
      current: 100,
      weekStart: DateTime(2026, 3, 9),
    );
    expect(over.progress, 1.0);
  });

  test('copyWith preserves unchanged fields', () {
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
    expect(updated.bonusAwarded, isFalse); // Default unchanged
  });

  test('all 5 ChallengeTypes are covered by rotation', () {
    final seenTypes = <ChallengeType>{};
    // Generate for 5 different weeks to hit all rotations.
    for (int w = 0; w < 5; w++) {
      final date = DateTime(2026, 1, 5 + w * 7); // Sequential Mondays
      final challenge = WeeklyChallenge.generate(date);
      seenTypes.add(challenge.type);
    }
    expect(seenTypes, ChallengeType.values.toSet());
  });

  test('bonusXp constant is 50', () {
    expect(WeeklyChallenge.bonusXp, 50);
  });

  test('daysLeft is between 0 and 7', () {
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
}
