import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/content_repository.dart';

void main() {
  late ContentDatabase db;
  late ContentRepository repository;

  setUp(() {
    db = ContentDatabase(executor: NativeDatabase.memory());
    repository = ContentRepository(db);
  });

  tearDown(() => db.close());

  // ── updateProgress ────────────────────────────────────────────────────────

  test('updateProgress creates new record on first correct answer', () async {
    await repository.updateProgress(1, true);

    final rows = await db.select(db.userProgress).get();
    expect(rows.length, 1);
    expect(rows.first.vocabId, 1);
    expect(rows.first.correctCount, 1);
    expect(rows.first.missedCount, 0);
  });

  test('updateProgress creates new record on first incorrect answer', () async {
    await repository.updateProgress(2, false);

    final rows = await db.select(db.userProgress).get();
    expect(rows.first.correctCount, 0);
    expect(rows.first.missedCount, 1);
  });

  test('updateProgress increments existing correct count', () async {
    await repository.updateProgress(3, true);
    await repository.updateProgress(3, true);

    final rows = await db.select(db.userProgress).get();
    expect(rows.first.correctCount, 2);
    expect(rows.first.missedCount, 0);
  });

  test('updateProgress increments both counts over multiple reviews', () async {
    await repository.updateProgress(4, true);
    await repository.updateProgress(4, false);
    await repository.updateProgress(4, true);

    final rows = await db.select(db.userProgress).get();
    expect(rows.first.correctCount, 2);
    expect(rows.first.missedCount, 1);
  });

  test('updateProgress tracks separate records per vocabId', () async {
    await repository.updateProgress(10, true);
    await repository.updateProgress(20, false);

    final rows = await db.select(db.userProgress).get();
    expect(rows.length, 2);
    final r10 = rows.firstWhere((r) => r.vocabId == 10);
    final r20 = rows.firstWhere((r) => r.vocabId == 20);
    expect(r10.correctCount, 1);
    expect(r20.missedCount, 1);
  });

}
