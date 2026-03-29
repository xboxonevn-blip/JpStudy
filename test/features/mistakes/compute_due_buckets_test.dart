import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';

UserMistake _mistake(DateTime lastAt) => UserMistake(
      id: 1,
      type: 'vocab',
      itemId: 1,
      wrongCount: 1,
      lastMistakeAt: lastAt,
    );

void main() {
  final now = DateTime(2026, 3, 1, 12);

  test('mistake < 24h → notDue', () {
    final m = _mistake(now.subtract(const Duration(hours: 10)));
    final b = computeMistakeDueBuckets([m], now);
    expect(b.notDue, 1);
    expect(b.totalDue, 0);
  });

  test('mistake 24-72h → due1d', () {
    final m = _mistake(now.subtract(const Duration(hours: 48)));
    final b = computeMistakeDueBuckets([m], now);
    expect(b.due1d, 1);
    expect(b.due3d, 0);
    expect(b.due7d, 0);
  });

  test('mistake 72h-7d → due3d', () {
    final m = _mistake(now.subtract(const Duration(hours: 96)));
    final b = computeMistakeDueBuckets([m], now);
    expect(b.due3d, 1);
    expect(b.due1d, 0);
  });

  test('mistake >= 7d → due7d', () {
    final m = _mistake(now.subtract(const Duration(days: 8)));
    final b = computeMistakeDueBuckets([m], now);
    expect(b.due7d, 1);
    expect(b.totalDue, 1);
  });

  test('totalDue excludes notDue', () {
    final mistakes = [
      _mistake(now.subtract(const Duration(hours: 2))),    // notDue
      _mistake(now.subtract(const Duration(hours: 48))),   // due1d
      _mistake(now.subtract(const Duration(hours: 100))),  // due3d
    ];
    final b = computeMistakeDueBuckets(mistakes, now);
    expect(b.notDue, 1);
    expect(b.totalDue, 2);
  });

  test('empty list returns all zeros', () {
    final b = computeMistakeDueBuckets([], now);
    expect(b.due1d, 0);
    expect(b.due3d, 0);
    expect(b.due7d, 0);
    expect(b.notDue, 0);
    expect(b.totalDue, 0);
  });
}
