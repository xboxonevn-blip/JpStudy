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

final kanjiHomeSummaryProvider = FutureProvider<KanjiHomeSummary>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
  final levelCode = level.shortLabel;

  // Fire all three COUNT queries concurrently — no full KanjiItem deserialization.
  final dueFuture = repo.countDueKanjiByLevel(levelCode);
  final unseenFuture = repo.countUnseenKanjiByLevel(levelCode);
  final allFuture = repo.countKanjiByLevel(levelCode);

  final dueCount = await dueFuture;
  final newCount = await unseenFuture;
  final exploreCount = await allFuture;

  return KanjiHomeSummary(
    levelCode: levelCode,
    dueCount: dueCount,
    newCount: newCount,
    exploreCount: exploreCount,
  );
});
