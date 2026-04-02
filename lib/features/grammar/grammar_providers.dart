import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'models/grammar_point_data.dart';

final grammarPointsProvider = FutureProvider.family<List<GrammarPoint>, String>(
  (ref, level) {
    final repo = ref.watch(grammarRepositoryProvider);
    return repo.fetchPointsByLevel(level);
  },
);

final grammarDueCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(grammarRepositoryProvider);
  return repo.db.grammarDao.getDueReviewCount();
});

// Reactive count of grammar ghost reviews — backed by watchGhostReviewCount()
// so the badge updates immediately after a ghost session without needing
// manual provider invalidation (unlike a FutureProvider which would only
// refresh on next rebuild).
final grammarGhostCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(grammarRepositoryProvider);
  return repo.db.grammarDao.watchGhostReviewCount();
});

final nextGrammarReviewProvider = StreamProvider.autoDispose<DateTime?>((
  ref,
) async* {
  final repo = ref.watch(grammarRepositoryProvider);
  await for (final _ in repo.db.grammarDao.watchDueReviewCount()) {
    yield await repo.db.grammarDao.getNextScheduledReview();
  }
});

final grammarGhostsProvider = FutureProvider<List<GrammarPointData>>((
  ref,
) async {
  final repo = ref.watch(grammarRepositoryProvider);
  final points = await repo.fetchGhostPoints();
  if (points.isEmpty) return const [];

  // Batch-fetch all examples in one query — avoids N*2 queries from Future.wait(getGrammarDetail).
  final pointIds = points.map((p) => p.id).toList();
  final allExamples = await (repo.db.select(repo.db.grammarExamples)
        ..where((tbl) => tbl.grammarId.isIn(pointIds)))
      .get();
  final examplesByGrammarId = <int, List<GrammarExample>>{};
  for (final example in allExamples) {
    examplesByGrammarId.putIfAbsent(example.grammarId, () => []).add(example);
  }

  return [
    for (final point in points)
      GrammarPointData(
        point: point,
        examples: examplesByGrammarId[point.id] ?? const [],
      ),
  ];
});
