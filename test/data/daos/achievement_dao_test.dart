import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';

void main() {
  late AppDatabase db;
  late AchievementDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = AchievementDao(db);
  });

  tearDown(() => db.close());

  test('hasAchievement returns false when no matching row', () async {
    final result = await dao.hasAchievement('streak', 7);
    expect(result, isFalse);
  });

  test('hasAchievement returns true after inserting matching row', () async {
    await dao.addAchievement(AchievementsCompanion.insert(
      type: 'streak',
      value: 7,
      earnedAt: DateTime.now(),
      isNotified: const Value(false),
    ));
    final result = await dao.hasAchievement('streak', 7);
    expect(result, isTrue);
  });

  test('hasAchievement is false for same type but different value', () async {
    await dao.addAchievement(AchievementsCompanion.insert(
      type: 'streak',
      value: 7,
      earnedAt: DateTime.now(),
      isNotified: const Value(false),
    ));
    final result = await dao.hasAchievement('streak', 14);
    expect(result, isFalse);
  });
}
