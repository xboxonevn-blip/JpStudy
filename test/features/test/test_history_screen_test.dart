import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/daos/test_dao.dart';
import 'package:jpstudy/features/test/providers/test_providers.dart';
import 'package:jpstudy/features/test/screens/test_history_screen.dart';
import 'package:jpstudy/features/test/services/test_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTestHistoryService extends TestHistoryService {
  _FakeTestHistoryService({
    required this.history,
    required this.progress,
    required this.best,
    required this.average,
    this.throwOnHistory = false,
    this.throwOnProgress = false,
  }) : super(TestDao(AppDatabase(executor: NativeDatabase.memory())));

  final List<TestHistoryRecord> history;
  final List<ProgressPoint> progress;
  final TestHistoryRecord? best;
  final double average;
  final bool throwOnHistory;
  final bool throwOnProgress;

  @override
  Future<List<TestHistoryRecord>> getHistory(int lessonId) async {
    if (throwOnHistory) throw Exception('history failed');
    return history;
  }

  @override
  Future<List<ProgressPoint>> getProgressData(int lessonId, {int limit = 10}) async {
    if (throwOnProgress) throw Exception('progress failed');
    return progress;
  }

  @override
  Future<TestHistoryRecord?> getBestScore(int lessonId) async => best;

  @override
  Future<double> getAverageScore(int lessonId) async => average;
}

final _record1 = TestHistoryRecord(
  sessionId: 's1',
  lessonId: 1,
  completedAt: DateTime(2026, 3, 10, 10, 0),
  score: 70,
  grade: 'C',
  correctCount: 14,
  totalQuestions: 20,
  timeElapsed: Duration(minutes: 12),
  xpEarned: 40,
  weakTermIds: [1, 2],
);

final _record2 = TestHistoryRecord(
  sessionId: 's2',
  lessonId: 1,
  completedAt: DateTime(2026, 3, 11, 10, 0),
  score: 90,
  grade: 'A',
  correctCount: 18,
  totalQuestions: 20,
  timeElapsed: Duration(minutes: 10),
  xpEarned: 70,
  weakTermIds: [2],
);

final _progress = [
  ProgressPoint(date: DateTime(2026, 3, 10), score: 70, grade: 'C'),
  ProgressPoint(date: DateTime(2026, 3, 11), score: 90, grade: 'A'),
];

Widget buildScreen({TestHistoryService? service}) {
  final db = AppDatabase(executor: NativeDatabase.memory());
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      databaseProvider.overrideWithValue(db),
      testHistoryServiceProvider.overrideWithValue(
        service ?? TestHistoryService(TestDao(db)),
      ),
    ],
    child: const MaterialApp(
      home: TestHistoryScreen(lessonId: 1, lessonTitle: 'Lesson 1'),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows attempt history app bar title with lesson name',
      (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    await tester.pumpWidget(buildScreen(service: TestHistoryService(TestDao(db))));
    await tester.pump();
    expect(find.text('Attempt history: Lesson 1'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
  });

  testWidgets('shows empty state when no history exists', (tester) async {
    final service = _FakeTestHistoryService(
      history: const [],
      progress: const [],
      best: null,
      average: 0,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No attempts yet.'), findsOneWidget);
    expect(find.text(AppLanguage.en.testHistoryEmptyHintLabel), findsOneWidget);
  });

  testWidgets('shows stats summary with test count, best score, and average',
      (tester) async {
    final service = _FakeTestHistoryService(
      history: [_record2, _record1],
      progress: _progress,
      best: _record2,
      average: 80,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.testHistoryTestsTakenLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.testHistoryBestScoreLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.testHistoryAverageLabel), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
  });

  testWidgets('shows progress chart when two or more progress points exist',
      (tester) async {
    final service = _FakeTestHistoryService(
      history: [_record2, _record1],
      progress: _progress,
      best: _record2,
      average: 80,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.testHistoryProgressOverTimeLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.testHistoryOldestLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.testHistoryLatestLabel), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });

  testWidgets('hides progress chart when fewer than two progress points exist',
      (tester) async {
    final service = _FakeTestHistoryService(
      history: [_record2],
      progress: [ProgressPoint(date: DateTime(2026, 3, 11), score: 90, grade: 'A')],
      best: _record2,
      average: 90,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.testHistoryProgressOverTimeLabel), findsNothing);
  });

  testWidgets('shows history list entries with grade and score details',
      (tester) async {
    final service = _FakeTestHistoryService(
      history: [_record2, _record1],
      progress: _progress,
      best: _record2,
      average: 80,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('A'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('90% (18/20)'), findsOneWidget);
    expect(find.text('70% (14/20)'), findsOneWidget);
  });

  testWidgets('shows load error when history loading fails', (tester) async {
    final service = _FakeTestHistoryService(
      history: const [],
      progress: const [],
      best: null,
      average: 0,
      throwOnHistory: true,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.loadErrorLabel), findsOneWidget);
  });

  testWidgets('shows load error when progress loading fails', (tester) async {
    final service = _FakeTestHistoryService(
      history: [_record2],
      progress: const [],
      best: _record2,
      average: 90,
      throwOnProgress: true,
    );
    await tester.pumpWidget(buildScreen(service: service));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppLanguage.en.loadErrorLabel), findsOneWidget);
  });
}
