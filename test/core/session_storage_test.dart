import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/models/test_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

<<<<<<< HEAD
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
      final snapshot = testSnapshot();
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
      final snapshot = testSnapshot();
      await storage.saveTestSession(snapshot: snapshot);
      await storage.clearTestSession(snapshot.sessionKey);

      expect(await storage.loadTestSession(snapshot.sessionKey), isNull);
    });

    test('buildSession clamps currentQuestionIndex and trims extra answers/flags', () {
      final snapshot = testSnapshot();
      final session = snapshot.buildSession([_item1, _item2]);

      expect(session.questions, hasLength(2));
      expect(session.currentQuestionIndex, 1); // clamped from 9
      expect(session.answers, hasLength(2)); // extra third answer trimmed
      expect(session.flaggedQuestions, {0}); // invalid flag 3 removed
      expect(session.timeLimitMinutes, 15);
    });

    test('buildSession drops questions whose vocab items cannot be hydrated', () {
      final snapshot = testSnapshot();
      final session = snapshot.buildSession([_item1]);

      expect(session.questions, hasLength(1));
      expect(session.answers, hasLength(1));
      expect(session.flaggedQuestions, {0});
    });

    test('fromJson falls back unknown used question type names to multipleChoice', () {
      final json = testSnapshot().toJson();
      json['usedTypesByItem'] = {
        '1': ['multipleChoice', 'unknownType'],
      };

      final loaded = TestSessionSnapshot.fromJson(json);
      expect(loaded.usedTypesByItem[1], containsAll({QuestionType.multipleChoice}));
    });
=======
// ── Fixtures ────────────────────────────────────────────────────────────────

VocabItem _vocab(int id) => VocabItem(
      id: id,
      term: 'term$id',
      meaning: 'meaning$id',
      level: 'N5',
    );

Question question(int vocabId) => Question(
      id: 'q$vocabId',
      type: QuestionType.multipleChoice,
      targetItem: _vocab(vocabId),
      questionText: 'term$vocabId',
      correctAnswer: 'meaning$vocabId',
      options: ['meaning$vocabId', 'other1', 'other2', 'other3'],
    );

LearnSessionSnapshot learnSnapshot({int lessonId = 1}) {
  final now = DateTime(2025, 6, 1, 12);
  return LearnSessionSnapshot(
    lessonId: lessonId,
    sessionId: 'sess-$lessonId',
    startedAt: now,
    currentRound: 2,
    currentQuestionIndex: 1,
    questions: [question(10), question(11)],
    results: const [],
    config: const LearnConfig(questionCount: 5),
    contextHintsShown: {'q10'},
    contextHintsRequeued: const {},
    wrongRequeued: const {},
    lastSavedAt: now,
  );
}

TestSessionSnapshot testSnapshot() {
  final now = DateTime(2025, 6, 1, 12);
  return TestSessionSnapshot(
    sessionKey: 'key-42',
    sessionId: 'tsess-1',
    lessonId: 42,
    startedAt: now,
    currentQuestionIndex: 0,
    questions: [question(20)],
    answers: const [],
    flaggedQuestions: const {0},
    config: const TestConfig(questionCount: 10),
    adaptiveAdded: 2,
    adaptiveMaxExtra: 5,
    usedTypesByItem: {
      20: {QuestionType.multipleChoice, QuestionType.trueFalse},
    },
    adaptiveRepeatCount: {20: 3},
    adaptiveCorrectStreak: {20: 1},
    adaptiveCompleted: const {20},
    lastSavedAt: now,
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // ── SessionStorage: learn session ────────────────────────────────────────

  test('save and load learn session roundtrips lessonId and sessionId', () async {
    final storage = SessionStorage();
    final snap = learnSnapshot(lessonId: 5);

    await storage.saveLearnSession(snapshot: snap);
    final loaded = await storage.loadLearnSession(5);

    expect(loaded, isNotNull);
    expect(loaded!.lessonId, 5);
    expect(loaded.sessionId, 'sess-5');
    expect(loaded.currentRound, 2);
    expect(loaded.contextHintsShown, {'q10'});
    expect(loaded.questions.length, 2);
  });

  test('loadLearnSession returns null when nothing saved', () async {
    final result = await SessionStorage().loadLearnSession(99);
    expect(result, isNull);
  });

  test('clearLearnSession removes saved snapshot', () async {
    final storage = SessionStorage();
    await storage.saveLearnSession(snapshot: learnSnapshot(lessonId: 3));
    await storage.clearLearnSession(3);
    expect(await storage.loadLearnSession(3), isNull);
  });

  // ── SessionStorage: test session ─────────────────────────────────────────

  test('save and load test session roundtrips key fields', () async {
    final storage = SessionStorage();
    final snap = testSnapshot();

    await storage.saveTestSession(snapshot: snap);
    final loaded = await storage.loadTestSession('key-42');

    expect(loaded, isNotNull);
    expect(loaded!.sessionKey, 'key-42');
    expect(loaded.lessonId, 42);
    expect(loaded.adaptiveAdded, 2);
    expect(loaded.flaggedQuestions, {0});
    expect(loaded.adaptiveCompleted, {20});
  });

  test('loadTestSession returns null when nothing saved', () async {
    expect(await SessionStorage().loadTestSession('missing'), isNull);
  });

  test('clearTestSession removes saved snapshot', () async {
    final storage = SessionStorage();
    await storage.saveTestSession(snapshot: testSnapshot());
    await storage.clearTestSession('key-42');
    expect(await storage.loadTestSession('key-42'), isNull);
  });

  // ── LearnSessionSnapshot serialization ───────────────────────────────────

  test('LearnSessionSnapshot toJson/fromJson roundtrip preserves all fields', () {
    final snap = learnSnapshot();
    final json = snap.toJson();
    final restored = LearnSessionSnapshot.fromJson(json);

    expect(restored.lessonId, snap.lessonId);
    expect(restored.sessionId, snap.sessionId);
    expect(restored.currentRound, snap.currentRound);
    expect(restored.currentQuestionIndex, snap.currentQuestionIndex);
    // normalized() caps questionCount to questions.length (2 here)
    expect(restored.config.questionCount, snap.questions.length);
    expect(restored.contextHintsShown, snap.contextHintsShown);
    expect(restored.questions.length, snap.questions.length);
  });

  test('LearnSessionSnapshot.fromJson uses legacy enabledTypes when config absent', () {
    final legacyJson = {
      'lessonId': 7,
      'sessionId': 'legacy',
      'startedAt': DateTime(2025).toIso8601String(),
      'currentRound': 1,
      'currentQuestionIndex': 0,
      'questions': <dynamic>[],
      'results': <dynamic>[],
      'enabledTypes': ['multipleChoice', 'trueFalse'],
      'contextHintsShown': <dynamic>[],
      'contextHintsRequeued': <dynamic>[],
      'wrongRequeued': <dynamic>[],
      'lastSavedAt': DateTime(2025).toIso8601String(),
    };
    final snap = LearnSessionSnapshot.fromJson(legacyJson);
    expect(snap.config.enabledTypes, contains(QuestionType.multipleChoice));
    expect(snap.config.enabledTypes, contains(QuestionType.trueFalse));
  });

  // ── TestSessionSnapshot serialization ────────────────────────────────────

  test('TestSessionSnapshot toJson/fromJson roundtrip preserves usedTypesByItem', () {
    final snap = testSnapshot();
    final json = snap.toJson();
    final restored = TestSessionSnapshot.fromJson(json);

    expect(restored.usedTypesByItem[20], {
      QuestionType.multipleChoice,
      QuestionType.trueFalse,
    });
    expect(restored.adaptiveRepeatCount[20], 3);
    expect(restored.adaptiveCorrectStreak[20], 1);
  });

  test('TestSessionSnapshot toJson/fromJson roundtrip preserves config', () {
    final snap = testSnapshot();
    final restored = TestSessionSnapshot.fromJson(snap.toJson());
    expect(restored.config.questionCount, 10);
    expect(restored.config.shuffleQuestions, isTrue);
  });

  // ── QuestionSerializer ───────────────────────────────────────────────────

  test('QuestionSerializer roundtrip preserves type and answers', () {
    final q = question(5);
    final json = QuestionSerializer.toJson(q);
    final restored = QuestionSerializer.fromJson(json);

    expect(restored, isNotNull);
    expect(restored!.id, q.id);
    expect(restored.type, QuestionType.multipleChoice);
    expect(restored.correctAnswer, q.correctAnswer);
    expect(restored.options, q.options);
  });

  test('QuestionSerializer.fromJson returns null for missing targetItemId', () {
    final result = QuestionSerializer.fromJson({'type': 'multipleChoice'});
    expect(result, isNull);
  });

  test('QuestionSerializer.hydrate returns question with vocab from map', () {
    final q = question(7);
    final vocab = _vocab(7);
    final hydrated = QuestionSerializer.hydrate(q, {7: vocab});
    expect(hydrated, isNotNull);
    expect(hydrated!.targetItem.term, vocab.term);
  });

  test('QuestionSerializer.hydrate returns null for unknown vocab id', () {
    final q = question(7);
    final hydrated = QuestionSerializer.hydrate(q, {});
    expect(hydrated, isNull);
  });

  // ── TestConfigSerializer ─────────────────────────────────────────────────

  test('TestConfigSerializer roundtrip preserves all fields', () {
    const config = TestConfig(
      questionCount: 15,
      timeLimitMinutes: 10,
      shuffleQuestions: false,
      showCorrectAfterWrong: false,
      adaptiveTesting: true,
    );
    final json = TestConfigSerializer.toJson(config);
    final restored = TestConfigSerializer.fromJson(json);

    expect(restored.questionCount, 15);
    expect(restored.timeLimitMinutes, 10);
    expect(restored.shuffleQuestions, isFalse);
    expect(restored.showCorrectAfterWrong, isFalse);
    expect(restored.adaptiveTesting, isTrue);
  });

  test('TestConfigSerializer.fromJson uses defaults for empty json', () {
    final config = TestConfigSerializer.fromJson({});
    expect(config.questionCount, 20);
    expect(config.timeLimitMinutes, isNull);
    expect(config.shuffleQuestions, isTrue);
>>>>>>> claude/confident-carson
  });
}
