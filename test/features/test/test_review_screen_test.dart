import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_session.dart';
import 'package:jpstudy/features/test/screens/test_review_screen.dart';
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

final _session = TestSession(
  sessionId: 'session_1',
  lessonId: 1,
  startedAt: DateTime(2026, 3, 24, 10),
  completedAt: DateTime(2026, 3, 24, 10, 5),
  questions: const [_question1, _question2],
  answers: const [
    TestAnswer(questionIndex: 0, userAnswer: 'water', isCorrect: true),
    TestAnswer(questionIndex: 1, userAnswer: null, isCorrect: false),
  ],
);

Widget buildScreen() => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      ],
      child: MaterialApp(
        home: TestReviewScreen(
          session: _session,
          lessonTitle: 'Lesson 1',
        ),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows review answers app bar and filter chips', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Review Answers'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Wrong/Skipped'), findsOneWidget);
  });

  testWidgets('shows review cards and retry wrong button on initial render',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Retry Wrong'), findsOneWidget);
    expect(find.text('#1 • Multiple Choice'), findsOneWidget);
    expect(find.text('#2 • True/False'), findsOneWidget);
  });

  testWidgets('shows user answer and correct answer text', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Your Answer: water'), findsOneWidget);
    expect(find.text('Your Answer: No answer'), findsOneWidget);
    expect(find.text('Correct Answer: water'), findsOneWidget);
    expect(find.text('Correct Answer: FALSE'), findsOneWidget);
  });
}
