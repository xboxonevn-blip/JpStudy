import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/kanji_hub/providers/kanji_home_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepo extends LessonRepository {
  _FakeRepo({
    this.n5All = const [],
    this.n5Due = const [],
    this.n5Unseen = const [],
    this.n4All = const [],
    this.n4Due = const [],
    this.n4Unseen = const [],
  }) : super(
         AppDatabase(executor: NativeDatabase.memory()),
         ContentDatabase(executor: NativeDatabase.memory()),
       );

  final List<KanjiItem> n5All;
  final List<KanjiItem> n5Due;
  final List<KanjiItem> n5Unseen;
  final List<KanjiItem> n4All;
  final List<KanjiItem> n4Due;
  final List<KanjiItem> n4Unseen;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async {
    return switch (level) {
      'N5' => n5All,
      'N4' => n4All,
      _ => const [],
    };
  }

  @override
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async {
    return switch (level) {
      'N5' => n5Due,
      'N4' => n4Due,
      _ => const [],
    };
  }

  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async {
    final items = switch (level) {
      'N5' => n5Unseen,
      'N4' => n4Unseen,
      _ => const <KanjiItem>[],
    };
    return items.take(limit).toList();
  }

  @override
  Future<Set<int>> fetchSeenKanjiIds() async => const {};

  @override
  Future<Set<int>> fetchDueKanjiIds() async => const {};

  @override
  Future<int> countKanjiByLevel(String level) async {
    return switch (level) {
      'N5' => n5All.length,
      'N4' => n4All.length,
      _ => 0,
    };
  }

  @override
  Future<int> countDueKanjiByLevel(String level) async {
    return switch (level) {
      'N5' => n5Due.length,
      'N4' => n4Due.length,
      _ => 0,
    };
  }

  @override
  Future<int> countUnseenKanjiByLevel(String level) async {
    return switch (level) {
      'N5' => n5Unseen.length,
      'N4' => n4Unseen.length,
      _ => 0,
    };
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

KanjiItem _makeKanji(int id, String level) => KanjiItem(
  id: id,
  lessonId: 1,
  character: '字$id',
  strokeCount: 4,
  meaning: 'char $id',
  meaningEn: 'char $id',
  examples: const [],
  jlptLevel: level,
  decomposition: const KanjiDecomposition(),
);

ProviderContainer _buildContainer({
  required LessonRepository repo,
  StudyLevel level = StudyLevel.n5,
}) {
  return ProviderContainer(
    overrides: [
      studyLevelProvider.overrideWith((ref) => level),
      lessonRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('kanjiHomeSummaryProvider', () {
    test('returns zero counts when repo is empty', () async {
      final container = _buildContainer(repo: _FakeRepo());
      addTearDown(container.dispose);

      final result = await container.read(kanjiHomeSummaryProvider.future);

      expect(result.levelCode, equals('N5'));
      expect(result.dueCount, equals(0));
      expect(result.newCount, equals(0));
      expect(result.exploreCount, equals(0));
    });

    test('surfaces correct dueCount from fetchDueKanjiByLevel', () async {
      final due = [_makeKanji(1, 'N5'), _makeKanji(2, 'N5')];
      final container = _buildContainer(repo: _FakeRepo(n5Due: due));
      addTearDown(container.dispose);

      final result = await container.read(kanjiHomeSummaryProvider.future);

      expect(result.dueCount, equals(2));
    });

    test('respects limit of 12 for newCount', () async {
      // 20 unseen kanji in the fake, but provider requests limit:12
      final unseen = List.generate(20, (i) => _makeKanji(100 + i, 'N5'));
      final container = _buildContainer(repo: _FakeRepo(n5Unseen: unseen));
      addTearDown(container.dispose);

      final result = await container.read(kanjiHomeSummaryProvider.future);

      expect(result.newCount, equals(12));
    });

    test('exploreCount reflects total kanji at the selected level', () async {
      final all = List.generate(80, (i) => _makeKanji(i + 1, 'N5'));
      final container = _buildContainer(repo: _FakeRepo(n5All: all));
      addTearDown(container.dispose);

      final result = await container.read(kanjiHomeSummaryProvider.future);

      expect(result.exploreCount, equals(80));
    });

    test('uses the active study level from studyLevelProvider', () async {
      final n4Due = [_makeKanji(1, 'N4'), _makeKanji(2, 'N4')];
      final n4Unseen = [_makeKanji(3, 'N4')];
      final n4All = List.generate(5, (i) => _makeKanji(10 + i, 'N4'));

      final container = _buildContainer(
        repo: _FakeRepo(n4Due: n4Due, n4Unseen: n4Unseen, n4All: n4All),
        level: StudyLevel.n4,
      );
      addTearDown(container.dispose);

      final result = await container.read(kanjiHomeSummaryProvider.future);

      expect(result.levelCode, equals('N4'));
      expect(result.dueCount, equals(2));
      expect(result.newCount, equals(1));
      expect(result.exploreCount, equals(5));
    });

    test(
      'family provider can load a scoped level without changing studyLevelProvider',
      () async {
        final n4Due = [_makeKanji(1, 'N4'), _makeKanji(2, 'N4')];
        final n4Unseen = [_makeKanji(3, 'N4')];
        final n4All = List.generate(5, (i) => _makeKanji(10 + i, 'N4'));

        final container = _buildContainer(
          repo: _FakeRepo(n4Due: n4Due, n4Unseen: n4Unseen, n4All: n4All),
          level: StudyLevel.n5,
        );
        addTearDown(container.dispose);

        final result = await container.read(
          kanjiHomeSummaryByLevelCodeProvider('N4').future,
        );

        expect(result.levelCode, equals('N4'));
        expect(result.dueCount, equals(2));
        expect(result.newCount, equals(1));
        expect(result.exploreCount, equals(5));
      },
    );

    test('all three counts can be non-zero simultaneously', () async {
      final n5Due = [
        _makeKanji(1, 'N5'),
        _makeKanji(2, 'N5'),
        _makeKanji(3, 'N5'),
      ];
      final n5Unseen = List.generate(8, (i) => _makeKanji(10 + i, 'N5'));
      final n5All = List.generate(40, (i) => _makeKanji(50 + i, 'N5'));

      final container = _buildContainer(
        repo: _FakeRepo(n5Due: n5Due, n5Unseen: n5Unseen, n5All: n5All),
      );
      addTearDown(container.dispose);

      final result = await container.read(kanjiHomeSummaryProvider.future);

      expect(result.dueCount, equals(3));
      expect(result.newCount, equals(8));
      expect(result.exploreCount, equals(40));
    });
  });
}
