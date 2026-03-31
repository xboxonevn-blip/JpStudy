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

final details = await Future.wait(
    points.map((p) => repo.getGrammarDetail(p.id)),
  );
  return [
    for (final d in details)
      if (d != null) GrammarPointData(point: d.point, examples: d.examples),
  ];
});
