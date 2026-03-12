import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/learn/models/achievement.dart';

void main() {
  test('all AchievementTypes have title, emoji, and color', () {
    for (final type in AchievementType.values) {
      expect(type.title, isNotEmpty);
      expect(type.emoji, isNotEmpty);
      expect(type.color, isNotNull);
    }
  });

  test('Achievement.description includes value for parametric types', () {
    final streak = Achievement(
      type: AchievementType.streak,
      value: 14,
      earnedAt: DateTime.now(),
    );
    expect(streak.description, contains('14'));

    final kanji = Achievement(
      type: AchievementType.kanjiMaster,
      value: 100,
      earnedAt: DateTime.now(),
    );
    expect(kanji.description, contains('100'));
  });

  test('Achievement.bonusXP returns positive values', () {
    for (final type in AchievementType.values) {
      final achievement = Achievement(
        type: type,
        value: 10,
        earnedAt: DateTime.now(),
      );
      expect(achievement.bonusXP, greaterThan(0));
    }
  });

  test('streak bonusXP scales with value', () {
    final low = Achievement(
      type: AchievementType.streak,
      value: 7,
      earnedAt: DateTime.now(),
    );
    final high = Achievement(
      type: AchievementType.streak,
      value: 30,
      earnedAt: DateTime.now(),
    );
    expect(high.bonusXP, greaterThan(low.bonusXP));
  });

  test('AchievementType enum has 8 values', () {
    expect(AchievementType.values.length, 8);
  });
}
