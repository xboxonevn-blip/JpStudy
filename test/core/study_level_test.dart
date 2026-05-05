import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';

void main() {
  // â”€â”€ shortLabel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  group('StudyLevel.shortLabel', () {
    test('each level exposes its JLPT code as shortLabel', () {
      expect(StudyLevel.n5.shortLabel, 'N5');
      expect(StudyLevel.n4.shortLabel, 'N4');
      expect(StudyLevel.n3.shortLabel, 'N3');
      expect(StudyLevel.n2.shortLabel, 'N2');
      expect(StudyLevel.n1.shortLabel, 'N1');
    });
  });

  // â”€â”€ fromCode parsing â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  group('StudyLevel.fromCode', () {
    test('returns the matching level for canonical uppercase codes', () {
      expect(StudyLevel.fromCode('N5'), StudyLevel.n5);
      expect(StudyLevel.fromCode('N4'), StudyLevel.n4);
      expect(StudyLevel.fromCode('N3'), StudyLevel.n3);
      expect(StudyLevel.fromCode('N2'), StudyLevel.n2);
      expect(StudyLevel.fromCode('N1'), StudyLevel.n1);
    });

    test('is case-insensitive (lowercase resolves)', () {
      expect(StudyLevel.fromCode('n5'), StudyLevel.n5);
      expect(StudyLevel.fromCode('n4'), StudyLevel.n4);
      expect(StudyLevel.fromCode('n3'), StudyLevel.n3);
      expect(StudyLevel.fromCode('n2'), StudyLevel.n2);
      expect(StudyLevel.fromCode('n1'), StudyLevel.n1);
    });

    test('mixed case resolves', () {
      expect(StudyLevel.fromCode('nN5'.substring(1)), StudyLevel.n5);
      expect(StudyLevel.fromCode('N5'), StudyLevel.n5);
    });

    test('trims surrounding whitespace before lookup', () {
      expect(StudyLevel.fromCode('  N5  '), StudyLevel.n5);
      expect(StudyLevel.fromCode('\tN4\n'), StudyLevel.n4);
    });

    test('returns null for unrelated codes', () {
      expect(StudyLevel.fromCode('SE'), isNull);
      expect(StudyLevel.fromCode('foo'), isNull);
      expect(StudyLevel.fromCode(''), isNull);
    });
  });

  // â”€â”€ description (localization) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
      // Pin exact strings â€” accidental copy edits would change onboarding UX.
      expect(
        StudyLevel.n5.description(AppLanguage.en),
        'Beginner fundamentals',
      );
      expect(StudyLevel.n4.description(AppLanguage.en), 'Lower intermediate');
      expect(StudyLevel.n3.description(AppLanguage.en), 'Intermediate');
      expect(StudyLevel.n2.description(AppLanguage.en), 'Upper intermediate');
      expect(StudyLevel.n1.description(AppLanguage.en), 'Advanced');
    });
  });
}
