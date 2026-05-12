import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';

void main() {
  // ── label (localization) ──────────────────────────────────────────────────

  group('QuestionType.label', () {
    test('English labels match the canonical app copy', () {
      expect(
        QuestionType.multipleChoice.label(AppLanguage.en),
        'Multiple Choice',
      );
      expect(QuestionType.trueFalse.label(AppLanguage.en), 'True/False');
      expect(QuestionType.fillBlank.label(AppLanguage.en), 'Fill in the Blank');
    });

    test('Vietnamese labels are non-empty and distinct per type', () {
      final labels = QuestionType.values
          .map((t) => t.label(AppLanguage.vi))
          .toSet();
      expect(labels.length, QuestionType.values.length);
      for (final label in labels) {
        expect(label, isNotEmpty);
      }
    });

    test('Japanese labels are non-empty and distinct per type', () {
      final labels = QuestionType.values
          .map((t) => t.label(AppLanguage.ja))
          .toSet();
      expect(labels.length, QuestionType.values.length);
    });

    test('cross-language labels for the same type differ', () {
      final en = QuestionType.multipleChoice.label(AppLanguage.en);
      final vi = QuestionType.multipleChoice.label(AppLanguage.vi);
      final ja = QuestionType.multipleChoice.label(AppLanguage.ja);
      expect({en, vi, ja}.length, 3);
    });
  });

  // ── icon (emoji) ──────────────────────────────────────────────────────────

  group('QuestionType.icon', () {
    test('returns the documented emoji per type', () {
      // Pin exact emoji strings — UI carrier of question-type identity.
      expect(QuestionType.multipleChoice.icon, '🔘');
      expect(QuestionType.trueFalse.icon, '✓✗');
      expect(QuestionType.fillBlank.icon, '✏️');
    });

    test('every type returns a non-empty icon', () {
      for (final type in QuestionType.values) {
        expect(type.icon, isNotEmpty);
      }
    });

    test('icons are unique across types', () {
      final icons = QuestionType.values.map((t) => t.icon).toSet();
      expect(icons.length, QuestionType.values.length);
    });
  });

  // ── difficulty (1-3) ──────────────────────────────────────────────────────
  //
  // Difficulty is used by the question planner to weight selection.
  // The contract is "1 = easiest, 3 = hardest" — pin the exact mapping.

  group('QuestionType.difficulty', () {
    test('multipleChoice is easiest (1)', () {
      expect(QuestionType.multipleChoice.difficulty, 1);
    });

    test('trueFalse is medium (2)', () {
      expect(QuestionType.trueFalse.difficulty, 2);
    });

    test('fillBlank is hardest (3)', () {
      expect(QuestionType.fillBlank.difficulty, 3);
    });

    test('all difficulties fall within [1, 3]', () {
      for (final type in QuestionType.values) {
        expect(type.difficulty, inInclusiveRange(1, 3));
      }
    });

    test('every type maps to a unique difficulty', () {
      final difficulties = QuestionType.values.map((t) => t.difficulty).toSet();
      expect(difficulties.length, QuestionType.values.length);
    });
  });
}
