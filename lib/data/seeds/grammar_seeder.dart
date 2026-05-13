import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/app_database.dart';
import '../daos/grammar_dao.dart';
import '../utils/grammar_example_matching.dart';
import '../utils/grammar_english_notation.dart';

typedef _LessonData = ({int lessonId, List<dynamic> def, List<dynamic>? ex});

class GrammarSeeder {
  final GrammarDao _dao;

  // Tăng version này lên khi thay đổi file JSON data
  static const int kGrammarDataVersion = 11;
  static const String kKeyGrammarVersion = 'grammar_data_version';

  GrammarSeeder(this._dao);

  Future<void> seedGrammarData(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(kKeyGrammarVersion) ?? 0;

    final existingCount =
        await (_dao.db.selectOnly(_dao.db.grammarPoints)
              ..addColumns([_dao.db.grammarPoints.id.count()]))
            .map((row) => row.read(_dao.db.grammarPoints.id.count()) ?? 0)
            .getSingle();

    // Smart Seeding: skip only when both version and DB rows are present.
    if (currentVersion >= kGrammarDataVersion && existingCount > 0) {
      debugPrint(
        'Skipping Grammar Seed: Data is up to date (v$currentVersion)',
      );
      return;
    }

    debugPrint('ðŸ”„ Starting Grammar Seed (v$kGrammarDataVersion)...');
    final stopwatch = Stopwatch()..start();

    // Load all JSON files concurrently before opening the transaction so
    // that asset I/O does not block or extend the DB transaction window.
    final allLevelData = await Future.wait([
      _loadLevelJson('N5', 1, 25),
      _loadLevelJson('N4', 26, 50),
      _loadLevelJson('N3', 1, 25),
      _loadLevelJson('N2', 1, 25),
      _loadLevelJson('N1', 1, 25),
    ]);

    // Chạy trong transaction để đảm bảo toàn vẹn dữ liệu
    await db.transaction(() async {
      await _seedLevelFromData('N5', allLevelData[0]);
      await _seedLevelFromData('N4', allLevelData[1]);
      await _seedLevelFromData('N3', allLevelData[2]);
      await _seedLevelFromData('N2', allLevelData[3]);
      await _seedLevelFromData('N1', allLevelData[4]);
    });

    await prefs.setInt(kKeyGrammarVersion, kGrammarDataVersion);
    stopwatch.stop();
    debugPrint(
      'âœ… Grammar Seed Completed in ${stopwatch.elapsedMilliseconds}ms. Version updated to $kGrammarDataVersion',
    );
  }

  // â”€â”€ JSON loading (pure I/O, no DB) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Loads all lesson JSON files for [level] concurrently.
  Future<List<_LessonData>> _loadLevelJson(String level, int start, int end) {
    return Future.wait([
      for (int i = start; i <= end; i++) _loadOneLessonJson(level, i),
    ]);
  }

  /// Loads the definition and example files for a single lesson in parallel.
  Future<_LessonData> _loadOneLessonJson(String level, int lessonId) async {
    final ll = level.toLowerCase();
    final defPath =
        'assets/data/content/grammar/$ll/grammar_${ll}_$lessonId.json';
    final exPath =
        'assets/data/content/grammar_examples/$ll/lesson_$lessonId.json';

    // Fire both loads concurrently — they are completely independent.
    final defFuture = rootBundle
        .loadString(defPath)
        .then((s) => json.decode(s) as List<dynamic>);
    final exFuture = _tryLoadJsonList(exPath);

    final def = await defFuture;
    final ex = await exFuture;
    return (lessonId: lessonId, def: def, ex: ex);
  }

  Future<List<dynamic>?> _tryLoadJsonList(String path) async {
    try {
      final s = await rootBundle.loadString(path);
      return json.decode(s) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  // â”€â”€ DB seeding â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _seedLevelFromData(
    String level,
    List<_LessonData> lessons,
  ) async {
    for (final lessonData in lessons) {
      try {
        await _seedOneLesson(level, lessonData);
        debugPrint('   -> Seeded Lesson ${lessonData.lessonId} ($level)');
      } catch (e) {
        debugPrint('   -> Error seeding Lesson ${lessonData.lessonId}: $e');
      }
    }
  }

  Future<void> _seedOneLesson(String level, _LessonData lessonData) async {
    final lessonId = lessonData.lessonId;
    final defJson = lessonData.def;
    final exJson = lessonData.ex;

    // Hoist: fetch existing points ONCE per lesson, not once per grammar item.
    final existingPoints = await (_dao.db.select(
      _dao.db.grammarPoints,
    )..where((tbl) => tbl.lessonId.equals(lessonId))).get();

    for (final item in defJson) {
      final rawGrammarPoint = item['grammarPoint'] as String?;
      final rawTitle = item['title'] as String?;
      final rawTitleEn = item['titleEn'] as String?;
      final rawStructure = (item['structure'] ?? item['connection'] ?? '')
          .toString()
          .trim();
      final grammarPointLabel = resolveCanonicalGrammarPointSource(
        grammarPoint: rawGrammarPoint,
        structure: rawStructure,
        title: rawTitle,
        structureEn: item['structureEn'] as String?,
        titleEn: rawTitleEn,
      );
      final structure = stripNonCanonicalGrammarNotes(
        rawStructure.isEmpty ? grammarPointLabel : rawStructure,
      );
      final titleVi =
          ((item['title'] ?? item['meaning_vi'] ?? '').toString().trim())
              .trim();
      final structureEn = normalizeGrammarStructureEn(
        item['structureEn'] as String?,
      );
      final explanationVi =
          (item['explanation'] ?? item['explanation_vi'] ?? '')
              .toString()
              .trim();
      final explanationEn = (item['explanationEn'] as String? ?? '').trim();

      if (grammarPointLabel.isEmpty || titleVi.isEmpty || structure.isEmpty) {
        continue;
      }

      final englishLabel = resolveEnglishGrammarLabel(
        titleEn: rawTitleEn,
        meaningEn: rawTitleEn,
        connectionEn: structureEn,
        connection: structure,
        grammarPoint: grammarPointLabel,
      );
      final englishMeaning = resolveEnglishGrammarMeaning(
        meaningEn: rawTitleEn,
        titleEn: rawTitleEn,
        connectionEn: structureEn,
        connection: structure,
        grammarPoint: grammarPointLabel,
      );
      final englishConnection = resolveEnglishGrammarConnection(
        connectionEn: structureEn,
        connection: structure,
        grammarPoint: grammarPointLabel,
        titleEn: rawTitleEn,
        meaningEn: rawTitleEn,
      );
      final storedTitleEn = englishLabel == 'Target pattern'
          ? null
          : englishLabel;
      final storedMeaningEn = englishMeaning == 'Target pattern'
          ? null
          : englishMeaning;
      final storedConnectionEn = englishConnection == 'Grammar pattern'
          ? null
          : englishConnection;

      final existing = _findExistingPoint(
        existingPoints,
        grammarPointLabel: grammarPointLabel,
        rawGrammarPoint: rawGrammarPoint,
        rawTitle: rawTitle,
        rawStructure: rawStructure,
      );

      final companion = GrammarPointsCompanion(
        lessonId: Value(lessonId),
        grammarPoint: Value(grammarPointLabel),
        titleEn: Value(storedTitleEn),
        meaning: Value(titleVi),
        meaningVi: Value(titleVi),
        meaningEn: Value(storedMeaningEn),
        connection: Value(structure),
        connectionEn: Value(storedConnectionEn),
        explanation: Value(explanationVi),
        explanationVi: Value(explanationVi),
        explanationEn: Value(explanationEn.isEmpty ? null : explanationEn),
        jlptLevel: Value(level),
      );

      late final int pointId;
      if (existing == null) {
        pointId = await _dao
            .into(_dao.db.grammarPoints)
            .insert(
              GrammarPointsCompanion.insert(
                lessonId: Value(lessonId),
                grammarPoint: grammarPointLabel,
                titleEn: Value(storedTitleEn),
                meaning: titleVi,
                meaningVi: Value(titleVi),
                meaningEn: Value(storedMeaningEn),
                connection: structure,
                connectionEn: Value(storedConnectionEn),
                explanation: explanationVi,
                explanationVi: Value(explanationVi),
                explanationEn: Value(
                  explanationEn.isEmpty ? null : explanationEn,
                ),
                jlptLevel: level,
                isLearned: const Value(false),
              ),
            );
      } else {
        pointId = existing.id;
        await (_dao.db.update(
          _dao.db.grammarPoints,
        )..where((tbl) => tbl.id.equals(pointId))).write(companion);
        await (_dao.db.delete(
          _dao.db.grammarExamples,
        )..where((tbl) => tbl.grammarId.equals(pointId))).go();
      }

      // Insert Examples
      if (exJson != null) {
        final examples = findGrammarExamplesForDefinition(
          exampleBlocks: exJson,
          title: rawTitle,
          grammarPoint: grammarPointLabel,
        );

        if (examples != null) {
          for (final ex in examples) {
            await _dao
                .into(_dao.db.grammarExamples)
                .insert(
                  GrammarExamplesCompanion.insert(
                    grammarId: pointId,
                    japanese: ex['sentence'],
                    translation:
                        (ex['translation'] ?? ex['translationEn'] ?? '')
                            .toString(),
                    translationVi: Value(ex['translation'] as String?),
                    translationEn: Value(ex['translationEn'] as String?),
                  ),
                );
          }
        }
      }
    }
  }

  GrammarPoint? _findExistingPoint(
    List<GrammarPoint> rows, {
    required String grammarPointLabel,
    required String? rawGrammarPoint,
    required String? rawTitle,
    required String rawStructure,
  }) {
    if (rows.isEmpty) return null;

    final candidateKeys = <String>{
      ..._buildGrammarSeedKeys(grammarPointLabel),
      ..._buildGrammarSeedKeys(rawGrammarPoint),
      ..._buildGrammarSeedKeys(rawTitle),
      ..._buildGrammarSeedKeys(rawStructure),
    };
    if (candidateKeys.isEmpty) return null;

    for (final row in rows) {
      final rowKeys = <String>{
        ..._buildGrammarSeedKeys(row.grammarPoint),
        ..._buildGrammarSeedKeys(row.connection),
        ..._buildGrammarSeedKeys(row.meaningVi ?? row.meaning),
      };
      if (rowKeys.any(candidateKeys.contains)) {
        return row;
      }
    }

    return null;
  }

  Set<String> _buildGrammarSeedKeys(String? rawValue) {
    final raw = (rawValue ?? '').trim();
    if (raw.isEmpty) return const <String>{};

    final normalized = stripNonCanonicalGrammarNotes(
      raw,
    ).replaceAll(RegExp(r'[~?]'), '?').trim();
    final compact = normalized
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\u3000\(\)?\[\]?:?,?.?/?\-\+]+'), '')
        .trim();
    final japaneseCore = normalized
        .replaceAll(RegExp(r'[^?-?-?-?]'), '')
        .trim();

    return <String>{raw, normalized, compact, japaneseCore}
      ..removeWhere((value) => value.isEmpty);
  }
}
