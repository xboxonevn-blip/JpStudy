import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/database_provider.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// One day in the 14-day review forecast.
class ForecastDay {
  const ForecastDay({
    required this.date,
    this.vocabDue = 0,
    this.grammarDue = 0,
    this.kanjiDue = 0,
  });

  final DateTime date;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;

  int get total => vocabDue + grammarDue + kanjiDue;
}

/// Stability distribution bucket.
class StabilityBucket {
  const StabilityBucket({
    required this.label,
    required this.minStability,
    required this.maxStability,
    this.vocabCount = 0,
    this.grammarCount = 0,
    this.kanjiCount = 0,
  });

  final String label;
  final double minStability;
  final double maxStability;
  final int vocabCount;
  final int grammarCount;
  final int kanjiCount;

  int get total => vocabCount + grammarCount + kanjiCount;
}

/// Confidence distribution (how user rated reviews).
class ConfidenceBreakdown {
  const ConfidenceBreakdown({
    this.again = 0,
    this.hard = 0,
    this.good = 0,
    this.easy = 0,
  });

  final int again;
  final int hard;
  final int good;
  final int easy;

  int get total => again + hard + good + easy;
}

/// Full analytics snapshot.
class ReviewForecast {
  const ReviewForecast({
    required this.days,
    required this.stabilityBuckets,
    required this.confidence,
    required this.totalTracked,
    required this.totalDueNow,
    required this.avgStability,
  });

  final List<ForecastDay> days;
  final List<StabilityBucket> stabilityBuckets;
  final ConfidenceBreakdown confidence;
  final int totalTracked;
  final int totalDueNow;
  final double avgStability;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final reviewForecastProvider = FutureProvider<ReviewForecast>((ref) async {
  final db = ref.watch(databaseProvider);

  // Fetch all SRS states
  final allVocab = await db.select(db.srsState).get();
  final allGrammar = await db.select(db.grammarSrsState).get();
  final allKanji = await db.select(db.kanjiSrsState).get();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // ── Build 14-day forecast ─────────────────────────────────────
  final days = <ForecastDay>[];
  for (int i = 0; i < 14; i++) {
    final dayStart = today.add(Duration(days: i));
    final dayEnd = dayStart.add(const Duration(days: 1));

    int vocabDue = 0, grammarDue = 0, kanjiDue = 0;

    for (final s in allVocab) {
      if (i == 0 ? s.nextReviewAt.isBefore(dayEnd)
          : !s.nextReviewAt.isBefore(dayStart) && s.nextReviewAt.isBefore(dayEnd)) {
        vocabDue++;
      }
    }
    for (final s in allGrammar) {
      if (i == 0 ? s.nextReviewAt.isBefore(dayEnd)
          : !s.nextReviewAt.isBefore(dayStart) && s.nextReviewAt.isBefore(dayEnd)) {
        grammarDue++;
      }
    }
    for (final s in allKanji) {
      if (i == 0 ? s.nextReviewAt.isBefore(dayEnd)
          : !s.nextReviewAt.isBefore(dayStart) && s.nextReviewAt.isBefore(dayEnd)) {
        kanjiDue++;
      }
    }

    days.add(ForecastDay(
      date: dayStart,
      vocabDue: vocabDue,
      grammarDue: grammarDue,
      kanjiDue: kanjiDue,
    ));
  }

  // ── Stability distribution ────────────────────────────────────
  final buckets = [
    _BucketDef('Critical', 0, 1),
    _BucketDef('Weak', 1, 5),
    _BucketDef('Growing', 5, 21),
    _BucketDef('Strong', 21, 90),
    _BucketDef('Mastered', 90, double.infinity),
  ];

  final stabilityBuckets = buckets.map((b) {
    int vc = 0, gc = 0, kc = 0;
    for (final s in allVocab) {
      if (s.stability >= b.min && s.stability < b.max) vc++;
    }
    for (final s in allGrammar) {
      if (s.stability >= b.min && s.stability < b.max) gc++;
    }
    for (final s in allKanji) {
      if (s.stability >= b.min && s.stability < b.max) kc++;
    }
    return StabilityBucket(
      label: b.label,
      minStability: b.min,
      maxStability: b.max,
      vocabCount: vc,
      grammarCount: gc,
      kanjiCount: kc,
    );
  }).toList();

  // ── Confidence distribution (vocab only, has lastConfidence) ──
  int again = 0, hard = 0, good = 0, easy = 0;
  for (final s in allVocab) {
    switch (s.lastConfidence) {
      case 1:
        again++;
      case 2:
        hard++;
      case 3:
        good++;
      case 4:
        easy++;
    }
  }

  // ── Aggregate stats ───────────────────────────────────────────
  final totalTracked = allVocab.length + allGrammar.length + allKanji.length;
  final totalDueNow = days.isNotEmpty ? days[0].total : 0;

  double sumStability = 0;
  int stabCount = 0;
  for (final s in allVocab) {
    sumStability += s.stability;
    stabCount++;
  }
  for (final s in allGrammar) {
    sumStability += s.stability;
    stabCount++;
  }
  for (final s in allKanji) {
    sumStability += s.stability;
    stabCount++;
  }
  final avgStability = stabCount > 0 ? sumStability / stabCount : 0.0;

  return ReviewForecast(
    days: days,
    stabilityBuckets: stabilityBuckets,
    confidence: ConfidenceBreakdown(
        again: again, hard: hard, good: good, easy: easy),
    totalTracked: totalTracked,
    totalDueNow: totalDueNow,
    avgStability: avgStability,
  );
});

class _BucketDef {
  const _BucketDef(this.label, this.min, this.max);
  final String label;
  final double min;
  final double max;
}
