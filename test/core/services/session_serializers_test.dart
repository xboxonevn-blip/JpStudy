import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/models/test_session.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  VocabItem vocab({int id = 1, String term = '食べる', String meaning = 'to eat'}) {
    return VocabItem(id: id, term: term, meaning: meaning, level: 'N5');
  }

  Question question({
    String id = 'q1',
    QuestionType type = QuestionType.multipleChoice,
    int vocabId = 1,
    String text = '食べる means?',
    String correct = 'to eat',
    List<String>? options,
    bool? isStatementTrue,
  }) {
    return Question(
      id: id,
      type: type,
      targetItem: vocab(id: vocabId),
      questionText: text,
      correctAnswer: correct,
      options: options ?? ['to eat', 'to drink', 'to sleep'],
      isStatementTrue: isStatementTrue,
    );
  }

  // ---------------------------------------------------------------------------
  // LearnConfig toJson / fromJson
  // ---------------------------------------------------------------------------

  group('LearnConfig', () {
    test('toJson / fromJson round-trip', () {
      const config = LearnConfig(
        questionCount: 15,
        enabledTypes: [QuestionType.multipleChoice, QuestionType.fillBlank],
        shuffleQuestions: false,
        enableHints: false,
        showCorrectAnswer: false,
      );

      final json = config.toJson();
      final restored = LearnConfig.fromJson(json);

      expect(restored.questionCount, 15);
      expect(restored.enabledTypes,
          [QuestionType.multipleChoice, QuestionType.fillBlank]);
      expect(restored.shuffleQuestions, false);
      expect(restored.enableHints, false);
      expect(restored.showCorrectAnswer, false);
    });

    test('fromJson uses defaults when keys are absent', () {
      final config = LearnConfig.fromJson({});
      expect(config.questionCount, 20);
      expect(config.shuffleQuestions, true);
      expect(config.enableHints, true);
      expect(config.showCorrectAnswer, true);
    });

    test('fromJson defaults to all three types when enabledTypes is empty', () {
      final config = LearnConfig.fromJson({'enabledTypes': []});
      expect(config.enabledTypes, [
        QuestionType.multipleChoice,
        QuestionType.trueFalse,
        QuestionType.fillBlank,
      ]);
    });

    test('fromJson falls back to multipleChoice for unknown type names', () {
      final config = LearnConfig.fromJson({
        'enabledTypes': ['unknownType'],
      });
      expect(config.enabledTypes, [QuestionType.multipleChoice]);
    });

    group('normalized', () {
      test('clamps questionCount to max', () {
        const config = LearnConfig(questionCount: 50);
        final normalized = config.normalized(maxQuestions: 10);
        expect(normalized.questionCount, 10);
      });

      test('clamps questionCount to 1 minimum', () {
        const config = LearnConfig(questionCount: 0);
        final normalized = config.normalized(maxQuestions: 5);
        expect(normalized.questionCount, 1);
      });

      test('treats maxQuestions < 1 as 1', () {
        const config = LearnConfig(questionCount: 5);
        final normalized = config.normalized(maxQuestions: 0);
        expect(normalized.questionCount, 1);
      });

      test('fills empty enabledTypes with multipleChoice', () {
        const config = LearnConfig(enabledTypes: []);
        final normalized = config.normalized(maxQuestions: 10);
        expect(normalized.enabledTypes, [QuestionType.multipleChoice]);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // TestConfig.mockExam
  // ---------------------------------------------------------------------------

  group('TestConfig.mockExam', () {
    test('clamps questionCount to 1..50', () {
      final config = TestConfig.mockExam(questionCount: 0);
      expect(config.questionCount, 1);

      final config2 = TestConfig.mockExam(questionCount: 100);
      expect(config2.questionCount, 50);
    });

    test('sets time limit proportional to question count', () {
      // 10 questions * 0.5 = 5 → clamped to 5
      final config = TestConfig.mockExam(questionCount: 10);
      expect(config.timeLimitMinutes, 5);
    });

    test('sets showCorrectAfterWrong to false', () {
      final config = TestConfig.mockExam(questionCount: 20);
      expect(config.showCorrectAfterWrong, false);
    });
  });

  // ---------------------------------------------------------------------------
  // QuestionSerializer
  // ---------------------------------------------------------------------------

  group('QuestionSerializer', () {
    test('toJson / fromJson round-trip for multipleChoice', () {
      final q = question(
        id: 'mc1',
        type: QuestionType.multipleChoice,
        options: ['to eat', 'to drink', 'to sleep'],
      );

      final json = QuestionSerializer.toJson(q);
      final restored = QuestionSerializer.fromJson(json);

      expect(restored, isNotNull);
      expect(restored!.id, 'mc1');
      expect(restored.type, QuestionType.multipleChoice);
      expect(restored.questionText, '食べる means?');
      expect(restored.correctAnswer, 'to eat');
      expect(restored.options, ['to eat', 'to drink', 'to sleep']);
    });

    test('toJson / fromJson round-trip for trueFalse', () {
      final q = question(
        id: 'tf1',
        type: QuestionType.trueFalse,
        isStatementTrue: true,
        options: null,
      );

      final json = QuestionSerializer.toJson(q);
      final restored = QuestionSerializer.fromJson(json);

      expect(restored, isNotNull);
      expect(restored!.type, QuestionType.trueFalse);
      expect(restored.isStatementTrue, true);
    });

    test('fromJson returns null when targetItemId is missing', () {
      final json = <String, dynamic>{
        'id': 'q1',
        'type': 'multipleChoice',
        // targetItemId missing
        'questionText': 'test',
        'correctAnswer': 'answer',
      };
      expect(QuestionSerializer.fromJson(json), isNull);
    });

    test('fromJson falls back to multipleChoice for unknown type', () {
      final json = <String, dynamic>{
        'id': 'q1',
        'type': 'unknownType',
        'targetItemId': 1,
        'questionText': 'test',
        'correctAnswer': 'answer',
      };
      final q = QuestionSerializer.fromJson(json);
      expect(q, isNotNull);
      expect(q!.type, QuestionType.multipleChoice);
    });

    test('hydrate replaces target item from vocabMap', () {
      final q = question(vocabId: 42);
      final richVocab = VocabItem(
        id: 42,
        term: '飲む',
        meaning: 'to drink',
        level: 'N5',
        reading: 'のむ',
      );
      final hydrated = QuestionSerializer.hydrate(q, {42: richVocab});
      expect(hydrated, isNotNull);
      expect(hydrated!.targetItem.term, '飲む');
    });

    test('hydrate returns null when vocabId is not in map', () {
      final q = question(vocabId: 999);
      final hydrated = QuestionSerializer.hydrate(q, {1: vocab()});
      expect(hydrated, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // TestAnswerSerializer
  // ---------------------------------------------------------------------------

  group('TestAnswerSerializer', () {
    test('toJson / fromJson round-trip with userAnswer and answeredAt', () {
      final now = DateTime(2024, 8, 1, 10, 30);
      const answer = TestAnswer(
        questionIndex: 2,
        userAnswer: 'to eat',
        isCorrect: true,
        answeredAt: null,
      );

      // answeredAt is null in this case; use a version with a date
      final answerWithDate = TestAnswer(
        questionIndex: 2,
        userAnswer: 'to eat',
        isCorrect: true,
        answeredAt: now,
      );

      final json = TestAnswerSerializer.toJson(answerWithDate);
      final restored = TestAnswerSerializer.fromJson(json);

      expect(restored, isNotNull);
      expect(restored!.questionIndex, 2);
      expect(restored.userAnswer, 'to eat');
      expect(restored.isCorrect, isTrue);
      expect(restored.answeredAt, now);
      // 'answer' exists to document the no-answeredAt variant; no assertion needed.
    });

    test('fromJson handles null userAnswer', () {
      final json = <String, dynamic>{
        'questionIndex': 0,
        'userAnswer': null,
        'isCorrect': false,
        'answeredAt': null,
      };
      final answer = TestAnswerSerializer.fromJson(json);
      expect(answer, isNotNull);
      expect(answer!.userAnswer, isNull);
      expect(answer.answeredAt, isNull);
    });

    test('fromJson defaults questionIndex to 0 when absent', () {
      final json = <String, dynamic>{
        'userAnswer': 'answer',
        'isCorrect': false,
        'answeredAt': null,
      };
      final answer = TestAnswerSerializer.fromJson(json);
      expect(answer!.questionIndex, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // TestConfigSerializer
  // ---------------------------------------------------------------------------

  group('TestConfigSerializer', () {
    test('toJson / fromJson round-trip', () {
      const config = TestConfig(
        questionCount: 12,
        enabledTypes: [QuestionType.fillBlank, QuestionType.trueFalse],
        timeLimitMinutes: 15,
        shuffleQuestions: false,
        showCorrectAfterWrong: false,
        adaptiveTesting: true,
      );

      final json = TestConfigSerializer.toJson(config);
      final restored = TestConfigSerializer.fromJson(json);

      expect(restored.questionCount, 12);
      expect(restored.enabledTypes,
          [QuestionType.fillBlank, QuestionType.trueFalse]);
      expect(restored.timeLimitMinutes, 15);
      expect(restored.shuffleQuestions, false);
      expect(restored.showCorrectAfterWrong, false);
      expect(restored.adaptiveTesting, true);
    });

    test('fromJson uses defaults when all keys are absent', () {
      final config = TestConfigSerializer.fromJson({});
      expect(config.questionCount, 20);
      expect(config.shuffleQuestions, true);
      expect(config.showCorrectAfterWrong, true);
      expect(config.adaptiveTesting, false);
      expect(config.timeLimitMinutes, isNull);
    });

    test('fromJson handles null timeLimitMinutes gracefully', () {
      final config = TestConfigSerializer.fromJson({
        'questionCount': 10,
        'timeLimitMinutes': null,
      });
      expect(config.timeLimitMinutes, isNull);
    });

    test('fromJson falls back to multipleChoice for unknown question type',
        () {
      final json = <String, dynamic>{
        'enabledTypes': ['unknownType'],
      };
      final config = TestConfigSerializer.fromJson(json);
      expect(config.enabledTypes, [QuestionType.multipleChoice]);
    });
  });
}

// ignore_for_file: unused_local_variable
