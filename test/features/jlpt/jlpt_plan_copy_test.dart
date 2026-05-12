import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_plan_copy.dart';

void main() {
  // jlpt_plan_copy.dart is a flat table of "Open X" action labels used as
  // CTA text in the JLPT plan widgets. Pin the EN strings (most likely to
  // get accidentally edited) and assert all three languages return non-empty
  // distinct values for every function (catches missing translations).

  // Each entry: (function, expectedEnglish)
  final localizers = <(String Function(AppLanguage), String)>[
    (jlptMiniMockPhaseLabel, 'Mini mock'),
    (jlptActionOpenRepairCheck, 'Open repair check'),
    (jlptActionOpenPrecisionCheck, 'Open precision check'),
    (jlptActionOpenTimedCheck, 'Open timed check'),
    (jlptActionOpenCoverageCheck, 'Open coverage check'),
    (jlptActionOpenCheckpoint, 'Open checkpoint'),
    (jlptActionOpenGrammarDrill, 'Open grammar drill'),
    (jlptActionOpenSpeedQuiz, 'Open speed quiz'),
    (jlptActionOpenFillBlankDrill, 'Open fill-in drill'),
    (jlptActionOpenTimedGrammar, 'Open timed grammar'),
    (jlptActionOpenHandwriting, 'Open handwriting'),
    (jlptActionOpenKanjiPractice, 'Open kanji practice'),
    (jlptActionOpenKanjiReading, 'Open kanji reading'),
    (jlptActionOpenImmersion, 'Open immersion'),
    (jlptActionOpenReadingDrill, 'Open reading drill'),
    (jlptActionOpenFinalReadingCheck, 'Open final reading check'),
  ];

  // ── EN string contracts ───────────────────────────────────────────────────
  //
  // Pin the exact English copy. UX writers can update this intentionally
  // — but accidental edits (via auto-complete or refactors) break here.

  group('jlpt_plan_copy English strings', () {
    for (final (fn, expectedEn) in localizers) {
      test('$expectedEn — EN matches expected', () {
        expect(fn(AppLanguage.en), expectedEn);
      });
    }
  });

  // ── completeness across languages ─────────────────────────────────────────

  group('jlpt_plan_copy completeness', () {
    test('every localizer returns non-empty for all three languages', () {
      for (final (fn, _) in localizers) {
        for (final lang in AppLanguage.values) {
          expect(
            fn(lang),
            isNotEmpty,
            reason: '${fn.runtimeType} returned empty for $lang',
          );
        }
      }
    });

    test(
      'every localizer returns three distinct strings (no missing translations)',
      () {
        // A common bug: VI and JA cases get copy-pasted from EN. Assert that
        // each function gives a unique string per language.
        for (final (fn, _) in localizers) {
          final outputs = AppLanguage.values.map(fn).toSet();
          expect(
            outputs.length,
            AppLanguage.values.length,
            reason:
                '${fn.runtimeType} produced duplicate strings across languages',
          );
        }
      },
    );
  });

  // ── EN convention: "Open X" prefix ────────────────────────────────────────

  group('jlpt_plan_copy EN convention', () {
    test('every action localizer (except mini mock) starts with "Open"', () {
      // The mini mock label is a noun phrase, not a CTA verb — exclude it.
      for (final (fn, expectedEn) in localizers) {
        if (fn == jlptMiniMockPhaseLabel) continue;
        expect(
          expectedEn.startsWith('Open '),
          isTrue,
          reason: 'EN copy "$expectedEn" should begin with "Open "',
        );
      }
    });
  });
}
