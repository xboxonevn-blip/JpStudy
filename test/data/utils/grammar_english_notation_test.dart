import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

void main() {
  // ---------------------------------------------------------------------------
  // resolveCanonicalGrammarPointSource
  // ---------------------------------------------------------------------------

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

    test('returns empty string when all inputs are null/empty', () {
      final canonical = resolveCanonicalGrammarPointSource(
        grammarPoint: null,
        structure: null,
        title: null,
        structureEn: null,
        titleEn: null,
      );
      expect(canonical, isEmpty);
    });

    test(
      'returns English fallback when all Japanese inputs contain Vietnamese',
      () {
        const viNote = 'động từ thể て';
        final canonical = resolveCanonicalGrammarPointSource(
          grammarPoint: viNote,
          structure: viNote,
          title: viNote,
          structureEn: 'V-てはいけません',
          titleEn: null,
        );
        // Should fall through to structureEn (which is in Japanese, not Vietnamese)
        expect(canonical, isNotEmpty);
        expect(containsVietnameseGrammarText(canonical), isFalse);
      },
    );

    test('prefers grammarPoint candidate when it has Japanese characters', () {
      final canonical = resolveCanonicalGrammarPointSource(
        grammarPoint: '〜てはいけない',
        structure: 'V-te wa ikemasen',
        title: 'Must not do',
        structureEn: 'V-てはいけません',
        titleEn: null,
      );
      expect(canonical, contains('て'));
    });
  });

  // ---------------------------------------------------------------------------
  // stripNonCanonicalGrammarNotes
  // ---------------------------------------------------------------------------

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

    test('returns empty string for null input', () {
      expect(stripNonCanonicalGrammarNotes(null), isEmpty);
    });

    test('normalizes spacing around / , +', () {
      expect(stripNonCanonicalGrammarNotes('A/B,C+D'), 'A / B, C + D');
    });

    test('collapses multiple spaces to single space', () {
      expect(stripNonCanonicalGrammarNotes('N1   に   N2'), 'N1 に N2');
    });
  });

  // ---------------------------------------------------------------------------
  // containsVietnameseGrammarText
  // ---------------------------------------------------------------------------

  group('containsVietnameseGrammarText', () {
    test('detects polluted Vietnamese grammar hints', () {
      expect(containsVietnameseGrammarText('địa điểm'), isTrue);
      expect(containsVietnameseGrammarText('N (vật/người) に'), isTrue);
      expect(containsVietnameseGrammarText('N に'), isFalse);
    });

    test('returns false for empty string', () {
      expect(containsVietnameseGrammarText(''), isFalse);
    });

    test('returns false for null', () {
      expect(containsVietnameseGrammarText(null), isFalse);
    });

    test('detects Vietnamese diacritics', () {
      expect(containsVietnameseGrammarText('ắ'), isTrue);
      expect(containsVietnameseGrammarText('ợ'), isTrue);
    });

    test('does not flag pure Japanese text', () {
      expect(containsVietnameseGrammarText('〜てはいけない'), isFalse);
      expect(containsVietnameseGrammarText('V-る / N の + 前に'), isFalse);
    });

    test('does not flag pure English grammar text', () {
      expect(containsVietnameseGrammarText('Before doing'), isFalse);
      expect(containsVietnameseGrammarText('N1 に N2 が'), isFalse);
    });

    test('detects Vietnamese keywords even without diacritics matches', () {
      // 'động từ' → detected via keyword list
      expect(containsVietnameseGrammarText('động từ thể て'), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // normalizeGrammarTitleEn
  // ---------------------------------------------------------------------------

  group('normalizeGrammarTitleEn', () {
    test('returns empty string for null input', () {
      expect(normalizeGrammarTitleEn(null), isEmpty);
    });

    test('returns empty string for empty string input', () {
      expect(normalizeGrammarTitleEn(''), isEmpty);
    });

    test('replaces romaji title with Japanese version', () {
      expect(normalizeGrammarTitleEn('Because (kara)'), 'Because (から)');
    });

    test('replaces V-ru token', () {
      expect(
        normalizeGrammarTitleEn('Dictionary Form (V-ru)'),
        'Dictionary Form (V-る)',
      );
    });

    test('replaces multiple token occurrences in one string', () {
      // 'Want to do (V-tai)' contains 'V-tai' as a token
      expect(
        normalizeGrammarTitleEn('Want to do (V-tai)'),
        'Want to do (V-たい)',
      );
    });

    test('trims trailing/leading whitespace', () {
      expect(normalizeGrammarTitleEn('  Before ... (前に)  '), 'Before ... (前に)');
    });
  });

  // ---------------------------------------------------------------------------
  // normalizeGrammarStructureEn
  // ---------------------------------------------------------------------------

  group('normalizeGrammarStructureEn', () {
    test('returns empty string for null input', () {
      expect(normalizeGrammarStructureEn(null), isEmpty);
    });

    test('applies exact replacements', () {
      expect(normalizeGrammarStructureEn('V-て mo ii desu ka'), 'V-てもいいですか');
    });

    test('applies simple token replacements', () {
      expect(normalizeGrammarStructureEn('V-ru koto ni naru'), contains('V-る'));
    });

    test('applies regex word-boundary replacements for desu ka', () {
      expect(normalizeGrammarStructureEn('N desu ka'), contains('ですか'));
    });

    test('applies regex replacement for wa particle', () {
      // Standalone 'wa' → 'は'
      final result = normalizeGrammarStructureEn('N wa N desu');
      expect(result, contains('は'));
    });

    test('collapses double spaces', () {
      expect(normalizeGrammarStructureEn('N  desu'), isNot(contains('  ')));
    });
  });

  // ---------------------------------------------------------------------------
  // resolveEnglishGrammarLabel
  // ---------------------------------------------------------------------------

  group('resolveEnglishGrammarLabel', () {
    test('returns titleEn when it is clean English', () {
      final label = resolveEnglishGrammarLabel(
        titleEn: 'Existence at a place',
        meaningEn: null,
        connectionEn: null,
        connection: null,
        grammarPoint: null,
      );
      expect(label, 'Existence at a place');
    });

    test('falls through to grammarPoint when titleEn is empty', () {
      final label = resolveEnglishGrammarLabel(
        titleEn: '',
        meaningEn: null,
        connectionEn: null,
        connection: null,
        grammarPoint: '〜てはいけない',
      );
      expect(label, isNotEmpty);
    });

    test('returns default label when all inputs are empty/null', () {
      final label = resolveEnglishGrammarLabel(
        titleEn: null,
        meaningEn: null,
        connectionEn: null,
        connection: null,
        grammarPoint: null,
      );
      expect(label, 'Target pattern');
    });

    test('skips Vietnamese-containing candidate', () {
      final label = resolveEnglishGrammarLabel(
        titleEn: 'động từ', // Vietnamese
        meaningEn: 'State of being',
        connectionEn: null,
        connection: null,
        grammarPoint: null,
      );
      // Should skip the Vietnamese title and use meaningEn
      expect(label, 'State of being');
    });
  });

  // ---------------------------------------------------------------------------
  // resolveEnglishGrammarMeaning
  // ---------------------------------------------------------------------------

  group('resolveEnglishGrammarMeaning', () {
    test('returns meaningEn when available and clean', () {
      final meaning = resolveEnglishGrammarMeaning(
        meaningEn: 'expresses prohibition',
        titleEn: 'Must not ...',
        connectionEn: null,
        connection: null,
        grammarPoint: null,
      );
      expect(meaning, 'expresses prohibition');
    });

    test('returns default when all inputs are empty', () {
      final meaning = resolveEnglishGrammarMeaning(
        meaningEn: null,
        titleEn: null,
        connectionEn: null,
        connection: null,
        grammarPoint: null,
      );
      expect(meaning, 'Target pattern');
    });
  });

  // ---------------------------------------------------------------------------
  // resolveEnglishGrammarConnection
  // ---------------------------------------------------------------------------

  group('resolveEnglishGrammarConnection', () {
    test('returns connectionEn when available', () {
      final conn = resolveEnglishGrammarConnection(
        connectionEn: 'V-てはいけません',
        connection: null,
        grammarPoint: null,
        titleEn: null,
        meaningEn: null,
      );
      expect(conn, isNotEmpty);
    });

    test('returns default when all inputs are empty', () {
      final conn = resolveEnglishGrammarConnection(
        connectionEn: null,
        connection: null,
        grammarPoint: null,
        titleEn: null,
        meaningEn: null,
      );
      expect(conn, 'Grammar pattern');
    });
  });

  // ---------------------------------------------------------------------------
  // resolveEnglishGrammarExplanation
  // ---------------------------------------------------------------------------

  group('resolveEnglishGrammarExplanation', () {
    test('returns explanationEn when it is clean', () {
      final result = resolveEnglishGrammarExplanation(
        explanationEn: 'Used to express prohibition.',
        explanation: null,
        label: null,
      );
      expect(result, 'Used to express prohibition.');
    });

    test('falls back to explanation when explanationEn is empty', () {
      final result = resolveEnglishGrammarExplanation(
        explanationEn: '',
        explanation: 'Fallback explanation.',
        label: null,
      );
      expect(result, 'Fallback explanation.');
    });

    test('uses label-based default when both explanations are empty', () {
      final result = resolveEnglishGrammarExplanation(
        explanationEn: '',
        explanation: null,
        label: 'てはいけない',
      );
      expect(result, contains('てはいけない'));
    });

    test('returns generic default when all inputs are null', () {
      final result = resolveEnglishGrammarExplanation(
        explanationEn: null,
        explanation: null,
        label: null,
      );
      expect(result, 'Use the target pattern in the right context.');
    });

    test('skips Vietnamese explanationEn and falls back', () {
      final result = resolveEnglishGrammarExplanation(
        explanationEn: 'Dùng động từ thể ている.',
        explanation: 'Used to express ongoing action.',
        label: null,
      );
      expect(result, 'Used to express ongoing action.');
    });
  });

  // ---------------------------------------------------------------------------
  // resolveEnglishGrammarExampleTranslation
  // ---------------------------------------------------------------------------

  group('resolveEnglishGrammarExampleTranslation', () {
    test('returns translationEn when available', () {
      final result = resolveEnglishGrammarExampleTranslation(
        japanese: '毎日勉強します。',
        translationEn: 'I study every day.',
        translation: null,
      );
      expect(result, 'I study every day.');
    });

    test('falls back to translation when translationEn is empty', () {
      final result = resolveEnglishGrammarExampleTranslation(
        japanese: '毎日勉強します。',
        translationEn: '',
        translation: 'I study every day (vi).',
      );
      expect(result, 'I study every day (vi).');
    });

    test('falls back to japanese when both translations are empty', () {
      final result = resolveEnglishGrammarExampleTranslation(
        japanese: '毎日勉強します。',
        translationEn: '',
        translation: null,
      );
      expect(result, '毎日勉強します。');
    });

    test('skips Vietnamese translation and falls back to japanese', () {
      final result = resolveEnglishGrammarExampleTranslation(
        japanese: '毎日勉強します。',
        translationEn: 'Tôi học mỗi ngày.',
        translation: null,
      );
      expect(result, '毎日勉強します。');
    });
  });
}
