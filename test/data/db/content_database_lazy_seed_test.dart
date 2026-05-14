import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('seeds grammar only for the active study level on first open', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
    final db = ContentDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    final levelCol = db.grammarPoint.level;
    final countExpr = db.grammarPoint.id.count();
    final rows =
        await (db.selectOnly(db.grammarPoint)
              ..addColumns([levelCol, countExpr])
              ..groupBy([levelCol]))
            .get();
    final levels = {
      for (final row in rows) row.read(levelCol): row.read(countExpr) ?? 0,
    };

    expect(levels.keys, unorderedEquals(['N5']));
    expect(levels['N5'], greaterThan(0));
  });
}
