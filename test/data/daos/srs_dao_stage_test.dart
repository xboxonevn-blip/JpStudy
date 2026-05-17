import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
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

  Future<void> insertState(
    int vocabId, {
    required double stability,
    FsrsCardState fsrsState = FsrsCardState.review,
    int? fsrsStep,
  }) async {
    await dao.initializeSrsState(vocabId);
    await dao.updateSrsState(
      vocabId: vocabId,
      repetitions: 1,
      stability: stability,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: DateTime.now().add(const Duration(days: 1)),
      fsrsState: fsrsState,
      fsrsStep: fsrsStep,
    );
  }

  test('getStageBreakdown returns zeros when no SRS state', () async {
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 0);
    expect(breakdown.young, 0);
    expect(breakdown.mature, 0);
    expect(breakdown.total, 0);
  });

  test(
    'getStageBreakdown classifies FSRS learning state as learning',
    () async {
      await insertState(
        1,
        stability: 2.3065,
        fsrsState: FsrsCardState.learning,
        fsrsStep: 1,
      );
      final breakdown = await dao.getStageBreakdown();
      expect(breakdown.learning, 1);
      expect(breakdown.young, 0);
      expect(breakdown.mature, 0);
    },
  );

  test('getStageBreakdown classifies 1.0 <= stability < 21 as young', () async {
    await insertState(1, stability: 1.0);
    await insertState(2, stability: 10.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.young, 2);
  });

  test(
    'getStageBreakdown treats graduated low-stability cards as young',
    () async {
      await insertState(1, stability: 0.5, fsrsState: FsrsCardState.review);
      final breakdown = await dao.getStageBreakdown();
      expect(breakdown.learning, 0);
      expect(breakdown.young, 1);
    },
  );

  test('getStageBreakdown classifies stability >= 21 as mature', () async {
    await insertState(1, stability: 21.0);
    await insertState(2, stability: 100.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.mature, 2);
  });

  test('getStageBreakdown mixes all three stages correctly', () async {
    await insertState(
      1,
      stability: 2.3065,
      fsrsState: FsrsCardState.learning,
      fsrsStep: 1,
    );
    await insertState(2, stability: 5.0);
    await insertState(3, stability: 30.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 1);
    expect(breakdown.young, 1);
    expect(breakdown.mature, 1);
    expect(breakdown.total, 3);
  });
}
