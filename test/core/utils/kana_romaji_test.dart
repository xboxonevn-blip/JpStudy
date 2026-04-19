import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/utils/kana_romaji.dart';

void main() {
  // ── Trivial / empty cases ──────────────────────────────────────────────────

  group('kanaToRomaji — empty input', () {
    test('empty string returns empty string', () {
      expect(kanaToRomaji(''), '');
    });

    test('whitespace-only returns empty string (trimmed)', () {
      expect(kanaToRomaji('   '), '');
    });
  });

  // ── Single-kana lookup ─────────────────────────────────────────────────────

  group('kanaToRomaji — single hiragana', () {
    test('basic vowels', () {
      expect(kanaToRomaji('あ'), 'a');
      expect(kanaToRomaji('い'), 'i');
      expect(kanaToRomaji('う'), 'u');
      expect(kanaToRomaji('え'), 'e');
      expect(kanaToRomaji('お'), 'o');
    });

    test('k-row', () {
      expect(kanaToRomaji('か'), 'ka');
      expect(kanaToRomaji('き'), 'ki');
      expect(kanaToRomaji('く'), 'ku');
      expect(kanaToRomaji('け'), 'ke');
      expect(kanaToRomaji('こ'), 'ko');
    });

    test('s-row uses shi for し', () {
      expect(kanaToRomaji('さ'), 'sa');
      expect(kanaToRomaji('し'), 'shi');
      expect(kanaToRomaji('す'), 'su');
    });

    test('t-row uses chi/tsu', () {
      expect(kanaToRomaji('ち'), 'chi');
      expect(kanaToRomaji('つ'), 'tsu');
    });

    test('voiced (dakuten) row', () {
      expect(kanaToRomaji('が'), 'ga');
      expect(kanaToRomaji('ざ'), 'za');
      expect(kanaToRomaji('じ'), 'ji');
      expect(kanaToRomaji('だ'), 'da');
      expect(kanaToRomaji('ば'), 'ba');
    });

    test('p-row (handakuten)', () {
      expect(kanaToRomaji('ぱ'), 'pa');
      expect(kanaToRomaji('ぴ'), 'pi');
      expect(kanaToRomaji('ぷ'), 'pu');
    });

    test('ん maps to n', () {
      expect(kanaToRomaji('ん'), 'n');
    });

    test('を maps to o (object particle)', () {
      expect(kanaToRomaji('を'), 'o');
    });

    test('ゔ maps to vu (modern V representation)', () {
      expect(kanaToRomaji('ゔ'), 'vu');
    });
  });

  // ── Multi-character words ──────────────────────────────────────────────────

  group('kanaToRomaji — multi-character hiragana words', () {
    test('arigatou', () {
      expect(kanaToRomaji('ありがとう'), 'arigatou');
    });

    test('konnichiwa (uses ん twice and chi)', () {
      expect(kanaToRomaji('こんにちは'), 'konnichiha');
    });

    test('namae (name)', () {
      expect(kanaToRomaji('なまえ'), 'namae');
    });

    test('nihongo (Japanese language)', () {
      expect(kanaToRomaji('にほんご'), 'nihongo');
    });
  });

  // ── Katakana → hiragana normalization ──────────────────────────────────────
  //
  // _normalizeKana shifts katakana code points (0x30A1-0x30F6) down by 0x60
  // to the hiragana range, so the lookup tables only need hiragana entries.

  group('kanaToRomaji — katakana normalization', () {
    test('katakana single chars produce same romaji as hiragana', () {
      expect(kanaToRomaji('ア'), 'a');
      expect(kanaToRomaji('カ'), 'ka');
      expect(kanaToRomaji('シ'), 'shi');
      expect(kanaToRomaji('ン'), 'n');
    });

    test('katakana compound: シャ = sha (same as しゃ)', () {
      expect(kanaToRomaji('シャ'), 'sha');
      expect(kanaToRomaji('しゃ'), 'sha');
    });

    test('mixed katakana + hiragana works', () {
      // ニュース = nyuusu — uses compound にゅ + prolongation ー + す
      expect(kanaToRomaji('ニュース'), 'nyuusu');
    });
  });

  // ── Compound kana (yōon) ──────────────────────────────────────────────────

  group('kanaToRomaji — compound kana', () {
    test('basic yōon きゃ/きゅ/きょ', () {
      expect(kanaToRomaji('きゃ'), 'kya');
      expect(kanaToRomaji('きゅ'), 'kyu');
      expect(kanaToRomaji('きょ'), 'kyo');
    });

    test('voiced yōon ぎゃ', () {
      expect(kanaToRomaji('ぎゃ'), 'gya');
    });

    test('しゃ / しゅ / しょ', () {
      expect(kanaToRomaji('しゃ'), 'sha');
      expect(kanaToRomaji('しゅ'), 'shu');
      expect(kanaToRomaji('しょ'), 'sho');
    });

    test('じゃ / じゅ / じょ', () {
      expect(kanaToRomaji('じゃ'), 'ja');
      expect(kanaToRomaji('じょ'), 'jo');
    });

    test('ちゃ / ちゅ / ちょ', () {
      expect(kanaToRomaji('ちゃ'), 'cha');
      expect(kanaToRomaji('ちょ'), 'cho');
    });

    test('ふぁ / ふぃ / ふぇ / ふぉ (foreign sounds)', () {
      expect(kanaToRomaji('ふぁ'), 'fa');
      expect(kanaToRomaji('ふぃ'), 'fi');
      expect(kanaToRomaji('ふぇ'), 'fe');
      expect(kanaToRomaji('ふぉ'), 'fo');
    });
  });

  // ── Gemination (sokuon っ) ────────────────────────────────────────────────
  //
  // The small っ doubles the consonant of the next romaji. The implementation
  // does this by writing romaji[0] before the next syllable (line 43).

  group('kanaToRomaji — gemination (small っ)', () {
    test('かっこ → kakko', () {
      expect(kanaToRomaji('かっこ'), 'kakko');
    });

    test('やった → yatta', () {
      expect(kanaToRomaji('やった'), 'yatta');
    });

    test('ざっし → zasshi (gemination on shi)', () {
      // s + shi = ssh? Implementation writes romaji[0] which is 's' → 'sshi'
      expect(kanaToRomaji('ざっし'), 'zasshi');
    });

    test('まって → matte', () {
      expect(kanaToRomaji('まって'), 'matte');
    });

    test('lone trailing っ produces no extra output (no syllable to double)', () {
      // っ alone sets pendingGeminate but never gets cleared if no next syllable
      expect(kanaToRomaji('あっ'), 'a');
    });

    test('two っ in a row collapse — the second wins (no compounding)', () {
      // Implementation just sets the flag; consecutive っ don't accumulate
      expect(kanaToRomaji('あっっか'), 'akka');
    });
  });

  // ── Prolongation (chōonpu ー) ──────────────────────────────────────────────
  //
  // The katakana long-mark ー extends the previous vowel sound. Implementation
  // tracks the last vowel via _lastVowel(romaji) and re-writes it (line 19).

  group('kanaToRomaji — prolongation (ー)', () {
    test('かー → kaa', () {
      expect(kanaToRomaji('かー'), 'kaa');
    });

    test('スーパー → suupaa', () {
      expect(kanaToRomaji('スーパー'), 'suupaa');
    });

    test('ー at the start (no prior vowel) is silently dropped', () {
      expect(kanaToRomaji('ーか'), 'ka');
    });

    test('compound + prolongation: きゃー → kyaa', () {
      expect(kanaToRomaji('きゃー'), 'kyaa');
    });

    test('multiple ー in a row keep extending the same vowel', () {
      expect(kanaToRomaji('かーー'), 'kaaa');
    });
  });

  // ── Unknown characters fall through ────────────────────────────────────────

  group('kanaToRomaji — non-kana fall-through', () {
    test('latin letters pass through unchanged (after lowercasing)', () {
      // _normalizeKana lowercases everything before lookup.
      expect(kanaToRomaji('ABC'), 'abc');
    });

    test('digits pass through unchanged', () {
      expect(kanaToRomaji('123'), '123');
    });

    test('mixed kana + ascii: あabcか → a abc ka concatenated', () {
      expect(kanaToRomaji('あabcか'), 'aabcka');
    });

    test('kanji characters fall through unchanged', () {
      // 日本 — neither in compound nor single kana table
      expect(kanaToRomaji('日本'), '日本');
    });
  });

  // ── Whitespace handling ───────────────────────────────────────────────────

  group('kanaToRomaji — whitespace', () {
    test('leading/trailing whitespace is trimmed', () {
      expect(kanaToRomaji('  あ  '), 'a');
    });

    test('internal whitespace is preserved (passes through fall-through)', () {
      expect(kanaToRomaji('あ い'), 'a i');
    });
  });

  // ── Last-vowel tracking is per-syllable, not per-character ────────────────
  //
  // The lastVowel state updates whenever a romaji is emitted, even via
  // compound lookup. Verify it's set correctly after compound emissions
  // (e.g. 'sha' → last vowel = 'a').

  group('kanaToRomaji — last-vowel state continuity', () {
    test('compound followed by ー uses compound\'s final vowel', () {
      // しゃ → sha (last vowel 'a'), ー → write 'a'
      expect(kanaToRomaji('しゃー'), 'shaa');
    });

    test('ん resets lastVowel → ー immediately after ん is silently dropped', () {
      // After ん → 'n', lastVowel is overwritten to '' (no vowel in 'n').
      // ー then sees an empty lastVowel and emits nothing.
      // Net result: かんー → 'kan' (the ー does NOT extend the 'a' from か).
      expect(kanaToRomaji('かんー'), 'kan');
    });
  });
}
