import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_config.dart';
import 'package:jpstudy/features/test/models/test_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Fixtures ────────────────────────────────────────────────────────────────

VocabItem _vocab(int id) => VocabItem(
      id: id,
      term: 'term$id',
      meaning: 'meaning$id',
      level: 'N5',
    );

Question _question(int vocabId) => Question(
      id: 'q$vocabId',
      type: QuestionType.multipleChoice,
      targetItem: _vocab(vocabId),
      questionText: 'term$vocabId',
      correctAnswer: 'meaning$vocabId',
      options: ['meaning$vocabId', 'other1', 'other2', 'other3'],
    );

LearnSessionSnapshot _learnSnapshot({int lessonId = 1}) {
  final now = DateTime(2025, 6, 1, 12);
  return LearnSessionSnapshot(
    lessonId: lessonId,
    sessionId: 'sess-$lessonId',
    startedAt: now,
    currentRound: 2,
    currentQuestionIndex: 1,
    questions: [_question(10), _question(11)],
    results: const [],
    config: const LearnConfig(questionCount: 5),
    contextHintsShown: {'q10'},
    contextHintsRequeued: const {},
    wrongRequeued: const {},
    lastSavedAt: now,
  );
}

TestSessionSnapshot _testSnapshot() {
  final now = DateTime(2025, 6, 1, 12);
  return TestSessionSnapshot(
    sessionKey: 'key-42',
    sessionId: 'tsess-1',
    lessonId: 42,
    startedAt: now,
    currentQuestionIndex: 0,
    questions: [_question(20)],
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
    final snap = _learnSnapshot(lessonId: 5);

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
    await storage.saveLearnSession(snapshot: _learnSnapshot(lessonId: 3));
    await storage.clearLearnSession(3);
    expect(await storage.loadLearnSession(3), isNull);
  });

  // ── SessionStorage: test session ─────────────────────────────────────────

  test('save and load test session roundtrips key fields', () async {
    final storage = SessionStorage();
    final snap = _testSnapshot();

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
    await storage.saveTestSession(snapshot: _testSnapshot());
    await storage.clearTestSession('key-42');
    expect(await storage.loadTestSession('key-42'), isNull);
  });

  // ── LearnSessionSnapshot serialization ───────────────────────────────────

  test('LearnSessionSnapshot toJson/fromJson roundtrip preserves all fields', () {
    final snap = _learnSnapshot();
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
    final snap = _testSnapshot();
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
    final snap = _testSnapshot();
    final restored = TestSessionSnapshot.fromJson(snap.toJson());
    expect(restored.config.questionCount, 10);
    expect(restored.config.shuffleQuestions, isTrue);
  });

  // ── QuestionSerializer ───────────────────────────────────────────────────

  test('QuestionSerializer roundtrip preserves type and answers', () {
    final q = _question(5);
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
    final q = _question(7);
    final vocab = _vocab(7);
    final hydrated = QuestionSerializer.hydrate(q, {7: vocab});
    expect(hydrated, isNotNull);
    expect(hydrated!.targetItem.term, vocab.term);
  });

  test('QuestionSerializer.hydrate returns null for unknown vocab id', () {
    final q = _question(7);
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
  });
}
