import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';

void main() {
  late AppDatabase db;
  late SrsDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = SrsDao(db);
  });

  tearDown(() => db.close());

  Future<void> insertState(int vocabId, double stability) async {
    await dao.initializeSrsState(vocabId);
    await dao.updateSrsState(
      vocabId: vocabId,
      box: 1,
      repetitions: 1,
      ease: 2.5,
      stability: stability,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: DateTime.now().add(const Duration(days: 1)),
    );
  }

  test('getStageBreakdown returns zeros when no SRS state', () async {
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 0);
    expect(breakdown.young, 0);
    expect(breakdown.mature, 0);
    expect(breakdown.total, 0);
  });

  test('getStageBreakdown classifies stability < 1 as learning', () async {
    await insertState(1, 0.5);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 1);
    expect(breakdown.young, 0);
    expect(breakdown.mature, 0);
  });

  test('getStageBreakdown classifies 1.0 <= stability < 21 as young', () async {
    await insertState(1, 1.0);
    await insertState(2, 10.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.young, 2);
  });

  test('getStageBreakdown classifies stability >= 21 as mature', () async {
    await insertState(1, 21.0);
    await insertState(2, 100.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.mature, 2);
  });

  test('getStageBreakdown mixes all three stages correctly', () async {
    await insertState(1, 0.3); // learning
    await insertState(2, 5.0); // young
    await insertState(3, 30.0); // mature
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 1);
    expect(breakdown.young, 1);
    expect(breakdown.mature, 1);
    expect(breakdown.total, 3);
  });
}
