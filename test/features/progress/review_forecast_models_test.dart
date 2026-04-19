import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/progress/providers/review_forecast_provider.dart';

void main() {
  // ── ForecastDay ─────────────────────────────────────────────────────────────

  group('ForecastDay.total', () {
    test('sums vocabDue + grammarDue + kanjiDue', () {
      final day = ForecastDay(
        date: _d,
        vocabDue: 5,
        grammarDue: 3,
        kanjiDue: 2,
      );
      expect(day.total, 10);
    });

    test('returns 0 when all fields default to 0', () {
      final day = ForecastDay(date: _d);
      expect(day.total, 0);
    });

    test('works correctly when only one type has items', () {
      final day = ForecastDay(date: _d, grammarDue: 7);
      expect(day.total, 7);
    });

    test('handles large values without overflow', () {
      final day = ForecastDay(
        date: _d,
        vocabDue: 1000,
        grammarDue: 2000,
        kanjiDue: 3000,
      );
      expect(day.total, 6000);
    });
  });

  // ── StabilityBucket ─────────────────────────────────────────────────────────

  group('StabilityBucket.total', () {
    test('sums vocabCount + grammarCount + kanjiCount', () {
      const bucket = StabilityBucket(
        label: 'Critical',
        minStability: 0,
        maxStability: 1,
        vocabCount: 10,
        grammarCount: 4,
        kanjiCount: 6,
      );
      expect(bucket.total, 20);
    });

    test('returns 0 when all counts default to 0', () {
      const bucket = StabilityBucket(
        label: 'Mastered',
        minStability: 90,
        maxStability: double.infinity,
      );
      expect(bucket.total, 0);
    });

    test('works correctly when only one type has items', () {
      const bucket = StabilityBucket(
        label: 'Weak',
        minStability: 1,
        maxStability: 5,
        kanjiCount: 13,
      );
      expect(bucket.total, 13);
    });

    test('handles single-item buckets', () {
      const bucket = StabilityBucket(
        label: 'Growing',
        minStability: 5,
        maxStability: 21,
        vocabCount: 1,
        grammarCount: 0,
        kanjiCount: 0,
      );
      expect(bucket.total, 1);
    });
  });

  // ── ConfidenceBreakdown ─────────────────────────────────────────────────────

  group('ConfidenceBreakdown.total', () {
    test('sums again + hard + good + easy', () {
      const breakdown = ConfidenceBreakdown(
        again: 2,
        hard: 5,
        good: 30,
        easy: 10,
      );
      expect(breakdown.total, 47);
    });

    test('returns 0 when all fields default to 0', () {
      const breakdown = ConfidenceBreakdown();
      expect(breakdown.total, 0);
    });

    test('works with only one confidence level populated', () {
      const breakdown = ConfidenceBreakdown(good: 15);
      expect(breakdown.total, 15);
    });

    test('again-only represents worst-case session', () {
      const breakdown = ConfidenceBreakdown(again: 100);
      expect(breakdown.total, 100);
    });

    test('easy-only represents best-case session', () {
      const breakdown = ConfidenceBreakdown(easy: 50);
      expect(breakdown.total, 50);
    });

    test('mixed session returns correct total', () {
      const breakdown = ConfidenceBreakdown(
        again: 1,
        hard: 2,
        good: 3,
        easy: 4,
      );
      expect(breakdown.total, 10);
    });
  });

  // ── ReviewForecast ───────────────────────────────────────────────────────────

  group('ReviewForecast', () {
    test('stores all fields correctly', () {
      final days = [ForecastDay(date: _d, vocabDue: 5)];
      final buckets = [
        const StabilityBucket(
          label: 'Critical',
          minStability: 0,
          maxStability: 1,
          vocabCount: 3,
        ),
      ];
      const confidence = ConfidenceBreakdown(good: 10);
      final forecast = ReviewForecast(
        days: days,
        stabilityBuckets: buckets,
        confidence: confidence,
        totalTracked: 42,
        totalDueNow: 5,
        avgStability: 7.5,
      );

      expect(forecast.days, days);
      expect(forecast.stabilityBuckets, buckets);
      expect(forecast.confidence, confidence);
      expect(forecast.totalTracked, 42);
      expect(forecast.totalDueNow, 5);
      expect(forecast.avgStability, 7.5);
    });

    test('totalDueNow equals first day total', () {
      final day0 = ForecastDay(date: _d, vocabDue: 3, grammarDue: 2);
      final forecast = ReviewForecast(
        days: [day0],
        stabilityBuckets: const [],
        confidence: const ConfidenceBreakdown(),
        totalTracked: 5,
        totalDueNow: day0.total,
        avgStability: 2.0,
      );

      expect(forecast.totalDueNow, 5);
    });
  });
}

// Shared fixture date — arbitrary, only used to satisfy the required field.
// DateTime.utc() has no const constructor, so this must be final.
final _d = DateTime.utc(2026, 4, 19);
