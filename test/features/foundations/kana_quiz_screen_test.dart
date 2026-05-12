import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/screens/kana_quiz_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  testWidgets('kana quiz answers ten questions and writes SRS rows', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final pool = List.generate(
      12,
      (i) => KanaQuizItem(
        kana: 'か$i',
        romaji: 'ka$i',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(await prefs()),
        ],
        child: MaterialApp(home: KanaQuizScreen(poolOverride: pool)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('kana_quiz_counter')), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byType(FilledButton).first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 250));
      final good = find.text('Good');
      if (good.evaluate().isNotEmpty) {
        expect(find.text('Easy'), findsOneWidget);
        await tester.tap(good);
      } else {
        await tester.tap(
          find.byKey(const ValueKey('kana_auto_again_continue')),
        );
      }
      await tester.pump(const Duration(milliseconds: 350));
    }

    expect(find.byKey(const ValueKey('kana_quiz_summary')), findsOneWidget);
    expect(await db.kanaSrsDao.studiedCount(), greaterThan(0));
  });

  testWidgets('kana quiz does not duplicate the correct-answer colon', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    const pool = [
      KanaQuizItem(
        kana: 'a',
        romaji: 'correct',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'b',
        romaji: 'wrong',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'c',
        romaji: 'neutral1',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'd',
        romaji: 'neutral2',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(
            await prefs({'app.locale': 'vi'}),
          ),
        ],
        child: MaterialApp(
          home: KanaQuizScreen(
            poolOverride: pool,
            questionBuilderOverride: (item, pool, kanaToRomaji, random) =>
                KanaQuizQuestion(
                  item: pool[0],
                  prompt: 'a',
                  correctAnswer: 'correct',
                  choices: ['wrong', 'correct', 'neutral1', 'neutral2'],
                  kanaToRomaji: true,
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('kana_choice_wrong')));
    await tester.pump();

    final result = tester.widget<Text>(
      find.byKey(const ValueKey('kana_quiz_result')),
    );
    expect(result.data, contains('correct'));
    expect(result.data, isNot(contains('::')));
  });

  testWidgets('kana quiz highlights correct and wrong choices after answer', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    const pool = [
      KanaQuizItem(
        kana: 'a',
        romaji: 'correct',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'b',
        romaji: 'wrong',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'c',
        romaji: 'neutral1',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'd',
        romaji: 'neutral2',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(await prefs()),
        ],
        child: MaterialApp(
          home: KanaQuizScreen(
            poolOverride: pool,
            questionBuilderOverride: (item, pool, kanaToRomaji, random) =>
                KanaQuizQuestion(
                  item: pool[0],
                  prompt: 'a',
                  correctAnswer: 'correct',
                  choices: ['correct', 'wrong', 'neutral1', 'neutral2'],
                  kanaToRomaji: true,
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('kana_choice_wrong')));
    await tester.pump();

    final correctButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('kana_choice_correct')),
    );
    final wrongButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('kana_choice_wrong')),
    );

    expect(
      correctButton.style?.backgroundColor?.resolve({}),
      Colors.green.shade100,
    );
    expect(
      correctButton.style?.side?.resolve({})?.color,
      Colors.green.shade400,
    );
    expect(
      wrongButton.style?.backgroundColor?.resolve({}),
      Colors.red.shade100,
    );
    expect(wrongButton.style?.side?.resolve({})?.color, Colors.red.shade400);
    expect(
      find.byKey(const ValueKey('kana_auto_again_continue')),
      findsOneWidget,
    );
    expect(find.text('Again'), findsNothing);
    expect(find.text('Good'), findsNothing);
    expect(find.text('Easy'), findsNothing);
  });

  testWidgets('kana quiz shows only Good and Easy after correct answer', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    const pool = [
      KanaQuizItem(
        kana: 'a',
        romaji: 'correct',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'b',
        romaji: 'wrong',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'c',
        romaji: 'neutral1',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
      KanaQuizItem(
        kana: 'd',
        romaji: 'neutral2',
        kanaScript: KanaScript.hiragana,
        view: KanaView.base,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(await prefs()),
        ],
        child: MaterialApp(
          home: KanaQuizScreen(
            poolOverride: pool,
            questionBuilderOverride: (item, pool, kanaToRomaji, random) =>
                KanaQuizQuestion(
                  item: pool[0],
                  prompt: 'a',
                  correctAnswer: 'correct',
                  choices: ['correct', 'wrong', 'neutral1', 'neutral2'],
                  kanaToRomaji: true,
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('kana_choice_correct')));
    await tester.pump();

    expect(find.text('Again'), findsNothing);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('kana_auto_again_continue')),
      findsNothing,
    );
  });
}
