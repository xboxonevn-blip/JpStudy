import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';

class PersonalBest {
  const PersonalBest({
    required this.mode,
    required this.level,
    required this.bestPercent,
    required this.attempts,
  });

  final String mode;
  final String level;
  final double bestPercent;
  final int attempts;
}

final personalBestsProvider =
    FutureProvider.autoDispose<List<PersonalBest>>((ref) async {
  final db = ref.watch(databaseProvider);
  return queryPersonalBests(db);
});

Future<List<PersonalBest>> queryPersonalBests(AppDatabase db) async {
  final rows = await db.customSelect(
    'SELECT mode, level, '
    'MAX(CAST(score AS REAL) * 100.0 / total) AS best_pct, '
    'COUNT(*) AS attempts '
    'FROM attempt '
    'WHERE score IS NOT NULL AND total IS NOT NULL AND total > 0 '
    'GROUP BY mode, level '
    'ORDER BY best_pct DESC',
  ).get();

  return rows.map((row) {
    return PersonalBest(
      mode: row.read<String>('mode'),
      level: row.read<String>('level'),
      bestPercent: row.read<double>('best_pct'),
      attempts: row.read<int>('attempts'),
    );
  }).toList();
}

/// Check if a given score beats the personal best for mode+level.
/// Must be called BEFORE the new attempt is inserted.
Future<bool> isNewPersonalBest(
  AppDatabase db, {
  required String mode,
  required String level,
  required int score,
  required int total,
}) async {
  if (total <= 0) return false;
  final currentPct = (score * 100.0 / total);

  final rows = await db.customSelect(
    'SELECT MAX(CAST(score AS REAL) * 100.0 / total) AS best_pct '
    'FROM attempt '
    'WHERE mode = ? AND level = ? '
    'AND score IS NOT NULL AND total IS NOT NULL AND total > 0',
    variables: [Variable.withString(mode), Variable.withString(level)],
  ).get();

  if (rows.isEmpty) return true;
  final prevBest = rows.first.readNullable<double>('best_pct');
  if (prevBest == null) return true;
  return currentPct > prevBest;
}
