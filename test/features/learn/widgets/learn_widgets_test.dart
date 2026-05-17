import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/widgets/fill_blank_widget.dart';
import 'package:jpstudy/features/learn/widgets/multiple_choice_widget.dart';
import 'package:jpstudy/features/learn/widgets/true_false_widget.dart';

// ---------------------------------------------------------------------------
// Shared Fixtures
// ---------------------------------------------------------------------------

const _kVocabItem = VocabItem(
  id: 1,
  term: '食べる',
  reading: 'たべる',
  meaning: 'ăn',
  meaningEn: 'to eat',
  level: 'N5',
);

const _kMcQuestion = Question(
  id: 'mc-1',
  type: QuestionType.multipleChoice,
  targetItem: _kVocabItem,
  questionText: 'What does 食べる mean?',
  correctAnswer: 'to eat',
  options: ['to drink', 'to eat', 'to sleep'],
);

const _kTfQuestion = Question(
  id: 'tf-1',
  type: QuestionType.trueFalse,
  targetItem: _kVocabItem,
  questionText: '食べる means "to eat."',
  correctAnswer: 'true',
  isStatementTrue: true,
);

const _kFillQuestion = Question(
  id: 'fill-1',
  type: QuestionType.fillBlank,
  targetItem: _kVocabItem,
  questionText: 'Write the meaning of 食べる.',
  correctAnswer: 'to eat',
  hint: 'Think about what you do with food.',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 420,
            height: 760,
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

// The hint card appended by FillBlankWidget after Show Hint is tapped adds
// ~80 px to the Column height; use a larger viewport so it fits on-screen.
void _largeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ---------------------------------------------------------------------------
// MultipleChoiceWidget Tests
// ---------------------------------------------------------------------------

void main() {
  group('MultipleChoiceWidget', () {
    testWidgets('renders prompt and all option tiles', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          MultipleChoiceWidget(
            question: _kMcQuestion,
            language: AppLanguage.en,
            onSelect: (s) {},
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('Multiple Choice'), findsOneWidget);
      expect(find.text('食べる'), findsOneWidget);
      expect(find.text('to drink'), findsOneWidget);
      expect(find.text('to eat'), findsOneWidget);
      expect(find.text('to sleep'), findsOneWidget);
    });

    testWidgets('tapping an option selects it before explicit confirm', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        _buildHarness(
          MultipleChoiceWidget(
            question: _kMcQuestion,
            language: AppLanguage.en,
            onSelect: (s) => selected = s,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('to eat'));
      await _pump(tester);

      expect(selected, isNull);
      expect(find.byKey(const ValueKey('learn_mc_confirm')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('learn_mc_confirm')));
      await _pump(tester);

      expect(selected, equals('to eat'));
    });

    testWidgets('showResult=true disables option taps', (tester) async {
      String? selected;
      await tester.pumpWidget(
        _buildHarness(
          MultipleChoiceWidget(
            question: _kMcQuestion,
            language: AppLanguage.en,
            selectedAnswer: 'to drink',
            showResult: true,
            onSelect: (s) => selected = s,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('to eat'));
      await _pump(tester);

      // Tapping should be a no-op when showResult is true
      expect(selected, isNull);
    });

    testWidgets('VI locale shows Vietnamese label', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          MultipleChoiceWidget(
            question: _kMcQuestion,
            language: AppLanguage.vi,
            onSelect: (s) {},
          ),
        ),
      );
      await _pump(tester);

      // VI multipleChoiceLabel
      expect(find.text('Trắc nghiệm'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // TrueFalseWidget Tests
  // -------------------------------------------------------------------------

  group('TrueFalseWidget', () {
    testWidgets('renders True/False label and both choice tiles', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          TrueFalseWidget(
            question: _kTfQuestion,
            language: AppLanguage.en,
            onSelect: (b) {},
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('True/False'), findsOneWidget);
      expect(find.text('TRUE'), findsOneWidget);
      expect(find.text('FALSE'), findsOneWidget);
    });

    testWidgets('tapping TRUE fires onSelect(true)', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _buildHarness(
          TrueFalseWidget(
            question: _kTfQuestion,
            language: AppLanguage.en,
            onSelect: (b) => result = b,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('TRUE'));
      await _pump(tester);

      expect(result, isTrue);
    });

    testWidgets('tapping FALSE fires onSelect(false)', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _buildHarness(
          TrueFalseWidget(
            question: _kTfQuestion,
            language: AppLanguage.en,
            onSelect: (b) => result = b,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('FALSE'));
      await _pump(tester);

      expect(result, isFalse);
    });

    testWidgets('showResult=true disables both tiles', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _buildHarness(
          TrueFalseWidget(
            question: _kTfQuestion,
            selectedAnswer: true,
            showResult: true,
            language: AppLanguage.en,
            onSelect: (b) => result = b,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('FALSE'));
      await _pump(tester);

      // showResult disables onTap — callback should not be called
      expect(result, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // FillBlankWidget Tests
  // -------------------------------------------------------------------------

  group('FillBlankWidget', () {
    testWidgets('renders Fill in the Blank label and Your Answer section', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          FillBlankWidget(
            question: _kFillQuestion,
            language: AppLanguage.en,
            onSubmit: (s) {},
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('Fill in the Blank'), findsOneWidget);
      expect(find.text('Your Answer:'), findsOneWidget);
      expect(find.text('Check Answer'), findsOneWidget);
    });

    testWidgets('Check Answer button calls onSubmit with typed text', (
      tester,
    ) async {
      String? submitted;
      await tester.pumpWidget(
        _buildHarness(
          FillBlankWidget(
            question: _kFillQuestion,
            language: AppLanguage.en,
            onSubmit: (s) => submitted = s,
          ),
        ),
      );
      await _pump(tester);

      await tester.enterText(find.byType(TextField), 'to eat');
      await _pump(tester);
      await tester.tap(find.text('Check Answer'));
      await _pump(tester);

      expect(submitted, equals('to eat'));
    });

    testWidgets('hint button appears when hint is provided', (tester) async {
      await tester.pumpWidget(
        _buildHarness(
          FillBlankWidget(
            question:
                _kFillQuestion, // hint = 'Think about what you do with food.'
            language: AppLanguage.en,
            onSubmit: (s) {},
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('Show Hint'), findsOneWidget);
    });

    testWidgets('tapping Show Hint reveals the hint text', (tester) async {
      _largeViewport(tester);
      await tester.pumpWidget(
        _buildHarness(
          FillBlankWidget(
            question: _kFillQuestion,
            language: AppLanguage.en,
            onSubmit: (s) {},
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('Show Hint'));
      await _pump(tester);

      expect(find.text('Think about what you do with food.'), findsOneWidget);
    });

    testWidgets('showResult=true with wrong answer shows Correct Answer card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          FillBlankWidget(
            question: _kFillQuestion,
            showResult: true,
            isCorrect: false,
            revealCorrectAnswer: true,
            language: AppLanguage.en,
            onSubmit: (s) {},
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('Correct Answer:'), findsOneWidget);
      expect(find.text('to eat'), findsOneWidget);
      // Check Answer button is hidden in result state
      expect(find.text('Check Answer'), findsNothing);
    });
  });
}
