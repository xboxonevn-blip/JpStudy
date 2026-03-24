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

Widget buildScreen({TestSessionSnapshot? resumeSnapshot}) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      ],
      child: MaterialApp(
        home: TestConfigScreen(
          lessonId: 1,
          lessonTitle: 'Lesson 1',
          maxQuestions: 20,
          initialConfig: _config,
          resumeSnapshot: resumeSnapshot,
          onStart: (_) {},
          onResume: () {},
          onDiscardResume: () async {},
        ),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows resume card when snapshot exists', (tester) async {
    await tester.pumpWidget(buildScreen(resumeSnapshot: _resumeSnapshot));
    await tester.pump();

    expect(find.text(AppLanguage.en.resumeSessionTitle), findsOneWidget);
    expect(find.text(AppLanguage.en.resumeButtonLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.discardButtonLabel), findsOneWidget);
  });

  testWidgets('shows config hero and selected options from initial config', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();

    expect(find.text(AppLanguage.en.configureTestLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.testQuestionsAvailableLabel(20)), findsOneWidget);
    expect(find.text(AppLanguage.en.timeLimitMinutesLabel(10)), findsWidgets);
  });
}
