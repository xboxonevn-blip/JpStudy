import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/widgets/sentence_builder_widget.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// Correct order: '食べても' + 'いいですか' = '食べてもいいですか'
const _kCorrect = '食べてもいいですか';
const _kPrompt = 'Use てもいい to express permission.';
const _kShuffled = ['いいですか', '食べても']; // intentionally wrong order

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildWidget({
  AppLanguage language = AppLanguage.en,
  String prompt = _kPrompt,
  String correctSentence = _kCorrect,
  List<String> shuffledWords = _kShuffled,
  void Function(bool, String)? onCheck,
  VoidCallback? onReset,
  String? feedback,
  String? explanation,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SentenceBuilderWidget(
        language: language,
        prompt: prompt,
        correctSentence: correctSentence,
        shuffledWords: shuffledWords,
        onCheck: onCheck ?? (_, _) {},
        onReset: onReset ?? () {},
        feedback: feedback,
        explanation: explanation,
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  testWidgets('renders prompt and available word chunks', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    expect(find.text(_kPrompt), findsOneWidget);
    // Both shuffled words appear in the available chunks area
    expect(find.text('食べても'), findsOneWidget);
    expect(find.text('いいですか'), findsOneWidget);
    // Placeholder shown when selection is empty
    expect(find.text('Build the answer here.'), findsOneWidget);
  });

  testWidgets('Check button is disabled when no words are selected',
      (tester) async {
    bool checkCalled = false;
    await tester.pumpWidget(
      _buildWidget(onCheck: (_, _) => checkCalled = true),
    );
    await _pump(tester);

    await tester.tap(find.text('Check'), warnIfMissed: false);
    await _pump(tester);

    // Disabled button should not trigger the callback
    expect(checkCalled, isFalse);
  });

  testWidgets('tapping a word chip moves it to the selection area',
      (tester) async {
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    await tester.tap(find.text('食べても'));
    await _pump(tester);

    // Word now appears in the selection tray (placeholder gone)
    expect(find.text('Build the answer here.'), findsNothing);
    expect(find.text('食べても'), findsOneWidget); // selected chip
  });

  testWidgets('correct word order triggers onCheck with isCorrect=true',
      (tester) async {
    bool? result;
    await tester.pumpWidget(
      _buildWidget(onCheck: (isCorrect, _) => result = isCorrect),
    );
    await _pump(tester);

    // Tap in correct order: 食べても → いいですか
    await tester.tap(find.text('食べても'));
    await _pump(tester);
    await tester.tap(find.text('いいですか'));
    await _pump(tester);

    await tester.tap(find.text('Check'));
    await _pump(tester);

    expect(result, isTrue);
    expect(
      find.text('Nice. The sentence order is correct.'),
      findsOneWidget,
    );
  });

  testWidgets('wrong word order triggers onCheck with isCorrect=false',
      (tester) async {
    bool? result;
    await tester.pumpWidget(
      _buildWidget(onCheck: (isCorrect, _) => result = isCorrect),
    );
    await _pump(tester);

    // Tap in wrong order: いいですか → 食べても
    await tester.tap(find.text('いいですか'));
    await _pump(tester);
    await tester.tap(find.text('食べても'));
    await _pump(tester);

    await tester.tap(find.text('Check'));
    await _pump(tester);

    expect(result, isFalse);
    expect(
      find.text('Order is still off. Review the chunks once more.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping a selected word removes it back to available chunks',
      (tester) async {
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    // Select '食べても'
    await tester.tap(find.text('食べても'));
    await _pump(tester);

    expect(find.text('Build the answer here.'), findsNothing);

    // Deselect it by tapping again from the selection tray
    await tester.tap(find.text('食べても'));
    await _pump(tester);

    // Placeholder returns once selection is empty
    expect(find.text('Build the answer here.'), findsOneWidget);
  });

  testWidgets('Reset clears selection and calls onReset callback',
      (tester) async {
    bool resetCalled = false;
    await tester.pumpWidget(
      _buildWidget(onReset: () => resetCalled = true),
    );
    await _pump(tester);

    await tester.tap(find.text('食べても'));
    await _pump(tester);

    expect(find.text('Build the answer here.'), findsNothing);

    await tester.tap(find.text('Reset'));
    await _pump(tester);

    // Selection cleared — placeholder returns
    expect(find.text('Build the answer here.'), findsOneWidget);
    expect(resetCalled, isTrue);
  });

  testWidgets('VI locale shows Vietnamese labels', (tester) async {
    await tester.pumpWidget(_buildWidget(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Sắp xếp thành câu hoàn chỉnh'), findsOneWidget);
    expect(find.text('Ghép câu trả lời ở đây.'), findsOneWidget);
    expect(find.text('Mảnh câu có sẵn'), findsOneWidget);
    expect(find.text('Kiểm tra'), findsOneWidget); // Check button
    expect(find.text('Làm lại'), findsOneWidget);  // Reset button
  });
}
