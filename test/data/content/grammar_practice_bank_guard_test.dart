import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/grammar_repository.dart';
import 'package:jpstudy/features/grammar/services/grammar_practice_bank.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every runtime grammar point has generated practice questions',
    () async {
      SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);

      final repo = GrammarRepository(db);
      const levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
      final gaps = <String>[];

      for (final level in levels) {
        final points = await repo.fetchPointsByLevel(level);
        final examples =
            await (db.select(db.grammarExamples)..where(
                  (tbl) => tbl.grammarId.isIn(
                    points.map((point) => point.id).toList(growable: false),
                  ),
                ))
                .get();
        final examplesByPoint = <int, List<GrammarExample>>{};
        for (final example in examples) {
          examplesByPoint.putIfAbsent(example.grammarId, () => []).add(example);
        }

        final details = [
          for (final point in points)
            (point: point, examples: examplesByPoint[point.id] ?? const []),
        ];
        final questions = GrammarPracticeBank.buildGenerated(
          details: details,
          allPoints: points,
          language: AppLanguage.vi,
        );
        final questionCounts = <int, int>{};
        for (final question in questions) {
          questionCounts[question.point.id] =
              (questionCounts[question.point.id] ?? 0) + 1;
        }

        for (final point in points) {
          if ((questionCounts[point.id] ?? 0) == 0) {
            gaps.add('$level#${point.id}:${point.grammarPoint}');
          }
        }
      }

      expect(gaps, isEmpty);
    },
  );

  test('authored grammar practice bank has no orphaned questions', () {
    final file = File(
      'assets/data/content/grammar_practice/authored_bank.json',
    );
    expect(file.existsSync(), isTrue);

    final payload = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final questions = payload['questions'] as List<dynamic>? ?? const [];
    final allowedConsumers =
        (payload['consumerRoutes'] as List<dynamic>? ?? const [])
            .map((value) => value.toString())
            .toSet();

    expect(allowedConsumers, contains('/grammar-practice'));

    final orphaned = <String>[];
    for (final raw in questions) {
      final item = raw as Map<String, dynamic>;
      final consumers = (item['consumerRoutes'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toSet();
      if (consumers.isEmpty ||
          consumers.intersection(allowedConsumers).isEmpty) {
        orphaned.add(item['id']?.toString() ?? '<missing id>');
      }
    }

    expect(orphaned, isEmpty);
  });
}
