import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/design_lab/design_lab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({AppLanguage language = AppLanguage.en}) {
  return ProviderScope(
    overrides: [appLanguageProvider.overrideWith((ref) => language)],
    child: const MaterialApp(home: DesignLabScreen()),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders app bar and hero card', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // AppBar title
    expect(find.text('Design Lab'), findsWidgets);
    // Hero card headline
    expect(find.text('Live UI/UX Workflow'), findsOneWidget);
  });

  testWidgets('stage switcher shows all three stages', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Visual'), findsOneWidget);
    expect(find.text('Validate'), findsOneWidget);
  });

  testWidgets('default stage renders Wireframe Snapshot panel', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Discover (default) stage shows wireframe panel title
    expect(find.text('Wireframe Snapshot'), findsOneWidget);
    expect(
      find.text('Block-level layout before visual polish.'),
      findsOneWidget,
    );
  });

  testWidgets('switching to Visual stage shows Visual Direction panel',
      (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Visual'));
    await _pump(tester);

    expect(find.text('Visual Direction'), findsOneWidget);
    expect(find.text('Primary'), findsOneWidget); // colour swatch label
  });

  testWidgets('switching to Validate stage shows validation chips',
      (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Validate'));
    await _pump(tester);

    expect(find.text('Validation Notes'), findsOneWidget);
    expect(find.text('Tap targets >= 44px'), findsOneWidget);
    expect(find.text('Text contrast pass'), findsOneWidget);
  });

  testWidgets('process checklist renders task items', (tester) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Panel title
    expect(find.text('Process Checklist'), findsOneWidget);
    // Task 1 (pre-checked) and task 3 (unchecked)
    expect(
      find.text('Wireframe approved in team review'),
      findsOneWidget,
    );
    expect(
      find.text('Prototype tested on desktop + mobile'),
      findsOneWidget,
    );
  });

  testWidgets('unchecked task can be toggled on', (tester) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // Task 3 starts unchecked (not in _checkedTaskIds initial set {1, 2})
    final taskLabel = find.text('Prototype tested on desktop + mobile');
    expect(taskLabel, findsOneWidget);

    final checkbox = find.ancestor(
      of: taskLabel,
      matching: find.byType(CheckboxListTile),
    );
    final tile = tester.widget<CheckboxListTile>(checkbox);
    expect(tile.value, isFalse);

    await tester.tap(checkbox);
    await _pump(tester);

    final updatedTile = tester.widget<CheckboxListTile>(
      find.ancestor(
        of: find.text('Prototype tested on desktop + mobile'),
        matching: find.byType(CheckboxListTile),
      ),
    );
    expect(updatedTile.value, isTrue);
  });

  testWidgets('VI locale shows Vietnamese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Phòng thí nghiệm thiết kế'), findsWidgets);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('デザインラボ'), findsWidgets);
  });
}
