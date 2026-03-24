import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart' as app_db;
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_session.dart' as test_model;
import 'package:jpstudy/features/test/screens/test_results_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _item = VocabItem(
  id: 1,
  term: '水',
  reading: 'みず',
  meaning: 'water',
  meaningEn: 'water',
  level: 'N5',
);

const _question1 = Question(
  id: 'q1',
  type: QuestionType.multipleChoice,
  targetItem: _item,
  questionText: 'What does 水 mean?',
  correctAnswer: 'water',
  options: ['water', 'fire'],
);

const _question2 = Question(
  id: 'q2',
  type: QuestionType.trueFalse,
  targetItem: _item,
  questionText: '水 means fire.',
  correctAnswer: 'false',
  isStatementTrue: false,
);

final _session = test_model.TestSession(
  sessionId: 'test_1',
  lessonId: 1,
  startedAt: DateTime(2026, 3, 24, 10),
  completedAt: DateTime(2026, 3, 24, 10, 5),
  questions: const [_question1, _question2],
  answers: const [
    test_model.TestAnswer(questionIndex: 0, userAnswer: 'water', isCorrect: true),
    test_model.TestAnswer(questionIndex: 1, userAnswer: 'true', isCorrect: false),
  ],
);

const _dashboard = DashboardState(
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

const _continueAction = ContinueAction(
  type: ContinueActionType.practiceMixed,
  label: 'practice',
);

Widget buildScreen(app_db.AppDatabase db) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        databaseProvider.overrideWithValue(db),
        recoveryPackProvider.overrideWith((ref) async => null),
        dashboardProvider.overrideWith((ref) => Stream.value(_dashboard)),
        continueActionProvider.overrideWith((ref) async => _continueAction),
        grammarGhostCountProvider.overrideWith((ref) async => 0),
        vocabGhostCountProvider.overrideWith((ref) async => 0),
        vocabGhostsProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        home: TestResultsScreen(
          session: _session,
          lessonTitle: 'Lesson 1',
        ),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows test results title and score summary', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(AppLanguage.en.testResultsTitle), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text(AppLanguage.en.testCorrectSummaryLabel(1, 2)), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump();
  });

  testWidgets('shows grade and XP earned', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('F'), findsOneWidget);
    expect(find.text('+5 XP'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump();
  });
}
