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
  final points = await repo.fetchDuePoints();
  return points.length;
});

// Count is derived from grammarRepository.fetchGhostPoints() (ghostReviewsDue > 0),
// same source as grammarGhostsProvider and GhostReviewScreen — badge and screen agree.
final grammarGhostCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(grammarRepositoryProvider);
  final points = await repo.fetchGhostPoints();
  return points.length;
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

  // Is GrammarPointData wrapping logic needed?
  // The repo returns List<GrammarPoint>.
  // But GhostReviewScreen expects GrammarPointData (which usually includes examples).
  // Let's check GrammarPointData definition.
  // Assuming we need to fetch details for each point or if the screen handles it.

  // Wait, I need to check how GrammarPointData is defined.
  // If fetchGhostPoints returns just points, I might need to fetch examples too.

  // Let's look at the screen usage: "final data = ghosts[index];" where data is GrammarPointData.
  // And data.examples is used.

  // So I need to fetch full data.

  List<GrammarPointData> fullData = [];
  for (final p in points) {
    final details = await repo.getGrammarDetail(p.id);
    if (details != null) {
      fullData.add(
        GrammarPointData(point: details.point, examples: details.examples),
      );
    }
  }
  return fullData;
});
