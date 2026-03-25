import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/gamification/level_calculator.dart';

void main() {
  group('LevelCalculator', () {
    // -------------------------------------------------------------------------
    // Boundary: 0 and negative XP
    // -------------------------------------------------------------------------

    test('0 XP → Level 1', () {
      final info = LevelCalculator.calculate(0);
      expect(info.level, 1);
      expect(info.totalXp, 0);
      expect(info.currentXp, 0);
      expect(info.progress, 0.0);
    });

    test('negative XP is treated as 0', () {
      final info = LevelCalculator.calculate(-100);
      expect(info.level, 1);
      expect(info.totalXp, 0);
    });

    // -------------------------------------------------------------------------
    // Level thresholds
    // The iterative algorithm:
    //   starts at threshold = 100, gap = 100.
    //   Level 1: [0, 100) — gap = 100
    //   Level 2: [100, 250) — gap += 50 → 150
    //   Level 3: [250, 450) — gap += 50 → 200
    //   Level 4: [450, 700) — gap += 50 → 250
    // -------------------------------------------------------------------------

    test('99 XP → still Level 1 (just below first threshold)', () {
      final info = LevelCalculator.calculate(99);
      expect(info.level, 1);
    });

    test('100 XP → Level 2 (exactly at first threshold)', () {
      final info = LevelCalculator.calculate(100);
      expect(info.level, 2);
    });

    test('249 XP → still Level 2 (just below second threshold)', () {
      final info = LevelCalculator.calculate(249);
      expect(info.level, 2);
    });

    test('250 XP → Level 3 (exactly at second threshold)', () {
      final info = LevelCalculator.calculate(250);
      expect(info.level, 3);
    });

    test('449 XP → still Level 3', () {
      final info = LevelCalculator.calculate(449);
      expect(info.level, 3);
    });

    test('450 XP → Level 4', () {
      final info = LevelCalculator.calculate(450);
      expect(info.level, 4);
    });

    test('699 XP → still Level 4', () {
      final info = LevelCalculator.calculate(699);
      expect(info.level, 4);
    });

    test('700 XP → Level 5', () {
      final info = LevelCalculator.calculate(700);
      expect(info.level, 5);
    });

    // -------------------------------------------------------------------------
    // Progress within a level
    // -------------------------------------------------------------------------

    test('progress is 0.0 at the start of a level', () {
      final info = LevelCalculator.calculate(100); // Level 2 starts at 100
      expect(info.progress, closeTo(0.0, 0.001));
    });

    test('progress is 1.0 at the top of a level (at threshold)', () {
      // Level 2 spans [100, 250), so 249 XP = 149/150 ≈ 0.993...
      // Level 1 spans [0, 100), so 99 XP = 99/100 = 0.99
      final info = LevelCalculator.calculate(99);
      expect(info.progress, closeTo(0.99, 0.001));
    });

    test('progress is 0.5 at halfway through Level 1', () {
      final info = LevelCalculator.calculate(50);
      expect(info.progress, closeTo(0.5, 0.001));
    });

    test('progress is 0.5 at halfway through Level 2', () {
      // Level 2: [100, 250) = 150 XP gap. Mid = 100 + 75 = 175.
      final info = LevelCalculator.calculate(175);
      expect(info.progress, closeTo(0.5, 0.001));
    });

    // -------------------------------------------------------------------------
    // currentXp and nextLevelXp
    // -------------------------------------------------------------------------

    test('currentXp is XP within current level', () {
      // Level 2 starts at 100.
      final info = LevelCalculator.calculate(130);
      expect(info.currentXp, 30);
    });

    test('nextLevelXp is the size of the current level range', () {
      // Level 1: gap = 100 XP
      final lvl1 = LevelCalculator.calculate(50);
      expect(lvl1.nextLevelXp, 100);

      // Level 2: gap = 150 XP
      final lvl2 = LevelCalculator.calculate(150);
      expect(lvl2.nextLevelXp, 150);
    });

    test('totalXp matches input', () {
      for (final xp in [0, 100, 500, 1000, 9999]) {
        final info = LevelCalculator.calculate(xp);
        expect(info.totalXp, xp,
            reason: 'totalXp should equal the input XP ($xp)');
      }
    });

    // -------------------------------------------------------------------------
    // LevelInfo helpers
    // -------------------------------------------------------------------------

    test('label returns "Level N" string', () {
      final info = LevelCalculator.calculate(0);
      expect(info.label, 'Level 1');

      final info2 = LevelCalculator.calculate(100);
      expect(info2.label, 'Level 2');
    });

    // -------------------------------------------------------------------------
    // High XP values (stress test)
    // -------------------------------------------------------------------------

    test('handles very high XP without throwing', () {
      expect(
        () => LevelCalculator.calculate(1000000),
        returnsNormally,
      );
    });

    test('level increases monotonically as XP increases', () {
      int previousLevel = 0;
      for (var xp = 0; xp <= 5000; xp += 50) {
        final level = LevelCalculator.calculate(xp).level;
        expect(level, greaterThanOrEqualTo(previousLevel),
            reason: 'Level should not decrease at $xp XP');
        previousLevel = level;
      }
    });

    test('progress is always in [0.0, 1.0]', () {
      for (var xp = 0; xp <= 5000; xp += 37) {
        final progress = LevelCalculator.calculate(xp).progress;
        expect(
          progress,
          inInclusiveRange(0.0, 1.0),
          reason: 'Progress $progress out of bounds at $xp XP',
        );
      }
    });
  });
}
