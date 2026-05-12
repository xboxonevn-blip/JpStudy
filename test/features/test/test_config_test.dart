import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';

void main() {
  // ── default constructor ────────────────────────────────────────────────────

  group('TestConfig default constructor', () {
    test('uses sensible defaults', () {
      const config = TestConfig();
      expect(config.questionCount, 20);
      expect(config.timeLimitMinutes, isNull);
      expect(config.shuffleQuestions, isTrue);
      expect(config.showCorrectAfterWrong, isTrue);
      expect(config.adaptiveTesting, isFalse);
      expect(config.enabledTypes, [
        QuestionType.multipleChoice,
        QuestionType.trueFalse,
        QuestionType.fillBlank,
      ]);
    });
  });

  // ── mockExam factory ───────────────────────────────────────────────────────

  group('TestConfig.mockExam', () {
    test('clamps questionCount to [1, 50]', () {
      expect(TestConfig.mockExam(questionCount: 0).questionCount, 1);
      expect(TestConfig.mockExam(questionCount: 100).questionCount, 50);
      expect(TestConfig.mockExam(questionCount: 25).questionCount, 25);
    });

    test('time limit is 0.5 × questionCount, clamped to [5, 30]', () {
      // 10 q × 0.5 = 5 min — at lower bound
      expect(TestConfig.mockExam(questionCount: 10).timeLimitMinutes, 5);
      // 20 q × 0.5 = 10 min
      expect(TestConfig.mockExam(questionCount: 20).timeLimitMinutes, 10);
      // 50 q × 0.5 = 25 min
      expect(TestConfig.mockExam(questionCount: 50).timeLimitMinutes, 25);
      // 80 q (clamped to 50) × 0.5 = 25 min
      expect(TestConfig.mockExam(questionCount: 80).timeLimitMinutes, 25);
    });

    test('time limit lower bound is 5 even for tiny exams', () {
      // 1 q × 0.5 = 0.5 → round to 1, but clamped to 5
      expect(TestConfig.mockExam(questionCount: 1).timeLimitMinutes, 5);
      expect(TestConfig.mockExam(questionCount: 2).timeLimitMinutes, 5);
    });

    test('time limit upper bound is 30 (would only hit if cap raised)', () {
      // The questionCount cap (50) makes it impossible to exceed 25 here,
      // but the .clamp(5, 30) still pins the upper bound contract.
      // Verify by calling with values that would push above 30 if not clamped.
      expect(TestConfig.mockExam(questionCount: 1000).timeLimitMinutes, 25);
    });

    test('mock exams shuffle and hide correct answer', () {
      final config = TestConfig.mockExam(questionCount: 20);
      expect(config.shuffleQuestions, isTrue);
      expect(config.showCorrectAfterWrong, isFalse);
      expect(config.adaptiveTesting, isFalse);
    });
  });

  // ── copyWith — clearTimeLimit semantics ───────────────────────────────────
  //
  // copyWith uses a separate `clearTimeLimit` boolean because passing
  // `timeLimitMinutes: null` is indistinguishable from "unspecified".
  // This pattern is easy to break in a refactor, so pin both paths.

  group('TestConfig.copyWith', () {
    const base = TestConfig(questionCount: 30, timeLimitMinutes: 15);

    test('changes only the specified field (and keeps timeLimit)', () {
      final updated = base.copyWith(questionCount: 25);
      expect(updated.questionCount, 25);
      expect(updated.timeLimitMinutes, 15);
    });

    test('copyWith with no args returns equivalent config', () {
      final copy = base.copyWith();
      expect(copy.questionCount, 30);
      expect(copy.timeLimitMinutes, 15);
      expect(copy.shuffleQuestions, base.shuffleQuestions);
    });

    test('clearTimeLimit=true sets timeLimit to null', () {
      final updated = base.copyWith(clearTimeLimit: true);
      expect(updated.timeLimitMinutes, isNull);
    });

    test('clearTimeLimit=true overrides any timeLimitMinutes argument', () {
      // The implementation evaluates clearTimeLimit FIRST.
      final updated = base.copyWith(clearTimeLimit: true, timeLimitMinutes: 99);
      expect(updated.timeLimitMinutes, isNull);
    });

    test('passing timeLimitMinutes without clearTimeLimit replaces it', () {
      final updated = base.copyWith(timeLimitMinutes: 20);
      expect(updated.timeLimitMinutes, 20);
    });

    test('replaces enabledTypes wholesale', () {
      final updated = base.copyWith(
        enabledTypes: const [QuestionType.fillBlank],
      );
      expect(updated.enabledTypes, [QuestionType.fillBlank]);
    });

    test('toggles boolean flags independently', () {
      final updated = base.copyWith(
        shuffleQuestions: false,
        showCorrectAfterWrong: false,
        adaptiveTesting: true,
      );
      expect(updated.shuffleQuestions, isFalse);
      expect(updated.showCorrectAfterWrong, isFalse);
      expect(updated.adaptiveTesting, isTrue);
    });
  });
}
