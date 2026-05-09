import 'package:drift/drift.dart';

import '../db/app_database.dart';

part 'kana_srs_dao.g.dart';

@DriftAccessor(tables: [KanaSrsState])
class KanaSrsDao extends DatabaseAccessor<AppDatabase> with _$KanaSrsDaoMixin {
  KanaSrsDao(super.db);

  Future<void> upsertReview({
    required String kana,
    required String script,
    required double stability,
    required double difficulty,
    required int reps,
    required int lapses,
    required DateTime dueAt,
    DateTime? lastReviewedAt,
  }) {
    return into(kanaSrsState).insertOnConflictUpdate(
      KanaSrsStateCompanion.insert(
        kana: kana,
        script: script,
        reps: Value(reps),
        lapses: Value(lapses),
        stability: Value(stability),
        difficulty: Value(difficulty),
        dueAt: Value(dueAt),
        lastReviewedAt: Value(lastReviewedAt ?? DateTime.now()),
      ),
    );
  }

  Future<KanaSrsStateData?> getOrEmpty(String kana) {
    return (select(
      kanaSrsState,
    )..where((t) => t.kana.equals(kana))).getSingleOrNull();
  }

  Future<int> dueKanaCount({DateTime? now}) async {
    final countExpr = kanaSrsState.kana.count();
    final row =
        await (selectOnly(kanaSrsState)
              ..addColumns([countExpr])
              ..where(
                kanaSrsState.dueAt.isSmallerOrEqualValue(now ?? DateTime.now()),
              ))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  Stream<int> watchDueCount({DateTime? now}) {
    final countExpr = kanaSrsState.kana.count();
    return (selectOnly(kanaSrsState)
          ..addColumns([countExpr])
          ..where(
            kanaSrsState.dueAt.isSmallerOrEqualValue(now ?? DateTime.now()),
          ))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  Future<List<KanaSrsStateData>> dueKana({DateTime? now, int limit = 50}) {
    return (select(kanaSrsState)
          ..where((t) => t.dueAt.isSmallerOrEqualValue(now ?? DateTime.now()))
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)])
          ..limit(limit))
        .get();
  }

  Future<int> studiedCount() async {
    final countExpr = kanaSrsState.kana.count();
    final row =
        await (selectOnly(kanaSrsState)
              ..addColumns([countExpr])
              ..where(kanaSrsState.reps.isBiggerThanValue(0)))
            .getSingle();
    return row.read(countExpr) ?? 0;
  }

  Stream<int> watchStudiedCount() {
    final countExpr = kanaSrsState.kana.count();
    return (selectOnly(kanaSrsState)
          ..addColumns([countExpr])
          ..where(kanaSrsState.reps.isBiggerThanValue(0)))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  Future<Set<String>> studiedKana() async {
    final rows = await (select(
      kanaSrsState,
    )..where((t) => t.reps.isBiggerThanValue(0))).get();
    return rows.map((row) => row.kana).toSet();
  }
}
