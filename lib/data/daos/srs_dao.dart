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

  /// Reactive due count used by dashboard and home indicators.
  Stream<int> watchDueReviewCount() {
    final countExpr = srsState.vocabId.count();
    return (selectOnly(srsState)
          ..addColumns([countExpr])
          ..where(srsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now())))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  /// Returns counts of SRS items in each FSRS stability bracket.
  /// Only items that have been reviewed at least once are counted.
  Future<SrsStageBreakdown> getStageBreakdown() async {
    final rows = await (select(
      srsState,
    )..where((t) => t.lastReviewedAt.isNotNull())).get();
    int learning = 0, young = 0, mature = 0;
    for (final r in rows) {
      final s = r.stability;
      if (s < 1.0) {
        learning++;
      } else if (s < 21.0) {
        young++;
      } else {
        mature++;
      }
    }
    return SrsStageBreakdown(learning: learning, young: young, mature: mature);
  }
}
