import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';
import 'package:jpstudy/features/test/screens/test_config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMockLessonRepository extends LessonRepository {
  FakeMockLessonRepository(
    super.db,
    super.contentDb, {
    required this.itemsByLevel,
    this.throwOnFetch = false,
    this.delay = Duration.zero,
  });

  final Map<String, List<VocabItem>> itemsByLevel;
  final bool throwOnFetch;
  final Duration delay;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (throwOnFetch) {
      throw Exception('boom');
    }
    return itemsByLevel[level] ?? const [];
  }
}

class _FakeSessionStorage extends SessionStorage {
  _FakeSessionStorage({this.resume});

  final TestSessionSnapshot? resume;
  String? lastLoadKey;
  String? lastClearedKey;

  @override
  Future<TestSessionSnapshot?> loadTestSession(String sessionKey) async {
    lastLoadKey = sessionKey;
    return resume;
  }

  @override
  Future<void> clearTestSession(String sessionKey) async {
    lastClearedKey = sessionKey;
  }
}

const _sampleVocab = [
  VocabItem(
    id: 1,
    term: '猫',
    reading: 'ねこ',
    meaning: 'mèo',
    meaningEn: 'cat',
    level: 'N5',
  ),
];

TestSessionSnapshot _resumeSnapshot() => TestSessionSnapshot(
  sessionKey: 'mock_N5',
  sessionId: 'resume-1',
  lessonId: -1,
  startedAt: DateTime(2026, 3, 1, 11, 0),
  currentQuestionIndex: 0,
  questions: const [],
  answers: const [],
  flaggedQuestions: const {},
  config: const TestConfig(questionCount: 1, timeLimitMinutes: 5),
  adaptiveAdded: 0,
  adaptiveMaxExtra: 0,
  usedTypesByItem: const {},
  adaptiveRepeatCount: const {},
  adaptiveCorrectStreak: const {},
  adaptiveCompleted: const {},
  lastSavedAt: DateTime(2026, 3, 1, 11, 1),
);

Widget buildScreen({
  StudyLevel? level,
  LessonRepository? repo,
  SessionStorage? storage,
  HomeMockExamLaunchArgs? launchArgs,
}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    studyLevelProvider.overrideWith((ref) => level),
    if (repo != null) lessonRepositoryProvider.overrideWithValue(repo),
    if (storage != null) sessionStorageProvider.overrideWithValue(storage),
  ],
  child: MaterialApp(home: HomeMockExamScreen(launchArgs: launchArgs)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'defaults to N5 mock exam when level is not selected',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      final cdb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = FakeMockLessonRepository(
        db,
        cdb,
        itemsByLevel: const {'N5': []},
      );

      await tester.pumpWidget(buildScreen(repo: repo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('JLPT N5 Mock Exam'), findsOneWidget);
      expect(find.text('No terms available for this lesson.'), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pump(const Duration(milliseconds: 100));
      await db.close();
      await cdb.close();
    },
  );

  testWidgets('shows JLPT mock exam title for selected level', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': []},
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('JLPT N5 Mock Exam'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('shows empty state when no vocab exists for selected level', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': []},
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No terms available for this lesson.'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('shows load error when repository throws', (tester) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': _sampleVocab},
      throwOnFetch: true,
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.loadErrorLabel), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('navigates to TestConfigScreen when vocab exists', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': _sampleVocab},
    );
    final storage = _FakeSessionStorage();

    await tester.pumpWidget(
      buildScreen(level: StudyLevel.n5, repo: repo, storage: storage),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TestConfigScreen), findsOneWidget);
    expect(storage.lastLoadKey, 'mock_N5');

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('uses launch args title override and session key suffix', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': _sampleVocab},
    );
    final storage = _FakeSessionStorage();

    await tester.pumpWidget(
      buildScreen(
        level: StudyLevel.n5,
        repo: repo,
        storage: storage,
        launchArgs: const HomeMockExamLaunchArgs(
          titleOverride: 'Weekly Mock',
          sessionKeySuffix: 'weekly',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Test: Weekly Mock'), findsOneWidget);
    expect(storage.lastLoadKey, 'mock_weekly_N5');

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });

  testWidgets('passes resume snapshot into TestConfigScreen when available', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final cdb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeMockLessonRepository(
      db,
      cdb,
      itemsByLevel: const {'N5': _sampleVocab},
    );
    final storage = _FakeSessionStorage(resume: _resumeSnapshot());

    await tester.pumpWidget(
      buildScreen(level: StudyLevel.n5, repo: repo, storage: storage),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final screen = tester.widget<TestConfigScreen>(
      find.byType(TestConfigScreen),
    );
    expect(screen.resumeSnapshot, isNotNull);
    expect(screen.onResume, isNotNull);
    expect(screen.onDiscardResume, isNotNull);

    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
    await db.close();
    await cdb.close();
  });
}
