import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/premium/premium_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildScreen({AppLanguage language = AppLanguage.en}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
    ],
    child: const MaterialApp(home: PremiumScreen()),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders app bar title and hero card', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // AppBar title is 'Upgrade' in EN
    expect(find.text('Upgrade'), findsWidgets);
    expect(find.text('Compare plans'), findsOneWidget);
    expect(find.text('JP Study Pro'), findsOneWidget);
  });

  testWidgets('plan selector chips are rendered', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Starter'), findsWidgets); // chip + plan card
    expect(
      find.text('Pro'),
      findsWidgets,
    ); // chip + plan card (default selected)
    expect(find.text('Coach'), findsOneWidget);
  });

  testWidgets('tapping a plan chip selects it', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Default selected is Pro (index 1). Tap Starter (index 0).
    await tester.tap(find.text('Starter'));
    await _pump(tester);

    // After selecting Starter, "Starter" plan name should appear in the plan card
    expect(find.text('Starter'), findsWidgets);
  });

  testWidgets('"Upgrade now" tap shows checkout snackbar', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Tap the first "Upgrade now" button (hero card primary action)
    await tester.tap(find.text('Upgrade now').first);
    await _pump(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('checkout'), findsOneWidget);
  });

  testWidgets('"Compare plans" tap does not show a snackbar', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Compare plans'));
    await _pump(tester);

    // Scroll attempt should not produce a snackbar
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('compare matrix section is rendered', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.scrollUntilVisible(
      find.text('Free vs selected plan'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await _pump(tester);

    expect(find.text('Free vs selected plan'), findsOneWidget);
  });

  testWidgets('feature list is rendered with at least one item', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.scrollUntilVisible(
      find.text('Full reading library'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _pump(tester);

    expect(find.text('Full reading library'), findsOneWidget);
  });

  testWidgets('VI locale shows Vietnamese title and upgrade label', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    // AppBar title is 'Nâng cấp' in VI
    expect(find.text('Nâng cấp'), findsWidgets);
    expect(find.text('So sánh gói'), findsOneWidget); // compare plans in VI
  });

  testWidgets('JA locale shows Japanese upgrade label', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('アップグレード'), findsOneWidget);
  });
}
