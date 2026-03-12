import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import '../../core/services/fsrs_service.dart';

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
  Future<List<GrammarPoint>> fetchPointsByLevel(String level) {
    return _db.grammarDao.getGrammarPointsByLevel(level);
  }

  Future<List<GrammarPoint>> fetchPointsByIds(List<int> ids) {
    if (ids.isEmpty) {
      return Future.value(const []);
    }
    return (_db.select(_db.grammarPoints)..where((t) => t.id.isIn(ids))).get();
  }

  /// Fetch all grammar points due for review
  Future<List<GrammarPoint>> fetchDuePoints() async {
    final dueStates = await _db.grammarDao.getDueReviews();
    final ids = dueStates.map((s) => s.grammarId).toList();
    if (ids.isEmpty) return [];

    // Fetch actual points for these ids
    final points = await (_db.select(
      _db.grammarPoints,
    )..where((t) => t.id.isIn(ids))).get();
    return points;
  }

  /// Fetch full details for a grammar point (including examples)
  Future<({GrammarPoint point, List<GrammarExample> examples})?>
  getGrammarDetail(int id) async {
    final point = await _db.grammarDao.getGrammarPoint(id);
    if (point == null) return null;

    final examples = await _db.grammarDao.getExamplesForPoint(id);
    return (point: point, examples: examples);
  }

  /// Initialize SRS for a grammar point if not exists
  Future<void> ensureSrsInitialized(int grammarId) async {
    final existing = await _db.grammarDao.getSrsState(grammarId);
    if (existing == null) {
      await _db.grammarDao.initializeSrsState(grammarId);
    }
  }

  /// Record a review for a grammar point
  /// Handles "Ghost Review" logic:
  /// - If quality < 3 (Wrong): Create/Reset Ghost.
  /// - If quality >= 3 (Correct): Reduce Ghost or Advance SRS.
  Future<void> recordReview({
    required int grammarId,
    required int grade, // 1-4
  }) async {
    await ensureSrsInitialized(grammarId);
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

  /// Fetch all grammar points that are "Ghosts" (failed previously)
  Future<List<GrammarPoint>> fetchGhostPoints() async {
    final ghostStates = await _db.grammarDao.getGhostReviews();
    final ids = ghostStates.map((s) => s.grammarId).toList();
    if (ids.isEmpty) return [];

    // Fetch actual points for these ids
    final points = await (_db.select(
      _db.grammarPoints,
    )..where((t) => t.id.isIn(ids))).get();
    return points;
  }

  /// Mark a grammar point as learned and initialize SRS
  Future<void> markAsLearned(int grammarId) async {
    await _db.grammarDao.updateLearnedStatus(grammarId, true);
    await ensureSrsInitialized(grammarId);
  }
}
