import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/features/kanji_reading/models/kanji_reading_question.dart';

void main() {
  KanjiItem kanji({
    int id = 1,
    String character = '日',
    String? onyomi = 'ニチ',
    String? kunyomi = 'ひ',
  }) {
    return KanjiItem(
      id: id,
      lessonId: 1,
      character: character,
      strokeCount: 4,
      onyomi: onyomi,
      kunyomi: kunyomi,
      meaning: 'ngày',
      examples: const [],
      jlptLevel: 'N5',
    );
  }

  // ── prompt getter ─────────────────────────────────────────────────────────

  group('KanjiReadingQuestion.prompt', () {
    test('kanjiToReading mode returns the kanji character', () {
      final q = KanjiReadingQuestion(
        target: kanji(character: '本'),
        options: const ['ホン', 'ニチ', 'ガク', 'コク'],
        correctIndex: 0,
        mode: KanjiQuizMode.kanjiToReading,
      );
      expect(q.prompt, '本');
    });

    test('readingToKanji mode prefers onyomi over kunyomi', () {
      // Implementation: _reading uses onyomi ?? kunyomi ?? character.
      final q = KanjiReadingQuestion(
        target: kanji(onyomi: 'ニチ', kunyomi: 'ひ'),
        options: const ['日', '本', '月', '火'],
        correctIndex: 0,
        mode: KanjiQuizMode.readingToKanji,
      );
      expect(q.prompt, 'ニチ');
    });

    test('readingToKanji mode falls back to kunyomi when onyomi is null', () {
      final q = KanjiReadingQuestion(
        target: kanji(onyomi: null, kunyomi: 'ひ'),
        options: const ['日', '本'],
        correctIndex: 0,
        mode: KanjiQuizMode.readingToKanji,
      );
      expect(q.prompt, 'ひ');
    });

    test(
      'readingToKanji mode falls back to character when both readings are null',
      () {
        // Pathological — kanji with no readings stored — but the lookup must
        // not crash. The character itself is the safest fallback.
        final q = KanjiReadingQuestion(
          target: kanji(character: '?', onyomi: null, kunyomi: null),
          options: const ['?', '!'],
          correctIndex: 0,
          mode: KanjiQuizMode.readingToKanji,
        );
        expect(q.prompt, '?');
      },
    );
  });

  // ── promptLabel ───────────────────────────────────────────────────────────

  group('KanjiReadingQuestion.promptLabel', () {
    test('kanjiToReading shows "what reading is this?" in Japanese', () {
      final q = KanjiReadingQuestion(
        target: kanji(),
        options: const ['a', 'b'],
        correctIndex: 0,
        mode: KanjiQuizMode.kanjiToReading,
      );
      expect(q.promptLabel, 'この漢字の読みは？');
    });

    test('readingToKanji shows "which kanji is this reading?" in Japanese', () {
      final q = KanjiReadingQuestion(
        target: kanji(),
        options: const ['a', 'b'],
        correctIndex: 0,
        mode: KanjiQuizMode.readingToKanji,
      );
      expect(q.promptLabel, 'この読みの漢字は？');
    });
  });

  // ── generate factory: empty / sparse pools ────────────────────────────────
  //
  // generate has guard rails: it returns [] when the pool can't produce a
  // valid question (no usable target, or fewer than 4 options for distractors).

  group('KanjiReadingQuestion.generate — guards', () {
    test('returns empty when pool is empty', () {
      final result = KanjiReadingQuestion.generate(const <KanjiItem>[]);
      expect(result, isEmpty);
    });

    test('returns empty when no kanji has any reading', () {
      final pool = [
        kanji(id: 1, onyomi: null, kunyomi: null),
        kanji(id: 2, onyomi: null, kunyomi: null),
        kanji(id: 3, onyomi: null, kunyomi: null),
        kanji(id: 4, onyomi: null, kunyomi: null),
        kanji(id: 5, onyomi: null, kunyomi: null),
      ];
      // No kanji passes the "has onyomi or kunyomi" filter, so usableTargets
      // is empty → guard returns [].
      expect(KanjiReadingQuestion.generate(pool), isEmpty);
    });

    test('returns empty when pool has fewer than 4 usable options', () {
      // Need at least 4 usable options to build distractors (3 + 1 correct).
      final pool = [
        kanji(id: 1, character: '日', onyomi: 'ニチ'),
        kanji(id: 2, character: '本', onyomi: 'ホン'),
        kanji(id: 3, character: '月', onyomi: 'ガツ'),
      ];
      // Only 3 usable options — guard returns [].
      expect(KanjiReadingQuestion.generate(pool), isEmpty);
    });

    test('whitespace-only readings are filtered out as not usable', () {
      // onyomi/kunyomi that trim to empty don't count as readings.
      final pool = [
        kanji(id: 1, onyomi: '   ', kunyomi: '\t\n'),
        kanji(id: 2, onyomi: '', kunyomi: ''),
        kanji(id: 3, onyomi: 'ニチ'),
        kanji(id: 4, onyomi: 'ホン'),
        kanji(id: 5, onyomi: 'ガツ'),
      ];
      // Only 3 usable — guard returns [].
      expect(KanjiReadingQuestion.generate(pool), isEmpty);
    });
  });

  // ── generate factory: invariants on output ────────────────────────────────
  //
  // Each generated question must satisfy:
  // - exactly 4 options
  // - correctIndex in [0, 3]
  // - the option at correctIndex actually matches the prompt's expected answer
  // - target is from the input pool
  // - count is respected (clamped to pool size)

  group('KanjiReadingQuestion.generate — output invariants', () {
    final fivePool = [
      kanji(id: 1, character: '日', onyomi: 'ニチ'),
      kanji(id: 2, character: '本', onyomi: 'ホン'),
      kanji(id: 3, character: '月', onyomi: 'ガツ'),
      kanji(id: 4, character: '火', onyomi: 'カ'),
      kanji(id: 5, character: '水', onyomi: 'スイ'),
    ];

    test('returns up to count questions', () {
      final result = KanjiReadingQuestion.generate(fivePool, count: 3);
      expect(result.length, lessThanOrEqualTo(3));
      expect(result, isNotEmpty);
    });

    test('count clamped to pool size when count exceeds pool', () {
      // Asking for 100 when only 5 usable targets → at most 5.
      final result = KanjiReadingQuestion.generate(fivePool, count: 100);
      expect(result.length, lessThanOrEqualTo(5));
    });

    test('every question has exactly 4 options', () {
      final result = KanjiReadingQuestion.generate(fivePool, count: 5);
      for (final q in result) {
        expect(q.options.length, 4);
      }
    });

    test('every correctIndex falls within [0, 3]', () {
      final result = KanjiReadingQuestion.generate(fivePool, count: 5);
      for (final q in result) {
        expect(q.correctIndex, inInclusiveRange(0, 3));
      }
    });

    test(
      'the option at correctIndex matches the expected answer for each mode',
      () {
        final result = KanjiReadingQuestion.generate(fivePool, count: 5);
        for (final q in result) {
          final expected = q.mode == KanjiQuizMode.kanjiToReading
              ? (q.target.onyomi ?? q.target.kunyomi ?? q.target.character)
              : q.target.character;
          expect(q.options[q.correctIndex], expected);
        }
      },
    );

    test('target of every question is one of the input pool items', () {
      final ids = fivePool.map((k) => k.id).toSet();
      final result = KanjiReadingQuestion.generate(fivePool, count: 5);
      for (final q in result) {
        expect(ids, contains(q.target.id));
      }
    });

    test('honors a separate distractorPool when provided', () {
      // Targets come from `pool`, but option strings should be drawn from
      // the (larger) distractorPool. We verify by giving a tiny pool with
      // only ONE usable target, and a richer distractor pool.
      final tinyPool = [kanji(id: 100, character: '夜', onyomi: 'ヤ')];
      final richDistractors = [
        kanji(id: 1, character: '日', onyomi: 'ニチ'),
        kanji(id: 2, character: '本', onyomi: 'ホン'),
        kanji(id: 3, character: '月', onyomi: 'ガツ'),
        kanji(id: 4, character: '火', onyomi: 'カ'),
        kanji(id: 5, character: '水', onyomi: 'スイ'),
      ];
      final result = KanjiReadingQuestion.generate(
        tinyPool,
        count: 1,
        distractorPool: richDistractors,
      );
      expect(result.length, 1);
      // Target id is from tinyPool, not the distractor pool.
      expect(result.first.target.id, 100);
    });
  });
}
