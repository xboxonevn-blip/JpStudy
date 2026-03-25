import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/test_dao.dart';

void main() {
  late AppDatabase db;
  late TestDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = TestDao(db);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int sessionCounter = 0;

  TestSessionsCompanion makeSession({
    String? sessionId,
    int lessonId = 1,
    DateTime? startedAt,
    DateTime? completedAt,
    int totalQuestions = 10,
    int correctCount = 7,
    int wrongCount = 3,
    int score = 70,
    String grade = 'C',
    int xpEarned = 50,
    int? timeLimitMinutes,
  }) {
    sessionCounter++;
    return TestSessionsCompanion(
      sessionId: Value(sessionId ?? 'session_$sessionCounter'),
      lessonId: Value(lessonId),
      startedAt: Value(startedAt ?? DateTime.now()),
      completedAt: Value(completedAt ?? DateTime.now()),
      totalQuestions: Value(totalQuestions),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      score: Value(score),
      grade: Value(grade),
      xpEarned: Value(xpEarned),
      timeLimitMinutes: Value(timeLimitMinutes),
    );
  }

  TestAnswersCompanion makeAnswer({
    required String sessionId,
    int questionIndex = 0,
    int termId = 1,
    String questionType = 'multiple_choice',
    String? userAnswer = 'Answer',
    bool isCorrect = true,
    DateTime? answeredAt,
  }) {
    return TestAnswersCompanion(
      sessionId: Value(sessionId),
      questionIndex: Value(questionIndex),
      termId: Value(termId),
      questionType: Value(questionType),
      userAnswer: Value(userAnswer),
      isCorrect: Value(isCorrect),
      answeredAt: Value(answeredAt ?? DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // createSession
  // ---------------------------------------------------------------------------

  group('createSession', () {
    test('inserts a session and returns a row id', () async {
      final id = await dao.createSession(makeSession(sessionId: 'abc-001'));
      expect(id, greaterThan(0));
    });

    test('inserts session that can be retrieved by sessionId', () async {
      await dao.createSession(makeSession(sessionId: 'abc-002'));
      final session = await dao.getSession('abc-002');
      expect(session, isNotNull);
      expect(session!.sessionId, 'abc-002');
    });
  });

  // ---------------------------------------------------------------------------
  // getSession
  // ---------------------------------------------------------------------------

  group('getSession', () {
    test('returns null for unknown session id', () async {
      final session = await dao.getSession('nonexistent');
      expect(session, isNull);
    });

    test('returns correct session when multiple sessions exist', () async {
      await dao.createSession(makeSession(sessionId: 'A', lessonId: 1));
      await dao.createSession(makeSession(sessionId: 'B', lessonId: 2));

      final session = await dao.getSession('B');
      expect(session, isNotNull);
      expect(session!.lessonId, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // updateSession
  // ---------------------------------------------------------------------------

  group('updateSession', () {
    test('updates score and grade of an existing session', () async {
      await dao.createSession(
        makeSession(sessionId: 'upd-01', score: 50, grade: 'F'),
      );
      final existing = await dao.getSession('upd-01');
      expect(existing, isNotNull);

      final updated = TestSessionsCompanion(
        id: Value(existing!.id),
        sessionId: const Value('upd-01'),
        lessonId: Value(existing.lessonId),
        startedAt: Value(existing.startedAt),
        completedAt: Value(existing.completedAt),
        totalQuestions: Value(existing.totalQuestions),
        correctCount: Value(existing.correctCount),
        wrongCount: Value(existing.wrongCount),
        score: const Value(95),
        grade: const Value('A'),
        xpEarned: Value(existing.xpEarned),
        timeLimitMinutes: Value(existing.timeLimitMinutes),
      );

      final result = await dao.updateSession(updated);
      expect(result, isTrue);

      final retrieved = await dao.getSession('upd-01');
      expect(retrieved!.score, 95);
      expect(retrieved.grade, 'A');
    });
  });

  // ---------------------------------------------------------------------------
  // recordAnswer
  // ---------------------------------------------------------------------------

  group('recordAnswer', () {
    test('inserts an answer linked to a session', () async {
      await dao.createSession(makeSession(sessionId: 'ans-01'));
      final rowId = await dao.recordAnswer(
        makeAnswer(sessionId: 'ans-01', termId: 42),
      );
      expect(rowId, greaterThan(0));
    });

    test('can insert multiple answers for the same session', () async {
      await dao.createSession(makeSession(sessionId: 'ans-02'));
      for (var i = 0; i < 3; i++) {
        await dao.recordAnswer(
          makeAnswer(
            sessionId: 'ans-02',
            questionIndex: i,
            termId: i + 1,
            isCorrect: i % 2 == 0,
          ),
        );
      }
      // No assertion beyond no-throw; the schema has no direct count query.
    });
  });

  // ---------------------------------------------------------------------------
  // getHistory
  // ---------------------------------------------------------------------------

  group('getHistory', () {
    test('returns empty list when no sessions exist for the lesson', () async {
      final history = await dao.getHistory(99);
      expect(history, isEmpty);
    });

    test('returns only completed sessions for the specified lesson', () async {
      await dao.createSession(
        makeSession(sessionId: 'h1', lessonId: 1, completedAt: DateTime.now()),
      );
      await dao.createSession(
        makeSession(sessionId: 'h2', lessonId: 2, completedAt: DateTime.now()),
      );
      // Incomplete session for lesson 1
      await dao.createSession(
        TestSessionsCompanion(
          sessionId: const Value('h3'),
          lessonId: const Value(1),
          startedAt: Value(DateTime.now()),
          completedAt: const Value.absent(), // null = incomplete
          totalQuestions: const Value(5),
          correctCount: const Value(0),
          wrongCount: const Value(0),
          score: const Value(0),
          grade: const Value('F'),
          xpEarned: const Value(0),
          timeLimitMinutes: const Value.absent(),
        ),
      );

      final history = await dao.getHistory(1);
      expect(history, hasLength(1));
      expect(history.first.sessionId, 'h1');
    });

    test('returns sessions ordered by completedAt descending', () async {
      final older = DateTime.now().subtract(const Duration(hours: 2));
      final newer = DateTime.now();
      await dao.createSession(
        makeSession(sessionId: 'old', lessonId: 5, completedAt: older),
      );
      await dao.createSession(
        makeSession(sessionId: 'new', lessonId: 5, completedAt: newer),
      );

      final history = await dao.getHistory(5);
      expect(history, hasLength(2));
      expect(history.first.sessionId, 'new');
      expect(history.last.sessionId, 'old');
    });
  });

  // ---------------------------------------------------------------------------
  // getBestScore
  // ---------------------------------------------------------------------------

  group('getBestScore', () {
    test('returns null when no completed sessions exist for lesson', () async {
      final best = await dao.getBestScore(50);
      expect(best, isNull);
    });

    test('returns the session with the highest score', () async {
      await dao.createSession(
        makeSession(sessionId: 'b1', lessonId: 7, score: 60),
      );
      await dao.createSession(
        makeSession(sessionId: 'b2', lessonId: 7, score: 95),
      );
      await dao.createSession(
        makeSession(sessionId: 'b3', lessonId: 7, score: 80),
      );

      final best = await dao.getBestScore(7);
      expect(best, isNotNull);
      expect(best!.score, 95);
    });

    test('ignores incomplete sessions', () async {
      await dao.createSession(
        makeSession(sessionId: 'comp', lessonId: 8, score: 70),
      );
      // Incomplete session with artificially high score (should not count)
      await dao.createSession(
        TestSessionsCompanion(
          sessionId: const Value('incomp'),
          lessonId: const Value(8),
          startedAt: Value(DateTime.now()),
          completedAt: const Value.absent(),
          totalQuestions: const Value(10),
          correctCount: const Value(10),
          wrongCount: const Value(0),
          score: const Value(100),
          grade: const Value('A'),
          xpEarned: const Value(100),
          timeLimitMinutes: const Value.absent(),
        ),
      );

      final best = await dao.getBestScore(8);
      expect(best, isNotNull);
      expect(best!.score, 70);
    });
  });

  // ---------------------------------------------------------------------------
  // getAllHistory
  // ---------------------------------------------------------------------------

  group('getAllHistory', () {
    test('returns empty list when no completed sessions', () async {
      final all = await dao.getAllHistory();
      expect(all, isEmpty);
    });

    test('returns all completed sessions across lessons', () async {
      await dao.createSession(
        makeSession(sessionId: 'all-1', lessonId: 1),
      );
      await dao.createSession(
        makeSession(sessionId: 'all-2', lessonId: 2),
      );
      await dao.createSession(
        makeSession(sessionId: 'all-3', lessonId: 3),
      );

      final all = await dao.getAllHistory();
      expect(all, hasLength(3));
    });

    test('returns sessions ordered by completedAt descending', () async {
      final oldest = DateTime.now().subtract(const Duration(hours: 5));
      final middle = DateTime.now().subtract(const Duration(hours: 2));
      final newest = DateTime.now();

      await dao.createSession(
        makeSession(sessionId: 'z1', lessonId: 1, completedAt: middle),
      );
      await dao.createSession(
        makeSession(sessionId: 'z2', lessonId: 2, completedAt: oldest),
      );
      await dao.createSession(
        makeSession(sessionId: 'z3', lessonId: 3, completedAt: newest),
      );

      final all = await dao.getAllHistory();
      expect(all.map((s) => s.sessionId).toList(), ['z3', 'z1', 'z2']);
    });
  });
}
