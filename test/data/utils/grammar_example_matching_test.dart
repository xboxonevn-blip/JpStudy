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
      {
        'grammarPoint': '〜てはいけない',
        'examples': [
          {'sentence': 'ここで話してはいけません。'},
        ],
      },
      {
        'grammarPoint': 'のに',
        'examples': [
          {'sentence': '田中さんが来たのに、話しかけなかった。'},
        ],
      },
    ];

    // -------------------------------------------------------------------------
    // Null / empty guard cases
    // -------------------------------------------------------------------------

    test('returns null when exampleBlocks is null', () {
      final result = findGrammarExamplesForDefinition(
        exampleBlocks: null,
        title: 'any',
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    test('returns null when exampleBlocks is empty', () {
      final result = findGrammarExamplesForDefinition(
        exampleBlocks: [],
        title: 'any',
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    test('returns null when both title and grammarPoint are null', () {
      final result = findGrammarExamplesForDefinition(
        exampleBlocks: exampleBlocks,
        title: null,
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    test('returns null when title is empty and grammarPoint is null', () {
      final result = findGrammarExamplesForDefinition(
        exampleBlocks: exampleBlocks,
        title: '',
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    // -------------------------------------------------------------------------
    // Exact / normalized matching
    // -------------------------------------------------------------------------

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

    test(
      'matches exact Japanese grammar point when title matches block key',
      () {
        final examples = findGrammarExamplesForDefinition(
          exampleBlocks: exampleBlocks,
          title: 'のに',
          grammarPoint: null,
        );

        expect(examples, isNotNull);
        expect(examples!.single['sentence'], equals('田中さんが来たのに、話しかけなかった。'));
      },
    );

    test(
      'matches when grammarPoint param matches block (title is different)',
      () {
        final examples = findGrammarExamplesForDefinition(
          exampleBlocks: exampleBlocks,
          title: 'Unrelated title',
          grammarPoint: 'のに',
        );

        expect(examples, isNotNull);
        expect(examples!.single['sentence'], equals('田中さんが来たのに、話しかけなかった。'));
      },
    );

    test('matches when tilde variants are normalized (~ → 〜)', () {
      final examples = findGrammarExamplesForDefinition(
        exampleBlocks: exampleBlocks,
        title: '~てはいけない',
        grammarPoint: null,
      );

      expect(examples, isNotNull);
      expect(examples!.single['sentence'], equals('ここで話してはいけません。'));
    });

    test('returns null when no block matches title or grammarPoint', () {
      final result = findGrammarExamplesForDefinition(
        exampleBlocks: exampleBlocks,
        title: '全く違う文法',
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    // -------------------------------------------------------------------------
    // Edge cases in block structure
    // -------------------------------------------------------------------------

    test('skips non-Map entries in exampleBlocks list', () {
      final blocks = <dynamic>[
        'not_a_map',
        42,
        {
          'grammarPoint': 'のに',
          'examples': [
            {'sentence': '彼が来たのに、驚いた。'},
          ],
        },
      ];

      final examples = findGrammarExamplesForDefinition(
        exampleBlocks: blocks,
        title: 'のに',
        grammarPoint: null,
      );

      expect(examples, isNotNull);
      expect(examples!.first['sentence'], '彼が来たのに、驚いた。');
    });

    test('returns null when matching block has no examples', () {
      final blocks = [
        {
          'grammarPoint': 'のに',
          // 'examples' key missing
        },
      ];

      final result = findGrammarExamplesForDefinition(
        exampleBlocks: blocks,
        title: 'のに',
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    test('returns null when matching block examples is not a List', () {
      final blocks = [
        {'grammarPoint': 'のに', 'examples': 'not_a_list'},
      ];

      final result = findGrammarExamplesForDefinition(
        exampleBlocks: blocks,
        title: 'のに',
        grammarPoint: null,
      );
      expect(result, isNull);
    });

    test('returns examples list when first block matches', () {
      final blocks = [
        {
          'grammarPoint': 'のに',
          'examples': [
            {'sentence': 'Ex1'},
            {'sentence': 'Ex2'},
          ],
        },
        {
          'grammarPoint': 'のに',
          'examples': [
            {'sentence': 'Should not be returned'},
          ],
        },
      ];

      final examples = findGrammarExamplesForDefinition(
        exampleBlocks: blocks,
        title: 'のに',
        grammarPoint: null,
      );

      // Should return the first match's examples
      expect(examples, isNotNull);
      expect(examples!, hasLength(2));
    });
  });
}
