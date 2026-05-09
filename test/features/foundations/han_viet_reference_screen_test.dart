import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/screens/han_viet_reference_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders, expands, and filters han viet rules', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en)],
        child: const MaterialApp(
          home: HanVietReferenceScreen(key: ValueKey('han_viet_reference')),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.byKey(const ValueKey('han_viet_rule_list_count_32')),
      findsOneWidget,
    );
    expect(find.byType(ExpansionTile), findsWidgets);

    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Kanji'), findsOneWidget);
    expect(find.text('Onyomi'), findsOneWidget);
    expect(find.text('Onyomi'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'final -t');
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.byKey(const ValueKey('han_viet_rule_list_count_32')),
      findsNothing,
    );
    expect(find.byType(ExpansionTile), findsWidgets);
  });
}
