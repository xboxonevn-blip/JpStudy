import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/widgets/cloze_test_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// Template: 彼は音楽を聴き{blank}勉強します。
// Correct option: 'ながら'
const _kTemplate = '彼は音楽を聴き{blank}勉強します。';
const _kOptions = ['てもいい', 'ながら', 'てから'];
const _kCorrect = 'ながら';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// ClozeTestWidget has an Expanded(ListView) in its root Column — it needs a
// bounded-height parent.  Scaffold.body provides that; a large physicalSize
// ensures GrammarPromptCard + GrammarPracticePanel + the check button all fit
// on screen, even after option selection adds the preview text (~30 px).
Widget _buildWidget({
  AppLanguage language = AppLanguage.en,
  String sentenceTemplate = _kTemplate,
  List<String> options = _kOptions,
  String correctOption = _kCorrect,
  void Function(bool, String)? onCheck,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ClozeTestWidget(
          language: language,
          sentenceTemplate: sentenceTemplate,
          options: options,
          correctOption: correctOption,
          onCheck: onCheck ?? (_, __) {},
        ),
      ),
    ),
  );
}

// Give the widget plenty of vertical room so the check button stays on-screen
// even after the option-selection preview text is added to GrammarPracticePanel.
void _largeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets('renders Fill the blank eyebrow label', (tester) async {
    _largeViewport(tester);
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    expect(find.text('Fill the blank'), findsOneWidget);
  });

  testWidgets('renders all option labels', (tester) async {
    _largeViewport(tester);
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    expect(find.text('てもいい'), findsOneWidget);
    expect(find.text('ながら'), findsOneWidget);
    expect(find.text('てから'), findsOneWidget);
  });

  testWidgets('Check button is disabled before any option is selected',
      (tester) async {
    _largeViewport(tester);
    bool called = false;
    await tester.pumpWidget(
      _buildWidget(onCheck: (_, __) => called = true),
    );
    await _pump(tester);

    // Tap the key-identified check button; disabled buttons ignore taps.
    await tester.tap(
      find.byKey(const ValueKey('grammar_cloze_check')),
      warnIfMissed: false,
    );
    await _pump(tester);

    expect(called, isFalse);
  });

  testWidgets('tapping an option shows selected preview text', (tester) async {
    _largeViewport(tester);
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    // Tap the option at index 1 ('ながら') via its ValueKey
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_option_1')));
    await _pump(tester);

    // _selectedPreview(en, 'ながら') = 'Selected: ながら'
    expect(find.text('Selected: ながら'), findsOneWidget);
  });

  testWidgets('correct option fires onCheck with isCorrect=true', (tester) async {
    _largeViewport(tester);
    bool? result;
    String? chosen;
    await tester.pumpWidget(
      _buildWidget(onCheck: (isCorrect, selected) {
        result = isCorrect;
        chosen = selected;
      }),
    );
    await _pump(tester);

    // Select the correct option ('ながら' at index 1)
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_option_1')));
    await _pump(tester);

    // Tap Check Answer
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_check')));
    await _pump(tester);

    expect(result, isTrue);
    expect(chosen, equals('ながら'));
  });

  testWidgets('wrong option fires onCheck with isCorrect=false', (tester) async {
    _largeViewport(tester);
    bool? result;
    await tester.pumpWidget(
      _buildWidget(onCheck: (isCorrect, _) => result = isCorrect),
    );
    await _pump(tester);

    // Select wrong option ('てもいい' at index 0)
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_option_0')));
    await _pump(tester);

    // Tap Check Answer
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_check')));
    await _pump(tester);

    expect(result, isFalse);
  });

  testWidgets('after checking, options are locked (re-tapping does nothing)',
      (tester) async {
    _largeViewport(tester);
    int checkCount = 0;
    await tester.pumpWidget(
      _buildWidget(onCheck: (_, __) => checkCount++),
    );
    await _pump(tester);

    // Select and check once
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_option_0')));
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_check')));
    await _pump(tester);

    expect(checkCount, equals(1));

    // Try tapping another option — widget should ignore it since _isCorrect != null
    await tester.tap(find.byKey(const ValueKey('grammar_cloze_option_1')));
    await _pump(tester);
    // Check button is also now disabled; tapping it should not trigger callback again
    await tester.tap(
      find.byKey(const ValueKey('grammar_cloze_check')),
      warnIfMissed: false,
    );
    await _pump(tester);

    expect(checkCount, equals(1));
  });

  testWidgets('VI locale shows Vietnamese check label', (tester) async {
    _largeViewport(tester);
    await tester.pumpWidget(_buildWidget(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Kiểm Tra Đáp Án'), findsOneWidget);
  });

  testWidgets('JA locale shows Japanese prompt eyebrow', (tester) async {
    _largeViewport(tester);
    await tester.pumpWidget(_buildWidget(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('空欄に合う形を選んでください'), findsOneWidget);
  });
}
