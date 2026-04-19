import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

class KanjiHomeSummary {
  const KanjiHomeSummary({
    required this.levelCode,
    required this.dueCount,
    required this.newCount,
    required this.exploreCount,
  });

  final String levelCode;
  final int dueCount;
  final int newCount;
  final int exploreCount;
}

/// IDs of all kanji that have been seen at least once (have an SRS row).
final kanjiSeenIdsProvider = FutureProvider<Set<int>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchSeenKanjiIds();
});

/// IDs of all kanji that are currently due for review.
final kanjiDueIdsProvider = FutureProvider<Set<int>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchDueKanjiIds();
});

Future<KanjiHomeSummary> _loadKanjiHomeSummary(
  Ref ref,
  String levelCode,
) async {
  final repo = ref.watch(lessonRepositoryProvider);

  // Fire all three COUNT queries concurrently — no full KanjiItem deserialization.
  final dueFuture = repo.countDueKanjiByLevel(levelCode);
  final unseenFuture = repo.countUnseenKanjiByLevel(levelCode);
  final allFuture = repo.countKanjiByLevel(levelCode);

  final dueCount = await dueFuture;
  // Cap at 12: UX session limit — avoids overwhelming the landing card with unseen items.
  final newCount = (await unseenFuture).clamp(0, 12);
  final exploreCount = await allFuture;

  return KanjiHomeSummary(
    levelCode: levelCode,
    dueCount: dueCount,
    newCount: newCount,
    exploreCount: exploreCount,
  );
}

final kanjiHomeSummaryByLevelCodeProvider =
    FutureProvider.family<KanjiHomeSummary, String>((ref, levelCode) async {
      return _loadKanjiHomeSummary(ref, levelCode);
    });

final kanjiHomeSummaryProvider = FutureProvider<KanjiHomeSummary>((ref) async {
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  return ref.watch(
    kanjiHomeSummaryByLevelCodeProvider(level.shortLabel).future,
  );
});
