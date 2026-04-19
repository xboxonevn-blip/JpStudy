import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';

void main() {
  // ── default constructor ────────────────────────────────────────────────────

  group('LearnConfig default constructor', () {
    test('uses sensible defaults', () {
      const config = LearnConfig();
      expect(config.questionCount, 20);
      expect(config.shuffleQuestions, isTrue);
      expect(config.enableHints, isTrue);
      expect(config.showCorrectAnswer, isTrue);
      expect(config.enabledTypes, [
        QuestionType.multipleChoice,
        QuestionType.trueFalse,
        QuestionType.fillBlank,
      ]);
    });
  });

  // ── copyWith ───────────────────────────────────────────────────────────────

  group('LearnConfig.copyWith', () {
    const base = LearnConfig();

    test('changes only the specified field', () {
      final updated = base.copyWith(questionCount: 5);
      expect(updated.questionCount, 5);
      expect(updated.shuffleQuestions, base.shuffleQuestions);
      expect(updated.enableHints, base.enableHints);
    });

    test('passing nothing returns an equivalent value', () {
      final copy = base.copyWith();
      expect(copy.questionCount, base.questionCount);
      expect(copy.enabledTypes, base.enabledTypes);
      expect(copy.shuffleQuestions, base.shuffleQuestions);
    });

    test('replaces enabledTypes wholesale', () {
      final updated = base.copyWith(
        enabledTypes: const [QuestionType.fillBlank],
      );
      expect(updated.enabledTypes, [QuestionType.fillBlank]);
    });
  });

  // ── normalized ─────────────────────────────────────────────────────────────

  group('LearnConfig.normalized', () {
    test('clamps questionCount to maxQuestions when above', () {
      const config = LearnConfig(questionCount: 50);
      final normalized = config.normalized(maxQuestions: 10);
      expect(normalized.questionCount, 10);
    });

    test('keeps questionCount when within range', () {
      const config = LearnConfig(questionCount: 7);
      final normalized = config.normalized(maxQuestions: 10);
      expect(normalized.questionCount, 7);
    });

    test('clamps questionCount to at least 1', () {
      const config = LearnConfig(questionCount: 0);
      final normalized = config.normalized(maxQuestions: 10);
      expect(normalized.questionCount, 1);
    });

    test('treats maxQuestions < 1 as 1 (safe lower bound)', () {
      const config = LearnConfig(questionCount: 5);
      final normalized = config.normalized(maxQuestions: 0);
      // safeMax becomes 1, then clamp(1, 1) = 1
      expect(normalized.questionCount, 1);
    });

    test('treats negative maxQuestions as 1 (safe lower bound)', () {
      const config = LearnConfig(questionCount: 5);
      final normalized = config.normalized(maxQuestions: -10);
      expect(normalized.questionCount, 1);
    });

    test('replaces empty enabledTypes with multipleChoice fallback', () {
      const config = LearnConfig(enabledTypes: []);
      final normalized = config.normalized(maxQuestions: 10);
      expect(normalized.enabledTypes, [QuestionType.multipleChoice]);
    });

    test('preserves non-empty enabledTypes as-is', () {
      const config = LearnConfig(
        enabledTypes: [QuestionType.fillBlank, QuestionType.trueFalse],
      );
      final normalized = config.normalized(maxQuestions: 10);
      expect(normalized.enabledTypes, [
        QuestionType.fillBlank,
        QuestionType.trueFalse,
      ]);
    });
  });

  // ── JSON round-trip ────────────────────────────────────────────────────────

  group('LearnConfig.toJson / fromJson', () {
    test('round-trip preserves all fields', () {
      const config = LearnConfig(
        questionCount: 15,
        enabledTypes: [QuestionType.fillBlank],
        shuffleQuestions: false,
        enableHints: false,
        showCorrectAnswer: false,
      );
      final restored = LearnConfig.fromJson(config.toJson());
      expect(restored.questionCount, 15);
      expect(restored.enabledTypes, [QuestionType.fillBlank]);
      expect(restored.shuffleQuestions, isFalse);
      expect(restored.enableHints, isFalse);
      expect(restored.showCorrectAnswer, isFalse);
    });

    test('toJson emits enabledTypes as string names', () {
      const config = LearnConfig(
        enabledTypes: [QuestionType.multipleChoice, QuestionType.trueFalse],
      );
      final json = config.toJson();
      expect(json['enabledTypes'], ['multipleChoice', 'trueFalse']);
    });

    test('fromJson defaults questionCount to 20 when missing', () {
      final config = LearnConfig.fromJson(<String, dynamic>{});
      expect(config.questionCount, 20);
    });

    test('fromJson defaults enabledTypes to all three when missing', () {
      final config = LearnConfig.fromJson(<String, dynamic>{});
      expect(config.enabledTypes, [
        QuestionType.multipleChoice,
        QuestionType.trueFalse,
        QuestionType.fillBlank,
      ]);
    });

    test('fromJson defaults enabledTypes when empty list provided', () {
      // Empty list path — falls back to all three defaults.
      final config = LearnConfig.fromJson(<String, dynamic>{
        'enabledTypes': const <String>[],
      });
      expect(config.enabledTypes, hasLength(3));
    });

    test('fromJson maps unknown type names to multipleChoice (orElse)', () {
      final config = LearnConfig.fromJson(<String, dynamic>{
        'enabledTypes': ['notARealType'],
      });
      expect(config.enabledTypes, [QuestionType.multipleChoice]);
    });

    test('fromJson defaults boolean flags to true when missing', () {
      final config = LearnConfig.fromJson(<String, dynamic>{});
      expect(config.shuffleQuestions, isTrue);
      expect(config.enableHints, isTrue);
      expect(config.showCorrectAnswer, isTrue);
    });
  });
}
