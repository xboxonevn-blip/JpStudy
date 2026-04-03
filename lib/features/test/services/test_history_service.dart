import 'package:drift/drift.dart';

import '../../../data/db/app_database.dart';
import '../../../data/daos/test_dao.dart';
import '../models/test_session.dart' as domain;

/// Service for tracking test history and analytics
class TestHistoryService {
  final TestDao _testDao;

  TestHistoryService(this._testDao);

  /// Save a completed test
  Future<void> saveTest(domain.TestSession session) async {
    final companion = TestSessionsCompanion(
      sessionId: Value(session.sessionId),
      lessonId: Value(session.lessonId),
      startedAt: Value(session.startedAt),
      completedAt: Value(session.completedAt),
      totalQuestions: Value(session.totalQuestions),
      correctCount: Value(session.correctCount),
      wrongCount: Value(session.wrongCount),
      score: Value(session.score.toInt()),
      grade: Value(session.grade),
      xpEarned: Value(session.xpEarned),
      timeLimitMinutes: Value(session.timeLimitMinutes),
    );

    await _testDao.createSession(companion);

    // Save answers (including unanswered)
    for (int i = 0; i < session.questions.length; i++) {
      final answer = session.getAnswer(i);
      await _testDao.recordAnswer(
        TestAnswersCompanion(
          sessionId: Value(session.sessionId),
          questionIndex: Value(i),
          termId: Value(session.questions[i].targetItem.id),
          questionType: Value(session.questions[i].type.name),
          userAnswer: Value(answer?.userAnswer),
          isCorrect: Value(answer?.isCorrect ?? false),
          answeredAt: Value(answer?.answeredAt ?? DateTime.now()),
        ),
      );
    }
  }

  /// Get test history for a lesson
  Future<List<TestHistoryRecord>> getHistory(int lessonId) async {
    final dbSessions = await _testDao.getHistory(lessonId);
    return dbSessions.map(_mapToRecord).toList();
  }

  /// Get all test history
  Future<List<TestHistoryRecord>> getAllHistory() async {
    final dbSessions = await _testDao.getAllHistory();
    return dbSessions.map(_mapToRecord).toList();
  }

  /// Get progress data for charts (last N tests)
  Future<List<ProgressPoint>> getProgressData(
    int lessonId, {
    int limit = 10,
  }) async {
    final history = await getHistory(lessonId);
    final limitedHistory = history.take(limit).toList().reversed;

    return limitedHistory
        .map(
          (h) => ProgressPoint(
            date: h.completedAt,
            score: h.score,
            grade: h.grade,
          ),
        )
        .toList();
  }

  /// Compare two test attempts
  Future<TestComparison?> compareAttempts(
    String sessionId1,
    String sessionId2,
  ) async {
    final s1Future = _testDao.getSession(sessionId1);
    final s2Future = _testDao.getSession(sessionId2);
    final s1 = await s1Future;
    final s2 = await s2Future;

    if (s1 == null || s2 == null) return null;

    final test1 = _mapToRecord(s1);
    final test2 = _mapToRecord(s2);

    return TestComparison(
      test1: test1,
      test2: test2,
      scoreDiff: test2.score - test1.score,
      timeDiff: test2.timeElapsed - test1.timeElapsed,
      isImproved: test2.score > test1.score,
    );
  }

  /// Get best score for a lesson
  Future<TestHistoryRecord?> getBestScore(int lessonId) async {
    final s = await _testDao.getBestScore(lessonId);
    if (s == null) return null;
    return _mapToRecord(s);
  }

  /// Get average score for a lesson
  Future<double> getAverageScore(int lessonId) async {
    final history = await getHistory(lessonId);
    if (history.isEmpty) return 0;

    return history.map((h) => h.score).reduce((a, b) => a + b) / history.length;
  }

  /// Get test count for a lesson
  Future<int> getTestCount(int lessonId) async {
    final history = await getHistory(lessonId);
    return history.length;
  }

  // Helper map
  TestHistoryRecord _mapToRecord(TestSession session) {
    final duration = session.completedAt != null
        ? session.completedAt!.difference(session.startedAt)
        : Duration.zero;

    return TestHistoryRecord(
      sessionId: session.sessionId,
      lessonId: session.lessonId,
      completedAt: session.completedAt ?? DateTime.now(),
      score: session.score.toDouble(),
      grade: session.grade,
      correctCount: session.correctCount,
      totalQuestions: session.totalQuestions,
      timeElapsed: duration,
      xpEarned: session.xpEarned,
      weakTermIds: [],
    );
  }
}

/// Record of a single test attempt
class TestHistoryRecord {
  final String sessionId;
  final int lessonId;
  final DateTime completedAt;
  final double score;
  final String grade;
  final int correctCount;
  final int totalQuestions;
  final Duration timeElapsed;
  final int xpEarned;
  final List<int> weakTermIds;

  const TestHistoryRecord({
    required this.sessionId,
    required this.lessonId,
    required this.completedAt,
    required this.score,
    required this.grade,
    required this.correctCount,
    required this.totalQuestions,
    required this.timeElapsed,
    required this.xpEarned,
    required this.weakTermIds,
  });

  double get accuracy => totalQuestions > 0 ? correctCount / totalQuestions : 0;
}

/// Point on progress chart
class ProgressPoint {
  final DateTime date;
  final double score;
  final String grade;

  const ProgressPoint({
    required this.date,
    required this.score,
    required this.grade,
  });
}

/// Comparison between two test attempts
class TestComparison {
  final TestHistoryRecord test1;
  final TestHistoryRecord test2;
  final double scoreDiff;
  final Duration timeDiff;
  final bool isImproved;

  const TestComparison({
    required this.test1,
    required this.test2,
    required this.scoreDiff,
    required this.timeDiff,
    required this.isImproved,
  });

  String get scoreDiffText {
    if (scoreDiff > 0) return '+${scoreDiff.toInt()}%';
    return '${scoreDiff.toInt()}%';
  }
}
