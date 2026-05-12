import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_priority.dart';

UserMistake buildMistake({
  required String type,
  required int wrongCount,
  required DateTime lastMistakeAt,
}) {
  return UserMistake(
    id: 1,
    type: type,
    itemId: 10,
    wrongCount: wrongCount,
    lastMistakeAt: lastMistakeAt,
  );
}

void main() {
  group('calculateMistakePriority', () {
    final now = DateTime(2026, 3, 28, 12);

    test('returns 0 for fresh mistakes under 24h', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 5,
        lastMistakeAt: now.subtract(const Duration(hours: 10)),
      );

      expect(calculateMistakePriority(mistake, now), 0);
    });

    test('prefers D1 over D3 and D7 when wrongCount is equal', () {
      final d1 = buildMistake(
        type: 'vocab',
        wrongCount: 2,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      final d3 = buildMistake(
        type: 'vocab',
        wrongCount: 2,
        lastMistakeAt: now.subtract(const Duration(hours: 90)),
      );
      final d7 = buildMistake(
        type: 'vocab',
        wrongCount: 2,
        lastMistakeAt: now.subtract(const Duration(days: 8)),
      );

      expect(
        calculateMistakePriority(d1, now),
        greaterThan(calculateMistakePriority(d3, now)),
      );
      expect(
        calculateMistakePriority(d3, now),
        greaterThan(calculateMistakePriority(d7, now)),
      );
    });

    test('higher wrongCount still increases score within same bucket', () {
      final low = buildMistake(
        type: 'grammar',
        wrongCount: 1,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      final high = buildMistake(
        type: 'grammar',
        wrongCount: 4,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );

      expect(
        calculateMistakePriority(high, now),
        greaterThan(calculateMistakePriority(low, now)),
      );
    });

    // ── Boundary hour transitions ────────────────────────────────────────────
    //
    // The function uses `>= 24 && < 72` for D1, `>= 72 && < 168` for D3,
    // `>= 168` for D7. Pin each transition explicitly so a future refactor
    // that flips a comparison operator can't slip through review.

    test('exactly 23h59m is still "fresh" → score 0', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 5,
        lastMistakeAt: now.subtract(const Duration(hours: 23, minutes: 59)),
      );
      expect(calculateMistakePriority(mistake, now), 0);
    });

    test('exactly 24h crosses into D1 bucket', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 1,
        lastMistakeAt: now.subtract(const Duration(hours: 24)),
      );
      // wrongCount(1)*10 + D1 bonus(50) = 60
      expect(calculateMistakePriority(mistake, now), 60);
    });

    test('exactly 71h59m is still D1', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 2,
        lastMistakeAt: now.subtract(const Duration(hours: 71, minutes: 59)),
      );
      // 2*10 + 50 = 70
      expect(calculateMistakePriority(mistake, now), 70);
    });

    test('exactly 72h crosses into D3 bucket', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 2,
        lastMistakeAt: now.subtract(const Duration(hours: 72)),
      );
      // 2*10 + 40 = 60
      expect(calculateMistakePriority(mistake, now), 60);
    });

    test('exactly 167h59m is still D3', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 3,
        lastMistakeAt: now.subtract(const Duration(hours: 167, minutes: 59)),
      );
      // 3*10 + 40 = 70
      expect(calculateMistakePriority(mistake, now), 70);
    });

    test('exactly 168h crosses into D7 bucket', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 3,
        lastMistakeAt: now.subtract(const Duration(hours: 168)),
      );
      // 3*10 + 30 = 60
      expect(calculateMistakePriority(mistake, now), 60);
    });

    test('very old mistakes (30 days) stay in D7 bucket', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 1,
        lastMistakeAt: now.subtract(const Duration(days: 30)),
      );
      // 1*10 + 30 = 40
      expect(calculateMistakePriority(mistake, now), 40);
    });

    // ── Exact score formula by bucket ────────────────────────────────────────

    test('D1 score formula: wrongCount=0 → only the 50 bonus', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 0,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      expect(calculateMistakePriority(mistake, now), 50);
    });

    test('D3 score formula: wrongCount=0 → only the 40 bonus', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 0,
        lastMistakeAt: now.subtract(const Duration(hours: 90)),
      );
      expect(calculateMistakePriority(mistake, now), 40);
    });

    test('D7 score formula: wrongCount=0 → only the 30 bonus', () {
      final mistake = buildMistake(
        type: 'vocab',
        wrongCount: 0,
        lastMistakeAt: now.subtract(const Duration(days: 8)),
      );
      expect(calculateMistakePriority(mistake, now), 30);
    });

    test('D1 score scales linearly with wrongCount', () {
      final w1 = buildMistake(
        type: 'vocab',
        wrongCount: 1,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      final w5 = buildMistake(
        type: 'vocab',
        wrongCount: 5,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      // Each wrongCount adds 10 → diff should be exactly (5-1)*10 = 40
      expect(
        calculateMistakePriority(w5, now) - calculateMistakePriority(w1, now),
        40,
      );
    });

    // ── Cross-bucket comparisons ─────────────────────────────────────────────

    test('high wrongCount in D7 can outrank low wrongCount in D1', () {
      // D7 with 5 wrong: 5*10 + 30 = 80
      // D1 with 1 wrong: 1*10 + 50 = 60
      final d7HighCount = buildMistake(
        type: 'vocab',
        wrongCount: 5,
        lastMistakeAt: now.subtract(const Duration(days: 8)),
      );
      final d1LowCount = buildMistake(
        type: 'vocab',
        wrongCount: 1,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      expect(
        calculateMistakePriority(d7HighCount, now),
        greaterThan(calculateMistakePriority(d1LowCount, now)),
      );
    });

    test('item type does not affect score (priority is type-agnostic)', () {
      final vocab = buildMistake(
        type: 'vocab',
        wrongCount: 3,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      final grammar = buildMistake(
        type: 'grammar',
        wrongCount: 3,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      final kanji = buildMistake(
        type: 'kanji',
        wrongCount: 3,
        lastMistakeAt: now.subtract(const Duration(hours: 30)),
      );
      expect(
        calculateMistakePriority(vocab, now),
        calculateMistakePriority(grammar, now),
      );
      expect(
        calculateMistakePriority(vocab, now),
        calculateMistakePriority(kanji, now),
      );
    });
  });
}
