import 'package:flutter/material.dart';

/// Achievement types
enum AchievementType {
  perfectRound,
  streak,
  levelUp,
  masteryComplete,
  speedDemon,
  /// Completed your very first lesson — triggered once, on first session save.
  firstLesson,
  /// Mastered 100 kanji via SRS — triggered from kanji review flow.
  kanjiMaster,
  /// Read 5 immersion articles — triggered from immersion reader.
  articleReader,
}

extension AchievementTypeExtension on AchievementType {
  String get title {
    switch (this) {
      case AchievementType.perfectRound:
        return 'Perfect Round!';
      case AchievementType.streak:
        return 'Study Streak!';
      case AchievementType.levelUp:
        return 'Level Up!';
      case AchievementType.masteryComplete:
        return 'Mastery Complete!';
      case AchievementType.speedDemon:
        return 'Speed Demon!';
      case AchievementType.firstLesson:
        return 'First Steps!';
      case AchievementType.kanjiMaster:
        return 'Kanji Master!';
      case AchievementType.articleReader:
        return 'Avid Reader!';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementType.perfectRound:
        return '🏆';
      case AchievementType.streak:
        return '🔥';
      case AchievementType.levelUp:
        return '⭐';
      case AchievementType.masteryComplete:
        return '🎓';
      case AchievementType.speedDemon:
        return '⚡';
      case AchievementType.firstLesson:
        return '🎌';
      case AchievementType.kanjiMaster:
        return '📚';
      case AchievementType.articleReader:
        return '📖';
    }
  }

  Color get color {
    switch (this) {
      case AchievementType.perfectRound:
        return Colors.amber;
      case AchievementType.streak:
        return Colors.deepOrange;
      case AchievementType.levelUp:
        return Colors.purple;
      case AchievementType.masteryComplete:
        return Colors.green;
      case AchievementType.speedDemon:
        return Colors.blue;
      case AchievementType.firstLesson:
        return Colors.teal;
      case AchievementType.kanjiMaster:
        return Colors.indigo;
      case AchievementType.articleReader:
        return Colors.cyan;
    }
  }
}

/// Achievement data model
class Achievement {
  final AchievementType type;
  final int value;
  final DateTime earnedAt;
  final int? lessonId;
  final String? sessionId;
  final bool isNotified;

  const Achievement({
    required this.type,
    required this.value,
    required this.earnedAt,
    this.lessonId,
    this.sessionId,
    this.isNotified = false,
  });

  String get description {
    switch (type) {
      case AchievementType.perfectRound:
        return 'Answered all questions correctly!';
      case AchievementType.streak:
        return '$value day study streak!';
      case AchievementType.levelUp:
        return 'Reached level $value!';
      case AchievementType.masteryComplete:
        return 'Mastered all terms in lesson!';
      case AchievementType.speedDemon:
        return 'Completed in record time!';
      case AchievementType.firstLesson:
        return 'Completed your very first lesson!';
      case AchievementType.kanjiMaster:
        return 'Mastered $value kanji through SRS!';
      case AchievementType.articleReader:
        return 'Read $value immersion articles!';
    }
  }

  int get bonusXP {
    switch (type) {
      case AchievementType.perfectRound:
        return 50;
      case AchievementType.streak:
        return value * 10;
      case AchievementType.levelUp:
        return 100;
      case AchievementType.masteryComplete:
        return 75;
      case AchievementType.speedDemon:
        return 25;
      case AchievementType.firstLesson:
        return 50;
      case AchievementType.kanjiMaster:
        return 200;
      case AchievementType.articleReader:
        return 100;
    }
  }
}
