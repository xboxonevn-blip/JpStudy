import 'package:drift/drift.dart';

import '../../../data/db/app_database.dart';
import '../../../data/daos/achievement_dao.dart';
import '../../../data/daos/learn_dao.dart';
import '../models/achievement.dart' as model;
import '../models/learn_session.dart' as domain;

/// Service for managing learn session persistence and achievements
class LearnSessionService {
  final LearnDao _learnDao;
  final AchievementDao _achievementDao;

  LearnSessionService(this._learnDao, this._achievementDao);

  /// Save a completed session
  Future<void> saveSession(domain.LearnSession session) async {
    final companion = LearnSessionsCompanion(
      sessionId: Value(session.sessionId),
      lessonId: Value(session.lessonId),
      startedAt: Value(session.startedAt),
      completedAt: Value(session.completedAt),
      totalQuestions: Value(session.totalQuestions),
      correctCount: Value(session.correctCount),
      wrongCount: Value(session.wrongCount),
      currentRound: Value(session.currentRound),
      xpEarned: Value(session.totalXP),
      isPerfect: Value(session.correctCount == session.totalQuestions),
    );

    await _learnDao.createSession(companion);

    // Check for achievements
    await _checkAchievements(session);
  }

  /// Get incomplete sessions for a lesson
  Future<List<LearnSession>> getIncompleteSessions(int lessonId) async {
    return _learnDao.getIncompleteSessions(lessonId);
  }

  /// Get session history for a lesson
  Future<List<LearnSession>> getSessionHistory(int lessonId) async {
    return _learnDao.getSessionHistory(lessonId);
  }

  /// Get pending achievements
  Future<List<model.Achievement>> getPendingAchievements() async {
    final dbAchievements = await _achievementDao.getUnnotifiedAchievements();
    final achievements = dbAchievements.map((a) {
      model.AchievementType type;
      try {
        type = model.AchievementType.values.firstWhere(
          (e) => e.toString() == 'AchievementType.${a.type}',
        );
      } catch (_) {
        type = model.AchievementType.values.firstWhere((e) => e.name == a.type);
      }

      return model.Achievement(
        type: type,
        value: a.value,
        earnedAt: a.earnedAt,
        lessonId: a.lessonId,
        sessionId: a.sessionId,
        isNotified: a.isNotified,
      );
    }).toList();

    // Mark all as notified in a single round-trip.
    await _achievementDao.markAllAsNotified(
      dbAchievements.map((a) => a.id).toList(growable: false),
    );

    return achievements;
  }

  /// Check for and record achievements
  Future<void> _checkAchievements(domain.LearnSession session) async {
    // Perfect round achievement
    if (session.correctCount == session.totalQuestions &&
        session.totalQuestions >= 10) {
      await _achievementDao.addAchievement(
        AchievementsCompanion(
          type: Value(model.AchievementType.perfectRound.name),
          value: Value(session.totalQuestions),
          earnedAt: Value(DateTime.now()),
          lessonId: Value(session.lessonId),
          sessionId: Value(session.sessionId),
          isNotified: const Value(false),
        ),
      );
    }

    // Speed demon achievement (completed in under 2 minutes for 20+ questions)
    if (session.totalTime.inMinutes < 2 && session.totalQuestions >= 20) {
      await _achievementDao.addAchievement(
        AchievementsCompanion(
          type: Value(model.AchievementType.speedDemon.name),
          value: Value(session.totalTime.inSeconds),
          earnedAt: Value(DateTime.now()),
          lessonId: Value(session.lessonId),
          sessionId: Value(session.sessionId),
          isNotified: const Value(false),
        ),
      );
    }

    // Mastery complete (all terms mastered)
    if (session.unmasteredTermIds.isEmpty && session.totalQuestions >= 10) {
      await _achievementDao.addAchievement(
        AchievementsCompanion(
          type: Value(model.AchievementType.masteryComplete.name),
          value: Value(session.totalQuestions),
          earnedAt: Value(DateTime.now()),
          lessonId: Value(session.lessonId),
          sessionId: Value(session.sessionId),
          isNotified: const Value(false),
        ),
      );
    }

    // First lesson — awarded once. Uses a targeted point-lookup instead of
    // loading the full achievements table and scanning in Dart.
    final alreadyAwarded = await _achievementDao.hasAchievement(
      model.AchievementType.firstLesson.name,
      1,
    );
    if (!alreadyAwarded) {
      await _achievementDao.addAchievement(
        AchievementsCompanion(
          type: Value(model.AchievementType.firstLesson.name),
          value: const Value(1),
          earnedAt: Value(DateTime.now()),
          lessonId: Value(session.lessonId),
          sessionId: Value(session.sessionId),
          isNotified: const Value(false),
        ),
      );
    }
    // D2: kanjiMaster — trigger from kanji SRS review flow when mastered count crosses 100.
    // D2: articleReader — trigger from immersion reader when completed article count crosses 5.
  }

  /// Calculate user's current level based on total XP
  int calculateLevel(int totalXP) {
    // XP thresholds for each level
    const xpPerLevel = [
      0, // Level 1
      100, // Level 2
      300, // Level 3
      600, // Level 4
      1000, // Level 5
      1500, // Level 6
      2100, // Level 7
      2800, // Level 8
      3600, // Level 9
      4500, // Level 10
    ];

    for (int i = xpPerLevel.length - 1; i >= 0; i--) {
      if (totalXP >= xpPerLevel[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  /// Get XP needed for next level
  int xpForNextLevel(int currentLevel) {
    const xpPerLevel = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    if (currentLevel >= xpPerLevel.length) return 0;
    return xpPerLevel[currentLevel];
  }
}
