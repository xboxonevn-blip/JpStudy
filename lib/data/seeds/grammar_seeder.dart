import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/app_database.dart';
import '../daos/grammar_dao.dart';
import '../utils/grammar_example_matching.dart';
import '../utils/grammar_english_notation.dart';

class GrammarSeeder {
  final GrammarDao _dao;

  // Tăng version này lên khi thay đổi file JSON data
  static const int kGrammarDataVersion = 8;
  static const String kKeyGrammarVersion = 'grammar_data_version';

  GrammarSeeder(this._dao);

  Future<void> seedGrammarData(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(kKeyGrammarVersion) ?? 0;

    // Smart Seeding: Chỉ chạy nếu version thay đổi hoặc chưa có data
    if (currentVersion >= kGrammarDataVersion) {
      debugPrint(
        '⚡ Skipping Grammar Seed: Data is up to date (v$currentVersion)',
      );
      return;
    }

    debugPrint('🔄 Starting Grammar Seed (v$kGrammarDataVersion)...');

    final stopwatch = Stopwatch()..start();

    // Chạy trong transaction để đảm bảo toàn vẹn dữ liệu
    await db.transaction(() async {
      await _seedLevel('N5', 1, 25);
      await _seedLevel('N4', 26, 50);
      await _seedLevel('N3', 51, 75);
    });

    await prefs.setInt(kKeyGrammarVersion, kGrammarDataVersion);
    stopwatch.stop();
    debugPrint(
      '✅ Grammar Seed Completed in ${stopwatch.elapsedMilliseconds}ms. Version updated to $kGrammarDataVersion',
    );
  }

  Future<void> _seedLevel(String level, int startLesson, int endLesson) async {
    for (int i = startLesson; i <= endLesson; i++) {
      try {
        // 1. Definition File
        final defPath =
            'assets/data/content/grammar/${level.toLowerCase()}/grammar_${level.toLowerCase()}_$i.json';
        final defString = await rootBundle.loadString(defPath);
        final List<dynamic> defJson = json.decode(defString);

        // 2. Example File
        final exPath =
            'assets/data/content/grammar_examples/${level.toLowerCase()}/lesson_$i.json';
        String? exString;
        try {
          exString = await rootBundle.loadString(exPath);
        } catch (_) {
          // Ignore missing examples
        }
        final List<dynamic>? exJson = exString != null
            ? json.decode(exString)
            : null;

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

          if (grammarPointLabel.isEmpty ||
              titleVi.isEmpty ||
              structure.isEmpty) {
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
            await (_dao.db.select(
              _dao.db.grammarPoints,
            )..where((tbl) => tbl.lessonId.equals(i))).get(),
            grammarPointLabel: grammarPointLabel,
            rawGrammarPoint: rawGrammarPoint,
            rawTitle: rawTitle,
            rawStructure: rawStructure,
          );

          final companion = GrammarPointsCompanion(
            lessonId: Value(i),
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
                    lessonId: Value(i),
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
        debugPrint('   -> Seeded Lesson $i ($level)');
      } catch (e) {
        debugPrint('   -> Error seeding Lesson $i: $e');
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
    ).replaceAll(RegExp(r'[~～]'), '〜').trim();
    final compact = normalized
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\u3000\(\)（）\[\]【】「」『』:：,，.．/／・\-\+]+'), '')
        .trim();
    final japaneseCore = normalized
        .replaceAll(RegExp(r'[^〜ぁ-ゖァ-ヶ一-龯々ー]'), '')
        .trim();

    return <String>{raw, normalized, compact, japaneseCore}
      ..removeWhere((value) => value.isEmpty);
  }
}
