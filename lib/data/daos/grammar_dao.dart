import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/grammar_tables.dart';

part 'grammar_dao.g.dart';

@DriftAccessor(tables: [GrammarPoints, GrammarExamples, GrammarSrsState])
class GrammarDao extends DatabaseAccessor<AppDatabase> with _$GrammarDaoMixin {
  GrammarDao(super.db);

  /// Get all grammar points for a specific level
  Future<List<GrammarPoint>> getGrammarPointsByLevel(String level) {
    return (select(
      grammarPoints,
    )..where((t) => t.jlptLevel.equals(level))).get();
  }

  /// Get a specific grammar point with its examples
  Future<GrammarPoint?> getGrammarPoint(int id) {
    return (select(
      grammarPoints,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get examples for a grammar point
  Future<List<GrammarExample>> getExamplesForPoint(int grammarId) {
    return (select(
      grammarExamples,
    )..where((t) => t.grammarId.equals(grammarId))).get();
  }

  /// Get SRS state for a grammar point
  Future<GrammarSrsStateData?> getSrsState(int grammarId) {
    return (select(
      grammarSrsState,
    )..where((t) => t.grammarId.equals(grammarId))).getSingleOrNull();
  }

  /// Initialize SRS for a grammar point
  Future<int> initializeSrsState(int grammarId) {
    return into(grammarSrsState).insert(
      GrammarSrsStateCompanion.insert(
        grammarId: grammarId,
        nextReviewAt: DateTime.now(),
        streak: const Value(0),
        ease: const Value(2.5),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Update SRS state
  Future<void> updateSrsState({
    required int grammarId,
    required int streak,
    required double ease,
    required double stability,
    required double difficulty,
    required DateTime nextReviewAt,
    int ghostReviewsDue = 0,
  }) {
    return (update(
      grammarSrsState,
    )..where((t) => t.grammarId.equals(grammarId))).write(
      GrammarSrsStateCompanion(
        streak: Value(streak),
        ease: Value(ease),
        stability: Value(stability),
        difficulty: Value(difficulty),
        lastReviewedAt: Value(DateTime.now()),
        nextReviewAt: Value(nextReviewAt),
        ghostReviewsDue: Value(ghostReviewsDue),
      ),
    );
  }

  /// Update learned status
  Future<void> updateLearnedStatus(int grammarId, bool isLearned) {
    return (update(grammarPoints)..where((t) => t.id.equals(grammarId))).write(
      GrammarPointsCompanion(isLearned: Value(isLearned)),
    );
  }

  /// Get all due reviews
  Future<List<GrammarSrsStateData>> getDueReviews() {
    final now = DateTime.now();
    return (select(
      grammarSrsState,
    )..where((t) => t.nextReviewAt.isSmallerOrEqualValue(now))).get();
  }

  /// Reactive due count for dashboard/home.
  Stream<int> watchDueReviewCount() {
    final countExpr = grammarSrsState.grammarId.count();
    return (selectOnly(grammarSrsState)
          ..addColumns([countExpr])
          ..where(
            grammarSrsState.nextReviewAt.isSmallerOrEqualValue(DateTime.now()),
          ))
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  /// Get all ghost reviews (items with ghostReviewsDue > 0)
  Future<List<GrammarSrsStateData>> getGhostReviews() {
    return (select(
      grammarSrsState,
    )..where((t) => t.ghostReviewsDue.isBiggerThanValue(0))).get();
  }
}
