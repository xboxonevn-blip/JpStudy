import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/daos/kanji_srs_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';

class _SeededKanjiBatchHarness {
  _SeededKanjiBatchHarness(this.dao, {this.totalN5Kanji = 185});

  final KanjiSrsDao dao;
  final int totalN5Kanji;
  int xp = 0;

  Future<void> rateBatch(List<int> ratings) async {
    for (var index = 0; index < ratings.length; index++) {
      final kanjiId = index + 1;
      final rating = ratings[index];
      await dao.initializeSrsState(kanjiId);
      await dao.updateSrsState(
        kanjiId: kanjiId,
        stability: switch (rating) {
          1 => 0.2,
          3 => 2.5,
          4 => 4.0,
          _ => 1.0,
        },
        difficulty: switch (rating) {
          1 => 8.0,
          3 => 5.0,
          4 => 3.5,
          _ => 6.0,
        },
        lastConfidence: rating,
        nextReviewAt: DateTime.now().add(switch (rating) {
          1 => const Duration(minutes: 10),
          4 => const Duration(days: 4),
          _ => const Duration(days: 1),
        }),
      );
      xp += 5;
    }
  }

  Future<int> get studiedCount async => (await dao.getAllSeenKanjiIds()).length;
  Future<int> get newCount async => totalN5Kanji - await studiedCount;
}

void main() {
  late AppDatabase db;
  late KanjiSrsDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = KanjiSrsDao(db);
  });

  tearDown(() => db.close());

  test(
    'seeded local DB records 12-kanji learn batch FSRS counts and XP',
    () async {
      final harness = _SeededKanjiBatchHarness(dao);
      expect(await harness.studiedCount, 0);
      expect(await harness.newCount, 185);

      await harness.rateBatch([
        1, 1, 1, // Sai x3
        3, 3, 3, 3, 3, 3, 3, // Dung x7
        4, 4, // De x2
      ]);

      expect(await harness.studiedCount, 12, reason: 'Da hoc');
      expect(await harness.newCount, 173, reason: 'Moi');
      expect(harness.xp, 60);

      final states = await dao.getStatesForIds(List.generate(12, (i) => i + 1));
      expect(states, hasLength(12));
      expect(states.where((s) => s.lastConfidence == 1), hasLength(3));
      expect(states.where((s) => s.lastConfidence == 3), hasLength(7));
      expect(states.where((s) => s.lastConfidence == 4), hasLength(2));
    },
  );
}
