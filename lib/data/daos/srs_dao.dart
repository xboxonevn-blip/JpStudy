import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/tables.dart';

part 'srs_dao.g.dart';

class SrsStageBreakdown {
  const SrsStageBreakdown({
    required this.learning,
    required this.young,
    required this.mature,
  });

  final int learning; // stability < 1.0
  final int young; // 1.0 ≤ stability < 21.0
  final int mature; // stability ≥ 21.0

  int get total => learning + young + mature;
}

@DriftAccessor(tables: [SrsState])
class SrsDao extends DatabaseAccessor<AppDatabase> with _$SrsDaoMixin {
  SrsDao(super.db);

  /// Get SRS state for a specific vocab term
  Future<SrsStateData?> getSrsState(int vocabId) {
    return (select(
      srsState,
    )..where((t) => t.vocabId.equals(vocabId))).getSingleOrNull();
  }

  /// Initialize SRS state for a new term
  Future<int> initializeSrsState(int vocabId) {
    return into(srsState).insert(
      SrsStateCompanion.insert(
        vocabId: vocabId,
        nextReviewAt: DateTime.now(),
        // Defaults defined in table
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Update SRS state after a review
  Future<void> updateSrsState({
    required int vocabId,
    required int box,
    required int repetitions,
    required double ease,
    required double stability,
    required double difficulty,
    required int lastConfidence,
    required DateTime nextReviewAt,
  }) {
    return (update(srsState)..where((t) => t.vocabId.equals(vocabId))).write(
      SrsStateCompanion(
        box: Value(box),
        repetitions: Value(repetitions),
        ease: Value(ease),
        stability: Value(stability),
        difficulty: Value(difficulty),
        lastConfidence: Value(lastConfidence),
        lastReviewedAt: Value(DateTime.now()),
        nextReviewAt: Value(nextReviewAt),
      ),
    );
  }

  /// Get all due reviews
  Future<List<SrsStateData>> getDueReviews() {
    return (select(srsState)
          ..where((t) => t.nextReviewAt.isSmallerOrEqualValue(DateTime.now())))
        .get();
  }

  /// Returns the nearest future review date (minimum nextReviewAt > now).
  /// Returns null if no SRS state exists yet.
  Future<DateTime?> getNextScheduledReview() async {
    final row =
        await (select(srsState)
              ..where((t) => t.nextReviewAt.isBiggerThanValue(DateTime.now()))
              ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.nextReviewAt;
  }

  /// One-shot due count — cheaper than getDueReviews().length as it runs
  /// a COUNT(*) query instead of fetching all rows.
  Future<int> getDueReviewCount() async {
    final countExpr = srsState.vocabId.count();
    final row =
        await (selectOnly(srsState)
              ..addColumns([countExpr])
              ..where(
                srsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now()),
              ))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Reactive due count used by dashboard and home indicators.
  Stream<int> watchDueReviewCount() {
    final countExpr = srsState.vocabId.count();
    return (selectOnly(srsState)
          ..addColumns([countExpr])
          ..where(srsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now())))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  /// Batch-fetch SRS states for multiple vocab IDs in a single query.
  /// Replaces the N+1 pattern of calling [getSrsState] per term in a loop.
  Future<Map<int, SrsStateData>> getStatesForIds(List<int> vocabIds) async {
    if (vocabIds.isEmpty) return const {};
    final rows = await (select(
      srsState,
    )..where((t) => t.vocabId.isIn(vocabIds))).get();
    return {for (final r in rows) r.vocabId: r};
  }

  /// COUNT of items that are both due now AND have stability < 1.0 (critical).
  /// Used by dailyPlanProvider to avoid fetching full rows for counting.
  Future<int> getCriticalDueCount() async {
    final countExpr = srsState.vocabId.count();
    final row =
        await (selectOnly(srsState)
              ..addColumns([countExpr])
              ..where(
                srsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now()) &
                    srsState.stability.isSmallerThanValue(1.0),
              ))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Returns counts of SRS items in each FSRS stability bracket.
  /// Only items that have been reviewed at least once are counted.
  ///
  /// Uses a single SQL pass with conditional SUM expressions, reducing
  /// three separate COUNT queries down to one round-trip:
  ///   SELECT SUM(CASE WHEN stability < 1   THEN 1 ELSE 0 END),
  ///          SUM(CASE WHEN stability < 21  THEN 1 ELSE 0 END) — subtracted later,
  ///          SUM(CASE WHEN stability >= 21 THEN 1 ELSE 0 END)
  ///   FROM srs_state WHERE last_reviewed_at IS NOT NULL
  Future<SrsStageBreakdown> getStageBreakdown() async {
    final rows = await customSelect(
      'SELECT '
      'SUM(CASE WHEN stability < 1.0                        THEN 1 ELSE 0 END) AS learning, '
      'SUM(CASE WHEN stability >= 1.0 AND stability < 21.0  THEN 1 ELSE 0 END) AS young, '
      'SUM(CASE WHEN stability >= 21.0                      THEN 1 ELSE 0 END) AS mature '
      'FROM srs_state '
      'WHERE last_reviewed_at IS NOT NULL',
      readsFrom: {srsState},
    ).get();

    if (rows.isEmpty) {
      return const SrsStageBreakdown(learning: 0, young: 0, mature: 0);
    }
    final row = rows.first;
    return SrsStageBreakdown(
      learning: row.read<int?>('learning') ?? 0,
      young: row.read<int?>('young') ?? 0,
      mature: row.read<int?>('mature') ?? 0,
    );
  }
}
