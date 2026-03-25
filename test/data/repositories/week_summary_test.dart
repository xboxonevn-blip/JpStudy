import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart' hide UserProgressCompanion;
import 'package:jpstudy/data/repositories/lesson_repository.dart';

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late LessonRepository repo;

  setUp(() {
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
    repo = LessonRepository(appDb, contentDb);
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  Future<void> insertProgress({
    required DateTime day,
    required int reviewed,
    int again = 0,
    int hard = 0,
    int good = 0,
    int easy = 0,
    int xp = 0,
    int streak = 0,
  }) async {
    await appDb
        .into(appDb.userProgress)
        .insert(UserProgressCompanion.insert(
          day: day,
          reviewedCount: drift.Value(reviewed),
          reviewAgainCount: drift.Value(again),
          reviewHardCount: drift.Value(hard),
          reviewGoodCount: drift.Value(good),
          reviewEasyCount: drift.Value(easy),
          xp: drift.Value(xp),
          streak: drift.Value(streak),
        ));
  }

  Future<void> insertAttempt({
    required String mode,
    required String level,
    required DateTime startedAt,
    DateTime? finishedAt,
    int? score,
    int? total,
  }) async {
    await appDb.into(appDb.attempt).insert(AttemptCompanion.insert(
      mode: mode,
      level: level,
      startedAt: startedAt,
      finishedAt: drift.Value(finishedAt),
      score: drift.Value(score),
      total: drift.Value(total),
    ));
  }

  group('WeekSummary data class', () {
    test('stores values correctly', () {
      const summary = WeekSummary(
        totalReviewed: 47,
        accuracy: 83,
        daysStudied: 5,
      );
      expect(summary.totalReviewed, 47);
      expect(summary.accuracy, 83);
      expect(summary.daysStudied, 5);
    });

    test('supports zero values', () {
      const summary = WeekSummary(
        totalReviewed: 0,
        accuracy: 0,
        daysStudied: 0,
      );
      expect(summary.totalReviewed, 0);
      expect(summary.accuracy, 0);
      expect(summary.daysStudied, 0);
    });
  });

  group('weekSummaryProvider', () {
    test('returns zeros when there is no review or attempt history', () async {
      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      expect(summary.totalReviewed, 0);
      expect(summary.accuracy, 0);
      expect(summary.daysStudied, 0);
    });

    test('sums reviewed counts and counts only studied days', () async {
      final now = DateTime.now();
      await insertProgress(day: now.subtract(const Duration(days: 1)), reviewed: 12);
      await insertProgress(day: now.subtract(const Duration(days: 2)), reviewed: 0);
      await insertProgress(day: now.subtract(const Duration(days: 3)), reviewed: 7);
      await insertProgress(day: now.subtract(const Duration(days: 4)), reviewed: 1);

      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      expect(summary.totalReviewed, 20);
      expect(summary.daysStudied, 3); // excludes reviewed == 0 day
    });

    test('computes accuracy from only attempts started within the last 7 days', () async {
      final now = DateTime.now();
      // inside cutoff
      await insertAttempt(
        mode: 'learn',
        level: 'N5',
        startedAt: now.subtract(const Duration(days: 1)),
        finishedAt: now,
        score: 8,
        total: 10,
      );
      await insertAttempt(
        mode: 'test',
        level: 'N5',
        startedAt: now.subtract(const Duration(days: 6)),
        finishedAt: now,
        score: 7,
        total: 10,
      );
      // outside cutoff
      await insertAttempt(
        mode: 'test',
        level: 'N5',
        startedAt: now.subtract(const Duration(days: 8)),
        finishedAt: now,
        score: 10,
        total: 10,
      );

      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      // only 8/10 + 7/10 count => 15/20 => 75%
      expect(summary.accuracy, 75);
    });

    test('returns accuracy 0 when recent attempts have total 0', () async {
      final now = DateTime.now();
      await insertAttempt(
        mode: 'learn',
        level: 'N5',
        startedAt: now.subtract(const Duration(days: 1)),
        finishedAt: now,
        score: 0,
        total: 0,
      );

      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      expect(summary.accuracy, 0);
    });

    test('rounds fractional accuracy to nearest integer', () async {
      final now = DateTime.now();
      await insertAttempt(
        mode: 'learn',
        level: 'N5',
        startedAt: now.subtract(const Duration(days: 1)),
        finishedAt: now,
        score: 2,
        total: 3,
      );

      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      expect(summary.accuracy, 67); // 66.67 rounds to 67
    });

    test('attempt exactly 7 days old is excluded because code uses isAfter(cutoff)',
        () async {
      final now = DateTime.now();
      final cutoffAttemptStartedAt = now.subtract(const Duration(days: 7));
      await insertAttempt(
        mode: 'test',
        level: 'N5',
        startedAt: cutoffAttemptStartedAt,
        finishedAt: now,
        score: 9,
        total: 10,
      );

      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      expect(summary.accuracy, 0); // excluded at exact cutoff boundary
    });

    test('review history contributes regardless of attempt history', () async {
      final now = DateTime.now();
      await insertProgress(day: now.subtract(const Duration(days: 1)), reviewed: 9);
      await insertProgress(day: now.subtract(const Duration(days: 2)), reviewed: 4);

      final container = ProviderContainer(
        overrides: [lessonRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final summary = await container.read(weekSummaryProvider.future);
      expect(summary.totalReviewed, 13);
      expect(summary.daysStudied, 2);
      expect(summary.accuracy, 0);
    });
  });
}
