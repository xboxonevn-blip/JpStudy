import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/screens/test_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Test screen can hide correct answer after wrong fill-in response',
    (tester) async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      final item = VocabItem(
        id: 1,
        term: 'たべる',
        reading: 'たべる',
        meaning: 'secret_meaning',
        meaningEn: 'secret_meaning',
        level: 'N5',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            home: TestScreen(
              items: [item],
              lessonId: 1,
              lessonTitle: 'Mock Test',
              config: const TestConfig(
                questionCount: 1,
                enabledTypes: [QuestionType.fillBlank],
                shuffleQuestions: false,
                showCorrectAfterWrong: false,
                adaptiveTesting: false,
              ),
              sessionKey: 'test_feedback_case',
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.enterText(find.byType(TextField), 'wrong_answer');
      await tester.ensureVisible(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.tap(find.text(AppLanguage.en.checkAnswerLabel));
      await tester.pumpAndSettle();

      expect(find.text(AppLanguage.en.correctAnswerLabel), findsNothing);
      expect(find.text('secret_meaning'), findsNothing);
      expect(find.text('wrong_answer'), findsOneWidget);
    },
  );
}
