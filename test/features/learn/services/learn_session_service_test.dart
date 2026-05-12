import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/gamification/level_calculator.dart';
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
  id: 'q$id',
  type: QuestionType.multipleChoice,
  targetItem: VocabItem(id: id, term: '水$id', meaning: 'm$id', level: 'N5'),
  questionText: 'Q$id?',
  correctAnswer: 'a$id',
);

QuestionResult _correctResult(Question q) => QuestionResult(
  question: q,
  userAnswer: q.correctAnswer,
  isCorrect: true,
  timeTaken: const Duration(seconds: 5),
  answeredAt: DateTime(2024, 1, 1),
);

QuestionResult _wrongResult(Question q) => QuestionResult(
  question: q,
  userAnswer: 'wrong',
  isCorrect: false,
  timeTaken: const Duration(seconds: 5),
  answeredAt: DateTime(2024, 1, 1),
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
    completedAt: DateTime(
      2024,
      1,
      1,
      10,
      0,
    ).add(totalTime ?? const Duration(minutes: 10)),
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
  // LevelCalculator is now the single source of truth for XP→level conversion.
  // The old service.calculateLevel() / xpForNextLevel() were removed in favour
  // of the infinite quadratic progression in LevelCalculator.
  group('LevelCalculator.calculate', () {
    // Thresholds (iterative quadratic, gap += 50 each level):
    // L1: 0–100   L2: 100–250  L3: 250–450  L4: 450–700  L5: 700–1000
    // L6: 1000–1350  L7: 1350–1750  L8: 1750–2200  L9: 2200–2700  L10: 2700–3250

    test('0 XP is level 1', () {
      expect(LevelCalculator.calculate(0).level, 1);
    });

    test('99 XP is still level 1', () {
      expect(LevelCalculator.calculate(99).level, 1);
    });

    test('100 XP is level 2', () {
      expect(LevelCalculator.calculate(100).level, 2);
    });

    test('249 XP is still level 2', () {
      expect(LevelCalculator.calculate(249).level, 2);
    });

    test('250 XP is level 3', () {
      expect(LevelCalculator.calculate(250).level, 3);
    });

    test('450 XP is level 4', () {
      expect(LevelCalculator.calculate(450).level, 4);
    });

    test('700 XP is level 5', () {
      expect(LevelCalculator.calculate(700).level, 5);
    });

    test('2700 XP is level 10', () {
      expect(LevelCalculator.calculate(2700).level, 10);
    });

    test('very high XP exceeds level 10 (no cap)', () {
      expect(LevelCalculator.calculate(99999).level, greaterThan(10));
    });

    test('progress is 0.0 at level start', () {
      final info = LevelCalculator.calculate(100); // exactly level 2 start
      expect(info.progress, 0.0);
    });

    test('progress increases within level', () {
      final info = LevelCalculator.calculate(
        175,
      ); // halfway through L2 (100-250)
      expect(info.progress, closeTo(0.5, 0.01));
    });

    test('totalXp is preserved', () {
      expect(LevelCalculator.calculate(1234).totalXp, 1234);
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

    test(
      'awards masteryComplete when all terms mastered and >= 10 questions',
      () async {
        final session = _buildSession(
          questionCount: 10,
          correctCount: 10,
          allMastered: true,
        );
        await service.saveSession(session);

        final achievements = await achievementDao.getAchievements();
        final types = achievements.map((a) => a.type).toList();
        expect(types, contains('masteryComplete'));
      },
    );

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
      expect(
        types,
        containsAll(['speedDemon', 'masteryComplete', 'firstLesson']),
      );
    });
  });
}
