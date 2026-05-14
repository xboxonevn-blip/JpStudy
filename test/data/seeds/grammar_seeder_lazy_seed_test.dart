import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'package:jpstudy/data/seeds/grammar_seeder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'startup grammar seed loads only the active level and other levels seed on demand',
    () async {
      SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      await GrammarSeeder(db.grammarDao).seedGrammarData(db);

      Future<Map<String, int>> countsByLevel() async {
        final levelCol = db.grammarPoints.jlptLevel;
        final countExpr = db.grammarPoints.id.count();
        final rows =
            await (db.selectOnly(db.grammarPoints)
                  ..addColumns([levelCol, countExpr])
                  ..groupBy([levelCol]))
                .get();
        final counts = <String, int>{};
        for (final row in rows) {
          final level = row.read(levelCol);
          if (level != null) {
            counts[level] = row.read(countExpr) ?? 0;
          }
        }
        return counts;
      }

      final startupCounts = await countsByLevel();
      expect(startupCounts.keys, unorderedEquals(['N5']));
      expect(startupCounts['N5'], greaterThan(0));

      final n4Points = await GrammarRepository(db).fetchPointsByLevel('N4');
      expect(n4Points, isNotEmpty);

      final onDemandCounts = await countsByLevel();
      expect(onDemandCounts.keys, unorderedEquals(['N5', 'N4']));
      expect(onDemandCounts['N4'], greaterThan(0));
    },
  );
}
