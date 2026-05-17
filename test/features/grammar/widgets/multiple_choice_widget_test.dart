import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';
import 'package:jpstudy/features/grammar/widgets/grammar_practice_surfaces.dart';
import 'package:jpstudy/features/grammar/widgets/multiple_choice_widget.dart';

void main() {
  Widget buildHarness(Widget child) {
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

  testWidgets('error correction question uses repair-specific prompt layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        MultipleChoiceWidget(
          language: AppLanguage.en,
          questionType: GrammarQuestionType.errorCorrection,
          question:
              'This sentence has a grammar mistake:\n昨日は学校に行くでした。\nWhich pattern fixes it?',
          options: const ['Vたことがある', 'Vます', 'Vました'],
          correctAnswer: 'Vました',
          onAnswer: (isCorrect, selected) {},
        ),
      ),
    );

    expect(find.text('Grammar repair'), findsOneWidget);
    expect(find.text('Repair'), findsOneWidget);
    expect(find.text('Sentence to repair'), findsOneWidget);
    expect(
      find.text(
        'Focus on the wrong sentence first, then choose the pattern that repairs it.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Which pattern fixes it?', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('昨日は学校に行くでした。', findRichText: true), findsOneWidget);
    expect(find.byType(GrammarPracticePanel), findsNWidgets(2));
  });

  testWidgets('error reason question uses reason-specific coaching copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        MultipleChoiceWidget(
          language: AppLanguage.en,
          questionType: GrammarQuestionType.errorReason,
          question: 'Why is this sentence wrong?\n昨日は学校に行くでした。',
          options: const [
            'The tense ending does not match the sentence.',
            'A particle is missing.',
            'The word order is impossible.',
          ],
          correctAnswer: 'The tense ending does not match the sentence.',
          onAnswer: (isCorrect, selected) {},
        ),
      ),
    );

    expect(find.text('Find the reason'), findsOneWidget);
    expect(find.text('Reason'), findsOneWidget);
    expect(find.text('Sentence to inspect'), findsOneWidget);
    expect(
      find.text(
        'Read the sentence as a learner would, then choose the main grammar reason it fails.',
      ),
      findsOneWidget,
    );
    expect(find.text('昨日は学校に行くでした。', findRichText: true), findsOneWidget);
    expect(find.byType(GrammarPracticePanel), findsNWidgets(2));
  });

  testWidgets('generic multiple choice keeps the default prompt surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        MultipleChoiceWidget(
          language: AppLanguage.en,
          questionType: GrammarQuestionType.multipleChoice,
          question: 'Choose the best meaning for に',
          options: const ['to', 'from', 'with'],
          correctAnswer: 'to',
          onAnswer: (isCorrect, selected) {},
        ),
      ),
    );

    expect(find.text('Choose the best answer'), findsOneWidget);
    expect(find.text('Grammar repair'), findsNothing);
    expect(find.text('Sentence to repair'), findsNothing);
    expect(find.byType(GrammarPracticePanel), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(3));
    expect(find.byKey(const ValueKey('grammar_mc_confirm')), findsOneWidget);
  });

  testWidgets('multiple choice selects first and confirms explicitly', (
    tester,
  ) async {
    final answers = <String>[];
    await tester.pumpWidget(
      buildHarness(
        MultipleChoiceWidget(
          language: AppLanguage.vi,
          questionType: GrammarQuestionType.multipleChoice,
          question: 'Chọn nghĩa đúng của に',
          options: const ['đến', 'từ', 'bằng', 'với'],
          correctAnswer: 'đến',
          onAnswer: (isCorrect, selected) => answers.add(selected),
        ),
      ),
    );

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('grammar_mc_confirm')),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.byKey(const ValueKey('grammar_mc_option_0')));
    await tester.pump();

    expect(answers, isEmpty);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('grammar_mc_confirm')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const ValueKey('grammar_mc_confirm')));
    await tester.pump();

    expect(answers, ['đến']);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('wide multiple choice lays four answers out as a 2x2 grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            height: 620,
            child: MultipleChoiceWidget(
              language: AppLanguage.en,
              questionType: GrammarQuestionType.multipleChoice,
              question: 'Choose the closest usage.',
              options: const ['Option A', 'Option B', 'Option C', 'Option D'],
              correctAnswer: 'Option A',
              onAnswer: (isCorrect, selected) {},
            ),
          ),
        ),
      ),
    );

    final a = tester.getTopLeft(
      find.byKey(const ValueKey('grammar_mc_option_0')),
    );
    final b = tester.getTopLeft(
      find.byKey(const ValueKey('grammar_mc_option_1')),
    );
    final c = tester.getTopLeft(
      find.byKey(const ValueKey('grammar_mc_option_2')),
    );

    expect((a.dy - b.dy).abs(), lessThan(2));
    expect(b.dx, greaterThan(a.dx + 200));
    expect(c.dy, greaterThan(a.dy + 40));
  });

  testWidgets('mobile answer selection exposes all options without scrolling', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 390,
            height: 640,
            child: MultipleChoiceWidget(
              language: AppLanguage.vi,
              questionType: GrammarQuestionType.multipleChoice,
              question: 'Chọn cách dùng đúng nhất.',
              options: const ['Đáp án A', 'Đáp án B', 'Đáp án C', 'Đáp án D'],
              correctAnswer: 'Đáp án A',
              onAnswer: (isCorrect, selected) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Scrollable), findsNothing);
    for (var index = 0; index < 4; index++) {
      expect(
        find.byKey(ValueKey('grammar_mc_option_$index')).hitTestable(),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const ValueKey('grammar_mc_confirm')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('new question resets prior multiple-choice selection state', (
    tester,
  ) async {
    Widget buildQuestion({
      required String question,
      required List<String> options,
      required String correctAnswer,
    }) {
      return buildHarness(
        MultipleChoiceWidget(
          language: AppLanguage.en,
          questionType: GrammarQuestionType.transformation,
          question: question,
          options: options,
          correctAnswer: correctAnswer,
          onAnswer: (isCorrect, selected) {},
        ),
      );
    }

    await tester.pumpWidget(
      buildQuestion(
        question: 'Transform this sentence to negative form:\n私は学生です。',
        options: const ['私は学生ではありません。', '私は学生ですか', '私は学生です。'],
        correctAnswer: '私は学生ではありません。',
      ),
    );

    await tester.tap(find.byKey(const ValueKey('grammar_mc_option_0')));
    await tester.pump();

    expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);

    await tester.pumpWidget(
      buildQuestion(
        question: 'Transform this sentence to past form:\n今日は雨です。',
        options: const ['今日は雨でした。', '今日は雨ではありません。', '今日は雨ですか。'],
        correctAnswer: '今日は雨でした。',
      ),
    );
    await tester.pump();

    expect(find.text('Transform this sentence to past form:'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
    expect(find.byIcon(Icons.radio_button_checked_rounded), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(3));
  });

  testWidgets(
    'same question in a new session key resets prior selection state',
    (tester) async {
      Widget buildQuestion(String sessionKey) {
        return buildHarness(
          KeyedSubtree(
            key: ValueKey(sessionKey),
            child: MultipleChoiceWidget(
              language: AppLanguage.en,
              questionType: GrammarQuestionType.multipleChoice,
              question: 'Which pattern matches "while doing"?',
              options: const ['ながら', 'だけ', 'しか'],
              correctAnswer: 'ながら',
              onAnswer: (isCorrect, selected) {},
            ),
          ),
        );
      }

      await tester.pumpWidget(buildQuestion('session_1'));
      await tester.tap(find.byKey(const ValueKey('grammar_mc_option_0')));
      await tester.pump();

      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);

      await tester.pumpWidget(buildQuestion('session_2'));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
      expect(find.byIcon(Icons.cancel_rounded), findsNothing);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsNothing);
      expect(
        find.byIcon(Icons.radio_button_unchecked_rounded),
        findsNWidgets(3),
      );
    },
  );
}
