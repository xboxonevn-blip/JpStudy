import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';

void main() {
  group('VocabItem.displayMeaning', () {
    const item = VocabItem(
      id: 1,
      term: '猫',
      reading: 'ねこ',
      meaning: 'mèo',
      meaningEn: 'cat',
      level: 'N5',
    );

    test('Vietnamese returns meaning', () {
      expect(item.displayMeaning(AppLanguage.vi), 'mèo');
    });

    test('English returns meaningEn when present', () {
      expect(item.displayMeaning(AppLanguage.en), 'cat');
    });

    test('Japanese UI also uses English meaning when present', () {
      expect(item.displayMeaning(AppLanguage.ja), 'cat');
    });

    test('falls back to Vietnamese meaning when meaningEn is null', () {
      const noEnglish = VocabItem(
        id: 2,
        term: '犬',
        reading: 'いぬ',
        meaning: 'chó',
        level: 'N5',
      );
      expect(noEnglish.displayMeaning(AppLanguage.en), 'chó');
      expect(noEnglish.displayMeaning(AppLanguage.ja), 'chó');
    });

    test('falls back to Vietnamese meaning when meaningEn is blank', () {
      const blankEnglish = VocabItem(
        id: 3,
        term: '鳥',
        reading: 'とり',
        meaning: 'chim',
        meaningEn: '  ',
        level: 'N5',
      );
      expect(blankEnglish.displayMeaning(AppLanguage.en), 'chim');
      expect(blankEnglish.displayMeaning(AppLanguage.ja), 'chim');
    });
  });

  group('VocabItem.displayMnemonic', () {
    const item = VocabItem(
      id: 1,
      term: '猫',
      reading: 'ねこ',
      meaning: 'mèo',
      meaningEn: 'cat',
      mnemonicVi: 'Con mèo có ria mép.',
      mnemonicEn: 'A cat with whiskers.',
      level: 'N5',
    );

    test('Vietnamese picks Vietnamese mnemonic', () {
      expect(item.displayMnemonic(AppLanguage.vi), 'Con mèo có ria mép.');
    });

    test('English picks English mnemonic', () {
      expect(item.displayMnemonic(AppLanguage.en), 'A cat with whiskers.');
    });

    test('Japanese UI picks English mnemonic', () {
      expect(item.displayMnemonic(AppLanguage.ja), 'A cat with whiskers.');
    });

    test('returns null for blank Vietnamese mnemonic', () {
      const blankVi = VocabItem(
        id: 2,
        term: '犬',
        reading: 'いぬ',
        meaning: 'chó',
        meaningEn: 'dog',
        mnemonicVi: '  ',
        mnemonicEn: 'A loyal dog.',
        level: 'N5',
      );
      expect(blankVi.displayMnemonic(AppLanguage.vi), isNull);
    });

    test('returns null for blank English mnemonic in EN/JA', () {
      const blankEn = VocabItem(
        id: 3,
        term: '鳥',
        reading: 'とり',
        meaning: 'chim',
        meaningEn: 'bird',
        mnemonicVi: 'Con chim bay.',
        mnemonicEn: ' ',
        level: 'N5',
      );
      expect(blankEn.displayMnemonic(AppLanguage.en), isNull);
      expect(blankEn.displayMnemonic(AppLanguage.ja), isNull);
    });
  });

  group('VocabItem.hasDisplayReading', () {
    test('returns true for kanji term with distinct reading', () {
      const item = VocabItem(
        id: 1,
        term: '食べる',
        reading: 'たべる',
        meaning: 'ăn',
        level: 'N5',
      );
      expect(item.hasDisplayReading, isTrue);
    });

    test('returns false when reading is null', () {
      const item = VocabItem(
        id: 2,
        term: '猫',
        meaning: 'mèo',
        level: 'N5',
      );
      expect(item.hasDisplayReading, isFalse);
    });

    test('returns false when reading is blank', () {
      const item = VocabItem(
        id: 3,
        term: '猫',
        reading: ' ',
        meaning: 'mèo',
        level: 'N5',
      );
      expect(item.hasDisplayReading, isFalse);
    });

    test('returns false when term equals reading', () {
      const item = VocabItem(
        id: 4,
        term: 'ねこ',
        reading: 'ねこ',
        meaning: 'mèo',
        level: 'N5',
      );
      expect(item.hasDisplayReading, isFalse);
    });

    test('returns false for kana-only term even if reading differs only by spacing', () {
      const item = VocabItem(
        id: 5,
        term: 'ねこ',
        reading: ' ねこ ',
        meaning: 'mèo',
        level: 'N5',
      );
      expect(item.hasDisplayReading, isFalse);
    });
  });

  group('KanjiItem.displayMnemonic', () {
    const item = KanjiItem(
      id: 1,
      lessonId: 1,
      character: '森',
      strokeCount: 12,
      meaning: 'rừng',
      meaningEn: 'forest',
      mnemonicVi: 'Ba cây hợp thành rừng.',
      mnemonicEn: 'Three trees make a forest.',
      examples: [],
      jlptLevel: 'N4',
    );

    test('Vietnamese does not leak English mnemonic', () {
      expect(item.displayMnemonic(AppLanguage.vi), 'Ba cây hợp thành rừng.');
    });

    test('English uses English mnemonic', () {
      expect(item.displayMnemonic(AppLanguage.en), 'Three trees make a forest.');
    });

    test('Japanese UI uses English mnemonic', () {
      expect(item.displayMnemonic(AppLanguage.ja), 'Three trees make a forest.');
    });

    test('returns null when selected mnemonic is blank', () {
      const blank = KanjiItem(
        id: 2,
        lessonId: 1,
        character: '林',
        strokeCount: 8,
        meaning: 'rừng nhỏ',
        meaningEn: 'woods',
        mnemonicVi: ' ',
        mnemonicEn: '',
        examples: [],
        jlptLevel: 'N4',
      );
      expect(blank.displayMnemonic(AppLanguage.vi), isNull);
      expect(blank.displayMnemonic(AppLanguage.en), isNull);
      expect(blank.displayMnemonic(AppLanguage.ja), isNull);
    });
  });
}
