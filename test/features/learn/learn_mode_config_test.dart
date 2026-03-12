import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  VocabItem buildItem({
    required int id,
    required String term,
    required String meaning,
  }) {
    return VocabItem(
      id: id,
      term: term,
      reading: 'reading_$id',
      meaning: meaning,
      meaningEn: meaning,
      level: 'N5',
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Learn session snapshot preserves config and retry metadata', () {
    final item = buildItem(id: 1, term: 'たべる', meaning: 'to eat');
    final question = Question(
      id: 'q1',
      type: QuestionType.fillBlank,
      targetItem: item,
      questionText: 'Meaning?',
      correctAnswer: 'to eat',
      expectsReading: false,
      hint: 't...',
    );
    final snapshot = LearnSessionSnapshot(
      lessonId: 12,
      sessionId: 'session_1',
      startedAt: DateTime(2026, 3, 11, 9),
      currentRound: 1,
      currentQuestionIndex: 0,
      questions: [question],
      results: [
        QuestionResult(
          question: question,
          userAnswer: 'wrong',
          isCorrect: false,
          timeTaken: const Duration(seconds: 4),
          answeredAt: DateTime(2026, 3, 11, 9, 1),
        ),
      ],
      config: const LearnConfig(
        questionCount: 1,
        enabledTypes: [QuestionType.fillBlank],
        shuffleQuestions: false,
        enableHints: false,
        showCorrectAnswer: false,
      ),
      contextHintsShown: const {'q1'},
      contextHintsRequeued: const {'q1'},
      wrongRequeued: const {'q1'},
      lastSavedAt: DateTime(2026, 3, 11, 9, 1),
    );

    final restored = LearnSessionSnapshot.fromJson(snapshot.toJson());

    expect(restored.config.questionCount, 1);
    expect(restored.config.enabledTypes, [QuestionType.fillBlank]);
    expect(restored.config.shuffleQuestions, isFalse);
    expect(restored.config.enableHints, isFalse);
    expect(restored.config.showCorrectAnswer, isFalse);
    expect(restored.wrongRequeued, {'q1'});
  });

  testWidgets(
    'Learn mode respects question count and item order when shuffle is off',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      final items = [
        buildItem(id: 1, term: 'term_1', meaning: 'meaning_1'),
        buildItem(id: 2, term: 'term_2', meaning: 'meaning_2'),
        buildItem(id: 3, term: 'term_3', meaning: 'meaning_3'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LearnScreen(
              items: items,
              lessonId: 1,
              lessonTitle: 'Lesson 1',
              config: const LearnConfig(
                questionCount: 2,
                enabledTypes: [QuestionType.multipleChoice],
                shuffleQuestions: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('term_1'), findsOneWidget);
      expect(find.text('term_3'), findsNothing);
    },
  );

  testWidgets(
    'Learn mode hides hints and correct answer when config disables them',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      final item = buildItem(id: 9, term: 'たべる', meaning: 'secret_meaning');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: LearnScreen(
              items: [item],
              lessonId: 9,
              lessonTitle: 'Lesson 9',
              config: const LearnConfig(
                questionCount: 1,
                enabledTypes: [QuestionType.fillBlank],
                shuffleQuestions: false,
                enableHints: false,
                showCorrectAnswer: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text(AppLanguage.en.showHintLabel), findsNothing);
      expect(find.text(AppLanguage.en.contextualHintButtonLabel), findsNothing);

      await tester.enterText(find.byType(TextField), 'wrong_answer');
      await tester.tap(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.pumpAndSettle();

      expect(find.text(AppLanguage.en.correctAnswerLabel), findsNothing);
      expect(find.text('secret_meaning'), findsNothing);
      expect(find.text('wrong_answer'), findsOneWidget);
      expect(find.text(AppLanguage.en.gotItLabel), findsOneWidget);
    },
  );
}
