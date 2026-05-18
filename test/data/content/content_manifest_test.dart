import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('content index reflects runtime inventory for all levels', () {
    final index =
        jsonDecode(File('assets/data/content/index.json').readAsStringSync())
            as Map<String, dynamic>;
    final datasets = index['datasets'] as Map<String, dynamic>;

    expect(
      datasets.keys,
      containsAll(<String>[
        'vocab',
        'kanji',
        'grammar',
        'grammarExamples',
        'grammarPractice',
        'immersion',
        'hanVietOnRules',
        'kana',
      ]),
    );

    expect(_summary(datasets['vocab']), _scanVocab());
    expect(_summary(datasets['kanji']), _scanLessonDataset('kanji'));
    expect(_summary(datasets['grammar']), _scanGrammarDefinitions());
    expect(_summary(datasets['grammarExamples']), _scanGrammarExamples());
    expect(_summary(datasets['grammarPractice']), _scanGrammarPractice());
    expect(_summary(datasets['immersion']), _scanImmersion());
  });
}

Map<String, dynamic> _summary(Object? raw) {
  final dataset = raw as Map<String, dynamic>;
  return <String, dynamic>{
    'files': dataset['files'],
    'entries': dataset['entries'],
    'levels': _normalizeLevels(dataset['levels'] as Map<String, dynamic>),
  };
}

Map<String, dynamic> _normalizeLevels(Map<String, dynamic> raw) {
  return {
    for (final entry in raw.entries)
      entry.key: {
        'files': (entry.value as Map<String, dynamic>)['files'],
        'entries': (entry.value as Map<String, dynamic>)['entries'],
      },
  };
}

Map<String, dynamic> _scanVocab() {
  final files = _jsonFiles(Directory('assets/data/content/vocab'));
  final levels = <String, ({int files, int entries})>{};
  var entries = 0;
  for (final file in files) {
    final level = _levelFromPath(file);
    if (level == null) continue;
    final count = _entryCount(jsonDecode(file.readAsStringSync()));
    entries += count;
    final current = levels[level] ?? (files: 0, entries: 0);
    levels[level] = (
      files: current.files + 1,
      entries: current.entries + count,
    );
  }
  return _result(files.length, entries, levels);
}

Map<String, dynamic> _scanLessonDataset(String dataset) {
  final files = _jsonFiles(
    Directory('assets/data/content/$dataset'),
  ).where((file) => _levelFromPath(file) != null).toList(growable: false);
  final levels = <String, ({int files, int entries})>{};
  var entries = 0;
  for (final file in files) {
    final level = _levelFromPath(file)!;
    final count = _entryCount(jsonDecode(file.readAsStringSync()));
    entries += count;
    final current = levels[level] ?? (files: 0, entries: 0);
    levels[level] = (
      files: current.files + 1,
      entries: current.entries + count,
    );
  }
  return _result(files.length, entries, levels);
}

Map<String, dynamic> _scanGrammarDefinitions() {
  final files = _jsonFiles(Directory('assets/data/content/grammar'));
  final levels = <String, ({int files, int entries})>{};
  var entries = 0;
  for (final file in files) {
    final level = _levelFromPath(file);
    if (level == null) continue;
    final count = _entryCount(jsonDecode(file.readAsStringSync()));
    entries += count;
    final current = levels[level] ?? (files: 0, entries: 0);
    levels[level] = (
      files: current.files + 1,
      entries: current.entries + count,
    );
  }
  return _result(files.length, entries, levels);
}

Map<String, dynamic> _scanGrammarExamples() {
  final files = _jsonFiles(Directory('assets/data/content/grammar_examples'));
  final levels = <String, ({int files, int entries})>{};
  var entries = 0;
  for (final file in files) {
    final level = _levelFromPath(file);
    if (level == null) continue;
    final count = _grammarExampleCount(jsonDecode(file.readAsStringSync()));
    entries += count;
    final current = levels[level] ?? (files: 0, entries: 0);
    levels[level] = (
      files: current.files + 1,
      entries: current.entries + count,
    );
  }
  return _result(files.length, entries, levels);
}

Map<String, dynamic> _scanGrammarPractice() {
  final grammar = _scanGrammarDefinitions();
  final rawLevels = grammar['levels'] as Map<String, dynamic>;
  return <String, dynamic>{
    'files': grammar['files'],
    'entries': grammar['entries'],
    'levels': rawLevels,
  };
}

Map<String, dynamic> _scanImmersion() {
  final files = _jsonFiles(Directory('assets/data/content/immersion'));
  final levels = <String, ({int files, int entries})>{};
  for (final file in files) {
    final level = _levelFromPath(file);
    if (level == null) continue;
    final current = levels[level] ?? (files: 0, entries: 0);
    levels[level] = (files: current.files + 1, entries: current.entries + 1);
  }
  return _result(files.length, files.length, levels);
}

List<File> _jsonFiles(Directory directory) {
  if (!directory.existsSync()) return const [];
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String? _levelFromPath(File file) {
  final parts = file.path.replaceAll('\\', '/').split('/');
  final index = parts.indexOf('content');
  if (index == -1 || index + 2 >= parts.length) return null;
  final level = parts[index + 2].toUpperCase();
  return RegExp(r'^N[1-5]$').hasMatch(level) ? level : null;
}

int _entryCount(Object? payload) {
  if (payload is List) return payload.length;
  if (payload is Map<String, dynamic>) {
    final entries = payload['entries'];
    if (entries is List) return entries.length;
  }
  return 0;
}

int _grammarExampleCount(Object? payload) {
  if (payload is Map<String, dynamic>) {
    final examples = payload['examples'];
    return examples is List ? examples.length : 0;
  }
  if (payload is List) {
    var total = 0;
    for (final item in payload) {
      if (item is Map<String, dynamic> && item['examples'] is List) {
        total += (item['examples'] as List).length;
      } else {
        total += 1;
      }
    }
    return total;
  }
  return 0;
}

Map<String, dynamic> _result(
  int files,
  int entries,
  Map<String, ({int files, int entries})> levels,
) {
  return <String, dynamic>{
    'files': files,
    'entries': entries,
    'levels': {
      for (final key in levels.keys.toList()..sort())
        key: {'files': levels[key]!.files, 'entries': levels[key]!.entries},
    },
  };
}
