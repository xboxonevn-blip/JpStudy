import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, int> loadKanjiStrokeCounts(String level) {
    final dir = Directory('assets/data/content/kanji/$level');
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    final result = <String, int>{};
    for (final file in files) {
      final wrapper =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final data = wrapper['entries'] as List<dynamic>;
      for (final entry in data) {
        final item = entry as Map<String, dynamic>;
        result[item['character'] as String] = item['strokeCount'] as int;
      }
    }
    return result;
  }

  test('stroke template coverage includes all N5 and N4 kanji', () {
    final raw = File(
      'assets/data/support/kanji/stroke_templates.json',
    ).readAsStringSync();
    final templates = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final templateChars = templates
        .map((entry) => entry['character'] as String)
        .toSet();

    final n5 = loadKanjiStrokeCounts('n5').keys.toSet();
    final n4 = loadKanjiStrokeCounts('n4').keys.toSet();
    final needed = {...n5, ...n4};

    final missing = needed.difference(templateChars);
    expect(missing, isEmpty, reason: 'Missing templates: ${missing.join(',')}');
  });

  test('template strokes match kanji strokeCount for N5/N4 set', () {
    final raw = File(
      'assets/data/support/kanji/stroke_templates.json',
    ).readAsStringSync();
    final templates = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final counts = <String, int>{}
      ..addAll(loadKanjiStrokeCounts('n5'))
      ..addAll(loadKanjiStrokeCounts('n4'));

    for (final template in templates) {
      final ch = template['character'] as String;
      final expected = counts[ch];
      if (expected == null) {
        continue;
      }
      final strokes = template['strokes'] as List<dynamic>;
      expect(
        strokes.length,
        expected,
        reason: 'Template stroke length mismatch for "$ch"',
      );
      final quality = template['quality'] as String?;
      expect(
        ['manual', 'curated', 'generated'],
        contains(quality),
        reason: 'Unexpected quality for "$ch": $quality',
      );
    }
  });

  test('high-frequency N5 has a manual template pack baseline', () {
    final raw = File(
      'assets/data/support/kanji/stroke_templates.json',
    ).readAsStringSync();
    final templates = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final manualN5 = templates.where((entry) {
      final level = entry['level'] as String?;
      final quality = entry['quality'] as String?;
      return level == 'N5' && quality == 'manual';
    });

    expect(
      manualN5.length,
      greaterThanOrEqualTo(45),
      reason: 'Manual N5 baseline is too small for stable scoring.',
    );
  });

  test('N4 has curated and manual rollout packs', () {
    final raw = File(
      'assets/data/support/kanji/stroke_templates.json',
    ).readAsStringSync();
    final templates = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final curatedN4 = templates.where((entry) {
      return entry['level'] == 'N4' && entry['quality'] == 'curated';
    });
    final manualN4 = templates.where((entry) {
      return entry['level'] == 'N4' && entry['quality'] == 'manual';
    });

    expect(
      curatedN4.length,
      greaterThanOrEqualTo(10),
      reason: 'Need enough curated N4 templates for gradual rollout.',
    );
    expect(
      manualN4.length,
      greaterThanOrEqualTo(18),
      reason: 'Need a meaningful N4 manual pack for wave rollout.',
    );
  });
}
