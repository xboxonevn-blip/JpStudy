import 'dart:convert';
import 'dart:io';

class ContentScopeReportBuilder {
  const ContentScopeReportBuilder._();

  static ContentScopeReport scan(Directory contentRoot) {
    final buckets = <String, _MutableContentScope>{};
    for (final entity in contentRoot.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final path = entity.path.replaceAll('\\', '/');
      final dataset = _datasetFromPath(path);
      final level = _levelFromPath(path);
      final decoded = jsonDecode(entity.readAsStringSync());
      switch (dataset) {
        case 'vocab':
          _readVocab(decoded, buckets, fallbackLevel: level);
          break;
        case 'kanji':
          _readKanji(decoded, buckets, fallbackLevel: level);
          break;
        case 'grammar':
          _readGrammar(decoded, buckets, fallbackLevel: level);
          break;
        case 'grammar_examples':
          _readGrammarExamples(decoded, buckets, fallbackLevel: level);
          break;
      }
    }
    final levels = {
      for (final entry in buckets.entries) entry.key: entry.value.toReport(),
    };
    return ContentScopeReport(levels: _sortLevels(levels));
  }

  static Map<String, ContentScopeLevelReport> _sortLevels(
    Map<String, ContentScopeLevelReport> levels,
  ) {
    final keys = levels.keys.toList()
      ..sort((a, b) => _levelSortKey(a).compareTo(_levelSortKey(b)));
    return {for (final key in keys) key: levels[key]!};
  }

  static String _levelSortKey(String value) =>
      RegExp(r'^N([1-5])$').firstMatch(value)?.group(1) ?? value;
}

class ContentScopeReport {
  const ContentScopeReport({required this.levels});

  final Map<String, ContentScopeLevelReport> levels;

  ContentScopeLevelReport level(String level) =>
      levels[level] ?? const ContentScopeLevelReport.empty('unknown');

  String toMarkdown({required String contentRoot}) {
    return [
      '# Content Scope Report',
      '',
      'Content root: `$contentRoot`',
      '',
      '| Level | Vocab | Kanji | Grammar | Example sentences |',
      '|---|---:|---:|---:|---:|',
      for (final level in levels.values)
        '| ${level.level} | ${level.distinctVocab} | '
            '${level.distinctKanji} | '
            '${level.distinctGrammarPoints} | '
            '${level.exampleSentences} |',
    ].join('\n');
  }
}

class ContentScopeLevelReport {
  const ContentScopeLevelReport({
    required this.level,
    required this.distinctVocab,
    required this.distinctKanji,
    required this.distinctGrammarPoints,
    required this.exampleSentences,
  });

  const ContentScopeLevelReport.empty(this.level)
    : distinctVocab = 0,
      distinctKanji = 0,
      distinctGrammarPoints = 0,
      exampleSentences = 0;

  final String level;
  final int distinctVocab;
  final int distinctKanji;
  final int distinctGrammarPoints;
  final int exampleSentences;
}

class _MutableContentScope {
  _MutableContentScope(this.level);

  final String level;
  final vocab = <String>{};
  final kanji = <String>{};
  final grammar = <String>{};
  var examples = 0;

  ContentScopeLevelReport toReport() {
    return ContentScopeLevelReport(
      level: level,
      distinctVocab: vocab.length,
      distinctKanji: kanji.length,
      distinctGrammarPoints: grammar.length,
      exampleSentences: examples,
    );
  }
}

void _readVocab(
  Object? decoded,
  Map<String, _MutableContentScope> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is! Map || decoded['entries'] is! List) return;
  for (final entry in decoded['entries'] as List) {
    if (entry is! Map) continue;
    final map = Map<String, Object?>.from(entry);
    final lemma = map['lemma'] is Map
        ? Map<String, Object?>.from(map['lemma'] as Map)
        : const <String, Object?>{};
    final term = _stringValue(lemma['term']);
    if (term == null || term.isEmpty) continue;
    final level = _stringValue(map['level']) ?? _stringValue(decoded['level']);
    _bucket(buckets, level ?? fallbackLevel).vocab.add(term);
  }
}

void _readKanji(
  Object? decoded,
  Map<String, _MutableContentScope> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is! Map || decoded['entries'] is! List) return;
  for (final entry in decoded['entries'] as List) {
    if (entry is! Map) continue;
    final map = Map<String, Object?>.from(entry);
    final character = _stringValue(map['character']);
    if (character == null || character.isEmpty) continue;
    final level = _stringValue(map['level']) ?? _stringValue(decoded['level']);
    _bucket(buckets, level ?? fallbackLevel).kanji.add(character);
  }
}

void _readGrammar(
  Object? decoded,
  Map<String, _MutableContentScope> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is! List) return;
  for (final entry in decoded) {
    if (entry is! Map) continue;
    final map = Map<String, Object?>.from(entry);
    final title = _stringValue(map['title']);
    if (title == null || title.isEmpty) continue;
    final level = _stringValue(map['level']) ?? fallbackLevel;
    _bucket(buckets, level).grammar.add(_grammarKey(title));
  }
}

void _readGrammarExamples(
  Object? decoded,
  Map<String, _MutableContentScope> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is List) {
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final examples = entry['examples'] is List
          ? entry['examples'] as List
          : const <Object?>[];
      _bucket(buckets, fallbackLevel).examples += examples.length;
    }
    return;
  }
  if (decoded is Map && decoded['examples'] is List) {
    final level = _stringValue(decoded['level']) ?? fallbackLevel;
    _bucket(buckets, level).examples += (decoded['examples'] as List).length;
  }
}

_MutableContentScope _bucket(
  Map<String, _MutableContentScope> buckets,
  String level,
) {
  return buckets.putIfAbsent(level, () => _MutableContentScope(level));
}

String _datasetFromPath(String path) {
  final segments = path.split('/');
  final contentIndex = segments.lastIndexOf('content');
  return contentIndex >= 0 && contentIndex + 1 < segments.length
      ? segments[contentIndex + 1]
      : 'unknown';
}

String _levelFromPath(String path) {
  final segment = path
      .split('/')
      .firstWhere(
        (part) => RegExp(r'^n[1-5]$', caseSensitive: false).hasMatch(part),
        orElse: () => 'unknown',
      );
  return segment == 'unknown' ? segment : segment.toUpperCase();
}

String? _stringValue(Object? value) => value is String ? value : null;

String _grammarKey(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
}
