import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/daos/achievement_dao.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/database_provider.dart';
import '../services/immersion_service.dart';

final immersionServiceProvider = Provider<ImmersionService>((ref) {
  return ImmersionService();
});

final readArticlesProvider =
    NotifierProvider<ReadArticlesNotifier, Set<String>>(
      ReadArticlesNotifier.new,
    );

class ReadArticlesNotifier extends Notifier<Set<String>> {
  late final ImmersionService _service;
  late final AchievementDao _achievementDao;

  @override
  Set<String> build() {
    _service = ref.watch(immersionServiceProvider);
    final db = ref.watch(databaseProvider);
    _achievementDao = AchievementDao(db);
    _load();
    return {};
  }

  /// Article-read milestones that unlock the Avid Reader achievement.
  static const _milestones = [5, 10, 20];

  Future<void> _load() async {
    final ids = await _service.getReadArticleIds();
    state = ids;
  }

  Future<void> toggle(String id) async {
    final isRead = state.contains(id);
    final newState = {...state};
    if (isRead) {
      newState.remove(id);
    } else {
      newState.add(id);
    }
    state = newState;
    await _service.markArticleAsRead(id, !isRead);

    // Achievement: articleReader — fire when the read count hits a milestone.
    // Only check on mark-as-read, not on un-mark.
    if (!isRead && _milestones.contains(newState.length)) {
      final count = newState.length;
      final already = await _achievementDao.hasAchievement(
        'articleReader',
        count,
      );
      if (!already) {
        await _achievementDao.addAchievement(
          AchievementsCompanion(
            type: const Value('articleReader'),
            value: Value(count),
            earnedAt: Value(DateTime.now()),
            isNotified: const Value(false),
          ),
        );
      }
    }
  }
}
