import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/screens/kana_quiz_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
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
      expect(find.text('Again'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      await tester.tap(find.text('Good'));
      await tester.pump(const Duration(milliseconds: 350));
    }

    expect(find.byKey(const ValueKey('kana_quiz_summary')), findsOneWidget);
    expect(await db.kanaSrsDao.studiedCount(), greaterThan(0));
  });
}
