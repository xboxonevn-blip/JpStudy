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

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  Future<int> _insert({
    String type = 'streak',
    int value = 7,
    bool isNotified = false,
    DateTime? earnedAt,
  }) {
    return dao.addAchievement(
      AchievementsCompanion.insert(
        type: type,
        value: value,
        earnedAt: earnedAt ?? DateTime.now(),
        isNotified: Value(isNotified),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // hasAchievement
  // ---------------------------------------------------------------------------

  group('hasAchievement', () {
    test('returns false when no matching row', () async {
      final result = await dao.hasAchievement('streak', 7);
      expect(result, isFalse);
    });

    test('returns true after inserting matching row', () async {
      await _insert(type: 'streak', value: 7);
      final result = await dao.hasAchievement('streak', 7);
      expect(result, isTrue);
    });

    test('is false for same type but different value', () async {
      await _insert(type: 'streak', value: 7);
      final result = await dao.hasAchievement('streak', 14);
      expect(result, isFalse);
    });

    test('is false for same value but different type', () async {
      await _insert(type: 'streak', value: 7);
      final result = await dao.hasAchievement('perfect_round', 7);
      expect(result, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // addAchievement and getAchievements
  // ---------------------------------------------------------------------------

  group('addAchievement / getAchievements', () {
    test('returns empty list when no achievements exist', () async {
      final all = await dao.getAchievements();
      expect(all, isEmpty);
    });

    test('inserts an achievement that appears in getAchievements', () async {
      await _insert(type: 'streak', value: 7);
      final all = await dao.getAchievements();
      expect(all, hasLength(1));
      expect(all.first.type, 'streak');
      expect(all.first.value, 7);
    });

    test('getAchievements orders by earnedAt descending', () async {
      final older = DateTime.now().subtract(const Duration(hours: 5));
      final newer = DateTime.now();
      await _insert(type: 'streak', value: 7, earnedAt: older);
      await _insert(type: 'perfect_round', value: 1, earnedAt: newer);

      final all = await dao.getAchievements();
      expect(all.first.type, 'perfect_round');
      expect(all.last.type, 'streak');
    });

    test('can insert multiple distinct achievements', () async {
      await _insert(type: 'streak', value: 7);
      await _insert(type: 'streak', value: 14);
      await _insert(type: 'level_up', value: 2);

      final all = await dao.getAchievements();
      expect(all, hasLength(3));
    });
  });

  // ---------------------------------------------------------------------------
  // getUnnotifiedAchievements
  // ---------------------------------------------------------------------------

  group('getUnnotifiedAchievements', () {
    test('returns empty list when no achievements exist', () async {
      final unnotified = await dao.getUnnotifiedAchievements();
      expect(unnotified, isEmpty);
    });

    test('returns only unnotified achievements', () async {
      await _insert(type: 'streak', value: 7, isNotified: false);
      await _insert(type: 'level_up', value: 1, isNotified: true);

      final unnotified = await dao.getUnnotifiedAchievements();
      expect(unnotified, hasLength(1));
      expect(unnotified.first.type, 'streak');
    });

    test('returns empty list when all achievements are notified', () async {
      await _insert(type: 'streak', value: 7, isNotified: true);
      await _insert(type: 'level_up', value: 1, isNotified: true);

      final unnotified = await dao.getUnnotifiedAchievements();
      expect(unnotified, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // markAsNotified
  // ---------------------------------------------------------------------------

  group('markAsNotified', () {
    test('marks a specific achievement as notified', () async {
      final id = await _insert(type: 'streak', value: 7, isNotified: false);

      await dao.markAsNotified(id);

      final unnotified = await dao.getUnnotifiedAchievements();
      expect(unnotified, isEmpty);

      final all = await dao.getAchievements();
      expect(all.first.isNotified, isTrue);
    });

    test('does not affect other achievements when marking one', () async {
      final id1 = await _insert(type: 'streak', value: 7, isNotified: false);
      await _insert(type: 'level_up', value: 1, isNotified: false);

      await dao.markAsNotified(id1);

      final unnotified = await dao.getUnnotifiedAchievements();
      expect(unnotified, hasLength(1));
      expect(unnotified.first.type, 'level_up');
    });

    test('is a no-op for unknown id', () async {
      await _insert(type: 'streak', value: 7, isNotified: false);
      await dao.markAsNotified(99999); // Unknown id

      final unnotified = await dao.getUnnotifiedAchievements();
      expect(unnotified, hasLength(1)); // Original still unnotified
    });
  });
}
