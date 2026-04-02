import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/app_database.dart';
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

// Minimal projection type — only the columns the forecast algorithm needs.
typedef _SrsRow = ({DateTime nextReviewAt, double stability, int? lastConfidence});

Future<List<_SrsRow>> _fetchVocabProjection(AppDatabase db) async {
  final rows = await (db.selectOnly(db.srsState)
        ..addColumns([
          db.srsState.nextReviewAt,
          db.srsState.stability,
          db.srsState.lastConfidence,
        ]))
      .get();
  return [
    for (final r in rows)
      (
        nextReviewAt: r.read(db.srsState.nextReviewAt)!,
        stability: r.read(db.srsState.stability) ?? 0.0,
        lastConfidence: r.read(db.srsState.lastConfidence),
      ),
  ];
}

Future<List<_SrsRow>> _fetchGrammarProjection(AppDatabase db) async {
  final rows = await (db.selectOnly(db.grammarSrsState)
        ..addColumns([
          db.grammarSrsState.nextReviewAt,
          db.grammarSrsState.stability,
        ]))
      .get();
  return [
    for (final r in rows)
      (
        nextReviewAt: r.read(db.grammarSrsState.nextReviewAt)!,
        stability: r.read(db.grammarSrsState.stability) ?? 0.0,
        lastConfidence: null,
      ),
  ];
}

Future<List<_SrsRow>> _fetchKanjiProjection(AppDatabase db) async {
  final rows = await (db.selectOnly(db.kanjiSrsState)
        ..addColumns([
          db.kanjiSrsState.nextReviewAt,
          db.kanjiSrsState.stability,
        ]))
      .get();
  return [
    for (final r in rows)
      (
        nextReviewAt: r.read(db.kanjiSrsState.nextReviewAt)!,
        stability: r.read(db.kanjiSrsState.stability) ?? 0.0,
        lastConfidence: null,
      ),
  ];
}

final reviewForecastProvider = FutureProvider<ReviewForecast>((ref) async {
  final db = ref.watch(databaseProvider);

  // Fetch only the columns needed for the forecast algorithm — avoids
  // transferring ease, repetitions, box, difficulty, etc. that are unused here.
  // All three queries are independent and run concurrently.
  final vocabFuture = _fetchVocabProjection(db);
  final grammarFuture = _fetchGrammarProjection(db);
  final kanjiFuture = _fetchKanjiProjection(db);
  final allVocab = await vocabFuture;
  final allGrammar = await grammarFuture;
  final allKanji = await kanjiFuture;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // ── Single-pass analysis ──────────────────────────────────────
  // Each type (vocab / grammar / kanji) is iterated exactly once.
  // In that single pass we simultaneously build the 14-day forecast
  // counts, the stability-bucket counts, and the stability average.
  // This reduces N×22 iterations (14 forecast + 5 bucket + 3 average
  // loops) down to N×3 — a ≈7× reduction for large SRS decks.

  const forecastDays = 14;

  // Per-day counts for each type.
  final vocabDay = List.filled(forecastDays, 0);
  final grammarDay = List.filled(forecastDays, 0);
  final kanjiDay = List.filled(forecastDays, 0);

  // Per-bucket counts: [Critical, Weak, Growing, Strong, Mastered]
  // Thresholds: 0-1, 1-5, 5-21, 21-90, 90+
  final vocabBkt = List.filled(5, 0);
  final grammarBkt = List.filled(5, 0);
  final kanjiBkt = List.filled(5, 0);

  // Confidence (vocab only).
  int again = 0, hard = 0, good = 0, easy = 0;

  // Stability totals for average.
  double sumStability = 0;
  int stabCount = 0;

  int stabilityIndex(double s) {
    if (s < 1) return 0;
    if (s < 5) return 1;
    if (s < 21) return 2;
    if (s < 90) return 3;
    return 4;
  }

  int dayIndex(DateTime nextReviewAt) {
    // Items overdue (< today) → day 0; items beyond window → -1 (skip).
    final diff = nextReviewAt.difference(today).inDays;
    if (diff >= forecastDays) return -1;
    return diff.clamp(0, forecastDays - 1);
  }

  for (final s in allVocab) {
    final di = dayIndex(s.nextReviewAt);
    if (di >= 0) vocabDay[di]++;
    vocabBkt[stabilityIndex(s.stability)]++;
    sumStability += s.stability;
    stabCount++;
    switch (s.lastConfidence) {
      case 1: again++;
      case 2: hard++;
      case 3: good++;
      case 4: easy++;
    }
  }
  for (final s in allGrammar) {
    final di = dayIndex(s.nextReviewAt);
    if (di >= 0) grammarDay[di]++;
    grammarBkt[stabilityIndex(s.stability)]++;
    sumStability += s.stability;
    stabCount++;
  }
  for (final s in allKanji) {
    final di = dayIndex(s.nextReviewAt);
    if (di >= 0) kanjiDay[di]++;
    kanjiBkt[stabilityIndex(s.stability)]++;
    sumStability += s.stability;
    stabCount++;
  }

  // ── Build 14-day forecast from pre-bucketed counts ────────────
  final days = <ForecastDay>[
    for (int i = 0; i < forecastDays; i++)
      ForecastDay(
        date: today.add(Duration(days: i)),
        vocabDue: vocabDay[i],
        grammarDue: grammarDay[i],
        kanjiDue: kanjiDay[i],
      ),
  ];

  // ── Stability distribution from pre-bucketed counts ───────────
  const bucketDefs = [
    ('Critical', 0.0, 1.0),
    ('Weak', 1.0, 5.0),
    ('Growing', 5.0, 21.0),
    ('Strong', 21.0, 90.0),
    ('Mastered', 90.0, double.infinity),
  ];
  final stabilityBuckets = <StabilityBucket>[
    for (int i = 0; i < 5; i++)
      StabilityBucket(
        label: bucketDefs[i].$1,
        minStability: bucketDefs[i].$2,
        maxStability: bucketDefs[i].$3,
        vocabCount: vocabBkt[i],
        grammarCount: grammarBkt[i],
        kanjiCount: kanjiBkt[i],
      ),
  ];

  // ── Aggregate stats ───────────────────────────────────────────
  // stabCount == totalTracked since we increment stabCount for every SRS row.
  final totalTracked = stabCount;
  final totalDueNow = days.isNotEmpty ? days[0].total : 0;
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

