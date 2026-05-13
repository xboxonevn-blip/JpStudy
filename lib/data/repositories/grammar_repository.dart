import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../../core/services/fsrs_service.dart';
import '../seeds/grammar_seeder.dart';

final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return GrammarRepository(db);
});

class GrammarRepository {
  final AppDatabase _db;
  final FsrsService _fsrsService = FsrsService();
  AppDatabase get db => _db;

  GrammarRepository(this._db);

  /// Fetch all grammar points for a specific JLPT level
  Future<List<GrammarPoint>> fetchPointsByLevel(String level) async {
    final existingForLevel = await (_db.select(_db.grammarPoints)
          ..where((table) => table.jlptLevel.equals(level))
          ..limit(1))
        .get();
    if (existingForLevel.isEmpty) {
      await GrammarSeeder(_db.grammarDao).seedGrammarData(_db);
    }
    return _db.grammarDao.getGrammarPointsByLevel(level);
  }

  Future<List<GrammarPoint>> fetchPointsByIds(List<int> ids) {
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return (_db.select(_db.grammarPoints)..where((t) => t.id.isIn(ids))).get();
  }

  /// Returns only the IDs of grammar points due for review.
  /// Cheaper than [fetchDuePoints] when the caller only needs IDs, not the
  /// full GrammarPoint rows (title, connection, explanation, etc.).
  Future<List<int>> fetchDueGrammarIds() {
    return _db.grammarDao.getDueGrammarIds();
  }

  /// Fetch all grammar points due for review.
  /// Uses a single JOIN query instead of two round-trips (get IDs then get points).
  Future<List<GrammarPoint>> fetchDuePoints() {
    return _db.grammarDao.getDuePoints();
  }

  /// Fetch full details for a grammar point (including examples)
  Future<({GrammarPoint point, List<GrammarExample> examples})?>
  getGrammarDetail(int id) async {
    // Fire both queries concurrently; discard examples if point not found.
    final pointFuture = _db.grammarDao.getGrammarPoint(id);
    final examplesFuture = _db.grammarDao.getExamplesForPoint(id);
    final point = await pointFuture;
    if (point == null) return null;
    final examples = await examplesFuture;
    return (point: point, examples: examples);
  }

  /// Record a review for a grammar point
  /// Handles "Ghost Review" logic:
  /// - If quality < 3 (Wrong): Create/Reset Ghost.
  /// - If quality >= 3 (Correct): Reduce Ghost or Advance SRS.
  Future<void> recordReview({
    required int grammarId,
    required int grade, // 1-4
  }) async {
    await _db.grammarDao.initializeSrsState(grammarId);
    final state = await _db.grammarDao.getSrsState(grammarId);
    if (state == null) return;

    int newStreak = state.streak;
    final nextGrade = grade.clamp(1, 4);
    int ghostReviewsDue = state.ghostReviewsDue;

    if (nextGrade == 1) {
      newStreak = 0;
      // Ghost logic: Mark as needing special review
      ghostReviewsDue = 1;
    } else {
      newStreak += 1;
      if (ghostReviewsDue > 0) {
        ghostReviewsDue = 0;
      }
    }

    final result = _fsrsService.review(
      grade: nextGrade,
      stability: state.stability,
      difficulty: state.difficulty,
      lastReviewedAt: state.lastReviewedAt,
    );

    await _db.grammarDao.updateSrsState(
      grammarId: grammarId,
      streak: newStreak,
      ease: state.ease,
      stability: result.stability,
      difficulty: result.difficulty,
      nextReviewAt: result.nextReviewAt,
      ghostReviewsDue: ghostReviewsDue,
    );
  }

  /// Fetch all grammar points that are "Ghosts" (failed previously).
  /// Uses a single JOIN query instead of two round-trips (get IDs then get points).
  Future<List<GrammarPoint>> fetchGhostPoints() {
    return _db.grammarDao.getGhostPoints();
  }

  /// Mark a grammar point as learned and initialize SRS
  Future<void> markAsLearned(int grammarId) async {
    await _db.grammarDao.updateLearnedStatus(grammarId, true);
    await _db.grammarDao.initializeSrsState(grammarId);
  }
}
