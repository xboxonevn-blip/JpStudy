import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/vocab_item.dart';

void main() {
  test('VocabItem.displayMnemonic chọn đúng theo ngôn ngữ', () {
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

    expect(item.displayMnemonic(AppLanguage.vi), 'Con mèo có ria mép.');
    expect(item.displayMnemonic(AppLanguage.en), 'A cat with whiskers.');
  });

  test('KanjiItem.displayMnemonic không rò rỉ tiếng Việt sang English', () {
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

    expect(item.displayMnemonic(AppLanguage.vi), 'Ba cây hợp thành rừng.');
    expect(item.displayMnemonic(AppLanguage.en), 'Three trees make a forest.');
  });
}
