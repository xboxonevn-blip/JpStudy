import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/features/kanji_reading/models/kanji_reading_question.dart';
import 'package:jpstudy/features/kanji_reading/screens/kanji_reading_quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

KanjiReadingQuestion _question() => KanjiReadingQuestion(
  target: const KanjiItem(
    id: 1,
    lessonId: 1,
    character: '火',
    strokeCount: 4,
    onyomi: 'カ',
    kunyomi: 'ひ',
    meaning: 'lửa',
    meaningEn: 'fire',
    meaningJa: '火のこと',
    examples: [],
    jlptLevel: 'N5',
  ),
  options: const ['カ', 'スイ', 'モク', 'キン'],
  correctIndex: 0,
  mode: KanjiQuizMode.kanjiToReading,
);

Widget buildScreen(
  List<KanjiReadingQuestion> questions, {
  AppLanguage language = AppLanguage.en,
}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(language),
    ),
  ],
  child: MaterialApp(home: KanjiReadingQuizScreen(questions: questions)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows progress in app bar title', (tester) async {
    await tester.pumpWidget(buildScreen([_question()]));
    await tester.pump();
    expect(find.text('1 / 1'), findsOneWidget);
  });

  testWidgets('shows kanji prompt and four options', (tester) async {
    await tester.pumpWidget(buildScreen([_question()]));
    await tester.pump();
    expect(find.text('火'), findsOneWidget);
    expect(find.text('fire'), findsOneWidget);
    expect(find.text('カ'), findsOneWidget);
  });

  testWidgets('JA locale shows Japanese meaning when available', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen([_question()], language: AppLanguage.ja),
    );
    await tester.pump();

    expect(find.text('火のこと'), findsOneWidget);
    expect(find.text('fire'), findsNothing);
    expect(find.text('lửa'), findsNothing);
  });

  testWidgets('shows progress indicator', (tester) async {
    await tester.pumpWidget(buildScreen([_question()]));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
