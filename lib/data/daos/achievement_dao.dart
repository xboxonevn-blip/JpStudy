import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/study_tables.dart';

part 'achievement_dao.g.dart';

@DriftAccessor(tables: [Achievements])
class AchievementDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementDaoMixin {
  AchievementDao(super.db);

  /// Add a new achievement
  Future<int> addAchievement(AchievementsCompanion achievement) {
    return into(achievements).insert(achievement);
  }

  /// Get all achievements
  Future<List<Achievement>> getAchievements() {
    return (select(achievements)..orderBy([
          (t) => OrderingTerm(expression: t.earnedAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Get un-notified achievements
  Future<List<Achievement>> getUnnotifiedAchievements() {
    return (select(
      achievements,
    )..where((t) => t.isNotified.equals(false))).get();
  }

  /// Mark achievement as notified
  Future<void> markAsNotified(int id) {
    return (update(achievements)..where((t) => t.id.equals(id))).write(
      const AchievementsCompanion(isNotified: Value(true)),
    );
  }

  /// Mark multiple achievements as notified in a single round-trip.
  Future<void> markAllAsNotified(List<int> ids) {
    if (ids.isEmpty) return Future.value();
    return (update(achievements)..where((t) => t.id.isIn(ids))).write(
      const AchievementsCompanion(isNotified: Value(true)),
    );
  }

  /// Returns true if an achievement of the given type and value already exists.
  Future<bool> hasAchievement(String type, int value) async {
    final row =
        await (select(achievements)
              ..where((t) => t.type.equals(type) & t.value.equals(value)))
            .getSingleOrNull();
    return row != null;
  }
}
