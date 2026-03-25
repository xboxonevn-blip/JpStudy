import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';

void main() {
  late AppDatabase db;
  late LearnDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = LearnDao(db);
  });

  tearDown(() => db.close());

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _counter = 0;

  LearnSessionsCompanion _makeSession({
    String? sessionId,
    int lessonId = 1,
    DateTime? startedAt,
    DateTime? completedAt,
    int totalQuestions = 10,
    int correctCount = 7,
    int wrongCount = 3,
    int currentRound = 1,
    int xpEarned = 30,
    bool isPerfect = false,
  }) {
    _counter++;
    return LearnSessionsCompanion(
      sessionId: Value(sessionId ?? 'session_$_counter'),
      lessonId: Value(lessonId),
      startedAt: Value(startedAt ?? DateTime.now()),
      completedAt: Value(completedAt),
      totalQuestions: Value(totalQuestions),
      correctCount: Value(correctCount),
      wrongCount: Value(wrongCount),
      currentRound: Value(currentRound),
      xpEarned: Value(xpEarned),
      isPerfect: Value(isPerfect),
    );
  }

  LearnAnswersCompanion _makeAnswer({
    required String sessionId,
    int questionIndex = 0,
    int termId = 1,
    String questionType = 'multiple_choice',
    String? userAnswer,
    bool isCorrect = true,
    int timeTakenMs = 1000,
    DateTime? answeredAt,
  }) {
    return LearnAnswersCompanion(
      sessionId: Value(sessionId),
      questionIndex: Value(questionIndex),
      termId: Value(termId),
      questionType: Value(questionType),
      userAnswer: Value(userAnswer),
      isCorrect: Value(isCorrect),
      timeTakenMs: Value(timeTakenMs),
      answeredAt: Value(answeredAt ?? DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // createSession
  // ---------------------------------------------------------------------------

  group('createSession', () {
    test('inserts a session and returns a positive row id', () async {
      final id = await dao.createSession(_makeSession(sessionId: 'ls-001'));
      expect(id, greaterThan(0));
    });

    test('inserted session can be retrieved by sessionId', () async {
      await dao.createSession(_makeSession(sessionId: 'ls-002', lessonId: 5));
      final session = await dao.getSession('ls-002');
      expect(session, isNotNull);
      expect(session!.sessionId, 'ls-002');
      expect(session.lessonId, 5);
    });
  });

  // ---------------------------------------------------------------------------
  // getSession
  // ---------------------------------------------------------------------------

  group('getSession', () {
    test('returns null for unknown sessionId', () async {
      final session = await dao.getSession('nonexistent');
      expect(session, isNull);
    });

    test('returns correct session when multiple exist', () async {
      await dao.createSession(_makeSession(sessionId: 'A', lessonId: 1));
      await dao.createSession(_makeSession(sessionId: 'B', lessonId: 2));

      final session = await dao.getSession('B');
      expect(session, isNotNull);
      expect(session!.lessonId, 2);
    });
  });

  // ---------------------------------------------------------------------------
  // updateSession
  // ---------------------------------------------------------------------------

  group('updateSession', () {
    test('updates correctCount and isPerfect on an existing session', () async {
      await dao.createSession(
        _makeSession(sessionId: 'upd-01', correctCount: 5, isPerfect: false),
      );
      final existing = await dao.getSession('upd-01');
      expect(existing, isNotNull);

      final updated = LearnSessionsCompanion(
        id: Value(existing!.id),
        sessionId: const Value('upd-01'),
        lessonId: Value(existing.lessonId),
        startedAt: Value(existing.startedAt),
        completedAt: Value(DateTime.now()),
        totalQuestions: Value(existing.totalQuestions),
        correctCount: const Value(10),
        wrongCount: const Value(0),
        currentRound: Value(existing.currentRound),
        xpEarned: Value(existing.xpEarned),
        isPerfect: const Value(true),
      );

      final result = await dao.updateSession(updated);
      expect(result, isTrue);

      final retrieved = await dao.getSession('upd-01');
      expect(retrieved!.correctCount, 10);
      expect(retrieved.isPerfect, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getIncompleteSessions
  // ---------------------------------------------------------------------------

  group('getIncompleteSessions', () {
    test('returns empty list when no sessions exist for lesson', () async {
      final result = await dao.getIncompleteSessions(99);
      expect(result, isEmpty);
    });

    test('returns incomplete sessions (completedAt is null)', () async {
      // Incomplete session for lesson 1
      await dao.createSession(
        _makeSession(sessionId: 'inc-1', lessonId: 1, completedAt: null),
      );
      // Completed session for lesson 1
      await dao.createSession(
        _makeSession(
          sessionId: 'comp-1',
          lessonId: 1,
          completedAt: DateTime.now(),
        ),
      );

      final incomplete = await dao.getIncompleteSessions(1);
      expect(incomplete, hasLength(1));
      expect(incomplete.first.sessionId, 'inc-1');
    });

    test('does not return sessions from other lessons', () async {
      await dao.createSession(
        _makeSession(sessionId: 'inc-L1', lessonId: 1, completedAt: null),
      );
      await dao.createSession(
        _makeSession(sessionId: 'inc-L2', lessonId: 2, completedAt: null),
      );

      final incomplete = await dao.getIncompleteSessions(1);
      expect(incomplete, hasLength(1));
      expect(incomplete.first.lessonId, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // getSessionHistory
  // ---------------------------------------------------------------------------

  group('getSessionHistory', () {
    test('returns empty list when no completed sessions for lesson', () async {
      final history = await dao.getSessionHistory(99);
      expect(history, isEmpty);
    });

    test('returns only completed sessions for the specified lesson', () async {
      await dao.createSession(
        _makeSession(
          sessionId: 'hist-done',
          lessonId: 3,
          completedAt: DateTime.now(),
        ),
      );
      await dao.createSession(
        _makeSession(sessionId: 'hist-pending', lessonId: 3, completedAt: null),
      );

      final history = await dao.getSessionHistory(3);
      expect(history, hasLength(1));
      expect(history.first.sessionId, 'hist-done');
    });

    test('orders completed sessions by completedAt descending', () async {
      final older = DateTime.now().subtract(const Duration(hours: 3));
      final newer = DateTime.now();

      await dao.createSession(
        _makeSession(
          sessionId: 'old-session',
          lessonId: 4,
          completedAt: older,
        ),
      );
      await dao.createSession(
        _makeSession(
          sessionId: 'new-session',
          lessonId: 4,
          completedAt: newer,
        ),
      );

      final history = await dao.getSessionHistory(4);
      expect(history, hasLength(2));
      expect(history.first.sessionId, 'new-session');
      expect(history.last.sessionId, 'old-session');
    });
  });

  // ---------------------------------------------------------------------------
  // recordAnswer and getSessionAnswers
  // ---------------------------------------------------------------------------

  group('recordAnswer / getSessionAnswers', () {
    test('getSessionAnswers returns empty list when no answers recorded',
        () async {
      await dao.createSession(_makeSession(sessionId: 'ans-empty'));
      final answers = await dao.getSessionAnswers('ans-empty');
      expect(answers, isEmpty);
    });

    test('recordAnswer inserts answer for a session', () async {
      await dao.createSession(_makeSession(sessionId: 'ans-session'));
      final rowId = await dao.recordAnswer(
        _makeAnswer(sessionId: 'ans-session', termId: 42, isCorrect: true),
      );
      expect(rowId, greaterThan(0));
    });

    test('getSessionAnswers returns answers ordered by questionIndex', () async {
      await dao.createSession(_makeSession(sessionId: 'ans-order'));
      for (var i in [2, 0, 1]) {
        await dao.recordAnswer(
          _makeAnswer(
            sessionId: 'ans-order',
            questionIndex: i,
            termId: i + 10,
          ),
        );
      }

      final answers = await dao.getSessionAnswers('ans-order');
      expect(answers, hasLength(3));
      expect(answers.map((a) => a.questionIndex).toList(), [0, 1, 2]);
    });

    test('getSessionAnswers returns only answers for the specified session',
        () async {
      await dao.createSession(_makeSession(sessionId: 's-filter-1'));
      await dao.createSession(_makeSession(sessionId: 's-filter-2'));

      await dao.recordAnswer(
        _makeAnswer(sessionId: 's-filter-1', termId: 1),
      );
      await dao.recordAnswer(
        _makeAnswer(sessionId: 's-filter-2', termId: 2),
      );
      await dao.recordAnswer(
        _makeAnswer(sessionId: 's-filter-1', questionIndex: 1, termId: 3),
      );

      final session1Answers = await dao.getSessionAnswers('s-filter-1');
      expect(session1Answers, hasLength(2));
      expect(
        session1Answers.every((a) => a.sessionId == 's-filter-1'),
        isTrue,
      );
    });
  });
}
