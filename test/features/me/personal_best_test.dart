import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/me/providers/personal_best_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertAttempt(
    String mode,
    String level,
    int score,
    int total,
  ) async {
    await db
        .into(db.attempt)
        .insert(
          AttemptCompanion.insert(
            mode: mode,
            level: level,
            startedAt: DateTime.now(),
            score: Value(score),
            total: Value(total),
          ),
        );
  }

  test('queryPersonalBests returns empty when no attempts exist', () async {
    final bests = await queryPersonalBests(db);
    expect(bests, isEmpty);
  });

  test('queryPersonalBests returns best percentage per mode+level', () async {
    await insertAttempt('test', 'N5', 7, 10); // 70%
    await insertAttempt('test', 'N5', 9, 10); // 90%
    await insertAttempt('test', 'N4', 5, 10); // 50%
    await insertAttempt('learn', 'N5', 8, 10); // 80%

    final bests = await queryPersonalBests(db);

    expect(bests.length, 3);
    // Sorted by best_pct DESC
    expect(bests[0].mode, 'test');
    expect(bests[0].level, 'N5');
    expect(bests[0].bestPercent, 90.0);
    expect(bests[0].attempts, 2);

    expect(bests[1].mode, 'learn');
    expect(bests[1].bestPercent, 80.0);

    expect(bests[2].mode, 'test');
    expect(bests[2].level, 'N4');
    expect(bests[2].bestPercent, 50.0);
  });

  test('isNewPersonalBest returns true when no prior attempts', () async {
    final result = await isNewPersonalBest(
      db,
      mode: 'test',
      level: 'N5',
      score: 5,
      total: 10,
    );
    expect(result, isTrue);
  });

  test('isNewPersonalBest returns true when score beats record', () async {
    await insertAttempt('test', 'N5', 7, 10);

    final result = await isNewPersonalBest(
      db,
      mode: 'test',
      level: 'N5',
      score: 8,
      total: 10,
    );
    expect(result, isTrue);
  });

  test('isNewPersonalBest returns false when score ties record', () async {
    await insertAttempt('test', 'N5', 8, 10);

    final result = await isNewPersonalBest(
      db,
      mode: 'test',
      level: 'N5',
      score: 8,
      total: 10,
    );
    expect(result, isFalse);
  });

  test('isNewPersonalBest returns false when score is lower', () async {
    await insertAttempt('test', 'N5', 9, 10);

    final result = await isNewPersonalBest(
      db,
      mode: 'test',
      level: 'N5',
      score: 7,
      total: 10,
    );
    expect(result, isFalse);
  });

  test('isNewPersonalBest returns false for zero total', () async {
    final result = await isNewPersonalBest(
      db,
      mode: 'test',
      level: 'N5',
      score: 0,
      total: 0,
    );
    expect(result, isFalse);
  });

  test('isNewPersonalBest is scoped to mode+level', () async {
    await insertAttempt('test', 'N5', 10, 10); // 100% for test/N5

    // Different mode — should be a new best
    final result = await isNewPersonalBest(
      db,
      mode: 'learn',
      level: 'N5',
      score: 5,
      total: 10,
    );
    expect(result, isTrue);
  });
}
