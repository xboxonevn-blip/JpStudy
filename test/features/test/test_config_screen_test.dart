import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/screens/test_config_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = TestConfig(
  questionCount: 10,
  enabledTypes: [QuestionType.multipleChoice, QuestionType.trueFalse],
  shuffleQuestions: false,
  timeLimitMinutes: 10,
  showCorrectAfterWrong: false,
  adaptiveTesting: true,
);

final _resumeSnapshot = TestSessionSnapshot(
  sessionKey: 'resume_1',
  sessionId: 'session_1',
  lessonId: 1,
  startedAt: DateTime(2026, 3, 24, 10),
  currentQuestionIndex: 3,
  questions: const <Question>[],
  answers: const [],
  flaggedQuestions: const {},
  config: _config,
  adaptiveAdded: 0,
  adaptiveMaxExtra: 0,
  usedTypesByItem: const {},
  adaptiveRepeatCount: const {},
  adaptiveCorrectStreak: const {},
  adaptiveCompleted: const {},
  lastSavedAt: DateTime(2026, 3, 24, 10, 5),
);

Widget buildScreen({
  TestSessionSnapshot? resumeSnapshot,
  TestConfig? initialConfig = _config,
  int maxQuestions = 20,
  void Function(TestConfig)? onStart,
  VoidCallback? onResume,
  Future<void> Function()? onDiscardResume,
}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
  ],
  child: MaterialApp(
    home: TestConfigScreen(
      lessonId: 1,
      lessonTitle: 'Lesson 1',
      maxQuestions: maxQuestions,
      initialConfig: initialConfig,
      resumeSnapshot: resumeSnapshot,
      onStart: onStart ?? (_) {},
      onResume: onResume,
      onDiscardResume: onDiscardResume,
    ),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows resume card when snapshot exists', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        resumeSnapshot: _resumeSnapshot,
        onResume: () {},
        onDiscardResume: () async {},
      ),
    );
    await tester.pump();

    expect(find.text(AppLanguage.en.resumeSessionTitle), findsOneWidget);
    expect(find.text(AppLanguage.en.resumeButtonLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.discardButtonLabel), findsOneWidget);
  });

  testWidgets('shows config hero and selected options from initial config', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text(AppLanguage.en.configureTestLabel), findsOneWidget);
    expect(
      find.text(AppLanguage.en.testQuestionsAvailableLabel(20)),
      findsOneWidget,
    );
    expect(find.text(AppLanguage.en.timeLimitMinutesLabel(10)), findsWidgets);
  });

  testWidgets('start button passes current config to onStart callback', (
    tester,
  ) async {
    TestConfig? started;
    await tester.pumpWidget(buildScreen(onStart: (config) => started = config));
    await tester.pump();

    await tester.ensureVisible(find.text(AppLanguage.en.startTestLabel));
    await tester.tap(find.text(AppLanguage.en.startTestLabel));
    await tester.pump();

    expect(started, isNotNull);
    expect(started!.questionCount, 10);
    expect(started!.enabledTypes, [
      QuestionType.multipleChoice,
      QuestionType.trueFalse,
    ]);
    expect(started!.timeLimitMinutes, 10);
  });

  testWidgets('resume button triggers onResume callback', (tester) async {
    var resumed = false;
    await tester.pumpWidget(
      buildScreen(
        resumeSnapshot: _resumeSnapshot,
        onResume: () => resumed = true,
        onDiscardResume: () async {},
      ),
    );
    await tester.pump();

    await tester.tap(find.text(AppLanguage.en.resumeButtonLabel));
    await tester.pump();

    expect(resumed, isTrue);
  });

  testWidgets('discard button removes resume card and triggers callback', (
    tester,
  ) async {
    var discarded = false;
    await tester.pumpWidget(
      buildScreen(
        resumeSnapshot: _resumeSnapshot,
        onResume: () {},
        onDiscardResume: () async => discarded = true,
      ),
    );
    await tester.pump();

    expect(find.text(AppLanguage.en.resumeSessionTitle), findsOneWidget);

    await tester.tap(find.text(AppLanguage.en.discardButtonLabel));
    await tester.pump();

    expect(discarded, isTrue);
    expect(find.text(AppLanguage.en.resumeSessionTitle), findsNothing);
  });

  testWidgets('clamps oversized initial question count down to max cap', (
    tester,
  ) async {
    const oversized = TestConfig(questionCount: 999, timeLimitMinutes: 30);
    TestConfig? started;

    await tester.pumpWidget(
      buildScreen(
        initialConfig: oversized,
        maxQuestions: 20,
        onStart: (config) => started = config,
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text(AppLanguage.en.startTestLabel));
    await tester.tap(find.text(AppLanguage.en.startTestLabel));
    await tester.pump();

    expect(started, isNotNull);
    expect(started!.questionCount, 20);
  });

  testWidgets(
    'uses maxQuestions as default question count when initialConfig is null',
    (tester) async {
      TestConfig? started;

      await tester.pumpWidget(
        buildScreen(
          initialConfig: null,
          maxQuestions: 7,
          onStart: (config) => started = config,
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text(AppLanguage.en.startTestLabel));
      await tester.tap(find.text(AppLanguage.en.startTestLabel));
      await tester.pump();

      expect(started, isNotNull);
      expect(started!.questionCount, 7);
    },
  );

  testWidgets('summary reflects adaptive testing feedback state from config', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text('Adaptive'), findsOneWidget);
    expect(find.textContaining('Wrong answers can return'), findsOneWidget);
    expect(find.textContaining('Cleaner exam-style feedback'), findsOneWidget);
  });
}
