import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/utils/grammar_example_matching.dart';

void main() {
  group('findGrammarExamplesForDefinition', () {
    const exampleBlocks = [
      {
        'grammarPoint': 'Động từ Vます',
        'examples': [
          {'sentence': '私は毎日勉強します。'},
        ],
      },
      {
        'grammarPoint': '～のために (Mục đích)',
        'examples': [
          {'sentence': '車を買うために、貯金します。'},
        ],
      },
    ];

    test(
      'matches Vietnamese helper labels that share the same Japanese core',
      () {
        final examples = findGrammarExamplesForDefinition(
          exampleBlocks: exampleBlocks,
          title: 'Động từ dạng ます',
          grammarPoint: null,
        );

        expect(examples, isNotNull);
        expect(examples!.single['sentence'], equals('私は毎日勉強します。'));
      },
    );

    test('matches relaxed wave-dash labels with optional の variants', () {
      final examples = findGrammarExamplesForDefinition(
        exampleBlocks: exampleBlocks,
        title: '～ために (Mục đích)',
        grammarPoint: null,
      );

      expect(examples, isNotNull);
      expect(examples!.single['sentence'], equals('車を買うために、貯金します。'));
    });
  });
}
