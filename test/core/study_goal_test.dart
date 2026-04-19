import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_goal.dart';

void main() {
  // ── label (localization) ───────────────────────────────────────────────────

  group('StudyGoal.label', () {
    test('English labels are distinct per goal and non-empty', () {
      final labels = StudyGoal.values
          .map((g) => g.label(AppLanguage.en))
          .toSet();
      expect(labels.length, StudyGoal.values.length);
      for (final label in labels) {
        expect(label, isNotEmpty);
      }
    });

    test('Vietnamese labels are distinct per goal', () {
      final labels = StudyGoal.values
          .map((g) => g.label(AppLanguage.vi))
          .toSet();
      expect(labels.length, StudyGoal.values.length);
    });

    test('Japanese labels are distinct per goal', () {
      final labels = StudyGoal.values
          .map((g) => g.label(AppLanguage.ja))
          .toSet();
      expect(labels.length, StudyGoal.values.length);
    });

    test('same goal in three languages produces three distinct labels', () {
      final en = StudyGoal.jlpt.label(AppLanguage.en);
      final vi = StudyGoal.jlpt.label(AppLanguage.vi);
      final ja = StudyGoal.jlpt.label(AppLanguage.ja);
      expect({en, vi, ja}.length, 3);
    });

    test('label content matches the documented copy', () {
      expect(StudyGoal.jlpt.label(AppLanguage.en), 'JLPT Exam Prep');
      expect(StudyGoal.reading.label(AppLanguage.en), 'Read Japanese');
      expect(StudyGoal.writing.label(AppLanguage.en), 'Practice Writing');
    });
  });

  // ── description (localization) ─────────────────────────────────────────────

  group('StudyGoal.description', () {
    test('English descriptions are distinct per goal and non-empty', () {
      final descriptions = StudyGoal.values
          .map((g) => g.description(AppLanguage.en))
          .toSet();
      expect(descriptions.length, StudyGoal.values.length);
    });

    test('description differs from label for each goal', () {
      for (final goal in StudyGoal.values) {
        for (final lang in AppLanguage.values) {
          expect(
            goal.description(lang),
            isNot(equals(goal.label(lang))),
            reason: '$goal $lang: description should not be the label',
          );
        }
      }
    });

    test('Japanese description for JLPT is non-empty', () {
      // Sanity check on JA strings — a missing translation would yield ''.
      expect(StudyGoal.jlpt.description(AppLanguage.ja), isNotEmpty);
    });
  });

  // ── icon ───────────────────────────────────────────────────────────────────

  group('StudyGoal.icon', () {
    test('each goal returns an IconData', () {
      for (final goal in StudyGoal.values) {
        expect(goal.icon, isA<IconData>());
      }
    });

    test('all three icons are distinct (no two goals share an icon)', () {
      final codePoints = StudyGoal.values
          .map((g) => g.icon.codePoint)
          .toSet();
      expect(codePoints.length, StudyGoal.values.length);
    });

    test('JLPT uses the assignment outlined icon', () {
      // Pin the icon — onboarding UX depends on the visual association.
      expect(StudyGoal.jlpt.icon, Icons.assignment_outlined);
      expect(StudyGoal.reading.icon, Icons.menu_book_outlined);
      expect(StudyGoal.writing.icon, Icons.edit_outlined);
    });
  });
}
