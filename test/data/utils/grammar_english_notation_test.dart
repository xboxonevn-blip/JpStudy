import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

void main() {
  group('resolveCanonicalGrammarPointSource', () {
    test('prefers Japanese-first grammar notation over Vietnamese notes', () {
      final canonical = resolveCanonicalGrammarPointSource(
        grammarPoint: 'N1 (địa điểm) に N2 (vật/người) が います/あります',
        structure: 'N1 (địa điểm) に N2 (vật/người) が います/あります',
        title: 'N1 (địa điểm) に N2 (vật/người) が います/あります',
        structureEn: 'N1 に N2 が います / あります',
        titleEn: 'Existence at a place',
      );

      expect(canonical, 'N1 に N2 が います / あります');
      expect(canonical, isNot(contains('địa điểm')));
      expect(canonical, isNot(contains('vật/người')));
    });

    test(
      'falls back to cleaned Japanese structure when grammarPoint is empty',
      () {
        final canonical = resolveCanonicalGrammarPointSource(
          grammarPoint: '',
          structure: 'V-る / N の / Time + mae ni, V2',
          title: 'Before doing ...',
          structureEn: 'V-る / N の / Time + mae ni, V2',
          titleEn: 'Before doing ...',
        );

        expect(canonical, 'V-る / N の / Time + mae ni, V2');
      },
    );
  });

  group('stripNonCanonicalGrammarNotes', () {
    test(
      'removes Vietnamese and English note fragments from grammar labels',
      () {
        expect(
          stripNonCanonicalGrammarNotes(
            'N1 (địa điểm) に N2 (vật/người) が います/あります',
          ),
          'N1 に N2 が います / あります',
        );
        expect(
          stripNonCanonicalGrammarNotes('Số lượng từ (Quantifiers)'),
          '数量詞',
        );
      },
    );

    test('keeps Japanese notation untouched', () {
      expect(stripNonCanonicalGrammarNotes('V-る / N の + 前に'), 'V-る / N の + 前に');
    });
  });

  group('containsVietnameseGrammarText', () {
    test('detects polluted Vietnamese grammar hints', () {
      expect(containsVietnameseGrammarText('địa điểm'), isTrue);
      expect(containsVietnameseGrammarText('N (vật/người) に'), isTrue);
      expect(containsVietnameseGrammarText('N に'), isFalse);
    });
  });
}
