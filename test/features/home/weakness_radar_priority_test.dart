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

      expect(calculateMistakePriority(d1, now), greaterThan(calculateMistakePriority(d3, now)));
      expect(calculateMistakePriority(d3, now), greaterThan(calculateMistakePriority(d7, now)));
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

      expect(calculateMistakePriority(high, now), greaterThan(calculateMistakePriority(low, now)));
    });
  });
}
