import 'dart:convert';
import 'dart:io';

class ContentLinkGraphBuilder {
  const ContentLinkGraphBuilder._();

  static ContentLinkGraphReport scan(Directory contentRoot) {
    final buckets = <String, _MutableLinkLevel>{};
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
      for (final entry in buckets.entries)
        entry.key: entry.value.toReport(
          cumulativeKanjiChars: _cumulativeKanjiChars(entry.key, buckets),
        ),
    };
    return ContentLinkGraphReport(levels: _sortLevels(levels));
  }

  static Map<String, ContentLinkLevelReport> _sortLevels(
    Map<String, ContentLinkLevelReport> levels,
  ) {
    final keys = levels.keys.toList()
      ..sort((a, b) => _levelSortKey(a).compareTo(_levelSortKey(b)));
    return {for (final key in keys) key: levels[key]!};
  }

  static String _levelSortKey(String value) =>
      RegExp(r'^N([1-5])$').firstMatch(value)?.group(1) ?? value;
}

class ContentLinkGraphReport {
  const ContentLinkGraphReport({required this.levels});

  final Map<String, ContentLinkLevelReport> levels;

  ContentLinkLevelReport level(String level) =>
      levels[level] ?? const ContentLinkLevelReport.empty('unknown');

  String toMarkdown({required String contentRoot}) {
    return [
      '# Content Link Graph Report',
      '',
      'Content root: `$contentRoot`',
      '',
      '## Vocab To Kanji Coverage',
      '',
      '| Level | Vocab | With kanji | Fully covered | Vocab kanji | Covered chars | Kanji chars |',
      '|---|---:|---:|---:|---:|---:|---:|',
      for (final level in levels.values)
        '| ${level.level} | ${level.vocabEntries} | '
            '${level.vocabEntriesWithKanji} | '
            '${level.vocabEntriesFullyCoveredByKanjiDataset} | '
            '${level.uniqueVocabKanji} | '
            '${level.vocabKanjiCharsCovered} | '
            '${level.uniqueKanjiDatasetChars} |',
      '',
      '## Cumulative Vocab To Kanji Coverage',
      '',
      '| Level | With kanji | Fully covered cumulative | Vocab kanji | Cumulative covered chars | Cumulative kanji chars |',
      '|---|---:|---:|---:|---:|---:|',
      for (final level in levels.values)
        '| ${level.level} | ${level.vocabEntriesWithKanji} | '
            '${level.vocabEntriesFullyCoveredByCumulativeKanjiDataset} | '
            '${level.uniqueVocabKanji} | '
            '${level.vocabKanjiCharsCoveredByCumulativeKanji} | '
            '${level.cumulativeKanjiDatasetChars} |',
      '',
      '## Kanji Example Links',
      '',
      '| Level | Kanji entries | Example words | Words in vocab | Example refs | Refs in vocab |',
      '|---|---:|---:|---:|---:|---:|',
      for (final level in levels.values)
        '| ${level.level} | ${level.kanjiEntries} | '
            '${level.kanjiExampleWords} | '
            '${level.kanjiExampleWordsFoundInVocab} | '
            '${level.kanjiExampleRefs} | '
            '${level.kanjiExampleRefsFoundInVocab} |',
      '',
      '## Grammar Example Links',
      '',
      '| Level | Grammar points | Example groups | Matched groups | Sentences |',
      '|---|---:|---:|---:|---:|',
      for (final level in levels.values)
        '| ${level.level} | ${level.grammarPoints} | '
            '${level.grammarExampleGroups} | '
            '${level.grammarExampleGroupsMatchedToPoint} | '
            '${level.grammarExampleSentences} |',
    ].join('\n');
  }
}

class ContentLinkLevelReport {
  const ContentLinkLevelReport({
    required this.level,
    required this.vocabEntries,
    required this.vocabEntriesWithKanji,
    required this.vocabEntriesFullyCoveredByKanjiDataset,
    required this.vocabEntriesFullyCoveredByCumulativeKanjiDataset,
    required this.uniqueVocabKanji,
    required this.uniqueKanjiDatasetChars,
    required this.cumulativeKanjiDatasetChars,
    required this.vocabKanjiCharsCovered,
    required this.vocabKanjiCharsCoveredByCumulativeKanji,
    required this.kanjiEntries,
    required this.kanjiExampleWords,
    required this.kanjiExampleWordsFoundInVocab,
    required this.kanjiExampleRefs,
    required this.kanjiExampleRefsFoundInVocab,
    required this.grammarPoints,
    required this.grammarExampleGroups,
    required this.grammarExampleGroupsMatchedToPoint,
    required this.grammarExampleSentences,
  });

  const ContentLinkLevelReport.empty(this.level)
    : vocabEntries = 0,
      vocabEntriesWithKanji = 0,
      vocabEntriesFullyCoveredByKanjiDataset = 0,
      vocabEntriesFullyCoveredByCumulativeKanjiDataset = 0,
      uniqueVocabKanji = 0,
      uniqueKanjiDatasetChars = 0,
      cumulativeKanjiDatasetChars = 0,
      vocabKanjiCharsCovered = 0,
      vocabKanjiCharsCoveredByCumulativeKanji = 0,
      kanjiEntries = 0,
      kanjiExampleWords = 0,
      kanjiExampleWordsFoundInVocab = 0,
      kanjiExampleRefs = 0,
      kanjiExampleRefsFoundInVocab = 0,
      grammarPoints = 0,
      grammarExampleGroups = 0,
      grammarExampleGroupsMatchedToPoint = 0,
      grammarExampleSentences = 0;

  final String level;
  final int vocabEntries;
  final int vocabEntriesWithKanji;
  final int vocabEntriesFullyCoveredByKanjiDataset;
  final int vocabEntriesFullyCoveredByCumulativeKanjiDataset;
  final int uniqueVocabKanji;
  final int uniqueKanjiDatasetChars;
  final int cumulativeKanjiDatasetChars;
  final int vocabKanjiCharsCovered;
  final int vocabKanjiCharsCoveredByCumulativeKanji;
  final int kanjiEntries;
  final int kanjiExampleWords;
  final int kanjiExampleWordsFoundInVocab;
  final int kanjiExampleRefs;
  final int kanjiExampleRefsFoundInVocab;
  final int grammarPoints;
  final int grammarExampleGroups;
  final int grammarExampleGroupsMatchedToPoint;
  final int grammarExampleSentences;
}

class _MutableLinkLevel {
  _MutableLinkLevel(this.level);

  final String level;
  final vocabTerms = <String>{};
  final vocabIds = <String>{};
  final vocabEntryKanji = <Set<String>>[];
  final vocabKanji = <String>{};
  final kanjiChars = <String>{};
  final kanjiExampleWordsSet = <String>{};
  final kanjiExampleRefsSet = <String>{};
  final grammarPointKeys = <String>{};
  final grammarExampleGroupKeys = <String>[];
  var vocabEntries = 0;
  var vocabEntriesWithKanji = 0;
  var kanjiEntries = 0;
  var grammarExampleSentences = 0;

  void addVocabEntry({
    required String? term,
    required String? sourceVocabId,
    required Set<String> kanji,
  }) {
    vocabEntries += 1;
    if (term != null && term.isNotEmpty) vocabTerms.add(term);
    if (sourceVocabId != null && sourceVocabId.isNotEmpty) {
      vocabIds.add(sourceVocabId);
    }
    if (kanji.isNotEmpty) {
      vocabEntriesWithKanji += 1;
      vocabEntryKanji.add(kanji);
      vocabKanji.addAll(kanji);
    }
  }

  void addKanjiEntry(
    String? character,
    Iterable<String> exampleWords,
    Iterable<String> exampleRefs,
  ) {
    kanjiEntries += 1;
    if (character != null && character.isNotEmpty) kanjiChars.add(character);
    kanjiExampleWordsSet.addAll(exampleWords.where((word) => word.isNotEmpty));
    kanjiExampleRefsSet.addAll(exampleRefs.where((ref) => ref.isNotEmpty));
  }

  void addGrammarPoint(String? title) {
    final key = _grammarKey(title);
    if (key.isNotEmpty) grammarPointKeys.add(key);
  }

  void addGrammarExampleGroup(String? grammarPoint, int sentenceCount) {
    final key = _grammarKey(grammarPoint);
    if (key.isNotEmpty) grammarExampleGroupKeys.add(key);
    grammarExampleSentences += sentenceCount;
  }

  ContentLinkLevelReport toReport({required Set<String> cumulativeKanjiChars}) {
    final fullyCoveredEntries = vocabEntryKanji
        .where((chars) => chars.every(kanjiChars.contains))
        .length;
    final cumulativeFullyCoveredEntries = vocabEntryKanji
        .where((chars) => chars.every(cumulativeKanjiChars.contains))
        .length;
    final coveredVocabChars = vocabKanji.where(kanjiChars.contains).length;
    final cumulativeCoveredVocabChars = vocabKanji
        .where(cumulativeKanjiChars.contains)
        .length;
    final linkedExampleWords = kanjiExampleWordsSet.where(vocabTerms.contains);
    final linkedExampleRefs = kanjiExampleRefsSet.where(vocabIds.contains);
    return ContentLinkLevelReport(
      level: level,
      vocabEntries: vocabEntries,
      vocabEntriesWithKanji: vocabEntriesWithKanji,
      vocabEntriesFullyCoveredByKanjiDataset: fullyCoveredEntries,
      vocabEntriesFullyCoveredByCumulativeKanjiDataset:
          cumulativeFullyCoveredEntries,
      uniqueVocabKanji: vocabKanji.length,
      uniqueKanjiDatasetChars: kanjiChars.length,
      cumulativeKanjiDatasetChars: cumulativeKanjiChars.length,
      vocabKanjiCharsCovered: coveredVocabChars,
      vocabKanjiCharsCoveredByCumulativeKanji: cumulativeCoveredVocabChars,
      kanjiEntries: kanjiEntries,
      kanjiExampleWords: kanjiExampleWordsSet.length,
      kanjiExampleWordsFoundInVocab: linkedExampleWords.length,
      kanjiExampleRefs: kanjiExampleRefsSet.length,
      kanjiExampleRefsFoundInVocab: linkedExampleRefs.length,
      grammarPoints: grammarPointKeys.length,
      grammarExampleGroups: grammarExampleGroupKeys.length,
      grammarExampleGroupsMatchedToPoint: grammarExampleGroupKeys
          .where(grammarPointKeys.contains)
          .length,
      grammarExampleSentences: grammarExampleSentences,
    );
  }
}

void _readVocab(
  Object? decoded,
  Map<String, _MutableLinkLevel> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is! Map || decoded['entries'] is! List) return;
  for (final entry in decoded['entries'] as List) {
    if (entry is! Map) continue;
    final map = Map<String, Object?>.from(entry);
    final lemma = map['lemma'] is Map
        ? Map<String, Object?>.from(map['lemma'] as Map)
        : const <String, Object?>{};
    final level = _stringValue(map['level']) ?? _stringValue(decoded['level']);
    final term = _stringValue(lemma['term']);
    final links = map['links'] is Map
        ? Map<String, Object?>.from(map['links'] as Map)
        : const <String, Object?>{};
    final kanji = _kanjiList(lemma['kanji']);
    if (kanji.isEmpty && term != null) kanji.addAll(_kanjiCharsIn(term));
    _bucket(buckets, level ?? fallbackLevel).addVocabEntry(
      term: term,
      sourceVocabId:
          _stringValue(lemma['vocabId']) ??
          _stringValue(links['sourceVocabId']),
      kanji: kanji,
    );
  }
}

Set<String> _cumulativeKanjiChars(
  String level,
  Map<String, _MutableLinkLevel> buckets,
) {
  final levelNumber = _jlptLevelNumber(level);
  if (levelNumber == null) return {...?buckets[level]?.kanjiChars};
  return {
    for (final entry in buckets.entries)
      if ((_jlptLevelNumber(entry.key) ?? -1) >= levelNumber)
        ...entry.value.kanjiChars,
  };
}

int? _jlptLevelNumber(String value) {
  final match = RegExp(r'^N([1-5])$').firstMatch(value);
  return match == null ? null : int.parse(match.group(1)!);
}

void _readKanji(
  Object? decoded,
  Map<String, _MutableLinkLevel> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is! Map || decoded['entries'] is! List) return;
  for (final entry in decoded['entries'] as List) {
    if (entry is! Map) continue;
    final map = Map<String, Object?>.from(entry);
    final level = _stringValue(map['level']) ?? _stringValue(decoded['level']);
    final examples = map['examples'] is List
        ? map['examples'] as List
        : const <Object?>[];
    final words = [
      for (final example in examples)
        if (example is Map && example['word'] is String)
          example['word'] as String,
    ];
    final refs = [
      for (final example in examples)
        if (example is Map && example['sourceVocabId'] is String)
          example['sourceVocabId'] as String,
    ];
    _bucket(
      buckets,
      level ?? fallbackLevel,
    ).addKanjiEntry(_stringValue(map['character']), words, refs);
  }
}

void _readGrammar(
  Object? decoded,
  Map<String, _MutableLinkLevel> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is! List) return;
  for (final entry in decoded) {
    if (entry is! Map) continue;
    final map = Map<String, Object?>.from(entry);
    final level = _stringValue(map['level']) ?? fallbackLevel;
    _bucket(buckets, level).addGrammarPoint(_stringValue(map['title']));
  }
}

void _readGrammarExamples(
  Object? decoded,
  Map<String, _MutableLinkLevel> buckets, {
  required String fallbackLevel,
}) {
  if (decoded is List) {
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final map = Map<String, Object?>.from(entry);
      final examples = map['examples'] is List
          ? map['examples'] as List
          : const <Object?>[];
      _bucket(buckets, fallbackLevel).addGrammarExampleGroup(
        _stringValue(map['grammarPoint']),
        examples.length,
      );
    }
    return;
  }
  if (decoded is Map && decoded['examples'] is List) {
    final level = _stringValue(decoded['level']) ?? fallbackLevel;
    for (final example in decoded['examples'] as List) {
      if (example is! Map) continue;
      final map = Map<String, Object?>.from(example);
      _bucket(
        buckets,
        level,
      ).addGrammarExampleGroup(_stringValue(map['grammarPoint']), 1);
    }
  }
}

_MutableLinkLevel _bucket(
  Map<String, _MutableLinkLevel> buckets,
  String level,
) {
  return buckets.putIfAbsent(level, () => _MutableLinkLevel(level));
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

Set<String> _kanjiList(Object? value) {
  if (value is! Iterable) return <String>{};
  return value.whereType<String>().where((char) => char.isNotEmpty).toSet();
}

Set<String> _kanjiCharsIn(String text) {
  return {
    for (final rune in text.runes)
      if (rune >= 0x4e00 && rune <= 0x9fff) String.fromCharCode(rune),
  };
}

String _grammarKey(String? value) {
  if (value == null) return '';
  return value.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
}
