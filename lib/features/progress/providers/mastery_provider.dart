import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/db/database_provider.dart';

/// Mastery stats for a single category (vocab, grammar, or kanji) within one JLPT level.
class CategoryMastery {
  const CategoryMastery({
    required this.total,
    required this.studied,
    required this.learning,
    required this.young,
    required this.mature,
  });

  /// Total items available in this level for this category.
  final int total;

  /// Items that have an SRS state (user has encountered them).
  final int studied;

  /// Items with stability < 1.0 (fragile, frequent reviews).
  final int learning;

  /// Items with 1.0 <= stability < 21.0 (consolidating).
  final int young;

  /// Items with stability >= 21.0 (solidified).
  final int mature;

  double get masteryRatio => total == 0 ? 0.0 : mature / total;
  double get studiedRatio => total == 0 ? 0.0 : studied / total;

  static const empty = CategoryMastery(
    total: 0,
    studied: 0,
    learning: 0,
    young: 0,
    mature: 0,
  );
}

/// Aggregated mastery for one JLPT level across all categories.
class LevelMastery {
  const LevelMastery({
    required this.level,
    required this.vocab,
    required this.grammar,
    required this.kanji,
  });

  final String level;
  final CategoryMastery vocab;
  final CategoryMastery grammar;
  final CategoryMastery kanji;

  int get totalItems => vocab.total + grammar.total + kanji.total;
  int get totalStudied => vocab.studied + grammar.studied + kanji.studied;
  int get totalMature => vocab.mature + grammar.mature + kanji.mature;

  double get overallMasteryRatio =>
      totalItems == 0 ? 0.0 : totalMature / totalItems;
  double get overallStudiedRatio =>
      totalItems == 0 ? 0.0 : totalStudied / totalItems;
}

/// Full mastery snapshot across all JLPT levels.
class MasterySnapshot {
  const MasterySnapshot({required this.levels});

  final List<LevelMastery> levels;
}

/// Fetches the full mastery snapshot.
final masterySnapshotProvider = FutureProvider<MasterySnapshot>((ref) async {
  final appDb = ref.watch(databaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
  return _fetchMasterySnapshot(appDb, contentDb);
});

Future<MasterySnapshot> _fetchMasterySnapshot(
  AppDatabase appDb,
  ContentDatabase contentDb,
) async {
  const levels = ['N5', 'N4', 'N3'];

  // --- Content totals from ContentDatabase ---
  final vocabTotals = await _countContentVocabByLevel(contentDb);
  final kanjiTotals = await _countContentKanjiByLevel(contentDb);

  // --- Grammar totals from AppDatabase (GrammarPoints) ---
  final grammarTotals = await _countGrammarByLevel(appDb);

  // --- SRS mastery from AppDatabase ---
  final vocabMastery = await _vocabMasteryByLevel(appDb);
  final grammarMastery = await _grammarMasteryByLevel(appDb);
  final kanjiMastery = await _kanjiMasteryByLevel(appDb, contentDb);

  final result = <LevelMastery>[];
  for (final level in levels) {
    final vTotal = vocabTotals[level] ?? 0;
    final gTotal = grammarTotals[level] ?? 0;
    final kTotal = kanjiTotals[level] ?? 0;

    final vm = vocabMastery[level];
    final gm = grammarMastery[level];
    final km = kanjiMastery[level];

    result.add(LevelMastery(
      level: level,
      vocab: CategoryMastery(
        total: vTotal,
        studied: vm?.studied ?? 0,
        learning: vm?.learning ?? 0,
        young: vm?.young ?? 0,
        mature: vm?.mature ?? 0,
      ),
      grammar: CategoryMastery(
        total: gTotal,
        studied: gm?.studied ?? 0,
        learning: gm?.learning ?? 0,
        young: gm?.young ?? 0,
        mature: gm?.mature ?? 0,
      ),
      kanji: CategoryMastery(
        total: kTotal,
        studied: km?.studied ?? 0,
        learning: km?.learning ?? 0,
        young: km?.young ?? 0,
        mature: km?.mature ?? 0,
      ),
    ));
  }

  return MasterySnapshot(levels: result);
}

/// Count vocab items per level from content database.
Future<Map<String, int>> _countContentVocabByLevel(
  ContentDatabase db,
) async {
  final rows = await (db.selectOnly(db.vocab)
        ..addColumns([db.vocab.level, db.vocab.id.count()])
        ..groupBy([db.vocab.level]))
      .get();
  final map = <String, int>{};
  for (final row in rows) {
    final level = row.read(db.vocab.level);
    final count = row.read(db.vocab.id.count());
    if (level != null && count != null) {
      map[level] = count;
    }
  }
  return map;
}

/// Count kanji items per level from content database.
Future<Map<String, int>> _countContentKanjiByLevel(
  ContentDatabase db,
) async {
  final rows = await (db.selectOnly(db.kanji)
        ..addColumns([db.kanji.jlptLevel, db.kanji.id.count()])
        ..groupBy([db.kanji.jlptLevel]))
      .get();
  final map = <String, int>{};
  for (final row in rows) {
    final level = row.read(db.kanji.jlptLevel);
    final count = row.read(db.kanji.id.count());
    if (level != null && count != null) {
      map[level] = count;
    }
  }
  return map;
}

/// Count grammar points per level from app database.
Future<Map<String, int>> _countGrammarByLevel(AppDatabase db) async {
  final rows = await (db.selectOnly(db.grammarPoints)
        ..addColumns([db.grammarPoints.jlptLevel, db.grammarPoints.id.count()])
        ..groupBy([db.grammarPoints.jlptLevel]))
      .get();
  final map = <String, int>{};
  for (final row in rows) {
    final level = row.read(db.grammarPoints.jlptLevel);
    final count = row.read(db.grammarPoints.id.count());
    if (level != null && count != null) {
      map[level] = count;
    }
  }
  return map;
}

/// Vocab mastery: join SrsState → UserLessonTerm → UserLesson to get level,
/// then bucket by stability.
Future<Map<String, CategoryMastery>> _vocabMasteryByLevel(
  AppDatabase db,
) async {
  // Get all SRS states with their associated lesson level
  final query = db.select(db.srsState).join([
    innerJoin(
      db.userLessonTerm,
      db.userLessonTerm.id.equalsExp(db.srsState.vocabId),
    ),
    innerJoin(
      db.userLesson,
      db.userLesson.id.equalsExp(db.userLessonTerm.lessonId),
    ),
  ]);

  final rows = await query.get();

  // Group by level
  final byLevel = <String, List<double>>{};
  for (final row in rows) {
    final level = row.readTable(db.userLesson).level;
    final stability = row.readTable(db.srsState).stability;
    byLevel.putIfAbsent(level, () => []).add(stability);
  }

  // Also need content totals for the denominator
  // (already have them from caller, but we recalculate here for independence)
  // Actually, we pass total from caller — skip for now, use a sentinel

  final result = <String, CategoryMastery>{};
  for (final entry in byLevel.entries) {
    int learning = 0, young = 0, mature = 0;
    for (final s in entry.value) {
      if (s < 1.0) {
        learning++;
      } else if (s < 21.0) {
        young++;
      } else {
        mature++;
      }
    }
    final studied = entry.value.length;
    // total will be overridden by caller
    result[entry.key] = CategoryMastery(
      total: 0, // placeholder — overridden in caller
      studied: studied,
      learning: learning,
      young: young,
      mature: mature,
    );
  }
  return result;
}

/// Grammar mastery: join GrammarSrsState → GrammarPoints to get level.
Future<Map<String, CategoryMastery>> _grammarMasteryByLevel(
  AppDatabase db,
) async {
  final query = db.select(db.grammarSrsState).join([
    innerJoin(
      db.grammarPoints,
      db.grammarPoints.id.equalsExp(db.grammarSrsState.grammarId),
    ),
  ]);

  final rows = await query.get();

  final byLevel = <String, List<double>>{};
  for (final row in rows) {
    final level = row.readTable(db.grammarPoints).jlptLevel;
    final stability = row.readTable(db.grammarSrsState).stability;
    byLevel.putIfAbsent(level, () => []).add(stability);
  }

  final result = <String, CategoryMastery>{};
  for (final entry in byLevel.entries) {
    int learning = 0, young = 0, mature = 0;
    for (final s in entry.value) {
      if (s < 1.0) {
        learning++;
      } else if (s < 21.0) {
        young++;
      } else {
        mature++;
      }
    }
    result[entry.key] = CategoryMastery(
      total: 0,
      studied: entry.value.length,
      learning: learning,
      young: young,
      mature: mature,
    );
  }
  return result;
}

/// Kanji mastery: KanjiSrsState links to content DB kanji by kanjiId.
/// We need to look up each kanji's level from the content DB.
Future<Map<String, CategoryMastery>> _kanjiMasteryByLevel(
  AppDatabase appDb,
  ContentDatabase contentDb,
) async {
  // Get all kanji SRS states
  final srsRows = await appDb.select(appDb.kanjiSrsState).get();
  if (srsRows.isEmpty) return {};

  // Get kanji id→level mapping from content DB
  final kanjiIds = srsRows.map((r) => r.kanjiId).toList();
  final kanjiRows = await (contentDb.select(contentDb.kanji)
        ..where((t) => t.id.isIn(kanjiIds)))
      .get();
  final idToLevel = <int, String>{};
  for (final k in kanjiRows) {
    idToLevel[k.id] = k.jlptLevel;
  }

  final byLevel = <String, List<double>>{};
  for (final srs in srsRows) {
    final level = idToLevel[srs.kanjiId];
    if (level == null) continue;
    byLevel.putIfAbsent(level, () => []).add(srs.stability);
  }

  final result = <String, CategoryMastery>{};
  for (final entry in byLevel.entries) {
    int learning = 0, young = 0, mature = 0;
    for (final s in entry.value) {
      if (s < 1.0) {
        learning++;
      } else if (s < 21.0) {
        young++;
      } else {
        mature++;
      }
    }
    result[entry.key] = CategoryMastery(
      total: 0,
      studied: entry.value.length,
      learning: learning,
      young: young,
      mature: mature,
    );
  }
  return result;
}
