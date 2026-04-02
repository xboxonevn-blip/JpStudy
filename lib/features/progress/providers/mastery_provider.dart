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
  // All six queries are independent — fire them all and await in parallel.
  final vocabTotalsFuture = _countContentVocabByLevel(contentDb);
  final kanjiTotalsFuture = _countContentKanjiByLevel(contentDb);
  final grammarTotalsFuture = _countGrammarByLevel(appDb);
  final vocabMasteryFuture = _vocabMasteryByLevel(appDb);
  final grammarMasteryFuture = _grammarMasteryByLevel(appDb);
  final kanjiMasteryFuture = _kanjiMasteryByLevel(appDb, contentDb);

  final vocabTotals = await vocabTotalsFuture;
  final kanjiTotals = await kanjiTotalsFuture;
  final grammarTotals = await grammarTotalsFuture;
  final vocabMastery = await vocabMasteryFuture;
  final grammarMastery = await grammarMasteryFuture;
  final kanjiMastery = await kanjiMasteryFuture;

  // Derive the level list from actual data so N2/N1 content shows up
  // automatically without code changes when new content is added.
  const jlptOrder = ['N5', 'N4', 'N3', 'N2', 'N1'];
  final allLevels = <String>{
    ...vocabTotals.keys,
    ...kanjiTotals.keys,
    ...grammarTotals.keys,
    ...vocabMastery.keys,
    ...grammarMastery.keys,
    ...kanjiMastery.keys,
  };
  // Sort by canonical JLPT order (beginner first); unknown levels go last.
  final levels = allLevels.toList()
    ..sort((a, b) {
      final ia = jlptOrder.indexOf(a);
      final ib = jlptOrder.indexOf(b);
      final sortA = ia == -1 ? 999 : ia;
      final sortB = ib == -1 ? 999 : ib;
      return sortA.compareTo(sortB);
    });

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

// Shared stability bucketer: returns (studied, learning, young, mature) for
// a given stability value, accumulated into an existing record.
typedef _MasteryAccum = (int studied, int learning, int young, int mature);

_MasteryAccum _accumulate(_MasteryAccum prev, double stability) {
  final (s, l, y, m) = prev;
  if (stability < 1.0) return (s + 1, l + 1, y, m);
  if (stability < 21.0) return (s + 1, l, y + 1, m);
  return (s + 1, l, y, m + 1);
}

CategoryMastery _fromAccum(_MasteryAccum a) => CategoryMastery(
      total: 0, // placeholder — overridden in caller
      studied: a.$1,
      learning: a.$2,
      young: a.$3,
      mature: a.$4,
    );

/// Vocab mastery: join SrsState → UserLessonTerm → UserLesson to get level,
/// then bucket by stability.  Single pass — no intermediate stability list.
Future<Map<String, CategoryMastery>> _vocabMasteryByLevel(
  AppDatabase db,
) async {
  final rows = await db.select(db.srsState).join([
    innerJoin(
      db.userLessonTerm,
      db.userLessonTerm.id.equalsExp(db.srsState.vocabId),
    ),
    innerJoin(
      db.userLesson,
      db.userLesson.id.equalsExp(db.userLessonTerm.lessonId),
    ),
  ]).get();

  final byLevel = <String, _MasteryAccum>{};
  for (final row in rows) {
    final level = row.readTable(db.userLesson).level;
    final stability = row.readTable(db.srsState).stability;
    byLevel[level] = _accumulate(
      byLevel[level] ?? (0, 0, 0, 0),
      stability,
    );
  }

  return {for (final e in byLevel.entries) e.key: _fromAccum(e.value)};
}

/// Grammar mastery: join GrammarSrsState → GrammarPoints to get level.
/// Single pass — no intermediate stability list.
Future<Map<String, CategoryMastery>> _grammarMasteryByLevel(
  AppDatabase db,
) async {
  final rows = await db.select(db.grammarSrsState).join([
    innerJoin(
      db.grammarPoints,
      db.grammarPoints.id.equalsExp(db.grammarSrsState.grammarId),
    ),
  ]).get();

  final byLevel = <String, _MasteryAccum>{};
  for (final row in rows) {
    final level = row.readTable(db.grammarPoints).jlptLevel;
    final stability = row.readTable(db.grammarSrsState).stability;
    byLevel[level] = _accumulate(
      byLevel[level] ?? (0, 0, 0, 0),
      stability,
    );
  }

  return {for (final e in byLevel.entries) e.key: _fromAccum(e.value)};
}

/// Kanji mastery: KanjiSrsState links to content DB kanji by kanjiId.
/// Single pass after the id→level lookup — no intermediate stability list.
Future<Map<String, CategoryMastery>> _kanjiMasteryByLevel(
  AppDatabase appDb,
  ContentDatabase contentDb,
) async {
  final srsRows = await appDb.select(appDb.kanjiSrsState).get();
  if (srsRows.isEmpty) return {};

  // Build id→level map from content DB.
  final kanjiIds = srsRows.map((r) => r.kanjiId).toList();
  final kanjiRows = await (contentDb.select(contentDb.kanji)
        ..where((t) => t.id.isIn(kanjiIds)))
      .get();
  final idToLevel = <int, String>{
    for (final k in kanjiRows) k.id: k.jlptLevel,
  };

  final byLevel = <String, _MasteryAccum>{};
  for (final srs in srsRows) {
    final level = idToLevel[srs.kanjiId];
    if (level == null) continue;
    byLevel[level] = _accumulate(
      byLevel[level] ?? (0, 0, 0, 0),
      srs.stability,
    );
  }

  return {for (final e in byLevel.entries) e.key: _fromAccum(e.value)};
}
