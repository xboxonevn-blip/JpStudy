import 'dart:convert';
import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content_tables.dart';
import '../utils/grammar_example_matching.dart';
import '../utils/grammar_english_notation.dart';
import '../utils/han_viet_lookup.dart';

part 'content_database.g.dart';

const _kanjiSeedRevision = 16;
const _kanjiSeedRevisionKey = 'kanjiSeedRevision';

@DriftDatabase(
  tables: [
    Vocab,
    GrammarPoint,
    GrammarExample,
    Question,
    MockTest,
    MockTestSection,
    MockTestQuestionMap,
    UserProgress,
    Kanji,
  ],
)
class ContentDatabase extends _$ContentDatabase {
  ContentDatabase({QueryExecutor? executor})
    : super(executor ?? _openContentConnection());

  @override
  int get schemaVersion => 35;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedMinnaVocabularyForActiveLevel();
        await _seedHajimeteVocabularyForActiveLevel();
        await _seedMinnaGrammarForActiveLevel();
        await _seedMinnaKanji();
        await _createContentIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(userProgress);
        }
        if (from < 3) {
          await _addColumn(m, vocab, vocab.kanjiMeaning);
        }
        if (from < 6) {
          await _addColumn(m, vocab, vocab.meaningEn);
        }
        if (from < 7) {
          await m.createTable(grammarPoint);
          await m.createTable(grammarExample);
          await _seedMinnaGrammar();
        }
        if (from < 9) {
          await m.createTable(kanji);
          await _seedMinnaKanji();
        }
        if (from < 10) {
          await _reseedMinnaKanji();
        }
        if (from < 11) {
          await _seedMinnaGrammar();
          await _reseedMinnaVocabulary();
        }
        if (from < 14) {
          await _seedMinnaGrammar();
        }
        if (from >= 11 && from < 15) {
          await _reseedMinnaVocabulary();
        }
        if (from < 15) {
          await _seedMinnaGrammar();
        }
        // Force re-seed for grammar examples expansion (v16)
        if (from < 16) {
          await _seedMinnaGrammar();
        }
        if (from < 17) {
          await _addColumn(m, kanji, kanji.mnemonicVi);
          await _addColumn(m, kanji, kanji.mnemonicEn);
          await _reseedMinnaKanji();
        }
        if (from < 18) {
          // Backfill users who seeded during path-transition versions.
          await _reseedMinnaVocabulary();
        }
        if (from < 19) {
          await _addColumn(m, vocab, vocab.sourceVocabId);
          await _addColumn(m, vocab, vocab.sourceSenseId);
          // Populate new source IDs for existing installs.
          await _reseedMinnaVocabulary();
        }
        if (from < 20) {
          await _addColumn(m, kanji, kanji.decompositionJson);
          await _backfillKanjiDecompositionFromCanonical();
        }
        if (from < 21) {
          await _seedMinnaGrammar();
        }
        if (from < 22) {
          await _seedMinnaGrammar();
        }
        if (from < 23) {
          await _seedMinnaGrammar();
        }
        if (from < 24) {
          await _seedMinnaGrammar();
        }
        if (from < 25) {
          await _seedMinnaGrammar();
        }
        if (from < 26) {
          await _addColumn(m, vocab, vocab.series);
          await customStatement(
            "UPDATE vocab SET series = 'minna' WHERE series IS NULL OR series = ''",
          );
          await _reseedHajimeteVocab();
        }
        if (from < 27) {
          await _reseedMinnaVocabulary();
        }
        if (from < 28) {
          await _createContentIndexes();
        }
        if (from < 29) {
          await _reseedMinnaVocabulary();
        }
        if (from < 30) {
          await _seedMinnaGrammar();
        }
        if (from < 31) {
          // kanji reseed consolidated into v32
        }
        if (from < 35) {
          await _selfHealKanjiMeaningJaColumn();
        }
        if (from < 32) {
          await _reseedMinnaKanji();
        }
        if (from < 33) {
          await _reseedMinnaKanji();
        }
        if (from < 34) {
          await _reseedMinnaKanji();
        }
        if (from < 35) {
          await _reseedMinnaKanji();
        }
      },
      beforeOpen: (details) async {
        await _selfHealKanjiMeaningJaColumn();
        await _ensureKanjiSeedRevision(details);
        // All four checks are independent — run them concurrently so the
        // content DB is ready in the time of the single slowest check.
        await Future.wait([
          _ensureMinnaVocabularySeededForActiveLevel(),
          _ensureHajimeteVocabularySeededForActiveLevel(),
          _ensureMinnaGrammarSeededForActiveLevel(),
          _ensureMinnaKanjiSeeded(),
        ]);
      },
    );
  }

  Future<void> _selfHealKanjiMeaningJaColumn() async {
    final columns = await customSelect("PRAGMA table_info('kanji')").get();
    if (columns.isEmpty) {
      return;
    }
    final columnNames = columns
        .map((row) => row.data['name'])
        .whereType<String>()
        .toSet();
    if (columnNames.contains('meaning_ja')) {
      return;
    }
    await customStatement('ALTER TABLE kanji ADD COLUMN meaning_ja TEXT NULL');
  }

  Future<void> _ensureKanjiSeedRevision(OpeningDetails details) async {
    await customStatement(
      'CREATE TABLE IF NOT EXISTS content_meta ('
      'key TEXT NOT NULL PRIMARY KEY, '
      'value TEXT NOT NULL'
      ')',
    );
    final revisionRows = await customSelect(
      "SELECT value FROM content_meta WHERE key = '$_kanjiSeedRevisionKey' "
      'LIMIT 1',
    ).get();
    final storedRevision = revisionRows.isEmpty
        ? null
        : int.tryParse('${revisionRows.single.data['value']}');
    if (storedRevision != null && storedRevision >= _kanjiSeedRevision) {
      return;
    }

    if (!details.wasCreated) {
      await _reseedMinnaKanji();
    }
    await customStatement(
      "INSERT OR REPLACE INTO content_meta (key, value) VALUES "
      "('$_kanjiSeedRevisionKey', '$_kanjiSeedRevision')",
    );
  }

  // ... (reseed methods)

  Future<void> _reseedMinnaVocabulary() async {
    await (delete(vocab)..where(
          (tbl) => tbl.series.equals('minna') | tbl.series.equals('ShinKanzen'),
        ))
        .go();

    await _seedMinnaVocabulary();
  }

  Future<void> _ensureMinnaVocabularySeeded([
    Iterable<_ContentSeedSpec> specs = _contentSeedSpecs,
  ]) async {
    // One GROUP BY query replaces N sequential COUNT queries (one per level).
    final levelCol = vocab.level;
    final seriesCol = vocab.series;
    final countExpr = vocab.id.count();
    final rows =
        await (selectOnly(vocab)
              ..addColumns([levelCol, seriesCol, countExpr])
              ..where(
                specs
                    .map((s) {
                      return vocab.level.equals(s.levelLabel) &
                          vocab.series.equals(s.series);
                    })
                    .reduce((a, b) => a | b),
              )
              ..groupBy([levelCol, seriesCol]))
            .get();
    final counts = {
      for (final row in rows)
        '${row.read(levelCol)}:${row.read(seriesCol)}':
            row.read(countExpr) ?? 0,
    };
    final missingSpecs = specs
        .where((s) => (counts['${s.levelLabel}:${s.series}'] ?? 0) == 0)
        .toList();
    if (missingSpecs.isNotEmpty) {
      await Future.wait(missingSpecs.map(_seedVocabularyLevel));
    }

    // Self-heal old seeded DBs that still contain placeholder/garbled rows.
    final corruptedCountExpr = vocab.id.count();
    final corruptedQuery = selectOnly(vocab)
      ..addColumns([corruptedCountExpr])
      ..where(vocab.tags.like('%minna_%') | vocab.tags.like('%shinkanzen_%'))
      ..where(
        vocab.term.like('%?%') |
            vocab.reading.like('%?%') |
            vocab.term.like('%ã%') |
            vocab.reading.like('%ã%') |
            vocab.term.like('%Ã%') |
            vocab.reading.like('%Ã%'),
      );
    final corruptedRow = await corruptedQuery.getSingle();
    final corruptedCount = corruptedRow.read(corruptedCountExpr) ?? 0;
    if (corruptedCount > 0) {
      await _reseedMinnaVocabulary();
      return;
    }

    // Self-heal DBs seeded before N2/N1 Vietnamese drafts were approved.
    final untranslatedCountExpr = vocab.id.count();
    final untranslatedQuery = selectOnly(vocab)
      ..addColumns([untranslatedCountExpr])
      ..where(
        vocab.series.equals('ShinKanzen') &
            vocab.level.isIn(const ['N2', 'N1']) &
            vocab.meaningEn.isNotNull() &
            vocab.meaning.equalsExp(vocab.meaningEn),
      );
    final untranslatedRow = await untranslatedQuery.getSingle();
    final untranslatedCount = untranslatedRow.read(untranslatedCountExpr) ?? 0;
    if (untranslatedCount > 0) {
      await _reseedMinnaVocabulary();
    }
  }

  Future<void> _ensureMinnaVocabularySeededForActiveLevel() async {
    final activeLevel = await _activeStudyLevelLabel();
    await _ensureMinnaVocabularySeeded(
      _contentSeedSpecs.where((s) => s.levelLabel == activeLevel),
    );
  }

  Future<void> _seedMinnaVocabulary() {
    // All level specs are independent — seed them concurrently so file I/O
    // for N5, N4, and N3 overlaps. DB writes still serialize through the isolate.
    return Future.wait(_contentSeedSpecs.map(_seedVocabularyLevel));
  }

  Future<void> _seedMinnaVocabularyForActiveLevel() async {
    final activeLevel = await _activeStudyLevelLabel();
    await Future.wait(
      _contentSeedSpecs
          .where((s) => s.levelLabel == activeLevel)
          .map(_seedVocabularyLevel),
    );
  }

  Future<void> _ensureHajimeteVocabularySeeded([
    Iterable<_HajimeteSeedSpec> specs = _hajimeteSeedSpecs,
  ]) async {
    // One GROUP BY query replaces N sequential COUNT queries (one per level).
    final levelCol = vocab.level;
    final countExpr = vocab.id.count();
    final rows =
        await (selectOnly(vocab)
              ..addColumns([levelCol, countExpr])
              ..where(
                vocab.series.equals('hajimete') &
                    vocab.level.isIn(specs.map((s) => s.levelLabel).toList()),
              )
              ..groupBy([levelCol]))
            .get();
    final counts = {
      for (final row in rows) row.read(levelCol)!: row.read(countExpr) ?? 0,
    };
    final missingSpecs = specs
        .where((s) => (counts[s.levelLabel] ?? 0) == 0)
        .toList();
    if (missingSpecs.isNotEmpty) {
      await Future.wait(missingSpecs.map(_seedHajimeteLevel));
    }
  }

  Future<void> _ensureHajimeteVocabularySeededForActiveLevel() async {
    final activeLevel = await _activeStudyLevelLabel();
    await _ensureHajimeteVocabularySeeded(
      _hajimeteSeedSpecs.where((s) => s.levelLabel == activeLevel),
    );
  }

  Future<void> _seedHajimeteVocabulary() {
    // All Hajimete level specs are independent — seed them concurrently.
    return Future.wait(_hajimeteSeedSpecs.map(_seedHajimeteLevel));
  }

  Future<void> _seedHajimeteVocabularyForActiveLevel() async {
    final activeLevel = await _activeStudyLevelLabel();
    await Future.wait(
      _hajimeteSeedSpecs
          .where((s) => s.levelLabel == activeLevel)
          .map(_seedHajimeteLevel),
    );
  }

  Future<void> _reseedHajimeteVocab() async {
    await (delete(vocab)..where((tbl) => tbl.series.equals('hajimete'))).go();
    await _seedHajimeteVocabulary();
  }

  Future<void> _seedHajimeteLevel(_HajimeteSeedSpec spec) async {
    final level = spec.levelLabel;

    // Step 1: Load all chapter JSON files concurrently.
    final chapterFutures = [
      for (int chapterId = 1; chapterId <= spec.chapterCount; chapterId++)
        _tryLoadHajimeteChapterEntries(spec.levelLower, chapterId),
    ];
    final chapterEntryLists = await Future.wait(chapterFutures);

    // Step 2: Resolve all HanViet lookups concurrently across all chapters.
    // HanVietLookup caches after first load; concurrent calls are safe.
    final resolutionFutures = <Future<VocabCompanion?>>[];
    for (final entries in chapterEntryLists) {
      if (entries == null) continue;
      for (final rawEntry in entries) {
        resolutionFutures.add(_resolveHajimeteEntry(rawEntry, level));
      }
    }
    final companions = await Future.wait(resolutionFutures);

    // Step 3: Batch insert all resolved entries in one round-trip.
    await batch((b) {
      for (final companion in companions) {
        if (companion != null) {
          b.insert(vocab, companion, mode: InsertMode.insertOrIgnore);
        }
      }
    });
  }

  Future<List<dynamic>?> _tryLoadHajimeteChapterEntries(
    String levelLower,
    int chapterId,
  ) async {
    final padded = chapterId.toString().padLeft(2, '0');
    final path = _hajimeteVocabAssetPath(levelLower, padded);
    try {
      final raw = await rootBundle.loadString(path);
      final payload = _asMap(json.decode(raw));
      final entries = payload?['entries'];
      return entries is List ? entries : null;
    } catch (_) {
      return null; // Missing chapter file: skip until that level is implemented.
    }
  }

  Future<VocabCompanion?> _resolveHajimeteEntry(
    dynamic rawEntry,
    String level,
  ) async {
    final entry = _asMap(rawEntry);
    final lemma = _asMap(entry?['lemma']);
    final sense = _asMap(entry?['sense']);
    if (entry == null || lemma == null || sense == null) return null;

    final term = _readText(lemma, 'term');
    final meaningVi = _readText(sense, 'meaningVi');
    if (term.isEmpty || meaningVi.isEmpty) return null;

    final labels = _asMap(lemma['labels']);
    final links = _asMap(entry['links']);
    final tags = _readTags(entry['tags']);

    final hvResolution = await HanVietLookup.resolve(
      term: term,
      explicitHanViet: _readText(
        labels ?? const <String, dynamic>{},
        'hanViet',
      ).nullIfEmpty(),
      explicitMeaningVi: meaningVi,
    );

    return VocabCompanion.insert(
      term: term,
      reading: Value(_readText(lemma, 'reading').nullIfEmpty()),
      meaning: hvResolution.meaningVi ?? meaningVi,
      meaningEn: Value(_readText(sense, 'meaningEn').nullIfEmpty()),
      kanjiMeaning: Value(hvResolution.hanViet),
      sourceVocabId: Value(
        _readText(
          links ?? const <String, dynamic>{},
          'sourceVocabId',
        ).nullIfEmpty(),
      ),
      sourceSenseId: Value(
        _readText(
          links ?? const <String, dynamic>{},
          'sourceSenseId',
        ).nullIfEmpty(),
      ),
      series: const Value('hajimete'),
      level: level,
      tags: Value(tags?.nullIfEmpty()),
    );
  }

  Future<void> _ensureMinnaKanjiSeeded() async {
    // One GROUP BY query replaces N sequential COUNT queries (one per level).
    final levelCol = kanji.jlptLevel;
    final countExpr = kanji.id.count();
    final rows =
        await (selectOnly(kanji)
              ..addColumns([levelCol, countExpr])
              ..where(
                kanji.jlptLevel.isIn(
                  _contentSeedSpecs.map((s) => s.levelLabel).toList(),
                ),
              )
              ..groupBy([levelCol]))
            .get();
    final counts = {
      for (final row in rows) row.read(levelCol)!: row.read(countExpr) ?? 0,
    };
    final missingKanjiSpecs = _contentSeedSpecs
        .where((s) => (counts[s.levelLabel] ?? 0) == 0)
        .toList();
    if (missingKanjiSpecs.isNotEmpty) {
      await Future.wait(missingKanjiSpecs.map(_seedKanjiLevel));
    }
  }

  Future<void> _ensureMinnaGrammarSeeded([
    Iterable<_ContentSeedSpec> specs = _contentSeedSpecs,
  ]) async {
    final specList = specs.toList(growable: false);
    if (specList.isEmpty) return;
    // One GROUP BY query replaces N sequential COUNT queries (one per level).
    final levelCol = grammarPoint.level;
    final countExpr = grammarPoint.id.count();
    final rows =
        await (selectOnly(grammarPoint)
              ..addColumns([levelCol, countExpr])
              ..where(
                grammarPoint.level.isIn(
                  specList.map((s) => s.levelLabel).toList(),
                ),
              )
              ..groupBy([levelCol]))
            .get();
    final counts = {
      for (final row in rows) row.read(levelCol)!: row.read(countExpr) ?? 0,
    };
    final missingSpecs = specList
        .where((spec) => (counts[spec.levelLabel] ?? 0) == 0)
        .toList(growable: false);
    if (missingSpecs.isNotEmpty) {
      await _seedMinnaGrammar(missingSpecs);
    }
  }

  Future<void> _ensureMinnaGrammarSeededForActiveLevel() async {
    final activeLevel = await _activeStudyLevelLabel();
    await ensureGrammarSeededForLevel(activeLevel);
  }

  Future<void> ensureGrammarSeededForLevel(String level) async {
    final spec = _contentSeedSpecForLevel(level);
    if (spec == null) return;
    await _ensureMinnaGrammarSeeded([spec]);
  }

  Future<void> _seedMinnaGrammar([
    Iterable<_ContentSeedSpec> specs = _contentSeedSpecs,
  ]) async {
    final specList = specs.toList(growable: false);
    if (specList.isEmpty) return;

    // Clear existing data for target levels only to prevent duplicates while
    // preserving levels that should stay lazy.
    final targetLevels = specList.map((s) => s.levelLabel).toList();
    final pointIdRows =
        await (selectOnly(grammarPoint)
              ..addColumns([grammarPoint.id])
              ..where(grammarPoint.level.isIn(targetLevels)))
            .get();
    final pointIds = pointIdRows
        .map((row) => row.read(grammarPoint.id))
        .whereType<int>()
        .toList();
    if (pointIds.isNotEmpty) {
      await (delete(
        grammarExample,
      )..where((tbl) => tbl.grammarPointId.isIn(pointIds))).go();
    }
    await (delete(
      grammarPoint,
    )..where((tbl) => tbl.level.isIn(targetLevels))).go();

    // Phase 1: Load every (def, examples) file pair concurrently — pure I/O.
    final filePairs = <({String defPath, String exPath})>[];
    for (final spec in specList) {
      for (
        var lessonId = spec.startLesson;
        lessonId <= spec.endLesson;
        lessonId++
      ) {
        filePairs.add((
          defPath:
              'assets/data/content/grammar/${spec.levelLower}/grammar_${spec.levelLower}_$lessonId.json',
          exPath:
              'assets/data/content/grammar_examples/${spec.levelLower}/lesson_$lessonId.json',
        ));
      }
    }

    final loadFutures = filePairs.map((pair) async {
      try {
        final defStr = await rootBundle.loadString(pair.defPath);
        final points = json.decode(defStr) as List<dynamic>;
        List<dynamic> extras = const [];
        try {
          final exStr = await rootBundle.loadString(pair.exPath);
          extras = json.decode(exStr) as List<dynamic>;
        } catch (_) {}
        return (points: points, extras: extras);
      } catch (_) {
        return null;
      }
    }).toList();
    final allFileData = await Future.wait(loadFutures);

    // Phase 2: Insert grammar points sequentially (need generated IDs for examples).
    // Accumulate all example companions for a single batch insert at the end.
    final exampleCompanions = <GrammarExampleCompanion>[];
    for (final fileData in allFileData) {
      if (fileData == null || fileData.points.isEmpty) continue;
      for (final pointData in fileData.points) {
        late final int pointId;
        try {
          pointId = await into(grammarPoint).insert(
            GrammarPointCompanion.insert(
              lessonId: pointData['lessonId'] as int,
              title: pointData['title'] as String,
              titleEn: Value(
                normalizeGrammarTitleEn(pointData['titleEn'] as String?),
              ),
              structure: pointData['structure'] as String,
              structureEn: Value(
                normalizeGrammarStructureEn(
                  pointData['structureEn'] as String?,
                ),
              ),
              explanation: pointData['explanation'] as String,
              explanationEn: Value(pointData['explanationEn'] as String?),
              level: pointData['level'] as String,
              tags: Value(_readTags(pointData['tags'])),
            ),
            mode: InsertMode.insertOrReplace,
          );
        } catch (_) {
          continue;
        }

        final List<dynamic> examples = [...(pointData['examples'] ?? const [])];
        final extraExamples = findGrammarExamplesForDefinition(
          exampleBlocks: fileData.extras,
          title: pointData['title'] as String?,
          grammarPoint: pointData['grammarPoint'] as String?,
        );
        if (extraExamples != null) {
          examples.addAll(extraExamples);
        }

        for (final ex in examples) {
          exampleCompanions.add(
            GrammarExampleCompanion.insert(
              grammarPointId: pointId,
              sentence: ex['sentence'] as String,
              translation: ex['translation'] as String,
              translationEn: Value(ex['translationEn'] as String?),
            ),
          );
        }
      }
    }

    // Phase 3: Single batch for all example rows.
    if (exampleCompanions.isNotEmpty) {
      await batch((b) {
        for (final companion in exampleCompanions) {
          b.insert(grammarExample, companion, mode: InsertMode.insertOrReplace);
        }
      });
    }
  }

  Future<void> _seedMinnaGrammarForActiveLevel() async {
    final activeLevel = await _activeStudyLevelLabel();
    final spec = _contentSeedSpecForLevel(activeLevel);
    await _seedMinnaGrammar(spec == null ? const [] : [spec]);
  }

  Future<void> _seedVocabularyLevel(_ContentSeedSpec spec) async {
    final level = spec.levelLabel;
    final startLesson = spec.startLesson;
    final endLesson = spec.endLesson;

    // Load all lesson JSON files concurrently — each file is independent.
    final perLessonFutures = [
      for (int lessonId = startLesson; lessonId <= endLesson; lessonId++)
        _loadCanonicalVocabRows(level: level, lessonId: lessonId),
    ];
    final perLessonRows = await Future.wait(perLessonFutures);

    final allRows = <Map<String, dynamic>>[];
    for (int idx = 0; idx < perLessonRows.length; idx++) {
      final rows = perLessonRows[idx];
      if (rows.isEmpty) continue;
      allRows.addAll(
        _mergeLessonRows(
          preferred: rows,
          fallback: const [],
          level: level,
          lessonId: startLesson + idx,
        ),
      );
    }

    final collapsedRows = _collapseExactDuplicateRows(allRows);
    // Batch all inserts in a single round-trip to the DB isolate.
    await batch((b) {
      for (final item in collapsedRows) {
        b.insert(
          vocab,
          VocabCompanion.insert(
            term: item['term'] as String,
            reading: Value(item['reading'] as String?),
            kanjiMeaning: Value(item['kanjiMeaning'] as String?),
            sourceVocabId: Value(item['sourceVocabId'] as String?),
            sourceSenseId: Value(item['sourceSenseId'] as String?),
            meaning: item['meaning_vi'] as String,
            meaningEn: Value(item['meaning_en'] as String?),
            series: Value((item['series'] as String?) ?? 'minna'),
            level: item['level'] as String,
            tags: Value(item['tags'] as String?),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  String _minnaVocabAssetPath(String levelLower, String paddedLessonId) {
    final nestedPath =
        'assets/data/content/vocab/$levelLower/minna/lesson_$paddedLessonId.json';
    if (levelLower == 'n4' || levelLower == 'n5') {
      return nestedPath;
    }
    return 'assets/data/content/vocab/$levelLower/lesson_$paddedLessonId.json';
  }

  Future<String> _resolveCanonicalVocabAssetPath({
    required String levelLower,
    required int lessonId,
  }) async {
    final paddedLessonId = lessonId.toString().padLeft(2, '0');
    final shinkanzenIndexPath =
        'assets/data/content/vocab/$levelLower/ShinKanzen/index.json';

    try {
      final indexRaw = await rootBundle.loadString(shinkanzenIndexPath);
      final indexPayload = _asMap(json.decode(indexRaw));
      final lessons = indexPayload?['lessons'];
      if (lessons is List) {
        for (final rawLesson in lessons) {
          final lesson = _asMap(rawLesson);
          if (lesson == null) continue;
          final indexedLessonId = _readInt(lesson, 'lessonId') ?? -1;
          final fileName = _readText(lesson, 'file');
          if (indexedLessonId == lessonId && fileName.isNotEmpty) {
            return 'assets/data/content/vocab/$levelLower/ShinKanzen/$fileName';
          }
        }
      }
    } catch (_) {}

    return _minnaVocabAssetPath(levelLower, paddedLessonId);
  }

  String _hajimeteVocabAssetPath(String levelLower, String paddedChapterId) {
    return 'assets/data/content/vocab/$levelLower/hajimete/hajimete_ch$paddedChapterId.json';
  }

  Future<List<Map<String, dynamic>>> _loadCanonicalVocabRows({
    required String level,
    required int lessonId,
  }) async {
    final levelLower = level.toLowerCase();
    final path = await _resolveCanonicalVocabAssetPath(
      levelLower: levelLower,
      lessonId: lessonId,
    );

    try {
      final raw = await rootBundle.loadString(path);
      final payload = _asMap(json.decode(raw));
      final entries = payload?['entries'];
      if (entries is! List) {
        return const [];
      }

      final rows = <Map<String, dynamic>>[];
      for (final rawEntry in entries) {
        final entry = _asMap(rawEntry);
        if (entry == null) continue;
        final lemma = _asMap(entry['lemma']);
        final sense = _asMap(entry['sense']);
        final links = _asMap(entry['links']);
        if (lemma == null || sense == null) continue;

        final term = _readText(lemma, 'term');
        final meaningVi = _readText(sense, 'meaningVi');
        if (term.isEmpty || meaningVi.isEmpty) continue;

        final labels = _asMap(lemma['labels']);
        final payloadSeries =
            _readText(payload ?? const {}, 'series').nullIfEmpty() ??
            _seriesForCanonicalLevel(level);
        final tags = _joinTags([
          _readTags(payload?['tags']),
          _readTags(entry['tags']),
        ]);
        final tagPrefix = _lessonSeriesTag(payloadSeries, lessonId);
        final mergedTags = tags.isEmpty ? tagPrefix : '$tagPrefix,$tags';

        rows.add({
          'term': term,
          'reading': _readNullableText(lemma, 'reading'),
          'kanjiMeaning': labels == null
              ? _readNullableText(entry, 'kanjiMeaning')
              : _readNullableText(labels, 'hanViet'),
          'sourceVocabId': links == null
              ? _readNullableText(entry, 'sourceVocabId')
              : _readNullableText(links, 'sourceVocabId'),
          'sourceSenseId': links == null
              ? _readNullableText(entry, 'sourceSenseId')
              : _readNullableText(links, 'sourceSenseId'),
          'meaning_vi': meaningVi,
          'meaning_en': _readNullableText(sense, 'meaningEn'),
          'level': level,
          'series': payloadSeries,
          'tags': mergedTags,
        });
      }

      return rows;
    } catch (_) {
      return const [];
    }
  }

  List<Map<String, dynamic>> _mergeLessonRows({
    required List<Map<String, dynamic>> preferred,
    required List<Map<String, dynamic>> fallback,
    required String level,
    required int lessonId,
  }) {
    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};

    void addRow(Map<String, dynamic> raw) {
      final term = _readText(raw, 'term');
      final meaningVi = _firstNonEmpty([
        _readText(raw, 'meaning_vi'),
        _readText(raw, 'meaning'),
      ]);
      if (term.isEmpty || meaningVi.isEmpty) return;

      final reading = _readNullableText(raw, 'reading');
      if (_containsPlaceholder(term) || _containsPlaceholder(reading)) {
        return;
      }
      final kanjiMeaning = _readNullableText(raw, 'kanjiMeaning');
      final sourceVocabId = _readNullableText(raw, 'sourceVocabId');
      final sourceSenseId = _readNullableText(raw, 'sourceSenseId');
      final meaningEn = _readNullableText(raw, 'meaning_en');
      final rowLevel = _firstNonEmpty([_readText(raw, 'level'), level]);
      final series = _firstNonEmpty([
        _readText(raw, 'series'),
        _seriesForCanonicalLevel(level),
      ]);
      final tags = _firstNonEmpty([
        _readText(raw, 'tags'),
        _lessonSeriesTag(series, lessonId),
      ]);

      final normalized = <String, dynamic>{
        'term': term,
        'reading': reading,
        'kanjiMeaning': kanjiMeaning,
        'sourceVocabId': sourceVocabId,
        'sourceSenseId': sourceSenseId,
        'meaning_vi': meaningVi,
        'meaning_en': meaningEn,
        'level': rowLevel,
        'series': series,
        'tags': tags,
      };

      final key = _exactSignature(normalized);
      if (seen.add(key)) {
        merged.add(normalized);
      }
    }

    for (final item in preferred) {
      addRow(item);
    }
    for (final item in fallback) {
      addRow(item);
    }

    return merged;
  }

  List<Map<String, dynamic>> _collapseExactDuplicateRows(
    List<Map<String, dynamic>> rows,
  ) {
    final aggregateBySignature = <String, _SeedVocabAggregate>{};
    for (final row in rows) {
      final signature = _exactSignature(row);
      final existing = aggregateBySignature[signature];
      if (existing == null) {
        aggregateBySignature[signature] = _SeedVocabAggregate.fromRow(row);
      } else {
        existing.mergeTags(_readNullableText(row, 'tags'));
      }
    }
    return aggregateBySignature.values.map((item) => item.toRow()).toList();
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  String _readText(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  String? _readNullableText(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return text;
  }

  String? _readTags(Object? raw) {
    if (raw == null) return null;
    if (raw is Iterable && raw is! String) {
      return _joinTags(raw.map((entry) => entry.toString()));
    }
    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _joinTags(Iterable<String?> rawTags) {
    final tags = <String>{};
    for (final raw in rawTags) {
      if (raw == null) continue;
      for (final tag in raw.split(',')) {
        final normalized = tag.trim();
        if (normalized.isNotEmpty) tags.add(normalized);
      }
    }
    return tags.join(',');
  }

  int? _readInt(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _firstNonEmpty(List<String?> candidates) {
    for (final candidate in candidates) {
      final normalized = candidate?.trim() ?? '';
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return '';
  }

  String _exactSignature(Map<String, dynamic> row) {
    final term = _readText(row, 'term');
    final reading = _readText(row, 'reading');
    final kanjiMeaning = _readText(row, 'kanjiMeaning');
    final sourceVocabId = _readText(row, 'sourceVocabId');
    final sourceSenseId = _readText(row, 'sourceSenseId');
    final meaningVi = _firstNonEmpty([
      _readText(row, 'meaning_vi'),
      _readText(row, 'meaning'),
    ]);
    final meaningEn = _readText(row, 'meaning_en');
    final level = _readText(row, 'level');
    final series = _readText(row, 'series');
    return '$term|$reading|$kanjiMeaning|$sourceVocabId|$sourceSenseId|$meaningVi|$meaningEn|$level|$series';
  }

  String _seriesForCanonicalLevel(String level) {
    final normalized = level.trim().toUpperCase();
    return normalized == 'N3' || normalized == 'N2' || normalized == 'N1'
        ? 'ShinKanzen'
        : 'minna';
  }

  static final _seriesNormalizeRe = RegExp(r'[^a-z0-9]+');

  String _lessonSeriesTag(String series, int lessonId) {
    final normalized = series.toLowerCase().replaceAll(_seriesNormalizeRe, '');
    final prefix = normalized.isEmpty ? 'lesson' : normalized;
    return '${prefix}_$lessonId';
  }

  bool _containsPlaceholder(String? value) {
    return (value ?? '').contains('?');
  }

  Future<void> _addColumn<T extends Object>(
    Migrator migrator,
    TableInfo table,
    Column<T> column,
  ) async {
    await migrator.addColumn(table, column as GeneratedColumn);
  }

  Future<void> _createContentIndexes() async {
    // Vocab — most frequently queried columns for every vocab screen load.
    // Composite (level, series) covers the common getVocabByLevelAndSeries
    // pattern; (level) alone covers getVocabByLevel fallback queries.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_level_series ON vocab(level, series)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_level ON vocab(level)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_vocab_series ON vocab(series)',
    );
    // Kanji — queried by JLPT level on every kanji hub / practice screen open.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_kanji_jlpt ON kanji(jlpt_level)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_kanji_lesson ON kanji(lesson_id)',
    );
    // Grammar (content DB copy) — queried by level in JLPT mock exam builder.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_point_level ON grammar_point(level)',
    );
  }

  Future<void> _reseedMinnaKanji() async {
    // Delete all existing Kanji data to prevent duplicates or stale data
    await delete(kanji).go();

    await _seedMinnaKanji();
  }

  Future<void> _seedMinnaKanji() {
    // All level specs are independent — seed them concurrently.
    return Future.wait(_contentSeedSpecs.map(_seedKanjiLevel));
  }

  Future<void> _backfillKanjiDecompositionFromCanonical() async {
    // Create all file-load futures before any await — pure IO, no deps between
    // lessons, so all reads start concurrently in the event loop.
    final rowFutures = <Future<List<Map<String, dynamic>>>>[];
    final lessonIds = <int>[];
    for (final spec in _contentSeedSpecs) {
      for (
        var lessonId = spec.startLesson;
        lessonId <= spec.endLesson;
        lessonId++
      ) {
        lessonIds.add(lessonId);
        rowFutures.add(
          _loadCanonicalKanjiRows(
            levelLower: spec.levelLower,
            lessonId: lessonId,
          ),
        );
      }
    }

    final allRowLists = await Future.wait(rowFutures);

    // Single batch for all decomposition updates across every level/lesson.
    await batch((b) {
      for (var i = 0; i < lessonIds.length; i++) {
        final lessonId = lessonIds[i];
        for (final row in allRowLists[i]) {
          final character = _readText(row, 'character');
          final decompositionJson = _readNullableText(
            row,
            'decomposition_json',
          );
          if (character.isEmpty || decompositionJson == null) continue;
          b.update(
            kanji,
            KanjiCompanion(decompositionJson: Value(decompositionJson)),
            where: (tbl) =>
                tbl.lessonId.equals(lessonId) & tbl.character.equals(character),
          );
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> _loadCanonicalKanjiRows({
    required String levelLower,
    required int lessonId,
  }) async {
    final paddedLessonId = lessonId.toString().padLeft(2, '0');
    final path =
        'assets/data/content/kanji/$levelLower/lesson_$paddedLessonId.json';

    try {
      final raw = await rootBundle.loadString(path);
      final payload = _asMap(json.decode(raw));
      final entries = payload?['entries'];
      if (entries is! List) {
        return const [];
      }

      final rows = <Map<String, dynamic>>[];
      for (final rawEntry in entries) {
        final entry = _asMap(rawEntry);
        if (entry == null) continue;
        final labels = _asMap(entry['labels']);
        final readings = _asMap(entry['readings']);
        final mnemonic = _asMap(entry['mnemonic']);
        final legacy = _asMap(entry['legacy']);
        final examples = entry['examples'];
        final character = _readText(entry, 'character');
        final meaning = labels == null
            ? _readNullableText(legacy ?? const {}, 'meaning')
            : _readNullableText(labels, 'meaningViDisplay');
        if (character.isEmpty || meaning == null || meaning.isEmpty) continue;
        final hanViet = labels == null
            ? null
            : _readNullableText(labels, 'hanViet');
        final decomposition = _asMap(entry['decomposition']);
        final decompositionJson = _kanjiDecompositionJson(
          decomposition: decomposition,
          hanViet: hanViet,
        );

        rows.add({
          'lessonId': _readInt(entry, 'lessonId') ?? lessonId,
          'character': character,
          'strokeCount': _readInt(entry, 'strokeCount') ?? 0,
          'onyomi': readings == null
              ? _readNullableText(legacy ?? const {}, 'onyomi')
              : (readings['onyomi'] is List
                    ? (readings['onyomi'] as List)
                          .map((item) => item.toString().trim())
                          .where((item) => item.isNotEmpty)
                          .join(', ')
                    : null),
          'kunyomi': readings == null
              ? _readNullableText(legacy ?? const {}, 'kunyomi')
              : (readings['kunyomi'] is List
                    ? (readings['kunyomi'] as List)
                          .map((item) => item.toString().trim())
                          .where((item) => item.isNotEmpty)
                          .join(', ')
                    : null),
          'meaning': meaning,
          'meaningEn': labels == null
              ? null
              : _readNullableText(labels, 'meaningEn'),
          'meaningJa': labels == null
              ? null
              : _readNullableText(labels, 'meaningJa'),
          'mnemonic_vi': mnemonic == null
              ? null
              : _readNullableText(mnemonic, 'vi'),
          'mnemonic_en': mnemonic == null
              ? null
              : _readNullableText(mnemonic, 'en'),
          'decomposition_json': decompositionJson,
          'examples': examples is List ? examples : const [],
          'jlptLevel': _readText(entry, 'level'),
        });
      }

      return rows;
    } catch (_) {
      return const [];
    }
  }

  String? _kanjiDecompositionJson({
    required Map<String, dynamic>? decomposition,
    required String? hanViet,
  }) {
    final merged = <String, dynamic>{
      if (decomposition != null) ...decomposition,
      if (hanViet != null && hanViet.isNotEmpty) 'hanViet': hanViet,
    };
    return merged.isEmpty ? null : json.encode(merged);
  }

  Future<void> _insertKanjiRows(List<dynamic> rows) async {
    await batch((batch) {
      for (final raw in rows) {
        final item = _asMap(raw);
        if (item == null) continue;
        batch.insert(
          kanji,
          KanjiCompanion.insert(
            lessonId: _readInt(item, 'lessonId') ?? 0,
            character: _readText(item, 'character'),
            strokeCount: _readInt(item, 'strokeCount') ?? 0,
            onyomi: Value(_readNullableText(item, 'onyomi')),
            kunyomi: Value(_readNullableText(item, 'kunyomi')),
            meaning: _readText(item, 'meaning'),
            meaningEn: Value(_readNullableText(item, 'meaningEn')),
            meaningJa: Value(_readNullableText(item, 'meaningJa')),
            mnemonicVi: Value(_readNullableText(item, 'mnemonic_vi')),
            mnemonicEn: Value(_readNullableText(item, 'mnemonic_en')),
            decompositionJson: Value(
              _readNullableText(item, 'decomposition_json') ??
                  (item['decomposition'] is Map
                      ? json.encode(item['decomposition'])
                      : null),
            ),
            examplesJson: json.encode(item['examples'] ?? const []),
            jlptLevel: _readText(item, 'jlptLevel'),
          ),
        );
      }
    });
  }

  Future<void> _seedKanjiLevel(_ContentSeedSpec spec) async {
    // Load all lesson files for this level concurrently — pure I/O, no deps.
    final perLessonFutures = [
      for (
        int lessonId = spec.startLesson;
        lessonId <= spec.endLesson;
        lessonId++
      )
        _loadCanonicalKanjiRows(
          levelLower: spec.levelLower,
          lessonId: lessonId,
        ),
    ];
    final perLessonRows = await Future.wait(perLessonFutures);

    final allRows = <Map<String, dynamic>>[];
    for (final rows in perLessonRows) {
      allRows.addAll(rows);
    }
    if (allRows.isNotEmpty) {
      await _insertKanjiRows(allRows);
    }
  }
}

class _SeedVocabAggregate {
  _SeedVocabAggregate({
    required this.term,
    required this.reading,
    required this.kanjiMeaning,
    required this.sourceVocabId,
    required this.sourceSenseId,
    required this.meaningVi,
    required this.meaningEn,
    required this.level,
    required this.series,
    required Iterable<String> tags,
  }) : _tags = LinkedHashSet<String>() {
    _mergeTags(tags);
  }

  final String term;
  final String? reading;
  final String? kanjiMeaning;
  final String? sourceVocabId;
  final String? sourceSenseId;
  final String meaningVi;
  final String? meaningEn;
  final String level;
  final String series;
  final LinkedHashSet<String> _tags;

  factory _SeedVocabAggregate.fromRow(Map<String, dynamic> row) {
    return _SeedVocabAggregate(
      term: row['term'] as String,
      reading: row['reading'] as String?,
      kanjiMeaning: row['kanjiMeaning'] as String?,
      sourceVocabId: row['sourceVocabId'] as String?,
      sourceSenseId: row['sourceSenseId'] as String?,
      meaningVi: row['meaning_vi'] as String,
      meaningEn: row['meaning_en'] as String?,
      level: row['level'] as String,
      series: (row['series'] as String?) ?? 'minna',
      tags: _splitTags(row['tags'] as String?),
    );
  }

  void mergeTags(String? tags) {
    _mergeTags(_splitTags(tags));
  }

  Map<String, dynamic> toRow() {
    return {
      'term': term,
      'reading': reading,
      'kanjiMeaning': kanjiMeaning,
      'sourceVocabId': sourceVocabId,
      'sourceSenseId': sourceSenseId,
      'meaning_vi': meaningVi,
      'meaning_en': meaningEn,
      'level': level,
      'series': series,
      'tags': _tags.join(','),
    };
  }

  void _mergeTags(Iterable<String> tags) {
    for (final tag in tags) {
      final normalized = tag.trim();
      if (normalized.isNotEmpty) {
        _tags.add(normalized);
      }
    }
  }

  static Iterable<String> _splitTags(String? rawTags) sync* {
    if (rawTags == null || rawTags.trim().isEmpty) {
      return;
    }

    for (final tag in rawTags.split(',')) {
      final normalized = tag.trim();
      if (normalized.isNotEmpty) {
        yield normalized;
      }
    }
  }
}

class _ContentSeedSpec {
  const _ContentSeedSpec(
    this.levelLabel,
    this.levelLower,
    this.startLesson,
    this.endLesson,
    this.series,
  );

  final String levelLabel;
  final String levelLower;
  final int startLesson;
  final int endLesson;
  final String series;
}

const _contentSeedSpecs = <_ContentSeedSpec>[
  _ContentSeedSpec('N5', 'n5', 1, 25, 'minna'),
  _ContentSeedSpec('N4', 'n4', 26, 50, 'minna'),
  _ContentSeedSpec('N3', 'n3', 1, 25, 'ShinKanzen'),
  _ContentSeedSpec('N2', 'n2', 1, 25, 'ShinKanzen'),
  _ContentSeedSpec('N1', 'n1', 1, 25, 'ShinKanzen'),
];

_ContentSeedSpec? _contentSeedSpecForLevel(String level) {
  final normalized = level.trim().toUpperCase();
  for (final spec in _contentSeedSpecs) {
    if (spec.levelLabel == normalized) {
      return spec;
    }
  }
  return null;
}

class _HajimeteSeedSpec {
  const _HajimeteSeedSpec(this.levelLabel, this.levelLower, this.chapterCount);

  final String levelLabel;
  final String levelLower;
  final int chapterCount;
}

const _hajimeteSeedSpecs = <_HajimeteSeedSpec>[
  _HajimeteSeedSpec('N5', 'n5', 14),
  _HajimeteSeedSpec('N4', 'n4', 20),
  _HajimeteSeedSpec('N3', 'n3', 28),
  _HajimeteSeedSpec('N2', 'n2', 38),
  _HajimeteSeedSpec('N1', 'n1', 50),
];

extension _StringNullIfEmpty on String {
  String? nullIfEmpty() => trim().isEmpty ? null : this;
}

Future<String> _activeStudyLevelLabel() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('onboarding.level')?.toUpperCase();
    return switch (stored) {
      'N1' || 'N2' || 'N3' || 'N4' || 'N5' => stored!,
      _ => 'N5',
    };
  } catch (_) {
    return 'N5';
  }
}

QueryExecutor _openContentConnection() {
  return driftDatabase(
    name: 'content',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
