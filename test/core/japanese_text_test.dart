import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/utils/japanese_text.dart';

void main() {
  group('isKanaOnly', () {
    test('hiragana only → true', () => expect(isKanaOnly('たべる'), isTrue));
    test('katakana only → true', () => expect(isKanaOnly('アイウ'), isTrue));
    test('mixed kana → true', () => expect(isKanaOnly('あいウエ'), isTrue));
    test('kanji present → false', () => expect(isKanaOnly('食べる'), isFalse));
    test('latin → false', () => expect(isKanaOnly('abc'), isFalse));
    test('empty string → false', () => expect(isKanaOnly(''), isFalse));
    test('whitespace only → false', () => expect(isKanaOnly('   '), isFalse));
    test('kana with spaces → true', () => expect(isKanaOnly('あ い'), isTrue));
  });

  group('shouldShowReading', () {
    test('shows reading for kanji term with different reading', () {
      expect(shouldShowReading(term: '食べる', reading: 'たべる'), isTrue);
    });

    test('hides reading when term == reading (kana word)', () {
      expect(shouldShowReading(term: 'たべる', reading: 'たべる'), isFalse);
    });

    test('hides reading when term is kana-only', () {
      expect(shouldShowReading(term: 'たべる', reading: 'different'), isFalse);
    });

    test('hides reading when reading is empty', () {
      expect(shouldShowReading(term: '食べる', reading: ''), isFalse);
    });

    test('hides reading when reading is null', () {
      expect(shouldShowReading(term: '食べる'), isFalse);
    });

    test('shows reading for mixed term with reading', () {
      expect(shouldShowReading(term: '日本語', reading: 'にほんご'), isTrue);
    });
  });
}
