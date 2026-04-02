import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/level_provider.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/models/kanji_item.dart';
import '../../../data/repositories/lesson_repository.dart';

final kanjiByLevelProvider =
    FutureProvider.autoDispose<List<KanjiItem>>((ref) async {
  final level = ref.watch(studyLevelProvider);
  if (level == null) return const [];
  final repo = ref.read(lessonRepositoryProvider);
  return repo.fetchKanjiByLevel(level.shortLabel);
});

final kanjiReadingDueItemsProvider =
    FutureProvider.autoDispose<List<KanjiItem>>((ref) async {
  final db = ref.read(databaseProvider);
  final repo = ref.read(lessonRepositoryProvider);
  // Use getDueKanjiIds (ID-only query) instead of getDueReviews (full rows)
  // so we don't transfer stability/difficulty/etc. that we don't need here.
  // Both queries start before any await so they run concurrently.
  final dueIdsFuture = db.kanjiSrsDao.getDueKanjiIds();
  // Warm up kanjiByLevelProvider in parallel if it's not cached yet.
  // We intentionally use ref.read here (not ref.watch) to avoid a reactive
  // dependency — this provider is autoDispose and rebuilt on each navigation.
  final levelFuture = ref.watch(kanjiByLevelProvider.future);
  final dueIds = (await dueIdsFuture).toSet();
  if (dueIds.isEmpty) return const [];
  // If the level list is already available (cache hit) use it directly;
  // otherwise fall through to the targeted fetchKanjiByIds call which avoids
  // loading the entire level catalogue when only a small subset is due.
  final cached = ref.read(kanjiByLevelProvider).valueOrNull;
  if (cached != null) {
    return cached.where((k) => dueIds.contains(k.id)).toList();
  }
  // No cache: fetch only the due items by ID — no need to load the full level.
  await levelFuture; // keep the level cache warm for subsequent requests
  return repo.fetchKanjiByIds(dueIds.toList());
});
