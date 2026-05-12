import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';
import 'package:jpstudy/data/models/vocab_item.dart';

void main() {
  // ---------------------------------------------------------------------------
  // isKanaOnly
  // ---------------------------------------------------------------------------

  group('isKanaOnly', () {
    test('returns false for empty string', () {
      expect(isKanaOnly(''), isFalse);
    });

    test('returns false for whitespace-only string', () {
      expect(isKanaOnly('   '), isFalse);
    });

    test('returns true for hiragana-only string', () {
      expect(isKanaOnly('たべる'), isTrue);
      expect(isKanaOnly('いく'), isTrue);
    });

    test('returns true for katakana-only string', () {
      expect(isKanaOnly('タベル'), isTrue);
      expect(isKanaOnly('コーヒー'), isTrue);
    });

    test('returns true for mixed hiragana and katakana', () {
      expect(isKanaOnly('たべるタベル'), isTrue);
    });

    test('returns true for kana with long vowel mark (ー)', () {
      expect(isKanaOnly('コーヒー'), isTrue);
    });

    test('returns false for kanji', () {
      expect(isKanaOnly('食べる'), isFalse);
      expect(isKanaOnly('日本語'), isFalse);
    });

    test('returns false for mixed kanji and kana', () {
      expect(isKanaOnly('食べる'), isFalse);
    });

    test('returns false for Latin characters', () {
      expect(isKanaOnly('abc'), isFalse);
      expect(isKanaOnly('N5'), isFalse);
    });

    test('returns false for Latin mixed with kana', () {
      expect(isKanaOnly('たべるa'), isFalse);
    });

    test('ignores surrounding whitespace when checking', () {
      // Trim happens internally; pure kana with spaces is still kana-only
      expect(isKanaOnly('  たべる  '), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // shouldShowReading
  // ---------------------------------------------------------------------------

  group('shouldShowReading', () {
    test('returns false when reading is null', () {
      expect(shouldShowReading(term: '食べる', reading: null), isFalse);
    });

    test('returns false when reading is empty', () {
      expect(shouldShowReading(term: '食べる', reading: ''), isFalse);
    });

    test('returns false when term equals reading', () {
      expect(shouldShowReading(term: 'たべる', reading: 'たべる'), isFalse);
    });

    test(
      'returns false when term is kana-only (reading would be redundant)',
      () {
        // Pure kana term → reading is unnecessary
        expect(shouldShowReading(term: 'たべる', reading: 'たべる'), isFalse);
        expect(shouldShowReading(term: 'いく', reading: 'いく'), isFalse);
      },
    );

    test('returns true when term has kanji and reading differs', () {
      expect(shouldShowReading(term: '食べる', reading: 'たべる'), isTrue);
    });

    test('returns true for kanji compound with different reading', () {
      expect(shouldShowReading(term: '日本語', reading: 'にほんご'), isTrue);
    });

    test('returns false for whitespace-only reading', () {
      expect(shouldShowReading(term: '食べる', reading: '   '), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // VocabItem.displayMeaning
  // ---------------------------------------------------------------------------

  group('VocabItem.displayMeaning', () {
    const vocabWithBoth = VocabItem(
      id: 1,
      term: '食べる',
      meaning: 'ăn (VI)',
      meaningEn: 'to eat',
      level: 'N5',
    );

    const vocabNoEn = VocabItem(
      id: 2,
      term: '飲む',
      meaning: 'uống (VI)',
      level: 'N5',
    );

    test('AppLanguage.vi returns Vietnamese meaning', () {
      expect(vocabWithBoth.displayMeaning(AppLanguage.vi), 'ăn (VI)');
    });

    test('AppLanguage.en returns English meaning when available', () {
      expect(vocabWithBoth.displayMeaning(AppLanguage.en), 'to eat');
    });

    test('AppLanguage.en falls back to meaning when meaningEn is null', () {
      expect(vocabNoEn.displayMeaning(AppLanguage.en), 'uống (VI)');
    });

    test('AppLanguage.ja returns English meaning when available', () {
      expect(vocabWithBoth.displayMeaning(AppLanguage.ja), 'to eat');
    });

    test('AppLanguage.ja falls back to meaning when meaningEn is null', () {
      expect(vocabNoEn.displayMeaning(AppLanguage.ja), 'uống (VI)');
    });

    test('AppLanguage.en falls back to meaning when meaningEn is blank', () {
      const vocabBlankEn = VocabItem(
        id: 3,
        term: '走る',
        meaning: 'chạy (VI)',
        meaningEn: '  ',
        level: 'N5',
      );
      expect(vocabBlankEn.displayMeaning(AppLanguage.en), 'chạy (VI)');
    });
  });

  // ---------------------------------------------------------------------------
  // VocabItem.displayMnemonic
  // ---------------------------------------------------------------------------

  group('VocabItem.displayMnemonic', () {
    const vocabFull = VocabItem(
      id: 1,
      term: '食べる',
      meaning: 'ăn',
      level: 'N5',
      mnemonicVi: 'Hãy tưởng tượng ...',
      mnemonicEn: 'Imagine eating ...',
    );

    test('AppLanguage.vi returns Vietnamese mnemonic', () {
      expect(vocabFull.displayMnemonic(AppLanguage.vi), 'Hãy tưởng tượng ...');
    });

    test('AppLanguage.en returns English mnemonic', () {
      expect(vocabFull.displayMnemonic(AppLanguage.en), 'Imagine eating ...');
    });

    test('AppLanguage.ja returns English mnemonic', () {
      expect(vocabFull.displayMnemonic(AppLanguage.ja), 'Imagine eating ...');
    });

    test('returns null when mnemonic is not available for language', () {
      const vocabViOnly = VocabItem(
        id: 2,
        term: '飲む',
        meaning: 'uống',
        level: 'N5',
        mnemonicVi: 'Ghi nhớ ...',
        mnemonicEn: null,
      );
      expect(vocabViOnly.displayMnemonic(AppLanguage.en), isNull);
      expect(vocabViOnly.displayMnemonic(AppLanguage.ja), isNull);
    });

    test('returns null when all mnemonics are null', () {
      const vocabNoMnemonic = VocabItem(
        id: 3,
        term: '走る',
        meaning: 'chạy',
        level: 'N5',
      );
      expect(vocabNoMnemonic.displayMnemonic(AppLanguage.vi), isNull);
      expect(vocabNoMnemonic.displayMnemonic(AppLanguage.en), isNull);
    });

    test('returns null when mnemonic is blank', () {
      const vocabBlank = VocabItem(
        id: 4,
        term: '走る',
        meaning: 'chạy',
        level: 'N5',
        mnemonicVi: '  ',
        mnemonicEn: '',
      );
      expect(vocabBlank.displayMnemonic(AppLanguage.vi), isNull);
      expect(vocabBlank.displayMnemonic(AppLanguage.en), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // VocabItem.hasDisplayReading
  // ---------------------------------------------------------------------------

  group('VocabItem.hasDisplayReading', () {
    test('returns true for kanji term with different reading', () {
      const vocab = VocabItem(
        id: 1,
        term: '食べる',
        reading: 'たべる',
        meaning: 'to eat',
        level: 'N5',
      );
      expect(vocab.hasDisplayReading, isTrue);
    });

    test('returns false for kana-only term', () {
      const vocab = VocabItem(
        id: 2,
        term: 'たべる',
        reading: 'たべる',
        meaning: 'to eat',
        level: 'N5',
      );
      expect(vocab.hasDisplayReading, isFalse);
    });

    test('returns false when reading is null', () {
      const vocab = VocabItem(
        id: 3,
        term: '食べる',
        reading: null,
        meaning: 'to eat',
        level: 'N5',
      );
      expect(vocab.hasDisplayReading, isFalse);
    });
  });
}
