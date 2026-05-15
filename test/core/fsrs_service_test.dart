import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';

void main() {
  final fsrs = FsrsService();
  final t0 = DateTime(2026, 1, 1, 12);

  group('FSRS-6 learning schedule', () {
    test('new-card intervals match reference steps', () {
      final expected = <int, Duration>{
        1: const Duration(minutes: 1),
        2: const Duration(minutes: 5, seconds: 30),
        3: const Duration(minutes: 10),
        4: const Duration(days: 4),
      };

      for (final entry in expected.entries) {
        final result = fsrs.review(
          grade: entry.key,
          stability: 0,
          difficulty: 0,
          lastReviewedAt: null,
          now: t0,
        );
        expect(result.nextReviewAt.difference(t0), entry.value);
      }
    });
  });

  // ── Initial review (first time seeing a card) ─────────────────────────────

  group('initial review (lastReviewedAt == null)', () {
    test('grade 1 gives lower stability than grade 4', () {
      final r1 = fsrs.review(
        grade: 1,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      final r4 = fsrs.review(
        grade: 4,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(r1.stability, lessThan(r4.stability));
    });

    test('easy grade gives longer interval than hard grade', () {
      final r1 = fsrs.review(
        grade: 1,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      final r4 = fsrs.review(
        grade: 4,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(r4.intervalDays, greaterThan(r1.intervalDays));
    });

    test('retrievability is 1 for a new card', () {
      final r = fsrs.review(
        grade: 3,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(r.retrievability, equals(1.0));
    });

    test('nextReviewAt is after now', () {
      final r = fsrs.review(
        grade: 3,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(r.nextReviewAt.isAfter(t0), isTrue);
    });

    test('stability is always >= 0.1 (min clamp)', () {
      final r = fsrs.review(
        grade: 1,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(r.stability, greaterThanOrEqualTo(0.1));
    });

    test('difficulty is clamped to [1, 10]', () {
      for (final g in [1, 2, 3, 4]) {
        final r = fsrs.review(
          grade: g,
          stability: 0,
          difficulty: 5,
          lastReviewedAt: null,
          now: t0,
        );
        expect(r.difficulty, inInclusiveRange(1.0, 10.0));
      }
    });
  });

  // ── Subsequent review ─────────────────────────────────────────────────────

  group('subsequent review', () {
    final lastReview = t0.subtract(const Duration(days: 3));

    test('grade 1 (forgot) lowers stability vs grade 3', () {
      final forgot = fsrs.review(
        grade: 1,
        stability: 5.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      final good = fsrs.review(
        grade: 3,
        stability: 5.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      expect(forgot.stability, lessThan(good.stability));
    });

    test('grade 3 increases stability over time', () {
      final r = fsrs.review(
        grade: 3,
        stability: 3.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      expect(r.stability, greaterThan(3.0));
    });

    test('grade 4 (easy) produces more stability than grade 3 (good)', () {
      final good = fsrs.review(
        grade: 3,
        stability: 3.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      final easy = fsrs.review(
        grade: 4,
        stability: 3.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      expect(easy.stability, greaterThan(good.stability));
    });

    test('grade 2 (hard) produces less stability than grade 3 (good)', () {
      final hard = fsrs.review(
        grade: 2,
        stability: 3.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      final good = fsrs.review(
        grade: 3,
        stability: 3.0,
        difficulty: 5.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      expect(hard.stability, lessThan(good.stability));
    });

    test('review lapse enters 10-minute relearning step', () {
      final r = fsrs.review(
        grade: 1,
        stability: 0.1,
        difficulty: 9.0,
        lastReviewedAt: lastReview,
        now: t0,
      );
      expect(r.intervalDays, closeTo(10 / (24 * 60), 0.00001));
    });
  });

  // ── Grade clamping ────────────────────────────────────────────────────────

  group('grade clamping', () {
    test('grade 0 behaves like grade 1', () {
      final g0 = fsrs.review(
        grade: 0,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      final g1 = fsrs.review(
        grade: 1,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(g0.stability, equals(g1.stability));
    });

    test('grade 5 behaves like grade 4', () {
      final g5 = fsrs.review(
        grade: 5,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      final g4 = fsrs.review(
        grade: 4,
        stability: 0,
        difficulty: 5,
        lastReviewedAt: null,
        now: t0,
      );
      expect(g5.stability, equals(g4.stability));
    });
  });

  // ── Public retrievability method ──────────────────────────────────────────

  group('retrievability()', () {
    test('returns 0 when lastReviewedAt is null', () {
      expect(
        fsrs.retrievability(stability: 5.0, lastReviewedAt: null),
        equals(0.0),
      );
    });

    test('is close to 1 immediately after review', () {
      final r = fsrs.retrievability(
        stability: 10.0,
        lastReviewedAt: t0.subtract(const Duration(seconds: 1)),
        now: t0,
      );
      expect(r, greaterThan(0.99));
    });

    test('decreases as elapsed time grows', () {
      final r1day = fsrs.retrievability(
        stability: 5.0,
        lastReviewedAt: t0.subtract(const Duration(days: 1)),
        now: t0,
      );
      final r10days = fsrs.retrievability(
        stability: 5.0,
        lastReviewedAt: t0.subtract(const Duration(days: 10)),
        now: t0,
      );
      expect(r1day, greaterThan(r10days));
    });
  });
}
