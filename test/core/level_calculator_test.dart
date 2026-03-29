import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/gamification/level_calculator.dart';

void main() {
  group('LevelCalculator.calculate', () {
    test('0 XP → Level 1', () {
      final r = LevelCalculator.calculate(0);
      expect(r.level, 1);
      expect(r.totalXp, 0);
    });

    test('99 XP → still Level 1', () {
      expect(LevelCalculator.calculate(99).level, 1);
    });

    test('100 XP → Level 2', () {
      final r = LevelCalculator.calculate(100);
      expect(r.level, 2);
    });

    test('200 XP → Level 2', () {
      expect(LevelCalculator.calculate(200).level, 2);
    });

    test('250 XP → Level 3', () {
      expect(LevelCalculator.calculate(249).level, 2);
      expect(LevelCalculator.calculate(250).level, 3);
    });

    test('level increases monotonically with XP', () {
      int prevLevel = 1;
      for (final xp in [0, 50, 100, 200, 300, 500, 1000, 5000]) {
        final r = LevelCalculator.calculate(xp);
        expect(r.level, greaterThanOrEqualTo(prevLevel));
        prevLevel = r.level;
      }
    });

    test('negative XP treated as 0', () {
      expect(LevelCalculator.calculate(-100).level, 1);
    });

    test('progress is in [0.0, 1.0]', () {
      for (final xp in [0, 99, 100, 249, 250, 1000]) {
        final r = LevelCalculator.calculate(xp);
        expect(r.progress, inInclusiveRange(0.0, 1.0));
      }
    });

    test('currentXp < nextLevelXp', () {
      for (final xp in [0, 50, 200, 600]) {
        final r = LevelCalculator.calculate(xp);
        expect(r.currentXp, lessThan(r.nextLevelXp));
      }
    });

    test('label is "Level N"', () {
      expect(LevelCalculator.calculate(0).label, 'Level 1');
      expect(LevelCalculator.calculate(100).label, 'Level 2');
    });
  });
}
