import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/kanji_reading/providers/kanji_reading_providers.dart';

// ---------------------------------------------------------------------------
// Fake repo — only overrides what the providers actually call.
// ---------------------------------------------------------------------------
class _FakeLessonRepository extends LessonRepository {
  _FakeLessonRepository(this._kanjiByLevel)
    : super(
        AppDatabase(executor: NativeDatabase.memory()),
        ContentDatabase(executor: NativeDatabase.memory()),
      );

  final Map<String, List<KanjiItem>> _kanjiByLevel;
  int fetchKanjiByIdsCallCount = 0;
  List<int>? lastFetchedIds;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async =>
      _kanjiByLevel[level] ?? const [];

  @override
  Future<List<KanjiItem>> fetchKanjiByIds(List<int> ids) async {
    fetchKanjiByIdsCallCount++;
    lastFetchedIds = List.of(ids);
    final all = _kanjiByLevel.values.expand((list) => list).toList();
    return all.where((k) => ids.contains(k.id)).toList();
  }

  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async => const [];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
KanjiItem _kanji(int id, String level) => KanjiItem(
  id: id,
  lessonId: 1,
  character: 'X',
  strokeCount: 2,
  meaning: 'm',
  meaningEn: 'm',
  examples: const [],
  jlptLevel: level,
);

ProviderContainer _container({
  required AppDatabase db,
  required _FakeLessonRepository repo,
  StudyLevel? level,
}) {
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      lessonRepositoryProvider.overrideWithValue(repo),
      if (level != null) studyLevelProvider.overrideWith((ref) => level),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('_normalizeLevelCode — via kanjiByLevelCodeProvider', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('lowercase levelCode resolves same as uppercase', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(1, 'N5')],
      });
      final container = _container(db: db, repo: repo);
      addTearDown(container.dispose);

      final upper = await container.read(kanjiByLevelCodeProvider('N5').future);
      final lower = await container.read(kanjiByLevelCodeProvider('n5').future);
      expect(upper, hasLength(1));
      expect(lower, hasLength(1));
      expect(lower.first.id, 1);
    });

    test('levelCode with surrounding whitespace is trimmed', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(2, 'N5')],
      });
      final container = _container(db: db, repo: repo);
      addTearDown(container.dispose);

      final result = await container.read(
        kanjiByLevelCodeProvider(' N5 ').future,
      );
      expect(result, hasLength(1));
    });

    test('N4 and N5 return independent results', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(1, 'N5')],
        'N4': [_kanji(2, 'N4'), _kanji(3, 'N4')],
      });
      final container = _container(db: db, repo: repo);
      addTearDown(container.dispose);

      final n5 = await container.read(kanjiByLevelCodeProvider('N5').future);
      final n4 = await container.read(kanjiByLevelCodeProvider('N4').future);
      expect(n5, hasLength(1));
      expect(n4, hasLength(2));
    });
  });

  group('kanjiReadingDueItemsByLevelCodeProvider', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('returns empty list when no SRS rows exist', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(1, 'N5')],
      });
      final container = _container(db: db, repo: repo);
      addTearDown(container.dispose);

      final result = await container.read(
        kanjiReadingDueItemsByLevelCodeProvider('N5').future,
      );
      expect(result, isEmpty);
      expect(repo.fetchKanjiByIdsCallCount, 0);
    });

    test(
      'returns only items that are due AND match the requested level',
      () async {
        final repo = _FakeLessonRepository({
          'N5': [_kanji(10, 'N5'), _kanji(11, 'N5')],
          'N4': [_kanji(20, 'N4')],
        });
        final container = _container(db: db, repo: repo);
        addTearDown(container.dispose);

        await db.kanjiSrsDao.insertTestState(
          kanjiId: 10,
          nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        await db.kanjiSrsDao.insertTestState(
          kanjiId: 20,
          nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final n5Due = await container.read(
          kanjiReadingDueItemsByLevelCodeProvider('N5').future,
        );
        expect(n5Due, hasLength(1));
        expect(n5Due.first.id, 10);

        final n4Due = await container.read(
          kanjiReadingDueItemsByLevelCodeProvider('N4').future,
        );
        expect(n4Due, hasLength(1));
        expect(n4Due.first.id, 20);
      },
    );

    test('returns empty when dueIds exist but none match the level', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(1, 'N5')],
        'N4': [_kanji(2, 'N4')],
      });
      final container = _container(db: db, repo: repo);
      addTearDown(container.dispose);

      await db.kanjiSrsDao.insertTestState(
        kanjiId: 2,
        nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final n5Due = await container.read(
        kanjiReadingDueItemsByLevelCodeProvider('N5').future,
      );
      expect(n5Due, isEmpty);
    });

    test('levelCode normalization: n5 returns same due items as N5', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(5, 'N5')],
      });

      await db.kanjiSrsDao.insertTestState(
        kanjiId: 5,
        nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final containerUpper = _container(db: db, repo: repo);
      addTearDown(containerUpper.dispose);
      final upper = await containerUpper.read(
        kanjiReadingDueItemsByLevelCodeProvider('N5').future,
      );

      final containerLower = _container(db: db, repo: repo);
      addTearDown(containerLower.dispose);
      final lower = await containerLower.read(
        kanjiReadingDueItemsByLevelCodeProvider('n5').future,
      );

      expect(
        upper.map((k) => k.id).toSet(),
        equals(lower.map((k) => k.id).toSet()),
      );
    });
  });

  group('kanjiReadingDueItemsByLevelCodeProvider — cache-hit path', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test(
      'uses cached level list and skips fetchKanjiByIds when pre-warmed',
      () async {
        final repo = _FakeLessonRepository({
          'N5': [_kanji(1, 'N5'), _kanji(2, 'N5')],
        });
        final container = _container(db: db, repo: repo);
        addTearDown(container.dispose);

        await db.kanjiSrsDao.insertTestState(
          kanjiId: 1,
          nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // Pre-warm and keep alive with a listener.
        final sub = container.listen(kanjiByLevelCodeProvider('N5'), (_, _) {});
        await container.read(kanjiByLevelCodeProvider('N5').future);
        addTearDown(sub.close);

        // Reset counter after pre-warm.
        repo.fetchKanjiByIdsCallCount = 0;

        final result = await container.read(
          kanjiReadingDueItemsByLevelCodeProvider('N5').future,
        );

        expect(result, hasLength(1));
        expect(result.first.id, 1);
        // Cache-hit path must not call fetchKanjiByIds.
        expect(repo.fetchKanjiByIdsCallCount, 0);
      },
    );
  });

  group('kanjiReadingDueItemsProvider — studyLevelProvider integration', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('returns empty list when studyLevelProvider is null', () async {
      final repo = _FakeLessonRepository({
        'N5': [_kanji(1, 'N5')],
      });
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          lessonRepositoryProvider.overrideWithValue(repo),
          // studyLevelProvider NOT overridden → defaults to null
        ],
      );
      addTearDown(container.dispose);

      await db.kanjiSrsDao.insertTestState(
        kanjiId: 1,
        nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final result = await container.read(kanjiReadingDueItemsProvider.future);
      expect(result, isEmpty);
    });

    test(
      'delegates to family provider when studyLevelProvider is N5',
      () async {
        final repo = _FakeLessonRepository({
          'N5': [_kanji(1, 'N5')],
        });
        final container = _container(db: db, repo: repo, level: StudyLevel.n5);
        addTearDown(container.dispose);

        await db.kanjiSrsDao.insertTestState(
          kanjiId: 1,
          nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        final result = await container.read(
          kanjiReadingDueItemsProvider.future,
        );
        expect(result, hasLength(1));
        expect(result.first.id, 1);
      },
    );
  });
}
