import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';

void main() {
  late AppDatabase db;
  late SrsDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = SrsDao(db);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  /// Insert a single SRS state with explicit nextReviewAt.
  Future<void> insertState(
    int vocabId, {
    required DateTime nextReviewAt,
    double stability = 1.0,
  }) async {
    await dao.initializeSrsState(vocabId);
    await dao.updateSrsState(
      vocabId: vocabId,
      box: 1,
      repetitions: 1,
      ease: 2.5,
      stability: stability,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: nextReviewAt,
    );
  }

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
      await insertState(1, nextReviewAt: past);

      final due = await dao.getDueReviews();
      expect(due, hasLength(1));
      expect(due.first.vocabId, 1);
    });

    test('returns item whose nextReviewAt equals now (boundary)', () async {
      // Use a time guaranteed to be <= now by the time the query runs.
      final justNow = DateTime.now().subtract(const Duration(milliseconds: 1));
      await insertState(1, nextReviewAt: justNow);

      final due = await dao.getDueReviews();
      expect(due, hasLength(1));
    });

    test('excludes item whose nextReviewAt is in the future', () async {
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertState(1, nextReviewAt: future);

      final due = await dao.getDueReviews();
      expect(due, isEmpty);
    });

    test('returns only past-due items when mix of past and future exists',
        () async {
      final past = DateTime.now().subtract(const Duration(minutes: 10));
      final future = DateTime.now().add(const Duration(hours: 3));
      await insertState(1, nextReviewAt: past);
      await insertState(2, nextReviewAt: future);
      await insertState(3, nextReviewAt: past);

      final due = await dao.getDueReviews();
      expect(due, hasLength(2));
      expect(due.map((r) => r.vocabId).toSet(), {1, 3});
    });

    test('returns all items when all are past-due', () async {
      for (var i = 1; i <= 5; i++) {
        await insertState(
          i,
          nextReviewAt: DateTime.now().subtract(Duration(hours: i)),
        );
      }
      final due = await dao.getDueReviews();
      expect(due, hasLength(5));
    });
  });

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
      await insertState(1, nextReviewAt: past);

      final result = await dao.getNextScheduledReview();
      expect(result, isNull);
    });

    test('returns nearest future review date when one future item exists',
        () async {
      final future = DateTime.now().add(const Duration(hours: 3));
      await insertState(1, nextReviewAt: future);

      final result = await dao.getNextScheduledReview();
      expect(result, isNotNull);
      expect(result!.isAfter(DateTime.now()), isTrue);
    });

    test('returns the earliest future date when multiple future items exist',
        () async {
      final soon = DateTime.now().add(const Duration(hours: 1));
      final later = DateTime.now().add(const Duration(hours: 5));
      final latest = DateTime.now().add(const Duration(days: 2));
      await insertState(1, nextReviewAt: later);
      await insertState(2, nextReviewAt: soon);
      await insertState(3, nextReviewAt: latest);

      final result = await dao.getNextScheduledReview();
      expect(result, isNotNull);
      // Should be the soonest future date
      expect(result!.isBefore(later), isTrue);
      expect(result.isBefore(latest), isTrue);
    });

    test('ignores past-due items and returns only future date', () async {
      final past = DateTime.now().subtract(const Duration(hours: 1));
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertState(1, nextReviewAt: past);
      await insertState(2, nextReviewAt: future);

      final result = await dao.getNextScheduledReview();
      expect(result, isNotNull);
      expect(result!.isAfter(DateTime.now()), isTrue);
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
      await insertState(1, nextReviewAt: future);

      final count = await dao.watchDueReviewCount().first;
      expect(count, 0);
    });

    test('emits correct count for past-due items', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      await insertState(1, nextReviewAt: past);
      await insertState(2, nextReviewAt: past);

      final count = await dao.watchDueReviewCount().first;
      expect(count, 2);
    });

    test('counts only past-due when mix of past and future', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 10));
      final future = DateTime.now().add(const Duration(hours: 2));
      await insertState(1, nextReviewAt: past);
      await insertState(2, nextReviewAt: future);
      await insertState(3, nextReviewAt: past);

      final count = await dao.watchDueReviewCount().first;
      expect(count, 2);
    });

    test('updates reactively when a new past-due item is added', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 5));

      // Collect two emissions: initial 0, then 1 after insert
      final stream = dao.watchDueReviewCount();
      final first = await stream.first;
      expect(first, 0);

      await insertState(1, nextReviewAt: past);

      final second = await dao.watchDueReviewCount().first;
      expect(second, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // getSrsState and initializeSrsState
  // ---------------------------------------------------------------------------

  group('getSrsState', () {
    test('returns null for unknown vocabId', () async {
      final result = await dao.getSrsState(999);
      expect(result, isNull);
    });

    test('returns state after initialization', () async {
      await dao.initializeSrsState(42);
      final result = await dao.getSrsState(42);
      expect(result, isNotNull);
      expect(result!.vocabId, 42);
    });

    test('initializeSrsState sets nextReviewAt to approximately now', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await dao.initializeSrsState(7);
      final after = DateTime.now().add(const Duration(seconds: 1));
      final result = await dao.getSrsState(7);
      expect(result, isNotNull);
      expect(result!.nextReviewAt.isAfter(before), isTrue);
      expect(result.nextReviewAt.isBefore(after), isTrue);
    });
  });
}
