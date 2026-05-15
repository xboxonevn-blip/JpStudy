import 'package:drift/drift.dart';
import '../../core/services/fsrs_service.dart';
import '../db/app_database.dart';
import '../db/kanji_tables.dart';

part 'kanji_srs_dao.g.dart';

@DriftAccessor(tables: [KanjiSrsState])
class KanjiSrsDao extends DatabaseAccessor<AppDatabase>
    with _$KanjiSrsDaoMixin {
  KanjiSrsDao(super.db);

  Future<KanjiSrsStateData?> getSrsState(int kanjiId) {
    return (select(
      kanjiSrsState,
    )..where((t) => t.kanjiId.equals(kanjiId))).getSingleOrNull();
  }

  Future<int> initializeSrsState(int kanjiId) {
    return into(kanjiSrsState).insert(
      KanjiSrsStateCompanion.insert(
        kanjiId: kanjiId,
        nextReviewAt: DateTime.now(),
        fsrsState: Value(FsrsCardState.learning.dbValue),
        fsrsStep: const Value(0),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> updateSrsState({
    required int kanjiId,
    required double stability,
    required double difficulty,
    required int lastConfidence,
    required DateTime nextReviewAt,
    FsrsCardState? fsrsState,
    int? fsrsStep,
  }) {
    return (update(
      kanjiSrsState,
    )..where((t) => t.kanjiId.equals(kanjiId))).write(
      KanjiSrsStateCompanion(
        stability: Value(stability),
        difficulty: Value(difficulty),
        lastConfidence: Value(lastConfidence),
        lastReviewedAt: Value(DateTime.now()),
        nextReviewAt: Value(nextReviewAt),
        fsrsState: fsrsState == null
            ? const Value.absent()
            : Value(fsrsState.dbValue),
        fsrsStep: fsrsState == null && fsrsStep == null
            ? const Value.absent()
            : Value(fsrsStep),
      ),
    );
  }

  Future<List<KanjiSrsStateData>> getStatesForIds(List<int> kanjiIds) {
    if (kanjiIds.isEmpty) return Future.value([]);
    return (select(
      kanjiSrsState,
    )..where((t) => t.kanjiId.isIn(kanjiIds))).get();
  }

  Future<List<KanjiSrsStateData>> getDueReviews() {
    final now = DateTime.now();
    return (select(
      kanjiSrsState,
    )..where((t) => t.nextReviewAt.isSmallerOrEqualValue(now))).get();
  }

  /// One-shot due count — cheaper than getDueReviews().length.
  Future<int> getDueReviewCount() async {
    final countExpr = kanjiSrsState.kanjiId.count();
    final row =
        await (selectOnly(kanjiSrsState)
              ..addColumns([countExpr])
              ..where(
                kanjiSrsState.nextReviewAt.isSmallerOrEqualValue(
                  DateTime.now(),
                ),
              ))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// COUNT of due items still inside FSRS learning/relearning steps.
  Future<int> getCriticalDueCount() async {
    final countExpr = kanjiSrsState.kanjiId.count();
    final row =
        await (selectOnly(kanjiSrsState)
              ..addColumns([countExpr])
              ..where(
                kanjiSrsState.nextReviewAt.isSmallerOrEqualValue(
                      DateTime.now(),
                    ) &
                    kanjiSrsState.fsrsState.isIn([
                      FsrsCardState.learning.dbValue,
                      FsrsCardState.relearning.dbValue,
                    ]),
              ))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Returns the nearest future review date (nextReviewAt > now).
  /// Returns null if all reviews are past-due or no state exists.
  Future<DateTime?> getNextScheduledReview() async {
    final row =
        await (select(kanjiSrsState)
              ..where((t) => t.nextReviewAt.isBiggerThanValue(DateTime.now()))
              ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.nextReviewAt;
  }

  /// Returns all kanjiIds that have an SRS state row.
  Future<List<int>> getAllSeenKanjiIds() {
    return (selectOnly(kanjiSrsState)..addColumns([kanjiSrsState.kanjiId]))
        .map((row) => row.read(kanjiSrsState.kanjiId)!)
        .get();
  }

  /// Returns only the kanjiId values for due SRS items.
  Future<List<int>> getDueKanjiIds() {
    final idExpr = kanjiSrsState.kanjiId;
    return (selectOnly(kanjiSrsState)
          ..addColumns([idExpr])
          ..where(
            kanjiSrsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now()),
          ))
        .map((row) => row.read(idExpr)!)
        .get();
  }

  /// Test helper — inserts a state row with a specific nextReviewAt.
  Future<void> insertTestState({
    required int kanjiId,
    required DateTime nextReviewAt,
  }) {
    return into(kanjiSrsState).insert(
      KanjiSrsStateCompanion.insert(
        kanjiId: kanjiId,
        nextReviewAt: nextReviewAt,
        fsrsState: Value(FsrsCardState.learning.dbValue),
        fsrsStep: const Value(0),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// COUNT of kanji whose stability has reached the Strong tier (≥ 21 days).
  /// Used to gate the kanjiMaster achievement milestones.
  Future<int> getMasteredCount() async {
    final countExpr = kanjiSrsState.kanjiId.count();
    final row =
        await (selectOnly(kanjiSrsState)
              ..addColumns([countExpr])
              ..where(kanjiSrsState.stability.isBiggerOrEqualValue(21.0)))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Reactive due count for dashboard/home.
  Stream<int> watchDueReviewCount() {
    final countExpr = kanjiSrsState.kanjiId.count();
    return (selectOnly(kanjiSrsState)
          ..addColumns([countExpr])
          ..where(
            kanjiSrsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now()),
          ))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }
}
