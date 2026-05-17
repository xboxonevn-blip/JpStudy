import 'dart:convert';

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

  test('seeds upper-level vocab tracks for the active study level', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N3'});
    final db = ContentDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    final levelCol = db.vocab.level;
    final seriesCol = db.vocab.series;
    final countExpr = db.vocab.id.count();
    final rows =
        await (db.selectOnly(db.vocab)
              ..addColumns([levelCol, seriesCol, countExpr])
              ..where(db.vocab.level.equals('N3'))
              ..groupBy([levelCol, seriesCol]))
            .get();
    final counts = {
      for (final row in rows) row.read(seriesCol): row.read(countExpr) ?? 0,
    };

    expect(counts['hajimete'], greaterThan(0));
    expect(counts['ShinKanzen'], greaterThan(0));
  });

  test('seeds kanji Han-Viet labels into decomposition metadata', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
    final db = ContentDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    final row =
        await (db.select(db.kanji)
              ..where(
                (tbl) => tbl.character.equals('人') & tbl.jlptLevel.equals('N5'),
              )
              ..limit(1))
            .getSingle();
    final decomposition =
        jsonDecode(row.decompositionJson!) as Map<String, dynamic>;

    expect(decomposition['hanViet'], 'Nhân');
  });
}
