import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/kanji_item.dart';

void main() {
  // ---------------------------------------------------------------------------
  // KanjiItem.displayMnemonic
  // ---------------------------------------------------------------------------

  group('KanjiItem.displayMnemonic', () {
    KanjiItem kanji({String? mnemonicVi, String? mnemonicEn}) {
      return KanjiItem(
        id: 1,
        lessonId: 1,
        character: '食',
        strokeCount: 9,
        meaning: 'thức ăn',
        examples: const [],
        jlptLevel: 'N5',
        mnemonicVi: mnemonicVi,
        mnemonicEn: mnemonicEn,
      );
    }

    test('AppLanguage.vi returns Vietnamese mnemonic when set', () {
      final k = kanji(mnemonicVi: 'Ghi nhớ...', mnemonicEn: 'Remember...');
      expect(k.displayMnemonic(AppLanguage.vi), 'Ghi nhớ...');
    });

    test('AppLanguage.en returns English mnemonic when set', () {
      final k = kanji(mnemonicVi: 'Ghi nhớ...', mnemonicEn: 'Remember...');
      expect(k.displayMnemonic(AppLanguage.en), 'Remember...');
    });

    test('AppLanguage.ja returns English mnemonic when set', () {
      final k = kanji(mnemonicVi: 'Ghi nhớ...', mnemonicEn: 'Remember...');
      expect(k.displayMnemonic(AppLanguage.ja), 'Remember...');
    });

    test('returns null when mnemonic for the language is null', () {
      final k = kanji(mnemonicVi: 'Ghi nhớ...', mnemonicEn: null);
      expect(k.displayMnemonic(AppLanguage.en), isNull);
    });

    test('returns null when mnemonic for the language is blank', () {
      final k = kanji(mnemonicVi: '  ', mnemonicEn: '');
      expect(k.displayMnemonic(AppLanguage.vi), isNull);
      expect(k.displayMnemonic(AppLanguage.en), isNull);
    });

    test('returns null when both mnemonics are null', () {
      final k = kanji();
      expect(k.displayMnemonic(AppLanguage.vi), isNull);
      expect(k.displayMnemonic(AppLanguage.en), isNull);
      expect(k.displayMnemonic(AppLanguage.ja), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // KanjiDecomposition.hasContent
  // ---------------------------------------------------------------------------

  group('KanjiDecomposition.hasContent', () {
    test('returns false when all fields are empty/null', () {
      const d = KanjiDecomposition();
      expect(d.hasContent, isFalse);
    });

    test('returns true when hanViet is non-empty', () {
      const d = KanjiDecomposition(hanViet: 'thực');
      expect(d.hasContent, isTrue);
    });

    test('returns true when structure is non-empty', () {
      const d = KanjiDecomposition(structure: 'left-right');
      expect(d.hasContent, isTrue);
    });

    test('returns true when components is non-empty', () {
      const d = KanjiDecomposition(components: ['⻙', '良']);
      expect(d.hasContent, isTrue);
    });

    test('returns true when componentNames is non-empty', () {
      const d = KanjiDecomposition(componentNames: ['metal', 'good']);
      expect(d.hasContent, isTrue);
    });

    test('returns true when relatedKanji is non-empty', () {
      const d = KanjiDecomposition(relatedKanji: ['鉄']);
      expect(d.hasContent, isTrue);
    });

    test('returns false when hanViet is blank whitespace', () {
      const d = KanjiDecomposition(hanViet: '   ');
      expect(d.hasContent, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // KanjiDecomposition.fromJson / toJson
  // ---------------------------------------------------------------------------

  group('KanjiDecomposition.fromJson', () {
    test('parses all fields from JSON', () {
      final json = <String, dynamic>{
        'hanViet': 'thực',
        'structure': 'enclosure',
        'components': ['⻙', '良'],
        'componentNames': ['metal', 'good'],
        'relatedKanji': ['鉄'],
      };
      final d = KanjiDecomposition.fromJson(json);
      expect(d.hanViet, 'thực');
      expect(d.structure, 'enclosure');
      expect(d.components, ['⻙', '良']);
      expect(d.componentNames, ['metal', 'good']);
      expect(d.relatedKanji, ['鉄']);
    });

    test('returns empty lists when list fields are absent', () {
      final json = <String, dynamic>{'hanViet': 'thực'};
      final d = KanjiDecomposition.fromJson(json);
      expect(d.components, isEmpty);
      expect(d.componentNames, isEmpty);
      expect(d.relatedKanji, isEmpty);
    });

    test('trims and filters blank list items', () {
      final json = <String, dynamic>{
        'components': ['a', '  ', 'b', ''],
      };
      final d = KanjiDecomposition.fromJson(json);
      expect(d.components, ['a', 'b']);
    });

    test('returns null for optional fields when absent', () {
      final d = KanjiDecomposition.fromJson({});
      expect(d.hanViet, isNull);
      expect(d.structure, isNull);
    });

    test('returns null for optional string when value is blank', () {
      final json = <String, dynamic>{'hanViet': '  ', 'structure': ''};
      final d = KanjiDecomposition.fromJson(json);
      expect(d.hanViet, isNull);
      expect(d.structure, isNull);
    });
  });

  group('KanjiDecomposition.toJson', () {
    test('round-trips a complete decomposition', () {
      const d = KanjiDecomposition(
        hanViet: 'thực',
        structure: 'left-right',
        components: ['⻙', '良'],
        componentNames: ['metal', 'good'],
        relatedKanji: ['鉄'],
      );
      final json = d.toJson();
      final restored = KanjiDecomposition.fromJson(json);
      expect(restored.hanViet, 'thực');
      expect(restored.structure, 'left-right');
      expect(restored.components, ['⻙', '良']);
    });

    test('omits null/blank optional fields from output', () {
      const d = KanjiDecomposition(
        hanViet: null,
        structure: null,
        components: [],
      );
      final json = d.toJson();
      expect(json.containsKey('hanViet'), isFalse);
      expect(json.containsKey('structure'), isFalse);
      expect(json.containsKey('components'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // KanjiExample.hasSourceRef
  // ---------------------------------------------------------------------------

  group('KanjiExample.hasSourceRef', () {
    test('returns false when both source fields are null', () {
      const e = KanjiExample();
      expect(e.hasSourceRef, isFalse);
    });

    test('returns true when sourceVocabId is set', () {
      const e = KanjiExample(sourceVocabId: 'v123');
      expect(e.hasSourceRef, isTrue);
    });

    test('returns true when sourceSenseId is set', () {
      const e = KanjiExample(sourceSenseId: 's456');
      expect(e.hasSourceRef, isTrue);
    });

    test('returns false when both are blank', () {
      const e = KanjiExample(sourceVocabId: '  ', sourceSenseId: '');
      expect(e.hasSourceRef, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // KanjiExample.fromJson / toJson
  // ---------------------------------------------------------------------------

  group('KanjiExample.fromJson', () {
    test('parses all fields from JSON', () {
      final json = <String, dynamic>{
        'word': '食べ物',
        'reading': 'たべもの',
        'meaning': 'thức ăn',
        'meaningEn': 'food',
        'sourceVocabId': 'v1',
        'sourceSenseId': 's1',
      };
      final e = KanjiExample.fromJson(json);
      expect(e.word, '食べ物');
      expect(e.reading, 'たべもの');
      expect(e.meaning, 'thức ăn');
      expect(e.meaningEn, 'food');
      expect(e.sourceVocabId, 'v1');
      expect(e.sourceSenseId, 's1');
    });

    test('defaults word/reading/meaning to empty string when absent', () {
      final e = KanjiExample.fromJson({});
      expect(e.word, '');
      expect(e.reading, '');
      expect(e.meaning, '');
    });

    test('returns null for optional fields when absent', () {
      final e = KanjiExample.fromJson({});
      expect(e.meaningEn, isNull);
      expect(e.sourceVocabId, isNull);
      expect(e.sourceSenseId, isNull);
    });

    test('trims values and converts blank to null for optional fields', () {
      final json = <String, dynamic>{
        'word': '  ',
        'meaningEn': '',
        'sourceVocabId': '  ',
      };
      final e = KanjiExample.fromJson(json);
      expect(e.word, ''); // required field defaults to empty
      expect(e.meaningEn, isNull);
      expect(e.sourceVocabId, isNull);
    });
  });

  group('KanjiExample.toJson', () {
    test('round-trips a complete example', () {
      const e = KanjiExample(
        word: '食べ物',
        reading: 'たべもの',
        meaning: 'thức ăn',
        meaningEn: 'food',
        sourceVocabId: 'v1',
        sourceSenseId: 's1',
      );
      final json = e.toJson();
      final restored = KanjiExample.fromJson(json);
      expect(restored.word, '食べ物');
      expect(restored.reading, 'たべもの');
      expect(restored.meaningEn, 'food');
      expect(restored.sourceVocabId, 'v1');
    });

    test('omits optional fields when blank/null', () {
      const e = KanjiExample(
        word: '食べ物',
        reading: 'たべもの',
        meaning: 'thức ăn',
      );
      final json = e.toJson();
      expect(json.containsKey('meaningEn'), isFalse);
      expect(json.containsKey('sourceVocabId'), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // KanjiExample.resolvedWith
  // ---------------------------------------------------------------------------

  group('KanjiExample.resolvedWith', () {
    test('creates new example with provided word/reading/meaning', () {
      const original = KanjiExample(
        sourceVocabId: 'v42',
        sourceSenseId: 's7',
      );
      final resolved = original.resolvedWith(
        word: '食べ物',
        reading: 'たべもの',
        meaning: 'food',
        meaningEn: 'food (en)',
      );

      expect(resolved.word, '食べ物');
      expect(resolved.reading, 'たべもの');
      expect(resolved.meaning, 'food');
      expect(resolved.meaningEn, 'food (en)');
      // Source refs preserved
      expect(resolved.sourceVocabId, 'v42');
      expect(resolved.sourceSenseId, 's7');
    });
  });
}
