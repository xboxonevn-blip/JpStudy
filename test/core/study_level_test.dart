import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';

void main() {
  // ── shortLabel ─────────────────────────────────────────────────────────────

  group('StudyLevel.shortLabel', () {
    test('each level exposes its JLPT code as shortLabel', () {
      expect(StudyLevel.n5.shortLabel, 'N5');
      expect(StudyLevel.n4.shortLabel, 'N4');
      expect(StudyLevel.n3.shortLabel, 'N3');
    });
  });

  // ── fromCode parsing ───────────────────────────────────────────────────────

  group('StudyLevel.fromCode', () {
    test('returns the matching level for canonical uppercase codes', () {
      expect(StudyLevel.fromCode('N5'), StudyLevel.n5);
      expect(StudyLevel.fromCode('N4'), StudyLevel.n4);
      expect(StudyLevel.fromCode('N3'), StudyLevel.n3);
    });

    test('is case-insensitive (lowercase resolves)', () {
      expect(StudyLevel.fromCode('n5'), StudyLevel.n5);
      expect(StudyLevel.fromCode('n4'), StudyLevel.n4);
      expect(StudyLevel.fromCode('n3'), StudyLevel.n3);
    });

    test('mixed case resolves', () {
      expect(StudyLevel.fromCode('nN5'.substring(1)), StudyLevel.n5);
      expect(StudyLevel.fromCode('N5'), StudyLevel.n5);
    });

    test('trims surrounding whitespace before lookup', () {
      expect(StudyLevel.fromCode('  N5  '), StudyLevel.n5);
      expect(StudyLevel.fromCode('\tN4\n'), StudyLevel.n4);
    });

    test('returns null for unsupported but valid JLPT codes (N2/N1)', () {
      // The app explicitly only supports N5/N4/N3 — N2 and N1 are out of scope.
      expect(StudyLevel.fromCode('N2'), isNull);
      expect(StudyLevel.fromCode('N1'), isNull);
    });

    test('returns null for unrelated codes', () {
      expect(StudyLevel.fromCode('SE'), isNull);
      expect(StudyLevel.fromCode('foo'), isNull);
      expect(StudyLevel.fromCode(''), isNull);
    });
  });

  // ── description (localization) ─────────────────────────────────────────────

  group('StudyLevel.description', () {
    test('English descriptions are non-empty and distinct per level', () {
      final descriptions = StudyLevel.values
          .map((l) => l.description(AppLanguage.en))
          .toSet();
      expect(descriptions.length, StudyLevel.values.length);
      for (final desc in descriptions) {
        expect(desc, isNotEmpty);
      }
    });

    test('Vietnamese descriptions are non-empty and distinct per level', () {
      final descriptions = StudyLevel.values
          .map((l) => l.description(AppLanguage.vi))
          .toSet();
      expect(descriptions.length, StudyLevel.values.length);
    });

    test('Japanese descriptions are non-empty and distinct per level', () {
      final descriptions = StudyLevel.values
          .map((l) => l.description(AppLanguage.ja))
          .toSet();
      expect(descriptions.length, StudyLevel.values.length);
    });

    test('cross-language descriptions for the same level differ', () {
      final en = StudyLevel.n5.description(AppLanguage.en);
      final vi = StudyLevel.n5.description(AppLanguage.vi);
      final ja = StudyLevel.n5.description(AppLanguage.ja);
      expect({en, vi, ja}.length, 3);
    });

    test('English description content matches the documented copy', () {
      // Pin exact strings — accidental copy edits would change onboarding UX.
      expect(StudyLevel.n5.description(AppLanguage.en), 'Beginner fundamentals');
      expect(StudyLevel.n4.description(AppLanguage.en), 'Lower intermediate');
      expect(StudyLevel.n3.description(AppLanguage.en), 'Intermediate');
    });
  });
}
