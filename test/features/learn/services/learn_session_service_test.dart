import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart' as domain;
import 'package:jpstudy/features/learn/services/learn_session_service.dart';

// ── Fixtures ─────────────────────────────────────────────────

Question _mcQuestion(int id) => Question(
  id: 'q$id', type: QuestionType.multipleChoice,
  targetItem: VocabItem(id: id, term: '水$id', meaning: 'm$id', level: 'N5'),
  questionText: 'Q$id?', correctAnswer: 'a$id',
);

QuestionResult _correctResult(Question q) => QuestionResult(
  question: q, userAnswer: q.correctAnswer, isCorrect: true,
  timeTaken: const Duration(seconds: 5), answeredAt: DateTime(2024, 1, 1),
);

QuestionResult _wrongResult(Question q) => QuestionResult(
  question: q, userAnswer: 'wrong', isCorrect: false,
  timeTaken: const Duration(seconds: 5), answeredAt: DateTime(2024, 1, 1),
);

/// Build a completed domain session with the given question count and correct count.
domain.LearnSession _buildSession({
  required int questionCount,
  required int correctCount,
  Duration? totalTime,
  bool allMastered = false,
}) {
  final questions = List.generate(questionCount, (i) => _mcQuestion(i));
  final session = domain.LearnSession(
    sessionId: 'sess-${DateTime.now().microsecondsSinceEpoch}',
    lessonId: 1,
    startedAt: DateTime(2024, 1, 1, 10, 0),
    completedAt: DateTime(2024, 1, 1, 10, 0).add(totalTime ?? const Duration(minutes: 10)),
    questions: questions,
  );

  // Record results via recordResult so mastery tracking works
  for (int i = 0; i < correctCount; i++) {
    session.recordResult(_correctResult(questions[i]));
  }
  for (int i = correctCount; i < questionCount; i++) {
    session.recordResult(_wrongResult(questions[i]));
  }

  // If allMastered, record 2 more correct per term to reach 3
  if (allMastered) {
    for (int i = 0; i < questionCount; i++) {
      session.recordResult(_correctResult(questions[i]));
      session.recordResult(_correctResult(questions[i]));
    }
  }

  return session;
}

// ── Tests ────────────────────────────────────────────────────

void main() {
  group('LearnSessionService.calculateLevel', () {
    late LearnSessionService service;

    setUp(() {
      final db = AppDatabase(executor: NativeDatabase.memory());
      service = LearnSessionService(LearnDao(db), AchievementDao(db));
    });

    test('0 XP is level 1', () {
      expect(service.calculateLevel(0), 1);
    });

    test('99 XP is still level 1', () {
      expect(service.calculateLevel(99), 1);
    });

    test('100 XP is level 2', () {
      expect(service.calculateLevel(100), 2);
    });

    test('299 XP is level 2', () {
      expect(service.calculateLevel(299), 2);
    });

    test('300 XP is level 3', () {
      expect(service.calculateLevel(300), 3);
    });

    test('4500 XP is level 10 (max)', () {
      expect(service.calculateLevel(4500), 10);
    });

    test('very high XP stays at level 10', () {
      expect(service.calculateLevel(99999), 10);
    });

    test('all threshold boundaries', () {
      const thresholds = {
        0: 1, 100: 2, 300: 3, 600: 4, 1000: 5,
        1500: 6, 2100: 7, 2800: 8, 3600: 9, 4500: 10,
      };
      for (final entry in thresholds.entries) {
        expect(service.calculateLevel(entry.key), entry.value,
            reason: '${entry.key} XP should be level ${entry.value}');
      }
    });
  });

  group('LearnSessionService.xpForNextLevel', () {
    late LearnSessionService service;

    setUp(() {
      final db = AppDatabase(executor: NativeDatabase.memory());
      service = LearnSessionService(LearnDao(db), AchievementDao(db));
    });

    test('level 1 needs 100 XP for level 2', () {
      expect(service.xpForNextLevel(1), 100);
    });

    test('level 9 needs 4500 XP for level 10', () {
      expect(service.xpForNextLevel(9), 4500);
    });

    test('level 10 (max) returns 0', () {
      expect(service.xpForNextLevel(10), 0);
    });

    test('beyond max level returns 0', () {
      expect(service.xpForNextLevel(99), 0);
    });
  });

  group('LearnSessionService.saveSession — achievement checks', () {
    late AppDatabase db;
    late AchievementDao achievementDao;
    late LearnSessionService service;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
      achievementDao = AchievementDao(db);
      service = LearnSessionService(LearnDao(db), achievementDao);
    });

    tearDown(() => db.close());

    test('awards perfectRound when all correct and >= 10 questions', () async {
      final session = _buildSession(questionCount: 10, correctCount: 10);
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, contains('perfectRound'));
    });

    test('no perfectRound when not all correct', () async {
      final session = _buildSession(questionCount: 10, correctCount: 9);
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, isNot(contains('perfectRound')));
    });

    test('no perfectRound when fewer than 10 questions', () async {
      final session = _buildSession(questionCount: 5, correctCount: 5);
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, isNot(contains('perfectRound')));
    });

    test('awards speedDemon when < 2 min and >= 20 questions', () async {
      final session = _buildSession(
        questionCount: 20,
        correctCount: 20,
        totalTime: const Duration(seconds: 90),
      );
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, contains('speedDemon'));
    });

    test('no speedDemon when >= 2 min', () async {
      final session = _buildSession(
        questionCount: 20,
        correctCount: 20,
        totalTime: const Duration(minutes: 3),
      );
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, isNot(contains('speedDemon')));
    });

    test('no speedDemon when < 20 questions', () async {
      final session = _buildSession(
        questionCount: 15,
        correctCount: 15,
        totalTime: const Duration(seconds: 60),
      );
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, isNot(contains('speedDemon')));
    });

    test('awards masteryComplete when all terms mastered and >= 10 questions', () async {
      final session = _buildSession(
        questionCount: 10,
        correctCount: 10,
        allMastered: true,
      );
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, contains('masteryComplete'));
    });

    test('no masteryComplete when terms not mastered', () async {
      // Only 1 correct per term → not mastered
      final session = _buildSession(questionCount: 10, correctCount: 10);
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, isNot(contains('masteryComplete')));
    });

    test('awards firstLesson on first ever session', () async {
      final session = _buildSession(questionCount: 5, correctCount: 3);
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toList();
      expect(types, contains('firstLesson'));
    });

    test('does not award firstLesson on second session', () async {
      final session1 = _buildSession(questionCount: 5, correctCount: 3);
      await service.saveSession(session1);

      final session2 = _buildSession(questionCount: 5, correctCount: 5);
      await service.saveSession(session2);

      final achievements = await achievementDao.getAchievements();
      final firstLessons = achievements.where((a) => a.type == 'firstLesson');
      expect(firstLessons.length, 1); // only awarded once
    });

    test('multiple achievements can be awarded in single session', () async {
      // Fast + all mastered + first lesson → 3 achievements
      // Note: allMastered inflates correctCount past totalQuestions,
      // so perfectRound (correctCount == totalQuestions) cannot co-fire.
      final session = _buildSession(
        questionCount: 20,
        correctCount: 20,
        totalTime: const Duration(seconds: 90),
        allMastered: true,
      );
      await service.saveSession(session);

      final achievements = await achievementDao.getAchievements();
      final types = achievements.map((a) => a.type).toSet();
      expect(types, containsAll(['speedDemon', 'masteryComplete', 'firstLesson']));
    });
  });
}
