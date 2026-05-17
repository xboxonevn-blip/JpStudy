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

VocabItem _item(int id, String term, String meaning) => VocabItem(
  id: id,
  term: term,
  reading: term,
  meaning: meaning,
  meaningEn: meaning,
  level: 'N5',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpMobileTestScreen(
    WidgetTester tester,
    QuestionType questionType, {
    String sessionKey = 'test_mobile_layout_case',
  }) async {
    tester.view.physicalSize = const Size(390, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: TestScreen(
            items: [
              _item(1, '水', 'water'),
              _item(2, '火', 'fire'),
              _item(3, '木', 'tree'),
              _item(4, '山', 'mountain'),
            ],
            lessonId: 1,
            lessonTitle: 'Mobile Layout Test',
            config: TestConfig(
              questionCount: 1,
              enabledTypes: [questionType],
              shuffleQuestions: false,
              showCorrectAfterWrong: false,
              adaptiveTesting: false,
            ),
            sessionKey: sessionKey,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets(
    'mobile test question keeps header readable and MC confirm visible',
    (tester) async {
      await pumpMobileTestScreen(tester, QuestionType.multipleChoice);

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.text(AppLanguage.en.testProgressLabel(1, 1))).width,
        greaterThan(80),
      );
      expect(
        tester.getSize(find.text(AppLanguage.en.multipleChoiceLabel)).width,
        greaterThan(120),
      );

      final confirm = find.text(AppLanguage.en.checkAnswerLabel);
      expect(confirm, findsOneWidget);
      final confirmBottom = tester.getBottomLeft(confirm).dy;
      expect(confirmBottom, lessThanOrEqualTo(540));
    },
  );

  testWidgets('mobile test true-false keeps both choices visible', (
    tester,
  ) async {
    await pumpMobileTestScreen(
      tester,
      QuestionType.trueFalse,
      sessionKey: 'test_mobile_true_false_layout_case',
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.text(AppLanguage.en.testProgressLabel(1, 1))).width,
      greaterThan(80),
    );

    final trueChoice = find.text(AppLanguage.en.trueLabel);
    final falseChoice = find.text(AppLanguage.en.falseLabel);
    expect(trueChoice, findsOneWidget);
    expect(falseChoice, findsOneWidget);
    expect(tester.getBottomLeft(falseChoice).dy, lessThanOrEqualTo(540));
  });
}
