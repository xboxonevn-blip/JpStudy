import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

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

  test('self-heals v34 content DBs missing kanji meaning_ja column', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N3'});
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_content_db_v34_missing_meaning_ja_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final file = File('${tempDir.path}/content.db');
    await _createV34DbMissingKanjiMeaningJa(file);

    final db = ContentDatabase(executor: NativeDatabase(file));
    addTearDown(db.close);

    final columns = await db.customSelect("PRAGMA table_info('kanji')").get();
    final columnNames = columns.map((row) => row.data['name']).toSet();
    expect(columnNames, contains('meaning_ja'));

    final rows =
        await (db.select(db.kanji)
              ..where((tbl) => tbl.jlptLevel.equals('N3'))
              ..limit(1))
            .get();
    expect(rows, isNotEmpty);
  });

  test('upgrades pre-v33 kanji DBs before reseeding current rows', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N3'});
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_content_db_v32_missing_meaning_ja_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final file = File('${tempDir.path}/content.db');
    await _createLegacyKanjiDb(file, userVersion: 32);

    final db = ContentDatabase(executor: NativeDatabase(file));
    addTearDown(db.close);

    final rows =
        await (db.select(db.kanji)
              ..where((tbl) => tbl.jlptLevel.equals('N3'))
              ..limit(1))
            .get();
    expect(rows, isNotEmpty);

    final columns = await db.customSelect("PRAGMA table_info('kanji')").get();
    final columnNames = columns.map((row) => row.data['name']).toSet();
    expect(columnNames, contains('meaning_ja'));
  });

  test('v35 upgrade reseeds edited kanji metadata for existing DBs', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_content_db_v34_stale_kanji_metadata_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final file = File('${tempDir.path}/content.db');
    await _createLegacyKanjiDb(
      file,
      userVersion: 34,
      kanjiLessonId: 2,
      kanjiCharacter: '二',
      kanjiLevel: 'N5',
      kanjiMeaning: 'Hai',
      kanjiMeaningEn: 'Two',
      kanjiOnyomi: 'NI',
      kanjiKunyomi: 'futa',
      kanjiDecompositionJson: '{"hanViet":"Hai"}',
    );

    final db = ContentDatabase(executor: NativeDatabase(file));
    addTearDown(db.close);

    final row =
        await (db.select(db.kanji)
              ..where(
                (tbl) => tbl.character.equals('二') & tbl.jlptLevel.equals('N5'),
              )
              ..limit(1))
            .getSingle();

    expect(row.meaning, 'Nhị (hai)');
    expect(row.decompositionJson, contains('"hanViet":"Nhị"'));
  });

  test('kanji seed revision reseeds current-version stale metadata', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'onboarding.level': 'N3'});
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_content_db_current_stale_kanji_metadata_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final file = File('${tempDir.path}/content.db');
    await _createLegacyKanjiDb(
      file,
      userVersion: 35,
      kanjiLessonId: 2,
      kanjiCharacter: '将',
      kanjiLevel: 'N3',
      kanjiMeaning: 'tướng, tương lai',
      kanjiMeaningEn: 'leader, commander',
      kanjiOnyomi: 'ショウ, ソウ',
      kanjiKunyomi: 'まさ.に',
      kanjiDecompositionJson: '{}',
    );

    final db = ContentDatabase(executor: NativeDatabase(file));
    addTearDown(db.close);

    final row =
        await (db.select(db.kanji)
              ..where(
                (tbl) => tbl.character.equals('将') & tbl.jlptLevel.equals('N3'),
              )
              ..limit(1))
            .getSingle();
    final prefs = await SharedPreferences.getInstance();

    expect(row.meaning, 'Tướng (tướng; tương lai)');
    expect(row.decompositionJson, contains('"hanViet":"Tướng"'));
    expect(prefs.getInt('content.kanji.seedRevision'), 2);
  });
}

Future<void> _createV34DbMissingKanjiMeaningJa(File file) {
  return _createLegacyKanjiDb(file, userVersion: 34);
}

Future<void> _createLegacyKanjiDb(
  File file, {
  required int userVersion,
  int kanjiLessonId = 1,
  String kanjiCharacter = '作',
  String kanjiLevel = 'N3',
  String kanjiMeaning = 'Tác (làm)',
  String kanjiMeaningEn = 'make, create',
  String kanjiOnyomi = 'サク',
  String kanjiKunyomi = 'つく.る',
  String kanjiDecompositionJson = '{"hanViet":"Tác"}',
}) async {
  final sqlite = sqlite3.open(file.path);
  try {
    sqlite.execute('PRAGMA user_version = $userVersion');
    sqlite.execute('''
CREATE TABLE vocab (
  id INTEGER NOT NULL PRIMARY KEY,
  term TEXT NOT NULL,
  reading TEXT NULL,
  meaning TEXT NOT NULL,
  meaning_en TEXT NULL,
  kanji_meaning TEXT NULL,
  source_vocab_id TEXT NULL,
  source_sense_id TEXT NULL,
  series TEXT NOT NULL DEFAULT 'minna',
  level TEXT NOT NULL,
  tags TEXT NULL
);
''');
    sqlite.execute('''
CREATE TABLE grammar_point (
  id INTEGER NOT NULL PRIMARY KEY,
  lesson_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  title_en TEXT NULL,
  structure TEXT NOT NULL,
  structure_en TEXT NULL,
  explanation TEXT NOT NULL,
  explanation_en TEXT NULL,
  level TEXT NOT NULL,
  tags TEXT NULL
);
''');
    sqlite.execute('''
CREATE TABLE grammar_example (
  id INTEGER NOT NULL PRIMARY KEY,
  grammar_point_id INTEGER NOT NULL,
  sentence TEXT NOT NULL,
  translation TEXT NOT NULL,
  translation_en TEXT NULL
);
''');
    sqlite.execute('''
CREATE TABLE user_progress (
  vocab_id INTEGER NOT NULL PRIMARY KEY,
  correct_count INTEGER NOT NULL DEFAULT 0,
  missed_count INTEGER NOT NULL DEFAULT 0,
  last_reviewed_at INTEGER NULL
);
''');
    sqlite.execute('''
CREATE TABLE kanji (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  lesson_id INTEGER NOT NULL,
  character TEXT NOT NULL,
  stroke_count INTEGER NOT NULL,
  onyomi TEXT NULL,
  kunyomi TEXT NULL,
  meaning TEXT NOT NULL,
  meaning_en TEXT NULL,
  mnemonic_vi TEXT NULL,
  mnemonic_en TEXT NULL,
  decomposition_json TEXT NULL,
  examples_json TEXT NOT NULL,
  jlpt_level TEXT NOT NULL
);
''');
    sqlite.execute('''
INSERT INTO kanji (
  lesson_id, character, stroke_count, onyomi, kunyomi, meaning, meaning_en,
  mnemonic_vi, mnemonic_en, decomposition_json, examples_json, jlpt_level
) VALUES (
  $kanjiLessonId, '$kanjiCharacter', 7, '$kanjiOnyomi', '$kanjiKunyomi',
  '$kanjiMeaning', '$kanjiMeaningEn', 'Ghi nhớ', 'Remember',
  '$kanjiDecompositionJson', '[]', '$kanjiLevel'
);
''');
  } finally {
    sqlite.close();
  }
}
