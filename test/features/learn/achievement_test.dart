import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/learn/models/achievement.dart';

void main() {
  // ── AchievementType metadata ──────────────────────────────────────────────

  test('every AchievementType has a non-empty title', () {
    for (final type in AchievementType.values) {
      expect(type.title, isNotEmpty, reason: '${type.name} has empty title');
    }
  });

  test('every AchievementType has a non-empty emoji', () {
    for (final type in AchievementType.values) {
      expect(type.emoji, isNotEmpty, reason: '${type.name} has empty emoji');
    }
  });

  test('AchievementType.perfectRound has correct title', () {
    expect(AchievementType.perfectRound.title, 'Perfect Round!');
  });

  test('AchievementType.streak has correct emoji', () {
    expect(AchievementType.streak.emoji, '🔥');
  });

  // ── Achievement.description ───────────────────────────────────────────────

  test('streak description includes value', () {
    final a = Achievement(
      type: AchievementType.streak,
      value: 7,
      earnedAt: DateTime(2025),
    );
    expect(a.description, contains('7'));
  });

  test('levelUp description includes value', () {
    final a = Achievement(
      type: AchievementType.levelUp,
      value: 5,
      earnedAt: DateTime(2025),
    );
    expect(a.description, contains('5'));
  });

  test('kanjiMaster description includes value', () {
    final a = Achievement(
      type: AchievementType.kanjiMaster,
      value: 100,
      earnedAt: DateTime(2025),
    );
    expect(a.description, contains('100'));
  });

  test('perfectRound description is fixed string', () {
    final a = Achievement(
      type: AchievementType.perfectRound,
      value: 0,
      earnedAt: DateTime(2025),
    );
    expect(a.description, 'Answered all questions correctly!');
  });

  // ── Achievement.bonusXP ───────────────────────────────────────────────────

  test('perfectRound bonusXP is 50', () {
    expect(
      Achievement(
        type: AchievementType.perfectRound,
        value: 0,
        earnedAt: DateTime(2025),
      ).bonusXP,
      50,
    );
  });

  test('streak bonusXP = value * 10', () {
    expect(
      Achievement(
        type: AchievementType.streak,
        value: 5,
        earnedAt: DateTime(2025),
      ).bonusXP,
      50,
    );
    expect(
      Achievement(
        type: AchievementType.streak,
        value: 30,
        earnedAt: DateTime(2025),
      ).bonusXP,
      300,
    );
  });

  test('levelUp bonusXP is 100', () {
    expect(
      Achievement(
        type: AchievementType.levelUp,
        value: 10,
        earnedAt: DateTime(2025),
      ).bonusXP,
      100,
    );
  });

  test('kanjiMaster bonusXP is 200', () {
    expect(
      Achievement(
        type: AchievementType.kanjiMaster,
        value: 0,
        earnedAt: DateTime(2025),
      ).bonusXP,
      200,
    );
  });

  test('speedDemon bonusXP is 25', () {
    expect(
      Achievement(
        type: AchievementType.speedDemon,
        value: 0,
        earnedAt: DateTime(2025),
      ).bonusXP,
      25,
    );
  });

  // ── Achievement defaults ──────────────────────────────────────────────────

  test('isNotified defaults to false', () {
    final a = Achievement(
      type: AchievementType.firstLesson,
      value: 1,
      earnedAt: DateTime(2025),
    );
    expect(a.isNotified, isFalse);
  });

  test('optional fields default to null', () {
    final a = Achievement(
      type: AchievementType.masteryComplete,
      value: 0,
      earnedAt: DateTime(2025),
    );
    expect(a.lessonId, isNull);
    expect(a.sessionId, isNull);
  });
}
