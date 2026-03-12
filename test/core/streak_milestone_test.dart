import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/models/streak_milestone.dart';

void main() {
  test('forStreak returns null for streak < 7', () {
    expect(StreakMilestone.forStreak(0), isNull);
    expect(StreakMilestone.forStreak(6), isNull);
  });

  test('forStreak returns Bronze at 7', () {
    final m = StreakMilestone.forStreak(7);
    expect(m, isNotNull);
    expect(m!.label, 'Bronze');
    expect(m.threshold, 7);
  });

  test('forStreak returns Silver at 14-29', () {
    final m = StreakMilestone.forStreak(20);
    expect(m, isNotNull);
    expect(m!.label, 'Silver');
  });

  test('forStreak returns Gold at 30-59', () {
    final m = StreakMilestone.forStreak(45);
    expect(m, isNotNull);
    expect(m!.label, 'Gold');
  });

  test('forStreak returns Diamond at 60-99', () {
    final m = StreakMilestone.forStreak(80);
    expect(m, isNotNull);
    expect(m!.label, 'Diamond');
  });

  test('forStreak returns Crown at 100+', () {
    final m = StreakMilestone.forStreak(100);
    expect(m, isNotNull);
    expect(m!.label, 'Crown');
    expect(m.bonusXp, 500);
  });

  test('nextMilestone returns Bronze when streak is 0', () {
    final m = StreakMilestone.nextMilestone(0);
    expect(m, isNotNull);
    expect(m!.label, 'Bronze');
  });

  test('nextMilestone returns Silver when streak is 7', () {
    final m = StreakMilestone.nextMilestone(7);
    expect(m, isNotNull);
    expect(m!.label, 'Silver');
  });

  test('nextMilestone returns null when all milestones achieved', () {
    final m = StreakMilestone.nextMilestone(100);
    expect(m, isNull);
  });

  test('bonusXp equals threshold * 5', () {
    for (final m in StreakMilestone.milestones) {
      expect(m.bonusXp, m.threshold * 5);
    }
  });

  test('milestones are in ascending threshold order', () {
    for (int i = 1; i < StreakMilestone.milestones.length; i++) {
      expect(
        StreakMilestone.milestones[i].threshold,
        greaterThan(StreakMilestone.milestones[i - 1].threshold),
      );
    }
  });
}
