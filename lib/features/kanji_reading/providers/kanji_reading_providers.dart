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
  final allItems = await ref.watch(kanjiByLevelProvider.future);
  if (allItems.isEmpty) return const [];
  final db = ref.read(databaseProvider);
  final dueStates = await db.kanjiSrsDao.getDueReviews();
  final dueIds = dueStates.map((s) => s.kanjiId).toSet();
  return allItems.where((k) => dueIds.contains(k.id)).toList();
});
