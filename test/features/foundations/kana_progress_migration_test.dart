import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/foundations/services/kana_progress_migration.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migration seeds studied kana once', () async {
    SharedPreferences.setMockInitialValues({
      'foundations.kana.studied': ['あ', 'い', 'う', 'え', 'お'],
    });
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final migration = KanaProgressMigration(
      dao: db.kanaSrsDao,
      preferences: prefs,
    );

    await migration.runIfNeeded();
    expect(await db.kanaSrsDao.studiedCount(), 5);
    expect(prefs.getBool(foundationsKanaMigratedPrefsKey), isTrue);

    await migration.runIfNeeded();
    expect(await db.kanaSrsDao.studiedCount(), 5);
  });
}
