import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/models/test_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _item1 = VocabItem(
  id: 1,
  term: '猫',
  reading: 'ねこ',
  meaning: 'mèo',
  meaningEn: 'cat',
  level: 'N5',
);
const _item2 = VocabItem(
  id: 2,
  term: '犬',
  reading: 'いぬ',
  meaning: 'chó',
  meaningEn: 'dog',
  level: 'N5',
);

Question _question({
  String id = 'q1',
  QuestionType type = QuestionType.multipleChoice,
  VocabItem item = _item1,
  String text = 'What is 猫?',
  String correct = 'cat',
}) => Question(
  id: id,
  type: type,
  targetItem: item,
  questionText: text,
  correctAnswer: correct,
  options: const ['cat', 'dog'],
);

LearnSessionSnapshot _learnSnapshot() => LearnSessionSnapshot(
  lessonId: 10,
  sessionId: 'learn-1',
  startedAt: DateTime(2026, 3, 1, 10, 0),
  currentRound: 2,
  currentQuestionIndex: 5,
  questions: [
    _question(id: 'q1', item: _item1),
    _question(id: 'q2', item: _item2, text: 'What is 犬?', correct: 'dog'),
  ],
  results: [
    QuestionResult(
      question: _question(id: 'q1', item: _item1),
      userAnswer: 'cat',
      isCorrect: true,
      timeTaken: const Duration(seconds: 2),
      answeredAt: DateTime(2026, 3, 1, 10, 1),
    ),
  ],
  config: const LearnConfig(questionCount: 2, enabledTypes: [QuestionType.multipleChoice]),
  contextHintsShown: {'q1'},
  contextHintsRequeued: {'q2'},
  wrongRequeued: {'q2'},
  lastSavedAt: DateTime(2026, 3, 1, 10, 2),
);

TestSessionSnapshot _testSnapshot() => TestSessionSnapshot(
  sessionKey: 'mock_N5',
  sessionId: 'test-1',
  lessonId: -1,
  startedAt: DateTime(2026, 3, 1, 11, 0),
  currentQuestionIndex: 9,
  questions: [
    _question(id: 'q1', item: _item1),
    _question(id: 'q2', item: _item2, text: 'What is 犬?', correct: 'dog'),
  ],
  answers: const [
    TestAnswer(questionIndex: 0, userAnswer: 'cat', isCorrect: true),
    TestAnswer(questionIndex: 1, userAnswer: 'dog', isCorrect: true),
    TestAnswer(questionIndex: 2, userAnswer: 'extra', isCorrect: false),
  ],
  flaggedQuestions: {0, 3},
  config: const TestConfig(
    questionCount: 2,
    enabledTypes: [QuestionType.multipleChoice],
    timeLimitMinutes: 15,
  ),
  adaptiveAdded: 1,
  adaptiveMaxExtra: 2,
  usedTypesByItem: {
    1: {QuestionType.multipleChoice, QuestionType.trueFalse},
  },
  adaptiveRepeatCount: {1: 2},
  adaptiveCorrectStreak: {1: 3},
  adaptiveCompleted: {1},
  lastSavedAt: DateTime(2026, 3, 1, 11, 5),
);

void main() {
  late SessionStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = SessionStorage();
  });

  group('learn session persistence', () {
    test('saveLearnSession then loadLearnSession round-trips snapshot', () async {
      final snapshot = _learnSnapshot();
      await storage.saveLearnSession(snapshot: snapshot);

      final loaded = await storage.loadLearnSession(snapshot.lessonId);
      expect(loaded, isNotNull);
      expect(loaded!.lessonId, snapshot.lessonId);
      expect(loaded.sessionId, snapshot.sessionId);
      expect(loaded.currentRound, snapshot.currentRound);
      expect(loaded.questions, hasLength(2));
      expect(loaded.results, hasLength(1));
      expect(loaded.contextHintsShown, {'q1'});
      expect(loaded.wrongRequeued, {'q2'});
    });

    test('loadLearnSession returns null for missing key', () async {
      expect(await storage.loadLearnSession(999), isNull);
    });

    test('loadLearnSession returns null for invalid JSON', () async {
      SharedPreferences.setMockInitialValues({'learn_session_10': 'not-json'});
      storage = SessionStorage();
      expect(await storage.loadLearnSession(10), isNull);
    });

    test('clearLearnSession removes persisted snapshot', () async {
      final snapshot = _learnSnapshot();
      await storage.saveLearnSession(snapshot: snapshot);
      await storage.clearLearnSession(snapshot.lessonId);

      expect(await storage.loadLearnSession(snapshot.lessonId), isNull);
    });

    test('buildSession hydrates vocab items and clamps currentQuestionIndex', () {
      final snapshot = _learnSnapshot();
      final session = snapshot.buildSession([_item1, _item2]);

      expect(session.questions, hasLength(2));
      expect(session.currentQuestionIndex, 1); // clamped from 5 to last valid index
      expect(session.questions.first.targetItem, _item1);
      expect(session.results, hasLength(1));
      expect(session.results.first.question.targetItem, _item1);
    });

    test('buildSession drops questions whose vocab items cannot be hydrated', () {
      final snapshot = _learnSnapshot();
      final session = snapshot.buildSession([_item1]); // item2 missing

      expect(session.questions, hasLength(1));
      expect(session.questions.single.targetItem.id, 1);
    });
  });

  group('test session persistence', () {
    test('saveTestSession then loadTestSession round-trips snapshot', () async {
      final snapshot = _testSnapshot();
      await storage.saveTestSession(snapshot: snapshot);

      final loaded = await storage.loadTestSession(snapshot.sessionKey);
      expect(loaded, isNotNull);
      expect(loaded!.sessionKey, snapshot.sessionKey);
      expect(loaded.sessionId, snapshot.sessionId);
      expect(loaded.config.timeLimitMinutes, 15);
      expect(loaded.usedTypesByItem[1], containsAll({QuestionType.multipleChoice, QuestionType.trueFalse}));
      expect(loaded.adaptiveRepeatCount[1], 2);
      expect(loaded.adaptiveCompleted, {1});
    });

    test('loadTestSession returns null for missing key', () async {
      expect(await storage.loadTestSession('missing'), isNull);
    });

    test('loadTestSession returns null for invalid JSON', () async {
      SharedPreferences.setMockInitialValues({'test_session_bad': 'not-json'});
      storage = SessionStorage();
      expect(await storage.loadTestSession('bad'), isNull);
    });

    test('clearTestSession removes persisted snapshot', () async {
      final snapshot = _testSnapshot();
      await storage.saveTestSession(snapshot: snapshot);
      await storage.clearTestSession(snapshot.sessionKey);

      expect(await storage.loadTestSession(snapshot.sessionKey), isNull);
    });

    test('buildSession clamps currentQuestionIndex and trims extra answers/flags', () {
      final snapshot = _testSnapshot();
      final session = snapshot.buildSession([_item1, _item2]);

      expect(session.questions, hasLength(2));
      expect(session.currentQuestionIndex, 1); // clamped from 9
      expect(session.answers, hasLength(2)); // extra third answer trimmed
      expect(session.flaggedQuestions, {0}); // invalid flag 3 removed
      expect(session.timeLimitMinutes, 15);
    });

    test('buildSession drops questions whose vocab items cannot be hydrated', () {
      final snapshot = _testSnapshot();
      final session = snapshot.buildSession([_item1]);

      expect(session.questions, hasLength(1));
      expect(session.answers, hasLength(1));
      expect(session.flaggedQuestions, {0});
    });

    test('fromJson falls back unknown used question type names to multipleChoice', () {
      final json = _testSnapshot().toJson();
      json['usedTypesByItem'] = {
        '1': ['multipleChoice', 'unknownType'],
      };

      final loaded = TestSessionSnapshot.fromJson(json);
      expect(loaded.usedTypesByItem[1], containsAll({QuestionType.multipleChoice}));
    });
  });
}
