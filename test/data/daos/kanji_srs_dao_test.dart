import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/kanji_srs_dao.dart';

void main() {
  late AppDatabase db;
  late KanjiSrsDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = KanjiSrsDao(db);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> insertReviewed(
    int kanjiId, {
    required DateTime nextReviewAt,
    double stability = 1.0,
    double difficulty = 5.0,
    int lastConfidence = 3,
  }) async {
    await dao.initializeSrsState(kanjiId);
    await dao.updateSrsState(
      kanjiId: kanjiId,
      stability: stability,
      difficulty: difficulty,
      lastConfidence: lastConfidence,
      nextReviewAt: nextReviewAt,
    );
  }

  // ---------------------------------------------------------------------------
  // getNextScheduledReview
  // ---------------------------------------------------------------------------

  group('getNextScheduledReview', () {
    test('returns null when no state exists', () async {
      final result = await dao.getNextScheduledReview();
      expect(result, isNull);
    });

    test('returns null when only past-due items exist', () async {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      await insertReviewed(1, nextReviewAt: past);
      final result = await dao.getNextScheduledReview();
      expect(result, isNull);
    });

    test('returns nearest future date when one future item exists', () async {
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertReviewed(1, nextReviewAt: future);
      final result = await dao.getNextScheduledReview();
      expect(result, isNotNull);
      expect(result!.isAfter(DateTime.now()), isTrue);
    });

    test('returns the earliest of multiple future dates', () async {
      final soon = DateTime.now().add(const Duration(hours: 1));
      final later = DateTime.now().add(const Duration(hours: 4));
      final latest = DateTime.now().add(const Duration(days: 3));
      await insertReviewed(1, nextReviewAt: later);
      await insertReviewed(2, nextReviewAt: soon);
      await insertReviewed(3, nextReviewAt: latest);

      final result = await dao.getNextScheduledReview();
      expect(result, isNotNull);
      expect(result!.isBefore(later), isTrue);
      expect(result.isBefore(latest), isTrue);
    });

    test('ignores past-due items and returns only future date', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 30));
      final future = DateTime.now().add(const Duration(hours: 6));
      await insertReviewed(1, nextReviewAt: past);
      await insertReviewed(2, nextReviewAt: future);

      final result = await dao.getNextScheduledReview();
      expect(result, isNotNull);
      expect(result!.isAfter(DateTime.now()), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getDueReviews
  // ---------------------------------------------------------------------------

  group('getDueReviews', () {
    test('returns empty list when no state exists', () async {
      final due = await dao.getDueReviews();
      expect(due, isEmpty);
    });

    test('returns item whose nextReviewAt is in the past', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      await insertReviewed(1, nextReviewAt: past);

      final due = await dao.getDueReviews();
      expect(due, hasLength(1));
      expect(due.first.kanjiId, 1);
    });

    test('excludes items scheduled in the future', () async {
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertReviewed(1, nextReviewAt: future);

      final due = await dao.getDueReviews();
      expect(due, isEmpty);
    });

    test('returns only past-due items when mix of past and future', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 10));
      final future = DateTime.now().add(const Duration(hours: 3));
      await insertReviewed(1, nextReviewAt: past);
      await insertReviewed(2, nextReviewAt: future);
      await insertReviewed(3, nextReviewAt: past);

      final due = await dao.getDueReviews();
      expect(due, hasLength(2));
      expect(due.map((r) => r.kanjiId).toSet(), {1, 3});
    });
  });

  // ---------------------------------------------------------------------------
  // initializeSrsState and getSrsState
  // ---------------------------------------------------------------------------

  group('initializeSrsState / getSrsState', () {
    test('getSrsState returns null for unknown kanjiId', () async {
      final result = await dao.getSrsState(999);
      expect(result, isNull);
    });

    test('getSrsState returns state after initialization', () async {
      await dao.initializeSrsState(10);
      final result = await dao.getSrsState(10);
      expect(result, isNotNull);
      expect(result!.kanjiId, 10);
    });

    test(
      'initializeSrsState is idempotent due to unique key on kanjiId',
      () async {
        await dao.initializeSrsState(5);
        await dao.initializeSrsState(5); // should be ignored
        final result = await dao.getSrsState(5);
        expect(result, isNotNull);
      },
    );

    test('default stability is 1.0 after initialization', () async {
      await dao.initializeSrsState(20);
      final result = await dao.getSrsState(20);
      expect(result!.stability, 1.0);
    });

    test('default difficulty is 5.0 after initialization', () async {
      await dao.initializeSrsState(21);
      final result = await dao.getSrsState(21);
      expect(result!.difficulty, 5.0);
    });
  });

  // ---------------------------------------------------------------------------
  // updateSrsState
  // ---------------------------------------------------------------------------

  group('updateSrsState', () {
    test('persists stability, difficulty, and lastConfidence', () async {
      final nextReview = DateTime.now().add(const Duration(days: 2));
      await insertReviewed(
        42,
        nextReviewAt: nextReview,
        stability: 7.5,
        difficulty: 3.2,
        lastConfidence: 4,
      );

      final state = await dao.getSrsState(42);
      expect(state, isNotNull);
      expect(state!.stability, closeTo(7.5, 0.001));
      expect(state.difficulty, closeTo(3.2, 0.001));
      expect(state.lastConfidence, 4);
    });

    test('sets lastReviewedAt when updateSrsState is called', () async {
      await dao.initializeSrsState(50);
      final initialState = await dao.getSrsState(50);
      expect(initialState!.lastReviewedAt, isNull);

      final future = DateTime.now().add(const Duration(days: 1));
      await dao.updateSrsState(
        kanjiId: 50,
        stability: 2.0,
        difficulty: 4.0,
        lastConfidence: 3,
        nextReviewAt: future,
      );

      final updatedState = await dao.getSrsState(50);
      expect(updatedState!.lastReviewedAt, isNotNull);
    });

    test('updates nextReviewAt correctly', () async {
      await dao.initializeSrsState(55);
      final future = DateTime.now().add(const Duration(days: 7));
      await dao.updateSrsState(
        kanjiId: 55,
        stability: 10.0,
        difficulty: 3.0,
        lastConfidence: 4,
        nextReviewAt: future,
      );

      final state = await dao.getSrsState(55);
      // The stored date should be within a second of our target
      final diff = state!.nextReviewAt.difference(future).abs();
      expect(diff.inSeconds, lessThan(2));
    });
  });

  // ---------------------------------------------------------------------------
  // getStatesForIds
  // ---------------------------------------------------------------------------

  group('getStatesForIds', () {
    test('returns empty list for empty id list', () async {
      final result = await dao.getStatesForIds([]);
      expect(result, isEmpty);
    });

    test('returns only the requested ids', () async {
      final past = DateTime.now().subtract(const Duration(days: 1));
      await insertReviewed(1, nextReviewAt: past);
      await insertReviewed(2, nextReviewAt: past);
      await insertReviewed(3, nextReviewAt: past);

      final result = await dao.getStatesForIds([1, 3]);
      expect(result, hasLength(2));
      expect(result.map((r) => r.kanjiId).toSet(), {1, 3});
    });

    test('returns empty list when none of the ids are found', () async {
      final result = await dao.getStatesForIds([100, 200, 300]);
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // getAllSeenKanjiIds
  // ---------------------------------------------------------------------------

  group('getAllSeenKanjiIds', () {
    test('returns empty list when no states exist', () async {
      final ids = await dao.getAllSeenKanjiIds();
      expect(ids, isEmpty);
    });

    test('returns all kanjiIds that have been initialized', () async {
      await dao.initializeSrsState(10);
      await dao.initializeSrsState(20);
      await dao.initializeSrsState(30);

      final ids = await dao.getAllSeenKanjiIds();
      expect(ids.toSet(), {10, 20, 30});
    });
  });

  // ---------------------------------------------------------------------------
  // watchDueReviewCount
  // ---------------------------------------------------------------------------

  group('watchDueReviewCount', () {
    test('emits 0 when no state exists', () async {
      final count = await dao.watchDueReviewCount().first;
      expect(count, 0);
    });

    test('emits 0 when only future items exist', () async {
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertReviewed(1, nextReviewAt: future);

      final count = await dao.watchDueReviewCount().first;
      expect(count, 0);
    });

    test('emits correct count for past-due items', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      await insertReviewed(1, nextReviewAt: past);
      await insertReviewed(2, nextReviewAt: past);

      final count = await dao.watchDueReviewCount().first;
      expect(count, 2);
    });

    test('counts only past-due when mix of past and future', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertReviewed(1, nextReviewAt: past);
      await insertReviewed(2, nextReviewAt: future);
      await insertReviewed(3, nextReviewAt: past);

      final count = await dao.watchDueReviewCount().first;
      expect(count, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // insertTestState (helper used in tests/production fixtures)
  // ---------------------------------------------------------------------------

  group('insertTestState', () {
    test('can insert and retrieve a test state', () async {
      final target = DateTime.now().add(const Duration(hours: 1));
      await dao.insertTestState(kanjiId: 99, nextReviewAt: target);

      final state = await dao.getSrsState(99);
      expect(state, isNotNull);
      expect(state!.kanjiId, 99);
      final diff = state.nextReviewAt.difference(target).abs();
      expect(diff.inSeconds, lessThan(2));
    });

    test('insertOrReplace overwrites existing state', () async {
      final first = DateTime.now().add(const Duration(hours: 1));
      final second = DateTime.now().add(const Duration(days: 5));
      await dao.insertTestState(kanjiId: 77, nextReviewAt: first);
      await dao.insertTestState(kanjiId: 77, nextReviewAt: second);

      final state = await dao.getSrsState(77);
      expect(state, isNotNull);
      // Should reflect the second insert
      final diff = state!.nextReviewAt.difference(second).abs();
      expect(diff.inSeconds, lessThan(2));
    });
  });
}
