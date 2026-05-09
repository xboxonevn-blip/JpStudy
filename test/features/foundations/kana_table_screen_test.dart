import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/features/foundations/models/kana_entry.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'renders kana tabs and opens a cell detail sheet',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);
      final chart = KanaChart(
        hiragana: const KanaScriptChart(
          label: 'Hiragana',
          entries: [
            KanaEntry(
              order: 1,
              kana: '\u3042',
              romaji: 'a',
              row: 'a',
              column: 'a',
            ),
            KanaEntry(
              order: 2,
              kana: '\u3044',
              romaji: 'i',
              row: 'a',
              column: 'i',
            ),
            KanaEntry(
              order: 3,
              kana: '\u3046',
              romaji: 'u',
              row: 'a',
              column: 'u',
            ),
            KanaEntry(
              order: 4,
              kana: '\u3048',
              romaji: 'e',
              row: 'a',
              column: 'e',
            ),
            KanaEntry(
              order: 5,
              kana: '\u304a',
              romaji: 'o',
              row: 'a',
              column: 'o',
            ),
          ],
          compounds: [
            KanaCompound(
              order: 1,
              kana: '\u304d\u3083',
              romaji: 'kya',
              row: 'k',
              column: 'ya',
            ),
          ],
        ),
        katakana: const KanaScriptChart(
          label: 'Katakana',
          entries: [],
          compounds: [],
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            appLanguageProvider.overrideWith((ref) => AppLanguage.vi),
            kanaChartProvider.overrideWith((ref) async => chart),
            foundationsProgressProvider.overrideWith(
              () => _StaticFoundationsProgressController(),
            ),
          ],
          child: const MaterialApp(
            home: KanaTableScreen(
              script: KanaScript.hiragana,
              initialView: KanaView.base,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        find.byKey(const ValueKey('kana_cell_base_\u3042')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('kana_base_count_5')), findsOneWidget);

      await tester.tap(find.byType(Tab).last);
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        find.byKey(const ValueKey('kana_cell_compound_\u304d\u3083')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('kana_compound_count_1')),
        findsOneWidget,
      );

      await tester.tap(find.byType(Tab).first);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.tap(find.byKey(const ValueKey('kana_cell_base_\u3042')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const ValueKey('kana_mark_\u3042')), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );
}

class _StaticFoundationsProgressController
    extends FoundationsProgressController {
  @override
  FoundationsProgress build() => const FoundationsProgress(studied: {});
}
