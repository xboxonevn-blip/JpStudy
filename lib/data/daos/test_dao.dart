import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/study_tables.dart';

part 'test_dao.g.dart';

@DriftAccessor(tables: [TestSessions, TestAnswers])
class TestDao extends DatabaseAccessor<AppDatabase> with _$TestDaoMixin {
  TestDao(super.db);

  /// Create a new test session
  Future<int> createSession(TestSessionsCompanion session) {
    return into(testSessions).insert(session);
  }

  /// Update/Complete a test session
  Future<bool> updateSession(TestSessionsCompanion session) {
    return update(testSessions).replace(session);
  }

  /// Get session by ID
  Future<TestSession?> getSession(String id) {
    return (select(
      testSessions,
    )..where((t) => t.sessionId.equals(id))).getSingleOrNull();
  }

  /// Record an answer
  Future<int> recordAnswer(TestAnswersCompanion answer) {
    return into(testAnswers).insert(answer);
  }

  /// Get test history for a lesson
  Future<List<TestSession>> getHistory(int lessonId) {
    return (select(testSessions)
          ..where((t) => t.lessonId.equals(lessonId))
          ..where((t) => t.completedAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.completedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Get best score for a lesson
  Future<TestSession?> getBestScore(int lessonId) {
    return (select(testSessions)
          ..where((t) => t.lessonId.equals(lessonId))
          ..where((t) => t.completedAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(expression: t.score, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Get all history sorted by date
  Future<List<TestSession>> getAllHistory() {
    return (select(testSessions)
          ..where((t) => t.completedAt.isNotNull())
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.completedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }
}
