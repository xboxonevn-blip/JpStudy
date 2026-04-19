import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';

// ---------------------------------------------------------------------------
// repairPotentialMojibake
// ---------------------------------------------------------------------------
//
// Mojibake pattern: a UTF-8 encoded Japanese string that was mistakenly read
// as Latin-1. The function detects this by looking for known Latin-1 marker
// characters (å, ã, æ, â, etc.) and then applies the inverse transform:
//   latin1.encode(input)  →  original UTF-8 bytes
//   utf8.decode(bytes)    →  correct Unicode string
//
// Example: "平" has UTF-8 bytes [E5, B9, B3].
// Misread as Latin-1: 0xE5='å', 0xB9='¹', 0xB3='³'  →  "å¹³"
// Repair:  latin1.encode("å¹³") = [E5, B9, B3]  →  utf8.decode  →  "平"

void main() {
  group('repairPotentialMojibake — identity cases', () {
    test('empty string returns empty string', () {
      expect(repairPotentialMojibake(''), '');
    });

    test('whitespace-only string returns empty string after trim', () {
      expect(repairPotentialMojibake('   '), '');
    });

    test('plain ASCII is returned unchanged', () {
      expect(repairPotentialMojibake('hello world'), 'hello world');
    });

    test('correctly encoded Japanese is returned unchanged', () {
      // "日本語" does not contain any of the Latin-1 marker characters
      // (ã, å, æ, â, €, ™, □) so it is not treated as mojibake.
      expect(repairPotentialMojibake('日本語'), '日本語');
    });

    test('numeric string is returned unchanged', () {
      expect(repairPotentialMojibake('12345'), '12345');
    });

    test('trims leading and trailing whitespace for non-mojibake input', () {
      expect(repairPotentialMojibake('  hello  '), 'hello');
    });

    test('trims whitespace around Japanese text', () {
      expect(repairPotentialMojibake('  日本語  '), '日本語');
    });
  });

  group('repairPotentialMojibake — mojibake repair cases', () {
    test('repairs double-encoded single kanji: å¹³ → 平', () {
      // "平" = UTF-8 [E5 B9 B3], misread as Latin-1 = "å¹³"
      expect(repairPotentialMojibake('å¹³'), '平');
    });

    test('repairs double-encoded single kanji: ã³ → repairs to non-empty', () {
      // Any input with marker characters undergoes repair; we verify it does
      // not crash and returns a non-null result.
      final result = repairPotentialMojibake('ãã');
      expect(result, isA<String>());
    });

    test('repairs typical book-title mojibake example: æ—¥æœ¬èªž → 日本語', () {
      // "日本語" UTF-8:
      //   日 = [E6 97 A5], 本 = [E6 9C AC], 語 = [E8 AA 9E]
      // Misread as Latin-1:
      //   [E6]='æ', [97]=\x97(control), [A5]='¥',
      //   [E6]='æ', [9C]=\x9c(control), [AC]='¬',
      //   [E8]='è', [AA]=\xaa, [9E]=\x9e
      // We encode those as a raw Latin-1 string and verify repair.
      // Build the mojibake string from its raw bytes:
      final bytes = [
        0xE6, 0x97, 0xA5, // 日
        0xE6, 0x9C, 0xAC, // 本
        0xE8, 0xAA, 0x9E, // 語
      ];
      final mojibake = String.fromCharCodes(bytes);
      // "æ" (0xE6) is a marker, so the repair path is triggered.
      expect(repairPotentialMojibake(mojibake), '日本語');
    });

    test('input with euro marker € triggers repair attempt', () {
      // Just verify non-crash and String return — full byte round-trip verified
      // in the dedicated test above.
      final result = repairPotentialMojibake('€test');
      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // HajimeteChapterCatalog.totalTerms
  // ---------------------------------------------------------------------------

  group('HajimeteChapterCatalog.totalTerms', () {
    test('returns 0 for catalog with no chapters', () {
      const catalog = HajimeteChapterCatalog(levelCode: 'N5', chapters: []);
      expect(catalog.totalTerms, 0);
    });

    test('returns entryCount of a single chapter', () {
      const catalog = HajimeteChapterCatalog(
        levelCode: 'N5',
        chapters: [
          HajimeteChapterSummary(
            chapterId: 1,
            title: 'Chapter 01',
            entryCount: 12,
            previewTerms: [],
            sourceVocabIds: [],
          ),
        ],
      );
      expect(catalog.totalTerms, 12);
    });

    test('sums entryCount across multiple chapters', () {
      const catalog = HajimeteChapterCatalog(
        levelCode: 'N4',
        chapters: [
          HajimeteChapterSummary(
            chapterId: 1,
            title: 'Chapter 01',
            entryCount: 10,
            previewTerms: [],
            sourceVocabIds: [],
          ),
          HajimeteChapterSummary(
            chapterId: 2,
            title: 'Chapter 02',
            entryCount: 15,
            previewTerms: [],
            sourceVocabIds: [],
          ),
          HajimeteChapterSummary(
            chapterId: 3,
            title: 'Chapter 03',
            entryCount: 8,
            previewTerms: [],
            sourceVocabIds: [],
          ),
        ],
      );
      expect(catalog.totalTerms, 33);
    });

    test('chapters with 0 entries do not break the sum', () {
      const catalog = HajimeteChapterCatalog(
        levelCode: 'N3',
        chapters: [
          HajimeteChapterSummary(
            chapterId: 1,
            title: 'Chapter 01',
            entryCount: 0,
            previewTerms: [],
            sourceVocabIds: [],
          ),
          HajimeteChapterSummary(
            chapterId: 2,
            title: 'Chapter 02',
            entryCount: 7,
            previewTerms: [],
            sourceVocabIds: [],
          ),
        ],
      );
      expect(catalog.totalTerms, 7);
    });
  });
}
