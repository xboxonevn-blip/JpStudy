import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/data/db/app_database.dart' as app_db;
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/learn_summary_screen.dart';
import 'package:jpstudy/features/test/models/test_session.dart';
import 'package:jpstudy/features/test/screens/test_results_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  DashboardState dashboard() {
    return const DashboardState(
      streak: 0,
      todayXp: 0,
      vocabDue: 0,
      grammarDue: 0,
      kanjiDue: 0,
      vocabMistakeCount: 0,
      grammarMistakeCount: 0,
      kanjiMistakeCount: 0,
      totalMistakeCount: 0,
    );
  }

  ProviderScope wrapWithOverrides({
    required Widget child,
    required app_db.AppDatabase db,
    RecoveryPack? recoveryPack,
  }) {
    return ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        databaseProvider.overrideWithValue(db),
        dashboardProvider.overrideWith((_) => Stream.value(dashboard())),
        continueActionProvider.overrideWith(
          (_) async => const ContinueAction(
            type: ContinueActionType.practiceMixed,
            label: 'practice',
          ),
        ),
        grammarGhostCountProvider.overrideWith((_) async => 0),
        vocabGhostCountProvider.overrideWith((_) async => 0),
        vocabGhostsProvider.overrideWith((_) async => const []),
        if (recoveryPack != null)
          recoveryPackProvider.overrideWith((_) async => recoveryPack),
      ],
      child: child,
    );
  }

  Question buildQuestion(VocabItem item) {
    return Question(
      id: 'q-${item.id}',
      type: QuestionType.multipleChoice,
      targetItem: item,
      questionText: 'What does ${item.term} mean?',
      correctAnswer: item.displayMeaning(AppLanguage.en),
      options: <String>[
        item.displayMeaning(AppLanguage.en),
        'Wrong answer',
        'Another answer',
      ],
    );
  }

  testWidgets('Test results can start the recovery pack route', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    final item = const VocabItem(
      id: 101,
      term: '日本',
      reading: 'にほん',
      meaning: 'Nhat Ban',
      meaningEn: 'Japan',
      level: 'N5',
    );
    final session = TestSession(
      sessionId: 'test-1',
      lessonId: 1,
      startedAt: DateTime(2026, 3, 12, 8),
      completedAt: DateTime(2026, 3, 12, 8, 1),
      questions: [buildQuestion(item)],
      answers: [
        const TestAnswer(
          questionIndex: 0,
          userAnswer: 'Wrong answer',
          isCorrect: false,
        ),
      ],
    );
    final pack = RecoveryPack(
      source: 'mock_exam',
      lessonTitle: 'Lesson 1',
      termIds: const [101],
      createdAt: DateTime(2026, 3, 12, 8, 2),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              TestResultsScreen(session: session, lessonTitle: 'Lesson 1'),
        ),
        GoRoute(
          path: '/learn/recovery-pack',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('recovery-pack-route'))),
        ),
      ],
    );

    await tester.pumpWidget(
      wrapWithOverrides(
        db: db,
        recoveryPack: pack,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start recovery pack'), findsOneWidget);

    await tester.ensureVisible(find.text('Start recovery pack'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start recovery pack'));
    await tester.pumpAndSettle();

    expect(find.text('recovery-pack-route'), findsOneWidget);
  });

  testWidgets('Learn summary clears saved recovery pack after completion', (
    tester,
  ) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await RecoveryPackService.saveExamPack(
      lessonTitle: 'Lesson 1',
      termIds: const [201],
    );
    expect(await RecoveryPackService.load(), isNotNull);

    final item = const VocabItem(
      id: 201,
      term: '水',
      reading: 'みず',
      meaning: 'Nuoc',
      meaningEn: 'Water',
      level: 'N5',
    );
    final question = buildQuestion(item);
    final session = LearnSession(
      sessionId: 'learn-1',
      lessonId: RecoveryPackService.recoveryLessonId,
      startedAt: DateTime(2026, 3, 12, 9),
      completedAt: DateTime(2026, 3, 12, 9, 1),
      questions: [question],
      results: [
        QuestionResult(
          question: question,
          userAnswer: 'Water',
          isCorrect: true,
          timeTaken: const Duration(seconds: 2),
          answeredAt: DateTime(2026, 3, 12, 9, 0, 10),
        ),
      ],
    );

    await tester.pumpWidget(
      wrapWithOverrides(
        db: db,
        child: MaterialApp(
          home: LearnSummaryScreen(
            session: session,
            lessonTitle: 'Recovery Pack',
            config: const LearnConfig(questionCount: 1),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(await RecoveryPackService.load(), isNull);
  });
}
