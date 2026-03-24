import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/screens/test_config_screen.dart';
import 'package:jpstudy/features/test/screens/test_screen.dart';
import 'package:jpstudy/features/test/widgets/practice_test_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMockLessonRepository extends LessonRepository {
  FakeMockLessonRepository(
    super.db,
    super.contentDb, {
    required this.itemsByLevel,
  });

  final Map<String, List<VocabItem>> itemsByLevel;
  int recordedXp = 0;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    return itemsByLevel[level] ?? const [];
  }

  @override
  Future<void> recordStudyActivity({required int xpDelta}) async {
    recordedXp += xpDelta;
  }
}

class SetStudyLevel extends ConsumerStatefulWidget {
  const SetStudyLevel({super.key, required this.level, required this.child});

  final StudyLevel level;
  final Widget child;

  @override
  ConsumerState<SetStudyLevel> createState() => _SetStudyLevelState();
}

class _SetStudyLevelState extends ConsumerState<SetStudyLevel> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(studyLevelProvider.notifier).state = widget.level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void main() {
  List<VocabItem> buildItems({
    required int startId,
    required int count,
    required String level,
  }) {
    return List<VocabItem>.generate(
      count,
      (index) => VocabItem(
        id: startId + index,
        term: 'term_${startId + index}',
        reading: 'read_${startId + index}',
        meaning: 'meaning_${startId + index}',
        meaningEn: 'meaning_${startId + index}',
        level: level,
      ),
    );
  }

  testWidgets('Mock dashboard opens config for N5 and N4 levels', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final db = AppDatabase(executor: NativeDatabase.memory());
    final contentDb = ContentDatabase(executor: NativeDatabase.memory());
    final fakeRepo = FakeMockLessonRepository(
      db,
      contentDb,
      itemsByLevel: {
        'N5': buildItems(startId: 1000, count: 12, level: 'N5'),
        'N4': buildItems(startId: 2000, count: 12, level: 'N4'),
      },
    );
    addTearDown(() async {
      await contentDb.close();
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [lessonRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(home: Scaffold(body: PracticeTestDashboard())),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.mockExamTitle('N5')));
    await tester.pumpAndSettle();
    expect(find.byType(TestConfigScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [lessonRepositoryProvider.overrideWithValue(fakeRepo)],
        child: const MaterialApp(
          home: SetStudyLevel(
            level: StudyLevel.n4,
            child: Scaffold(body: PracticeTestDashboard()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.mockExamTitle('N4')));
    await tester.pumpAndSettle();
    expect(find.byType(TestConfigScreen), findsOneWidget);
  });

  testWidgets('Mock exam shows timer when config has time limit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final db = AppDatabase(executor: NativeDatabase.memory());
    final contentDb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = LessonRepository(db, contentDb);
    addTearDown(() async {
      await contentDb.close();
      await db.close();
    });

    final items = buildItems(startId: 3000, count: 3, level: 'N5');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          lessonRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: TestScreen(
            items: items,
            lessonId: -1,
            lessonTitle: AppLanguage.en.mockExamTitle('N5'),
            config: const TestConfig(
              questionCount: 3,
              enabledTypes: [QuestionType.multipleChoice],
              timeLimitMinutes: 5,
              shuffleQuestions: false,
              showCorrectAfterWrong: false,
              adaptiveTesting: false,
            ),
            sessionKey: 'mock_n5_walkthrough',
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.timer), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'Mock exam desktop layout does not overflow with long side panel',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      final db = AppDatabase(executor: NativeDatabase.memory());
      final contentDb = ContentDatabase(executor: NativeDatabase.memory());
      final repo = LessonRepository(db, contentDb);
      addTearDown(() async {
        await contentDb.close();
        await db.close();
      });

      final items = buildItems(startId: 5000, count: 50, level: 'N5');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            lessonRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            home: TestScreen(
              items: items,
              lessonId: -1,
              lessonTitle: AppLanguage.en.mockExamTitle('N5'),
              config: const TestConfig(
                questionCount: 50,
                enabledTypes: [
                  QuestionType.multipleChoice,
                  QuestionType.trueFalse,
                  QuestionType.fillBlank,
                ],
                shuffleQuestions: false,
                showCorrectAfterWrong: false,
                adaptiveTesting: false,
              ),
              sessionKey: 'mock_n5_desktop_no_overflow',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Run mode'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Mock exam last question opens submit confirmation dialog', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    const item = VocabItem(
      id: 3000,
      term: '水',
      reading: 'みず',
      meaning: 'Nuoc',
      meaningEn: 'Water',
      level: 'N5',
    );
    const config = TestConfig(
      questionCount: 1,
      enabledTypes: [QuestionType.multipleChoice],
      shuffleQuestions: false,
      showCorrectAfterWrong: false,
      adaptiveTesting: false,
    );
    final question = Question(
      id: 'submit_regression_q1',
      type: QuestionType.multipleChoice,
      targetItem: item,
      questionText: 'What does 水 mean?',
      correctAnswer: 'Water',
      options: const ['Water', 'Rice', 'Fire'],
    );
    const sessionKey = 'mock_n5_submit_regression';
    final resumeSnapshot = TestSessionSnapshot(
      sessionKey: sessionKey,
      sessionId: 'session_submit_regression',
      lessonId: -1,
      startedAt: DateTime(2026, 3, 24, 9),
      currentQuestionIndex: 0,
      questions: [question],
      answers: const [],
      flaggedQuestions: const {},
      config: config,
      adaptiveAdded: 0,
      adaptiveMaxExtra: 0,
      usedTypesByItem: const {},
      adaptiveRepeatCount: const {},
      adaptiveCorrectStreak: const {},
      adaptiveCompleted: const {},
      lastSavedAt: DateTime(2026, 3, 24, 9, 1),
    );
    final storage = SessionStorage();
    await storage.saveTestSession(snapshot: resumeSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: MaterialApp(
          home: TestScreen(
            items: const [item],
            lessonId: -1,
            lessonTitle: AppLanguage.en.mockExamTitle('N5'),
            config: config,
            sessionKey: sessionKey,
            resumeSnapshot: resumeSnapshot,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(AppLanguage.en.submitTestLabel), findsOneWidget);
    await tester.ensureVisible(find.text(AppLanguage.en.submitTestLabel));
    await tester.tap(find.text(AppLanguage.en.submitTestLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text(AppLanguage.en.submitTestTitle), findsOneWidget);
    expect(find.text(AppLanguage.en.unansweredSubmitLabel(1)), findsOneWidget);
    expect(find.text(AppLanguage.en.submitTestConfirmLabel), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text(AppLanguage.en.submitTestTitle), findsNothing);
    expect(await storage.loadTestSession(sessionKey), isNotNull);
    expect(find.text(AppLanguage.en.submitTestLabel), findsOneWidget);
  });

  testWidgets('Mock exam config shows resume card and resume action', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    var resumed = false;
    final vocabItem = VocabItem(
      id: 999,
      term: 'resume_term',
      reading: 'resume_read',
      meaning: 'resume_meaning',
      meaningEn: 'resume_meaning',
      level: 'N5',
    );
    final snapshot = TestSessionSnapshot(
      sessionKey: 'mock_resume',
      sessionId: 'session_resume',
      lessonId: -1,
      startedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      currentQuestionIndex: 0,
      questions: [
        Question(
          id: 'q_resume',
          type: QuestionType.multipleChoice,
          targetItem: vocabItem,
          questionText: 'What is resume_term?',
          correctAnswer: 'resume_meaning',
          options: const ['resume_meaning', 'x', 'y', 'z'],
        ),
      ],
      answers: const [],
      flaggedQuestions: const {},
      config: const TestConfig(questionCount: 10),
      adaptiveAdded: 0,
      adaptiveMaxExtra: 0,
      usedTypesByItem: const {},
      adaptiveRepeatCount: const {},
      adaptiveCorrectStreak: const {},
      adaptiveCompleted: const {},
      lastSavedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: TestConfigScreen(
            lessonId: -1,
            lessonTitle: AppLanguage.en.mockExamTitle('N5'),
            maxQuestions: 20,
            initialConfig: const TestConfig(questionCount: 10),
            resumeSnapshot: snapshot,
            onResume: () {
              resumed = true;
            },
            onStart: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text(AppLanguage.en.resumeSessionTitle), findsOneWidget);

    await tester.tap(find.text(AppLanguage.en.resumeButtonLabel));
    await tester.pumpAndSettle();
    expect(resumed, isTrue);
  });
}
