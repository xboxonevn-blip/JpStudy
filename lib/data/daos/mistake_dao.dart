import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/mistake_tables.dart';

part 'mistake_dao.g.dart';

@DriftAccessor(tables: [UserMistakes])
class MistakeDao extends DatabaseAccessor<AppDatabase> with _$MistakeDaoMixin {
  MistakeDao(super.db);
  static const int requiredCorrectStreak = 2;

  /// Adds a mistake to the bank.
  /// If it already exists, increments the wrongCount and updates the timestamp.
  Future<void> addMistake(
    String type,
    int itemId, {
    String? prompt,
    String? correctAnswer,
    String? userAnswer,
    String? source,
    String? extraJson,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      'INSERT INTO user_mistakes '
      '(type, item_id, wrong_count, last_mistake_at, prompt, correct_answer, user_answer, source, extra_json) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) '
      'ON CONFLICT(type, item_id) DO UPDATE SET '
      'wrong_count = wrong_count + 1, '
      'last_mistake_at = ?, '
      'prompt = COALESCE(excluded.prompt, user_mistakes.prompt), '
      'correct_answer = COALESCE(excluded.correct_answer, user_mistakes.correct_answer), '
      'user_answer = COALESCE(excluded.user_answer, user_mistakes.user_answer), '
      'source = COALESCE(excluded.source, user_mistakes.source), '
      'extra_json = COALESCE(excluded.extra_json, user_mistakes.extra_json)',
      [
        type,
        itemId,
        requiredCorrectStreak,
        now,
        prompt,
        correctAnswer,
        userAnswer,
        source,
        extraJson,
        now,
      ],
    );
  }

  /// Removes a mistake from the bank (e.g. when answered correctly enough times).
  Future<void> removeMistake(String type, int itemId) async {
    await (delete(
      userMistakes,
    )..where((tbl) => tbl.type.equals(type) & tbl.itemId.equals(itemId))).go();
  }

  /// Decrease remaining mistakes; remove when cleared.
  Future<void> markCorrect(String type, int itemId) async {
    final existing =
        await (select(userMistakes)..where(
              (tbl) => tbl.type.equals(type) & tbl.itemId.equals(itemId),
            ))
            .getSingleOrNull();
    if (existing == null) {
      return;
    }

    if (existing.wrongCount <= 1) {
      await removeMistake(type, itemId);
      return;
    }

    await (update(
      userMistakes,
    )..where((tbl) => tbl.type.equals(type) & tbl.itemId.equals(itemId))).write(
      UserMistakesCompanion(
        wrongCount: Value(existing.wrongCount - 1),
        lastMistakeAt: Value(DateTime.now()),
      ),
    );
  }

  /// Gets the total count of mistakes in the bank.
  Stream<int> watchTotalMistakes() {
    final total = userMistakes.wrongCount.sum();
    return (selectOnly(
      userMistakes,
    )..addColumns([total])).map((row) => row.read(total) ?? 0).watchSingle();
  }

  /// Gets the count of unique mistake items, optionally filtered by type.
  Stream<int> watchMistakeItemCount({String? type}) {
    final count = userMistakes.id.count();
    final query = selectOnly(userMistakes)..addColumns([count]);
    if (type != null) {
      query.where(userMistakes.type.equals(type));
    }
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  /// Gets key-value pairs of pending mistakes for a specific type.
  Future<List<UserMistake>> getMistakesByType(String type) {
    return (select(userMistakes)..where((tbl) => tbl.type.equals(type))).get();
  }

  /// One-shot count for a specific type — cheaper than getMistakesByType().length.
  Future<int> getMistakeCountByType(String type) async {
    final countExpr = userMistakes.id.count();
    final row = await (selectOnly(userMistakes)
          ..addColumns([countExpr])
          ..where(userMistakes.type.equals(type)))
        .getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Streams counts of mistake items grouped by type — returns a named record
  /// (vocab, grammar, kanji, total) using a single GROUP BY query.
  /// Transfers 3 rows instead of N full UserMistake rows — replaces the
  /// watchAllMistakes() + Dart-side counting pattern in the dashboard.
  Stream<({int vocab, int grammar, int kanji, int total})> watchMistakeCounts() {
    final countExpr = userMistakes.id.count();
    final typeCol = userMistakes.type;
    return (selectOnly(userMistakes)
          ..addColumns([typeCol, countExpr])
          ..groupBy([typeCol]))
        .watch()
        .map((rows) {
          var vocab = 0, grammar = 0, kanji = 0;
          for (final row in rows) {
            final t = row.read(typeCol);
            final c = row.read(countExpr) ?? 0;
            if (t == 'vocab') {
              vocab = c;
            } else if (t == 'grammar') {
              grammar = c;
            } else if (t == 'kanji') {
              kanji = c;
            }
          }
          return (vocab: vocab, grammar: grammar, kanji: kanji, total: vocab + grammar + kanji);
        });
  }

  /// One-shot version of [watchMistakeCounts] — useful for the initial snapshot.
  Future<({int vocab, int grammar, int kanji, int total})> getMistakeCounts() async {
    final countExpr = userMistakes.id.count();
    final typeCol = userMistakes.type;
    final rows = await (selectOnly(userMistakes)
          ..addColumns([typeCol, countExpr])
          ..groupBy([typeCol]))
        .get();
    var vocab = 0, grammar = 0, kanji = 0;
    for (final row in rows) {
      final t = row.read(typeCol);
      final c = row.read(countExpr) ?? 0;
      if (t == 'vocab') {
        vocab = c;
      } else if (t == 'grammar') {
        grammar = c;
      } else if (t == 'kanji') {
        kanji = c;
      }
    }
    return (vocab: vocab, grammar: grammar, kanji: kanji, total: vocab + grammar + kanji);
  }

  /// Get all mistakes (unordered, unbounded — prefer [getTopMistakesByType] for
  /// UI-facing queries where only the highest-priority items are needed).
  Future<List<UserMistake>> getAllMistakes() {
    return select(userMistakes).get();
  }

  /// Returns the top [limit] mistakes of [type], ordered by recency and
  /// wrong-count so callers don't have to fetch the full table to find the
  /// highest-priority items.  Defaults to 10 rows.
  Future<List<UserMistake>> getTopMistakesByType(
    String type, {
    int limit = 10,
  }) {
    return (select(userMistakes)
          ..where((tbl) => tbl.type.equals(type))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.lastMistakeAt,
              mode: OrderingMode.desc,
            ),
            (tbl) => OrderingTerm(
              expression: tbl.wrongCount,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  /// Watch all mistakes for live updates.
  /// Pass [limit] and [offset] to paginate — e.g. first 30 rows on page 0,
  /// next 30 on page 1.  Omitting both returns the full list (original behaviour).
  Stream<List<UserMistake>> watchAllMistakes({int? limit, int? offset}) {
    final query = select(userMistakes)
      ..orderBy([
        (tbl) => OrderingTerm(
          expression: tbl.lastMistakeAt,
          mode: OrderingMode.desc,
        ),
        (tbl) => OrderingTerm(
          expression: tbl.wrongCount,
          mode: OrderingMode.desc,
        ),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset ?? 0);
    }
    return query.watch();
  }
}
