import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';

final vocabPreviewProvider = FutureProvider.family<List<VocabData>, String>((
  ref,
  level,
) async {
  final db = ref.watch(contentDatabaseProvider);
  final query = db.select(db.vocab)
    ..where(
      (tbl) =>
          tbl.level.equals(level) &
          tbl.term.like('%?%').not() &
          tbl.reading.like('%?%').not(),
    );
  final result = await query.get();
  return result;
});

class ContentRepository {
  final ContentDatabase _db;

  ContentRepository(this._db);

  Future<void> updateProgress(int vocabId, bool isCorrect) {
    final correctDelta = isCorrect ? 1 : 0;
    final missedDelta = isCorrect ? 0 : 1;
    final reviewedAt = DateTime.now().millisecondsSinceEpoch;
    // Single-round-trip upsert: insert on first encounter, or atomically
    // increment the appropriate counter on subsequent reviews.
    return _db.customStatement(
      'INSERT INTO user_progress (vocab_id, correct_count, missed_count, last_reviewed_at) '
      'VALUES (?, ?, ?, ?) '
      'ON CONFLICT(vocab_id) DO UPDATE SET '
      'correct_count = correct_count + ?, '
      'missed_count  = missed_count  + ?, '
      'last_reviewed_at = ?',
      [
        vocabId,
        correctDelta,
        missedDelta,
        reviewedAt,
        correctDelta,
        missedDelta,
        reviewedAt,
      ],
    );
  }
}

final contentRepositoryProvider = Provider((ref) {
  return ContentRepository(ref.watch(contentDatabaseProvider));
});
