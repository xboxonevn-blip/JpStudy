import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/models/vocab_item.dart';

void main() {
  // Helper: build a VocabItem with sensible defaults so tests stay focused
  // on the field they're exercising.
  VocabItem item({
    String term = '日本',
    String? reading = 'にほん',
    String meaning = 'Nhật Bản',
    String? meaningEn,
    String? mnemonicVi,
    String? mnemonicEn,
  }) {
    return VocabItem(
      id: 1,
      term: term,
      reading: reading,
      meaning: meaning,
      meaningEn: meaningEn,
      mnemonicVi: mnemonicVi,
      mnemonicEn: mnemonicEn,
      level: 'N5',
    );
  }

  // ── displayMeaning(language) ──────────────────────────────────────────────
  //
  // VI always returns the (mandatory) Vietnamese `meaning`. EN/JA prefer
  // English, but fall back to Vietnamese when meaningEn is missing or empty.
  // This fallback is critical — most legacy data lacks meaningEn.

  group('VocabItem.displayMeaning', () {
    test('Vietnamese language returns the VI meaning verbatim', () {
      final v = item(meaning: 'Mẫu giáo', meaningEn: 'kindergarten');
      expect(v.displayMeaning(AppLanguage.vi), 'Mẫu giáo');
    });

    test('English language returns meaningEn when present', () {
      final v = item(meaning: 'Mẫu giáo', meaningEn: 'kindergarten');
      expect(v.displayMeaning(AppLanguage.en), 'kindergarten');
    });

    test(
      'English language falls back to VI meaning when meaningEn is null',
      () {
        final v = item(meaning: 'Bệnh viện', meaningEn: null);
        expect(v.displayMeaning(AppLanguage.en), 'Bệnh viện');
      },
    );

    test(
      'English language falls back to VI when meaningEn is empty string',
      () {
        final v = item(meaning: 'Bệnh viện', meaningEn: '');
        expect(v.displayMeaning(AppLanguage.en), 'Bệnh viện');
      },
    );

    test('English language falls back when meaningEn is whitespace-only', () {
      // The implementation trims meaningEn before checking — confirm that
      // "   " counts as empty (otherwise users would see blank cards).
      final v = item(meaning: 'Bệnh viện', meaningEn: '   ');
      expect(v.displayMeaning(AppLanguage.en), 'Bệnh viện');
    });

    test(
      'Japanese language behaves like English (prefers EN, falls back to VI)',
      () {
        final withEn = item(meaning: 'Bệnh viện', meaningEn: 'hospital');
        expect(withEn.displayMeaning(AppLanguage.ja), 'hospital');

        final noEn = item(meaning: 'Bệnh viện', meaningEn: null);
        expect(noEn.displayMeaning(AppLanguage.ja), 'Bệnh viện');
      },
    );
  });

  // ── displayMnemonic(language) ─────────────────────────────────────────────
  //
  // Mnemonics are entirely optional. Returns null (NOT empty string) when
  // unavailable so callers can use a null-check to decide whether to render.

  group('VocabItem.displayMnemonic', () {
    test('returns null when no mnemonics are set', () {
      final v = item();
      expect(v.displayMnemonic(AppLanguage.vi), isNull);
      expect(v.displayMnemonic(AppLanguage.en), isNull);
      expect(v.displayMnemonic(AppLanguage.ja), isNull);
    });

    test('VI returns mnemonicVi when present', () {
      final v = item(mnemonicVi: 'Hai chữ nhật ghép lại');
      expect(v.displayMnemonic(AppLanguage.vi), 'Hai chữ nhật ghép lại');
    });

    test('VI returns null when mnemonicVi is empty after trim', () {
      final v = item(mnemonicVi: '   ');
      expect(v.displayMnemonic(AppLanguage.vi), isNull);
    });

    test('EN returns mnemonicEn when present', () {
      final v = item(mnemonicEn: 'Two suns combined');
      expect(v.displayMnemonic(AppLanguage.en), 'Two suns combined');
    });

    test('JA returns mnemonicEn (the EN-EN/JA branch)', () {
      // Per implementation, JA falls into the same case as EN.
      final v = item(mnemonicEn: 'Two suns combined');
      expect(v.displayMnemonic(AppLanguage.ja), 'Two suns combined');
    });

    test('EN/JA do NOT use mnemonicVi as fallback', () {
      // Mnemonic display is strict per language — VI mnemonics are not
      // shown to EN/JA users (intentional, to avoid jarring code-switches).
      final v = item(mnemonicVi: 'Tiếng Việt only', mnemonicEn: null);
      expect(v.displayMnemonic(AppLanguage.en), isNull);
      expect(v.displayMnemonic(AppLanguage.ja), isNull);
    });

    test('VI does NOT use mnemonicEn as fallback', () {
      // Same strictness in the other direction.
      final v = item(mnemonicVi: null, mnemonicEn: 'English only');
      expect(v.displayMnemonic(AppLanguage.vi), isNull);
    });

    test('whitespace-only mnemonicEn is treated as missing', () {
      final v = item(mnemonicEn: '\t\n  ');
      expect(v.displayMnemonic(AppLanguage.en), isNull);
      expect(v.displayMnemonic(AppLanguage.ja), isNull);
    });
  });

  // ── hasDisplayReading ─────────────────────────────────────────────────────
  //
  // Delegates to `shouldShowReading` from japanese_text. We don't re-test
  // that helper's full behavior here — just confirm the wiring works.

  group('VocabItem.hasDisplayReading', () {
    test('false when reading is null', () {
      final v = item(term: 'てがみ', reading: null);
      expect(v.hasDisplayReading, isFalse);
    });

    test('true for kanji term with non-null reading', () {
      final v = item(term: '日本', reading: 'にほん');
      expect(v.hasDisplayReading, isTrue);
    });

    test('false when reading equals term (pure-kana redundancy)', () {
      final v = item(term: 'てがみ', reading: 'てがみ');
      expect(v.hasDisplayReading, isFalse);
    });
  });
}
