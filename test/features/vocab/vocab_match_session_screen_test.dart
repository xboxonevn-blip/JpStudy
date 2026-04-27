import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/vocab/models/vocab_match_session_args.dart';
import 'package:jpstudy/features/vocab/screens/vocab_match_session_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures — three items with unique terms and meanings
// ---------------------------------------------------------------------------

const _items = [
  VocabItem(id: 1, term: '猫', reading: 'ねこ', meaning: 'cat', level: 'N5'),
  VocabItem(id: 2, term: '犬', reading: 'いぬ', meaning: 'dog', level: 'N5'),
  VocabItem(id: 3, term: '魚', reading: 'さかな', meaning: 'fish', level: 'N5'),
];

const _kTitle = 'Chapter 1';

const _kArgs = VocabMatchSessionArgs(items: _items, title: _kTitle);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({AppLanguage language = AppLanguage.en}) {
  return ProviderScope(
    overrides: [appLanguageProvider.overrideWith((ref) => language)],
    child: MaterialApp(home: VocabMatchSessionScreen(args: _kArgs)),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('intro screen renders session title and start button',
      (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // AppBar title: "Match: Chapter 1"
    expect(find.textContaining(_kTitle), findsWidgets);
    expect(find.text('Match the term with its meaning'), findsOneWidget);
    expect(find.text('Start match'), findsOneWidget);
    // Shows item count
    expect(find.textContaining('${_items.length} terms'), findsOneWidget);
  });

  testWidgets('"Start match" transitions to board with timer and grid',
      (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Start match'));
    await _pump(tester);

    // Timer starts at 0
    expect(find.text('Time: 0s'), findsOneWidget);
    // Grid renders (each card shows term or meaning text)
    expect(find.text('猫'), findsOneWidget);
    expect(find.text('cat'), findsOneWidget);
  });

  testWidgets('tapping a card does not immediately complete the game',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Start match'));
    await _pump(tester);

    // Board is showing, start button gone
    expect(find.text('Start match'), findsNothing);
    // Timer label is shown (any elapsed value is valid)
    expect(find.textContaining('Time:'), findsOneWidget);

    // Single card tap should not trigger a match (needs two taps for a pair)
    await tester.tap(find.text('猫'), warnIfMissed: false);
    await _pump(tester);

    // Game is still ongoing — summary not shown
    expect(find.text('Match round completed'), findsNothing);
    expect(find.textContaining('Time:'), findsOneWidget);
  });

  testWidgets('all pairs matched shows summary and restart button',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Start match'));
    await _pump(tester);

    // Match every pair by finding term + its meaning
    for (final item in _items) {
      await tester.tap(find.text(item.term), warnIfMissed: false);
      await _pump(tester);
      await tester.tap(find.text(item.meaning), warnIfMissed: false);
      await _pump(tester);
    }

    // Summary screen should appear
    expect(find.text('Match round completed'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('"Restart" from summary transitions back to board', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.tap(find.text('Start match'));
    await _pump(tester);

    for (final item in _items) {
      await tester.tap(find.text(item.term), warnIfMissed: false);
      await _pump(tester);
      await tester.tap(find.text(item.meaning), warnIfMissed: false);
      await _pump(tester);
    }

    expect(find.text('Match round completed'), findsOneWidget);

    await tester.tap(find.text('Restart'));
    await _pump(tester);

    // Back to board with fresh timer
    expect(find.text('Time: 0s'), findsOneWidget);
    expect(find.text('Match round completed'), findsNothing);
  });

  testWidgets('VI locale shows Vietnamese intro title and start label',
      (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Ghép đúng term và nghĩa'), findsOneWidget);
    expect(find.text('Bắt đầu match'), findsOneWidget);
  });
}
