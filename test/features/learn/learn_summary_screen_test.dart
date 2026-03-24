import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/data/db/app_database.dart' as app_db;
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart' as learn;
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/learn_summary_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSessionStorage extends SessionStorage {
  @override
  Future<void> clearLearnSession(int lessonId) async {}
}

const _item = VocabItem(
  id: 1,
  term: '水',
  reading: 'みず',
  meaning: 'water',
  meaningEn: 'water',
  level: 'N5',
);

const _question = Question(
  id: 'q1',
  type: QuestionType.multipleChoice,
  targetItem: _item,
  questionText: 'What does 水 mean?',
  correctAnswer: 'water',
  options: ['water', 'fire'],
);

final _session = learn.LearnSession(
  sessionId: 'learn_1',
  lessonId: 1,
  startedAt: DateTime(2026, 3, 24, 10),
  completedAt: DateTime(2026, 3, 24, 10, 5),
  questions: const [_question, _question, _question],
  results: [
    QuestionResult(
      question: _question,
      userAnswer: 'water',
      isCorrect: true,
      timeTaken: const Duration(seconds: 2),
      answeredAt: DateTime(2026, 3, 24, 10, 1),
    ),
    QuestionResult(
      question: _question,
      userAnswer: 'fire',
      isCorrect: false,
      timeTaken: const Duration(seconds: 4),
      answeredAt: DateTime(2026, 3, 24, 10, 2),
    ),
    QuestionResult(
      question: _question,
      userAnswer: 'water',
      isCorrect: true,
      timeTaken: const Duration(seconds: 2),
      answeredAt: DateTime(2026, 3, 24, 10, 3),
    ),
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
        sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
        recoveryPackProvider.overrideWith((ref) async => null),
        weaknessRadarProvider.overrideWith((ref) async => const []),
        dashboardProvider.overrideWith((ref) => Stream.value(_dashboard)),
        continueActionProvider.overrideWith((ref) async => _continueAction),
        grammarGhostCountProvider.overrideWith((ref) async => 0),
        vocabGhostCountProvider.overrideWith((ref) async => 0),
        vocabGhostsProvider.overrideWith((ref) async => const []),
      ],
      child: MaterialApp(
        home: LearnSummaryScreen(
          session: _session,
          lessonTitle: 'Lesson 1',
          config: const LearnConfig(questionCount: 3),
        ),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows learn summary title and accuracy', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(AppLanguage.en.learnSummaryTitle), findsOneWidget);
    expect(find.text('66%'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump();
  });

  testWidgets('shows correct wrong and XP summary values', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('2'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    expect(find.text('+16 XP'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump();
  });
}
