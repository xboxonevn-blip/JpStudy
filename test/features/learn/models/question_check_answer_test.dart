import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';

// ── Helpers ───────────────────────────────────────────────────

const _vocab = VocabItem(
  id: 1, term: '水', reading: 'みず', meaning: 'nước', meaningEn: 'water', level: 'N5',
);

Question _mc(String correctAnswer, {List<String>? options}) => Question(
  id: 'q', type: QuestionType.multipleChoice,
  targetItem: _vocab, questionText: 'Q?',
  correctAnswer: correctAnswer,
  options: options ?? [correctAnswer, 'wrong'],
);

Question _tf({required bool isTrue}) => Question(
  id: 'q', type: QuestionType.trueFalse,
  targetItem: _vocab, questionText: '水 means water',
  correctAnswer: isTrue ? 'true' : 'false',
  isStatementTrue: isTrue,
);

Question _fb(String correctAnswer) => Question(
  id: 'q', type: QuestionType.fillBlank,
  targetItem: _vocab, questionText: 'Fill in: ___',
  correctAnswer: correctAnswer,
);

// ── Multiple Choice ───────────────────────────────────────────

void main() {
  group('Question.checkAnswer — multipleChoice', () {
    test('exact correct answer returns true', () {
      expect(_mc('water').checkAnswer('water'), isTrue);
    });

    test('wrong answer returns false', () {
      expect(_mc('water').checkAnswer('fire'), isFalse);
    });

    test('case-insensitive match', () {
      expect(_mc('Water').checkAnswer('water'), isTrue);
      expect(_mc('water').checkAnswer('WATER'), isTrue);
      expect(_mc('WATER').checkAnswer('Water'), isTrue);
    });

    test('trims leading and trailing whitespace', () {
      expect(_mc('water').checkAnswer('  water  '), isTrue);
      expect(_mc('  water  ').checkAnswer('water'), isTrue);
    });

    test('empty answer does not match non-empty correct', () {
      expect(_mc('water').checkAnswer(''), isFalse);
    });

    test('partial match returns false — no fuzzy for multiple choice', () {
      expect(_mc('waterfall').checkAnswer('water'), isFalse);
    });
  });

  // ── True / False ──────────────────────────────────────────────

  group('Question.checkAnswer — trueFalse', () {
    test('true question: "true" answer is correct', () {
      expect(_tf(isTrue: true).checkAnswer('true'), isTrue);
    });

    test('true question: "false" answer is wrong', () {
      expect(_tf(isTrue: true).checkAnswer('false'), isFalse);
    });

    test('false question: "false" answer is correct', () {
      expect(_tf(isTrue: false).checkAnswer('false'), isTrue);
    });

    test('false question: "true" answer is wrong', () {
      expect(_tf(isTrue: false).checkAnswer('true'), isFalse);
    });

    test('case-insensitive: "True" and "TRUE" accepted', () {
      expect(_tf(isTrue: true).checkAnswer('True'), isTrue);
      expect(_tf(isTrue: true).checkAnswer('TRUE'), isTrue);
    });

    test('arbitrary string is not accepted', () {
      expect(_tf(isTrue: true).checkAnswer('yes'), isFalse);
      expect(_tf(isTrue: false).checkAnswer('no'), isFalse);
    });
  });

  // ── Fill-in-blank — exact match ───────────────────────────────

  group('Question.checkAnswer — fillBlank exact', () {
    test('exact correct answer returns true', () {
      expect(_fb('water').checkAnswer('water'), isTrue);
    });

    test('case-insensitive exact match', () {
      expect(_fb('water').checkAnswer('WATER'), isTrue);
    });

    test('whitespace trimmed', () {
      expect(_fb('water').checkAnswer('  water  '), isTrue);
    });

    test('wrong answer returns false', () {
      expect(_fb('water').checkAnswer('fire'), isFalse);
    });

    test('empty answer vs non-empty correct returns false', () {
      expect(_fb('water').checkAnswer(''), isFalse);
    });
  });

  // ── Fill-in-blank — fuzzy matching (Levenshtein) ─────────────

  group('Question.checkAnswer — fillBlank fuzzy', () {
    // Fuzzy only applies when correctAnswer.length > 4

    test('edit distance 1 accepted for long word (> 4 chars)', () {
      // "watsr" vs "water": distance 1
      expect(_fb('water').checkAnswer('watsr'), isTrue);
    });

    test('edit distance 2 accepted for long word', () {
      // "wattr" vs "water": distance 2
      expect(_fb('water').checkAnswer('wattr'), isTrue);
    });

    test('edit distance 3 rejected for long word', () {
      // "waxxx" vs "water": distance 3 (a→a, t→x, e→x, r→x)
      expect(_fb('water').checkAnswer('waxxx'), isFalse);
    });

    test('short correct answer (≤4 chars) requires exact match', () {
      // "fire" length == 4, no fuzzy
      expect(_fb('fire').checkAnswer('fir'), isFalse);
    });

    test('correct answer exactly 4 chars — boundary: no fuzzy', () {
      // length 4 does NOT trigger fuzzy (condition is > 4)
      expect(_fb('rain').checkAnswer('rein'), isFalse);
    });

    test('correct answer 5 chars — triggers fuzzy', () {
      // "earth" length 5, edit distance 1 accepted
      expect(_fb('earth').checkAnswer('earht'), isTrue);
    });

    test('completely different short answer is not fuzzy-accepted', () {
      expect(_fb('water').checkAnswer('xyz'), isFalse);
    });
  });

  // ── Fill-in-blank — alternative splitting ─────────────────────
  //
  // NOTE: The regex in _splitAlternatives uses a raw string:
  //   r'\s*(?:/|／|\\bor\\b|;|\\|)\\s*'
  // In a raw string, \\b is a literal two-char sequence (backslash + b),
  // not a regex word boundary. As a result, the "or" separator only matches
  // the literal text "\\bor\\b" — not the word "or" surrounded by boundaries.
  // The trailing \\s* also matches literal "\s*", not whitespace.
  // The tests below document the ACTUAL current behavior.

  group('Question.checkAnswer — fillBlank alternatives', () {
    test('slash / separates alternatives', () {
      final q = _fb('water / eau');
      expect(q.checkAnswer('water'), isTrue);
      expect(q.checkAnswer('eau'), isTrue);
      expect(q.checkAnswer('fire'), isFalse);
    });

    test('full-width slash ／ separates alternatives', () {
      final q = _fb('water／eau');
      expect(q.checkAnswer('water'), isTrue);
      expect(q.checkAnswer('eau'), isTrue);
    });

    test('semicolon ; separates alternatives', () {
      final q = _fb('water;eau');
      expect(q.checkAnswer('water'), isTrue);
      expect(q.checkAnswer('eau'), isTrue);
    });

    test('"or" word boundary splits alternatives', () {
      // \bor\b correctly splits "water or fire" into ["water", "fire"]
      final q = _fb('water or fire');
      expect(q.checkAnswer('water'), isTrue);
      expect(q.checkAnswer('fire'), isTrue);
      expect(q.checkAnswer('sky'), isFalse);
    });

    test('pipe | separates alternatives', () {
      final q = _fb('water|fire');
      expect(q.checkAnswer('water'), isTrue);
      expect(q.checkAnswer('fire'), isTrue);
    });

    test('multiple / alternatives, first one matches', () {
      final q = _fb('dog / canine / hound');
      expect(q.checkAnswer('dog'), isTrue);
      expect(q.checkAnswer('canine'), isTrue);
      expect(q.checkAnswer('hound'), isTrue);
      expect(q.checkAnswer('cat'), isFalse);
    });

    test('fuzzy match works within each alternative', () {
      // "canine" is 6 chars, so fuzzy applies; 1-char typo accepted
      final q = _fb('dog / canine');
      expect(q.checkAnswer('cannie'), isTrue); // edit distance 1
    });

    test('correct answer with only spaces normalizes correctly', () {
      final q = _fb('   water   ');
      expect(q.checkAnswer('water'), isTrue);
    });

    test('all alternatives rejected returns false', () {
      final q = _fb('dog / cat');
      expect(q.checkAnswer('bird'), isFalse);
    });
  });

  // ── Levenshtein edge cases ────────────────────────────────────

  group('Question.checkAnswer — Levenshtein edge cases', () {
    test('empty input vs long correct: rejected', () {
      // edit distance == len(correct) which is >> 2
      expect(_fb('water').checkAnswer(''), isFalse);
    });

    test('insertion only — one extra char', () {
      // "waater" vs "water": distance 1
      expect(_fb('water').checkAnswer('waater'), isTrue);
    });

    test('deletion only — one missing char', () {
      // "watr" vs "water": distance 1
      // But "watr" has length 4, and correctAnswer "water" length 5 > 4 — fuzzy kicks in
      expect(_fb('water').checkAnswer('watr'), isTrue);
    });

    test('transposition counted as 2 substitutions', () {
      // Levenshtein counts transposition as 2 ops (not Damerau-Levenshtein)
      // "waetr" vs "water": swap a↔e → distance 2 → accepted
      expect(_fb('water').checkAnswer('waetr'), isTrue);
    });

    test('Japanese term (exact only — short)', () {
      // みず is 3 chars, length ≤ 4, so no fuzzy
      expect(_fb('みず').checkAnswer('みず'), isTrue);
      expect(_fb('みず').checkAnswer('みざ'), isFalse); // edit distance 1 but short
    });

    test('longer Japanese term uses fuzzy', () {
      // かいもの is 5 chars — triggers fuzzy
      expect(_fb('かいもの').checkAnswer('かいもの'), isTrue);
      // Note: 'かいもの' length is 4 chars, still no fuzzy.
      // Use longer: 'たべもの' (4), 'おかあさん' (5)
      expect(_fb('おかあさん').checkAnswer('おかあさに'), isTrue); // edit 1
    });
  });
}
