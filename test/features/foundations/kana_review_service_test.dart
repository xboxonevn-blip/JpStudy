import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/foundations/services/kana_review_service.dart';

void main() {
  test('grade creates rows, records lapses, and accumulates reps', () async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final service = KanaReviewService(dao: db.kanaSrsDao);

    await service.grade('あ', 'hiragana', 3);
    var row = await db.kanaSrsDao.getOrEmpty('あ');
    expect(row, isNotNull);
    expect(row!.stability, greaterThan(0));
    expect(row.reps, 1);

    await service.grade('あ', 'hiragana', 1);
    row = await db.kanaSrsDao.getOrEmpty('あ');
    expect(row!.lapses, 1);
    expect(row.reps, 2);

    for (final kana in ['い', 'う', 'え', 'お']) {
      await service.grade(kana, 'hiragana', 3);
    }
    expect(await db.kanaSrsDao.studiedCount(), 5);
  });
}
