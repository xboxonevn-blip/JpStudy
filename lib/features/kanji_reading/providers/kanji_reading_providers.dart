import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/level_provider.dart';
import '../../../data/db/database_provider.dart';
import '../../../data/models/kanji_item.dart';
import '../../../data/repositories/lesson_repository.dart';

final kanjiByLevelCodeProvider =
    FutureProvider.autoDispose.family<List<KanjiItem>, String>((
      ref,
      levelCode,
    ) async {
      final repo = ref.read(lessonRepositoryProvider);
      return repo.fetchKanjiByLevel(_normalizeLevelCode(levelCode));
    });

final kanjiByLevelProvider =
    FutureProvider.autoDispose<List<KanjiItem>>((ref) async {
  final level = ref.watch(studyLevelProvider);
  if (level == null) return const [];
  return ref.watch(kanjiByLevelCodeProvider(level.shortLabel).future);
});

final kanjiReadingUnseenItemsByLevelCodeProvider =
    FutureProvider.autoDispose.family<List<KanjiItem>, String>((
      ref,
      levelCode,
    ) async {
      final repo = ref.read(lessonRepositoryProvider);
      return repo.fetchUnseenKanjiByLevel(
        _normalizeLevelCode(levelCode),
        limit: 15,
      );
    });

final kanjiReadingDueItemsByLevelCodeProvider =
    FutureProvider.autoDispose.family<List<KanjiItem>, String>((
      ref,
      levelCode,
    ) async {
      final normalizedLevelCode = _normalizeLevelCode(levelCode);
      final db = ref.read(databaseProvider);
      final repo = ref.read(lessonRepositoryProvider);
      final dueIdsFuture = db.kanjiSrsDao.getDueKanjiIds();
      final levelFuture = ref.watch(
        kanjiByLevelCodeProvider(normalizedLevelCode).future,
      );
      final dueIds = (await dueIdsFuture).toSet();
      if (dueIds.isEmpty) return const [];

      final cached = ref.read(
        kanjiByLevelCodeProvider(normalizedLevelCode),
      ).value;
      if (cached != null) {
        return cached.where((k) => dueIds.contains(k.id)).toList();
      }

      final dueItems = await repo.fetchKanjiByIds(dueIds.toList());
      await levelFuture;
      return dueItems
          .where(
            (item) => _normalizeLevelCode(item.jlptLevel) == normalizedLevelCode,
          )
          .toList();
    });

final kanjiReadingDueItemsProvider =
    FutureProvider.autoDispose<List<KanjiItem>>((ref) async {
  final level = ref.watch(studyLevelProvider);
  if (level == null) return const [];
  return ref.watch(
    kanjiReadingDueItemsByLevelCodeProvider(level.shortLabel).future,
  );
});

String _normalizeLevelCode(String levelCode) => levelCode.trim().toUpperCase();


