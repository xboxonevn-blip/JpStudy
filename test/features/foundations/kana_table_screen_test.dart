import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders kana tabs and marks a cell studied', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.vi)],
        child: const MaterialApp(
          home: KanaTableScreen(
            key: ValueKey('kana_tabs_screen'),
            script: KanaScript.hiragana,
            initialView: KanaView.base,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const ValueKey('kana_cell_base_あ')), findsOneWidget);
    expect(find.byKey(const ValueKey('kana_cell_base_ん')), findsOneWidget);
    expect(find.byKey(const ValueKey('kana_base_grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('kana_base_count_71')), findsOneWidget);

    await tester.tap(find.text('Âm ghép'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('kana_cell_compound_きゃ')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('kana_compound_count_33')),
      findsOneWidget,
    );

    await tester.tap(find.text('Cơ bản'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byKey(const ValueKey('kana_cell_base_あ')));
    await tester.pump(const Duration(seconds: 1));
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -260),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(find.text('Tôi đã thuộc'));
    await tester.pump(const Duration(milliseconds: 150));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(foundationsStudiedPrefsKey), contains('あ'));
  });
}
