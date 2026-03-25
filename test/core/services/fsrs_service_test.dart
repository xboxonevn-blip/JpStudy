import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';

// ── Helpers ───────────────────────────────────────────────────

final _svc = FsrsService();

/// Call review for a term seen for the first time.
FsrsReviewResult _firstReview(int grade) => _svc.review(
  grade: grade,
  stability: 0.0,
  difficulty: 0.0,
  lastReviewedAt: null,
  now: DateTime(2024, 1, 1, 12, 0),
);

/// Call review for a subsequent review.
FsrsReviewResult _subsequentReview({
  required int grade,
  required double stability,
  required double difficulty,
  int elapsedDays = 1,
}) {
  final now = DateTime(2024, 1, 10, 12, 0);
  final lastReviewed = now.subtract(Duration(days: elapsedDays));
  return _svc.review(
    grade: grade,
    stability: stability,
    difficulty: difficulty,
    lastReviewedAt: lastReviewed,
    now: now,
  );
}

// ── Tests ────────────────────────────────────────────────────

void main() {
  // ── First review (new card) ───────────────────────────────

  group('FsrsService.review — first review (lastReviewedAt == null)', () {
    test('returns FsrsReviewResult', () {
      expect(_firstReview(3), isA<FsrsReviewResult>());
    });

    test('retrievability is 1.0 on first review', () {
      // No prior review means 100% retrievability at that moment
      expect(_firstReview(3).retrievability, 1.0);
    });

    test('stability is positive for all grades', () {
      for (final grade in [1, 2, 3, 4]) {
        expect(_firstReview(grade).stability, greaterThan(0));
      }
    });

    test('higher grade produces higher initial stability', () {
      // grade 4 (easy) should give higher stability than grade 1 (again)
      final s1 = _firstReview(1).stability;
      final s4 = _firstReview(4).stability;
      expect(s4, greaterThan(s1));
    });

    test('difficulty is in [1.0, 10.0] range', () {
      for (final grade in [1, 2, 3, 4]) {
        final d = _firstReview(grade).difficulty;
        expect(d, inInclusiveRange(1.0, 10.0));
      }
    });

    test('intervalDays is positive', () {
      for (final grade in [1, 2, 3, 4]) {
        expect(_firstReview(grade).intervalDays, greaterThan(0));
      }
    });

    test('nextReviewAt is in the future relative to review time', () {
      final reviewTime = DateTime(2024, 1, 1, 12, 0);
      final result = _svc.review(
        grade: 3,
        stability: 0,
        difficulty: 0,
        lastReviewedAt: null,
        now: reviewTime,
      );
      expect(result.nextReviewAt.isAfter(reviewTime), isTrue);
    });

    test('grade 1 gives lower initial stability than grade 3', () {
      final s1 = _firstReview(1).stability;
      final s3 = _firstReview(3).stability;
      expect(s3, greaterThan(s1));
    });

    test('grades outside 1-4 are clamped', () {
      // grade 0 should be treated as 1, grade 5 as 4
      final r0 = _svc.review(
        grade: 0, stability: 0, difficulty: 0, lastReviewedAt: null,
        now: DateTime(2024, 1, 1),
      );
      final r1 = _firstReview(1);
      expect(r0.stability, closeTo(r1.stability, 0.001));

      final r5 = _svc.review(
        grade: 5, stability: 0, difficulty: 0, lastReviewedAt: null,
        now: DateTime(2024, 1, 1),
      );
      final r4 = _firstReview(4);
      expect(r5.stability, closeTo(r4.stability, 0.001));
    });
  });

  // ── Subsequent review — recall (grades 2-4) ───────────────

  group('FsrsService.review — subsequent recall (grades 2-4)', () {
    const baseStability = 5.0;
    const baseDifficulty = 5.0;

    test('stability increases after correct recall', () {
      final result = _subsequentReview(
        grade: 3,
        stability: baseStability,
        difficulty: baseDifficulty,
      );
      expect(result.stability, greaterThan(baseStability));
    });

    test('easy recall (grade 4) grows stability more than normal recall (grade 3)', () {
      final easy = _subsequentReview(
        grade: 4, stability: baseStability, difficulty: baseDifficulty,
      );
      final normal = _subsequentReview(
        grade: 3, stability: baseStability, difficulty: baseDifficulty,
      );
      expect(easy.stability, greaterThan(normal.stability));
    });

    test('hard recall (grade 2) grows stability less than normal recall (grade 3)', () {
      final hard = _subsequentReview(
        grade: 2, stability: baseStability, difficulty: baseDifficulty,
      );
      final normal = _subsequentReview(
        grade: 3, stability: baseStability, difficulty: baseDifficulty,
      );
      expect(hard.stability, lessThan(normal.stability));
    });

    test('longer elapsed time gives lower retrievability', () {
      final shortElapsed = _subsequentReview(
        grade: 3, stability: baseStability, difficulty: baseDifficulty,
        elapsedDays: 1,
      );
      final longElapsed = _subsequentReview(
        grade: 3, stability: baseStability, difficulty: baseDifficulty,
        elapsedDays: 10,
      );
      expect(longElapsed.retrievability, lessThan(shortElapsed.retrievability));
    });

    test('retrievability is in (0.0, 1.0] range', () {
      final r = _subsequentReview(
        grade: 3, stability: baseStability, difficulty: baseDifficulty,
      );
      expect(r.retrievability, inInclusiveRange(0.0, 1.0));
    });

    test('difficulty stays in [1.0, 10.0] after easy recall', () {
      // Starting with low difficulty + easy grade should not go below 1
      final r = _subsequentReview(
        grade: 4, stability: baseStability, difficulty: 1.5,
      );
      expect(r.difficulty, inInclusiveRange(1.0, 10.0));
    });

    test('difficulty stays in [1.0, 10.0] after hard recall', () {
      // Starting with high difficulty + hard grade should not exceed 10
      final r = _subsequentReview(
        grade: 2, stability: baseStability, difficulty: 9.5,
      );
      expect(r.difficulty, inInclusiveRange(1.0, 10.0));
    });

    test('interval increases with higher stability', () {
      final lowStab = _subsequentReview(
        grade: 3, stability: 1.0, difficulty: baseDifficulty,
      );
      final highStab = _subsequentReview(
        grade: 3, stability: 20.0, difficulty: baseDifficulty,
      );
      expect(highStab.intervalDays, greaterThan(lowStab.intervalDays));
    });

    test('nextReviewAt is after review time', () {
      final now = DateTime(2024, 1, 10, 12, 0);
      final result = _svc.review(
        grade: 3,
        stability: baseStability,
        difficulty: baseDifficulty,
        lastReviewedAt: now.subtract(const Duration(days: 5)),
        now: now,
      );
      expect(result.nextReviewAt.isAfter(now), isTrue);
    });
  });

  // ── Subsequent review — forgotten (grade 1) ───────────────

  group('FsrsService.review — forgotten (grade 1)', () {
    test('forgotten card gets significantly lower stability than recalled', () {
      const stability = 10.0;
      const difficulty = 5.0;

      final forgotten = _subsequentReview(
        grade: 1, stability: stability, difficulty: difficulty,
      );
      final recalled = _subsequentReview(
        grade: 3, stability: stability, difficulty: difficulty,
      );

      expect(forgotten.stability, lessThan(recalled.stability));
    });

    test('forgotten stability is still positive (minimum 0.1)', () {
      final r = _subsequentReview(
        grade: 1, stability: 1.0, difficulty: 5.0,
      );
      expect(r.stability, greaterThanOrEqualTo(0.1));
    });

    test('forgotten card gets shorter interval than recalled', () {
      final forgotten = _subsequentReview(
        grade: 1, stability: 5.0, difficulty: 5.0,
      );
      final recalled = _subsequentReview(
        grade: 3, stability: 5.0, difficulty: 5.0,
      );
      expect(forgotten.intervalDays, lessThan(recalled.intervalDays));
    });

    test('difficulty increases after forgetting', () {
      // Forgetting a card means grade=1 < 3 baseline, so difficulty increases
      final r = _subsequentReview(
        grade: 1, stability: 5.0, difficulty: 5.0,
      );
      expect(r.difficulty, greaterThan(5.0));
    });
  });

  // ── retrievability() public method ───────────────────────

  group('FsrsService.retrievability()', () {
    test('returns 0 when lastReviewedAt is null', () {
      final r = _svc.retrievability(stability: 5.0, lastReviewedAt: null);
      expect(r, 0.0);
    });

    test('returns ~1 immediately after review', () {
      final now = DateTime(2024, 1, 1, 12, 0);
      final r = _svc.retrievability(
        stability: 5.0,
        lastReviewedAt: now,
        now: now,
      );
      // elapsedDays = 0 → retrievability = 1
      expect(r, closeTo(1.0, 0.001));
    });

    test('decreases as time passes', () {
      final now = DateTime(2024, 1, 15);
      final r1 = _svc.retrievability(
        stability: 5.0,
        lastReviewedAt: now.subtract(const Duration(days: 1)),
        now: now,
      );
      final r10 = _svc.retrievability(
        stability: 5.0,
        lastReviewedAt: now.subtract(const Duration(days: 10)),
        now: now,
      );
      expect(r10, lessThan(r1));
    });

    test('higher stability means slower forgetting', () {
      final now = DateTime(2024, 1, 10);
      final lastReviewed = now.subtract(const Duration(days: 5));
      final lowStab = _svc.retrievability(
        stability: 1.0, lastReviewedAt: lastReviewed, now: now,
      );
      final highStab = _svc.retrievability(
        stability: 20.0, lastReviewedAt: lastReviewed, now: now,
      );
      expect(highStab, greaterThan(lowStab));
    });
  });

  // ── Interval minimum ─────────────────────────────────────

  group('FsrsService — interval minimum', () {
    test('minimum interval is at least 60 seconds even for very low stability', () {
      // grade 1, lastReviewed just now → should still be at least 60s later
      final now = DateTime(2024, 1, 1, 12, 0);
      final result = _svc.review(
        grade: 1,
        stability: 0.01,
        difficulty: 9.0,
        lastReviewedAt: now,
        now: now,
      );
      final diff = result.nextReviewAt.difference(now).inSeconds;
      expect(diff, greaterThanOrEqualTo(60));
    });

    test('intervalDays is at least 0.01', () {
      final result = _svc.review(
        grade: 1,
        stability: 0.001,
        difficulty: 10.0,
        lastReviewedAt: DateTime(2024, 1, 1),
        now: DateTime(2024, 1, 1),
      );
      expect(result.intervalDays, greaterThanOrEqualTo(0.01));
    });
  });

  // ── Retention parameter ──────────────────────────────────

  group('FsrsService — retention parameter', () {
    test('lower retention target produces shorter interval', () {
      const stability = 10.0;
      const difficulty = 5.0;
      final now = DateTime(2024, 1, 10);
      final lastReviewed = now.subtract(const Duration(days: 5));

      final highRetention = _svc.review(
        grade: 3, stability: stability, difficulty: difficulty,
        lastReviewedAt: lastReviewed, now: now,
        retention: 0.95,
      );
      final lowRetention = _svc.review(
        grade: 3, stability: stability, difficulty: difficulty,
        lastReviewedAt: lastReviewed, now: now,
        retention: 0.7,
      );
      // Higher retention = stricter = shorter intervals
      expect(highRetention.intervalDays, lessThan(lowRetention.intervalDays));
    });
  });
}
