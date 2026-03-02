import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

void main() {
  test('WeekSummary stores values correctly', () {
    const summary = WeekSummary(
      totalReviewed: 47,
      accuracy: 83,
      daysStudied: 5,
    );
    expect(summary.totalReviewed, 47);
    expect(summary.accuracy, 83);
    expect(summary.daysStudied, 5);
  });

  test('WeekSummary with zero values', () {
    const summary = WeekSummary(
      totalReviewed: 0,
      accuracy: 0,
      daysStudied: 0,
    );
    expect(summary.totalReviewed, 0);
    expect(summary.accuracy, 0);
    expect(summary.daysStudied, 0);
  });
}
