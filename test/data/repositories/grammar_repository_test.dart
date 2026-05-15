import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';

GrammarPointsCompanion _point({
  required int id,
  required String grammarPoint,
  String level = 'N5',
}) => GrammarPointsCompanion.insert(
  id: Value(id),
  grammarPoint: grammarPoint,
  meaning: 'meaning $id',
  connection: 'conn $id',
  explanation: 'explanation $id',
  jlptLevel: level,
);

void main() {
  late AppDatabase db;
  late GrammarRepository repository;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    repository = GrammarRepository(db);
  });

  tearDown(() => db.close());

  // ── fetchPointsByIds ──────────────────────────────────────────────────────

  test('fetchPointsByIds returns empty list for empty input', () async {
    final result = await repository.fetchPointsByIds([]);
    expect(result, isEmpty);
  });

  test('fetchPointsByIds returns matching points', () async {
    await db.into(db.grammarPoints).insert(_point(id: 1, grammarPoint: '〜は'));
    await db.into(db.grammarPoints).insert(_point(id: 2, grammarPoint: '〜が'));
    await db.into(db.grammarPoints).insert(_point(id: 3, grammarPoint: '〜を'));

    final result = await repository.fetchPointsByIds([1, 3]);
    expect(result.map((p) => p.id).toSet(), {1, 3});
  });

  test('fetchPointsByIds skips ids not in database', () async {
    await db.into(db.grammarPoints).insert(_point(id: 10, grammarPoint: '〜で'));

    final result = await repository.fetchPointsByIds([10, 99]);
    expect(result.length, 1);
    expect(result.first.id, 10);
  });

  // ── fetchDuePoints ────────────────────────────────────────────────────────

  test('fetchDuePoints returns empty when no SRS states exist', () async {
    await db.into(db.grammarPoints).insert(_point(id: 1, grammarPoint: '〜ない'));

    final result = await repository.fetchDuePoints();
    expect(result, isEmpty);
  });

  test('fetchDuePoints returns point with past nextReviewAt', () async {
    await db.into(db.grammarPoints).insert(_point(id: 1, grammarPoint: '〜ない'));
    final pastDate = DateTime.now().subtract(const Duration(hours: 1));
    await db
        .into(db.grammarSrsState)
        .insert(
          GrammarSrsStateCompanion.insert(grammarId: 1, nextReviewAt: pastDate),
        );

    final result = await repository.fetchDuePoints();
    expect(result.length, 1);
    expect(result.first.id, 1);
  });

  test('fetchDuePoints excludes point with future nextReviewAt', () async {
    await db.into(db.grammarPoints).insert(_point(id: 1, grammarPoint: '〜ない'));
    final futureDate = DateTime.now().add(const Duration(days: 3));
    await db
        .into(db.grammarSrsState)
        .insert(
          GrammarSrsStateCompanion.insert(
            grammarId: 1,
            nextReviewAt: futureDate,
          ),
        );

    final result = await repository.fetchDuePoints();
    expect(result, isEmpty);
  });

  // ── getGrammarDetail ──────────────────────────────────────────────────────

  test('getGrammarDetail returns null for unknown id', () async {
    final result = await repository.getGrammarDetail(999);
    expect(result, isNull);
  });

  test('getGrammarDetail returns point with examples', () async {
    await db.into(db.grammarPoints).insert(_point(id: 5, grammarPoint: '〜て'));
    await db
        .into(db.grammarExamples)
        .insert(
          GrammarExamplesCompanion.insert(
            grammarId: 5,
            japanese: '食べて、寝た。',
            translation: 'I ate and slept.',
          ),
        );

    final result = await repository.getGrammarDetail(5);
    expect(result, isNotNull);
    expect(result!.point.grammarPoint, '〜て');
    expect(result.examples.length, 1);
    expect(result.examples.first.japanese, '食べて、寝た。');
  });

  test(
    'getGrammarDetail returns empty examples list when none exist',
    () async {
      await db.into(db.grammarPoints).insert(_point(id: 6, grammarPoint: '〜に'));

      final result = await repository.getGrammarDetail(6);
      expect(result, isNotNull);
      expect(result!.examples, isEmpty);
    },
  );

  // ── markAsLearned ─────────────────────────────────────────────────────────

  test('markAsLearned sets isLearned=true and initializes SRS', () async {
    await db.into(db.grammarPoints).insert(_point(id: 7, grammarPoint: '〜から'));

    await repository.markAsLearned(7);

    final points = await db.select(db.grammarPoints).get();
    expect(points.first.isLearned, isTrue);

    final srsStates = await db.select(db.grammarSrsState).get();
    expect(srsStates.length, 1);
    expect(srsStates.first.grammarId, 7);
    expect(srsStates.first.fsrsState, FsrsCardState.learning.dbValue);
    expect(srsStates.first.fsrsStep, 0);
  });

  test(
    'markAsLearned does not create duplicate SRS state on second call',
    () async {
      await db
          .into(db.grammarPoints)
          .insert(_point(id: 8, grammarPoint: '〜けど'));

      await repository.markAsLearned(8);
      await repository.markAsLearned(8);

      final srsStates = await db.select(db.grammarSrsState).get();
      expect(srsStates.length, 1);
    },
  );

  // ── recordReview ──────────────────────────────────────────────────────────

  test('recordReview grade 1 sets ghostReviewsDue and resets streak', () async {
    await db.into(db.grammarPoints).insert(_point(id: 9, grammarPoint: '〜も'));
    await repository.markAsLearned(9);

    await repository.recordReview(grammarId: 9, grade: 1);

    final state = (await db.select(db.grammarSrsState).get()).first;
    expect(state.ghostReviewsDue, 1);
    expect(state.streak, 0);
  });

  test('recordReview grade 3 increments streak and clears ghost', () async {
    await db.into(db.grammarPoints).insert(_point(id: 10, grammarPoint: '〜と'));
    await repository.markAsLearned(10);

    // First fail to set ghost
    await repository.recordReview(grammarId: 10, grade: 1);
    // Then pass
    await repository.recordReview(grammarId: 10, grade: 3);

    final state = (await db.select(db.grammarSrsState).get()).first;
    expect(state.ghostReviewsDue, 0);
    expect(state.streak, greaterThan(0));
  });
}
