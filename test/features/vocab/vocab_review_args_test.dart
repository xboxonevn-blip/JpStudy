import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';

void main() {
  // ── hasLessonRange ─────────────────────────────────────────────────────────

  group('VocabReviewArgs.hasLessonRange', () {
    test('false when both lesson bounds are null', () {
      const args = VocabReviewArgs(source: 'home');
      expect(args.hasLessonRange, isFalse);
    });

    test('false when only lessonStart is set', () {
      const args = VocabReviewArgs(source: 'home', lessonStart: 1);
      expect(args.hasLessonRange, isFalse);
    });

    test('false when only lessonEnd is set', () {
      const args = VocabReviewArgs(source: 'home', lessonEnd: 5);
      expect(args.hasLessonRange, isFalse);
    });

    test('true when both bounds are set (even equal)', () {
      const args = VocabReviewArgs(
        source: 'home',
        lessonStart: 3,
        lessonEnd: 3,
      );
      expect(args.hasLessonRange, isTrue);
    });
  });

  // ── toQueryParameters ──────────────────────────────────────────────────────
  //
  // The map is built with conditional keys: a key only appears when the field
  // is non-null and (for strings) non-empty after trimming. `source` is the
  // only mandatory key. This is the contract the legacy go_router parses.

  group('VocabReviewArgs.toQueryParameters', () {
    test('source is always present', () {
      const args = VocabReviewArgs(source: 'home');
      final params = args.toQueryParameters();
      expect(params['source'], 'home');
    });

    test('only source key when nothing else is set', () {
      const args = VocabReviewArgs(source: 'home');
      expect(args.toQueryParameters().keys, ['source']);
    });

    test('includes all fields when set', () {
      const args = VocabReviewArgs(
        source: 'home',
        levelCode: 'N5',
        series: 'hajimete',
        lessonStart: 1,
        lessonEnd: 5,
        title: 'Vocabulary review',
        subtitle: 'Lesson 1-5',
      );
      final params = args.toQueryParameters();
      expect(params, {
        'title': 'Vocabulary review',
        'subtitle': 'Lesson 1-5',
        'lessonStart': '1',
        'lessonEnd': '5',
        'level': 'N5',
        'series': 'hajimete',
        'source': 'home',
      });
    });

    test('trims whitespace from string fields', () {
      const args = VocabReviewArgs(
        source: 'home',
        levelCode: '  N4  ',
        series: '\thajimete\n',
        title: ' Hello ',
        subtitle: ' Sub ',
      );
      final params = args.toQueryParameters();
      expect(params['level'], 'N4');
      expect(params['series'], 'hajimete');
      expect(params['title'], 'Hello');
      expect(params['subtitle'], 'Sub');
    });

    test('omits whitespace-only string fields', () {
      // Empty-after-trim fields should NOT appear in the output map.
      const args = VocabReviewArgs(
        source: 'home',
        levelCode: '   ',
        series: '\t\n',
        title: '',
        subtitle: '   ',
      );
      final params = args.toQueryParameters();
      expect(params.containsKey('level'), isFalse);
      expect(params.containsKey('series'), isFalse);
      expect(params.containsKey('title'), isFalse);
      expect(params.containsKey('subtitle'), isFalse);
    });

    test('lessonStart=0 and lessonEnd=0 are still serialized', () {
      // Numeric 0 is not null, so the key should appear with "0".
      const args = VocabReviewArgs(
        source: 'home',
        lessonStart: 0,
        lessonEnd: 0,
      );
      final params = args.toQueryParameters();
      expect(params['lessonStart'], '0');
      expect(params['lessonEnd'], '0');
    });

    test('serializes only one lesson bound when only one is set', () {
      const args = VocabReviewArgs(source: 'home', lessonStart: 2);
      final params = args.toQueryParameters();
      expect(params['lessonStart'], '2');
      expect(params.containsKey('lessonEnd'), isFalse);
    });
  });

  // ── fromLegacyQuery ────────────────────────────────────────────────────────
  //
  // Inverse of toQueryParameters, but tolerant of missing/malformed inputs:
  // - missing 'source' falls back to 'legacy' (so legacy URLs still resolve)
  // - lessonStart/lessonEnd parse via int.tryParse so non-numeric → null
  // - levelCode/series/title/subtitle pass through nullable

  group('VocabReviewArgs.fromLegacyQuery', () {
    test('round-trip preserves all set fields', () {
      const original = VocabReviewArgs(
        source: 'home',
        levelCode: 'N3',
        series: 'minna',
        lessonStart: 2,
        lessonEnd: 8,
        title: 'My title',
        subtitle: 'My subtitle',
      );
      final restored = VocabReviewArgs.fromLegacyQuery(
        original.toQueryParameters(),
      );
      expect(restored.source, 'home');
      expect(restored.levelCode, 'N3');
      expect(restored.series, 'minna');
      expect(restored.lessonStart, 2);
      expect(restored.lessonEnd, 8);
      expect(restored.title, 'My title');
      expect(restored.subtitle, 'My subtitle');
    });

    test('missing source defaults to "legacy"', () {
      final args = VocabReviewArgs.fromLegacyQuery(<String, String>{});
      expect(args.source, 'legacy');
    });

    test('missing optional fields stay null', () {
      final args = VocabReviewArgs.fromLegacyQuery({'source': 'home'});
      expect(args.levelCode, isNull);
      expect(args.series, isNull);
      expect(args.lessonStart, isNull);
      expect(args.lessonEnd, isNull);
      expect(args.title, isNull);
      expect(args.subtitle, isNull);
    });

    test('non-numeric lessonStart parses to null (no crash)', () {
      final args = VocabReviewArgs.fromLegacyQuery({
        'source': 'home',
        'lessonStart': 'not-a-number',
      });
      expect(args.lessonStart, isNull);
    });

    test('non-numeric lessonEnd parses to null (no crash)', () {
      final args = VocabReviewArgs.fromLegacyQuery({
        'source': 'home',
        'lessonEnd': '∞',
      });
      expect(args.lessonEnd, isNull);
    });

    test('empty-string lesson bounds parse to null', () {
      // int.tryParse('') returns null.
      final args = VocabReviewArgs.fromLegacyQuery({
        'source': 'home',
        'lessonStart': '',
        'lessonEnd': '',
      });
      expect(args.lessonStart, isNull);
      expect(args.lessonEnd, isNull);
    });

    test('reads "level" key (not "levelCode") for backwards compat', () {
      // The legacy URL uses "level" — confirm this is still wired.
      final args = VocabReviewArgs.fromLegacyQuery({
        'source': 'home',
        'level': 'N5',
      });
      expect(args.levelCode, 'N5');
    });
  });
}
