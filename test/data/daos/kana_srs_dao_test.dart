import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';

void main() {
  test('upsertReview inserts and updates rows by kana primary key', () async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final dao = db.kanaSrsDao;
    final now = DateTime(2026, 1, 1);

    await dao.upsertReview(
      kana: 'あ',
      script: 'hiragana',
      stability: 1,
      difficulty: 5,
      reps: 1,
      lapses: 0,
      dueAt: now,
      lastReviewedAt: now,
    );
    expect((await dao.getOrEmpty('あ'))?.reps, 1);

    await dao.upsertReview(
      kana: 'あ',
      script: 'hiragana',
      stability: 2,
      difficulty: 4,
      reps: 2,
      lapses: 1,
      dueAt: now.add(const Duration(days: 1)),
      lastReviewedAt: now,
    );
    final row = await dao.getOrEmpty('あ');
    expect(row?.reps, 2);
    expect(row?.lapses, 1);
  });

  test('dueKanaCount counts due rows only', () async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final dao = db.kanaSrsDao;
    final now = DateTime(2026, 1, 1, 12);

    expect(await dao.dueKanaCount(now: now), 0);
    for (final entry in [
      ('あ', now.subtract(const Duration(minutes: 1))),
      ('い', now),
      ('う', now.add(const Duration(days: 1))),
    ]) {
      await dao.upsertReview(
        kana: entry.$1,
        script: 'hiragana',
        stability: 1,
        difficulty: 5,
        reps: 1,
        lapses: 0,
        dueAt: entry.$2,
        lastReviewedAt: now,
      );
    }

    expect(await dao.dueKanaCount(now: now), 2);
    expect(
      (await dao.dueKana(now: now)).map((e) => e.kana),
      containsAll(['あ', 'い']),
    );
  });
}
