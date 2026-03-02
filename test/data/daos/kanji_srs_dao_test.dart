import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/kanji_srs_dao.dart';

void main() {
  late AppDatabase db;
  late KanjiSrsDao dao;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    dao = KanjiSrsDao(db);
  });

  tearDown(() => db.close());

  test('getNextScheduledReview returns null when no state exists', () async {
    final result = await dao.getNextScheduledReview();
    expect(result, isNull);
  });

  test('getNextScheduledReview returns nearest future date', () async {
    final future1 = DateTime.now().add(const Duration(hours: 2));
    final future2 = DateTime.now().add(const Duration(hours: 5));
    await dao.initializeSrsState(1);
    await dao.updateSrsState(
      kanjiId: 1,
      stability: 1.0,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: future2,
    );
    await dao.initializeSrsState(2);
    await dao.updateSrsState(
      kanjiId: 2,
      stability: 1.0,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: future1,
    );
    final result = await dao.getNextScheduledReview();
    expect(result, isNotNull);
    expect(result!.isBefore(future2), isTrue);
  });

  test('getNextScheduledReview ignores past dates', () async {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    await dao.initializeSrsState(1);
    await dao.updateSrsState(
      kanjiId: 1,
      stability: 1.0,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: past,
    );
    final result = await dao.getNextScheduledReview();
    expect(result, isNull);
  });
}
