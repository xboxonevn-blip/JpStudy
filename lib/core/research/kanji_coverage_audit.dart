import 'dart:convert';
import 'dart:io';

class KanjiCoverageAuditRunner {
  const KanjiCoverageAuditRunner._();

  static Future<KanjiCoverageAuditReport> run({
    required Directory contentRoot,
    required File kanjidic2Xml,
  }) async {
    final source = _parseKanjidic2(kanjidic2Xml);
    final current = _parseCurrentKanji(contentRoot);
    final levels = <String, KanjiCoverageLevelReport>{};

    for (final level in const ['N5', 'N4', 'N3', 'N2', 'N1']) {
      final currentByLevel =
          current[level] ?? const <String, CurrentKanjiEntry>{};
      final sourceByLevel =
          source.byLevel[level] ?? const <String, Kanjidic2Entry>{};
      final missing =
          sourceByLevel.keys
              .where((character) => !currentByLevel.containsKey(character))
              .toList()
            ..sort();
      final incomplete =
          currentByLevel.values
              .where((entry) => entry.missingFields.isNotEmpty)
              .toList()
            ..sort((a, b) => a.character.compareTo(b.character));
      levels[level] = KanjiCoverageLevelReport(
        level: level,
        currentUnique: currentByLevel.length,
        sourceUnique: sourceByLevel.length,
        missingCharacters: missing,
        missingCompleteness: incomplete,
      );
    }

    return KanjiCoverageAuditReport(
      currentUniqueTotal: current.values
          .expand((entries) => entries.keys)
          .toSet()
          .length,
      sourceUniqueTotal: source.byLevel.values
          .expand((entries) => entries.keys)
          .toSet()
          .length,
      levels: levels,
    );
  }
}

class KanjiCoverageAuditReport {
  const KanjiCoverageAuditReport({
    required this.currentUniqueTotal,
    required this.sourceUniqueTotal,
    required this.levels,
  });

  final int currentUniqueTotal;
  final int sourceUniqueTotal;
  final Map<String, KanjiCoverageLevelReport> levels;

  String toMarkdown({
    required String contentRoot,
    required String kanjidic2Xml,
    int sampleSize = 20,
  }) {
    final lines = <String>[
      '# Kanji Expansion Coverage Audit',
      '',
      'Content root: `$contentRoot`',
      'KANJIDIC2 XML: `$kanjidic2Xml`',
      '',
      'Note: KANJIDIC2 exposes the pre-2010 JLPT tiers (`1`-`4`). '
          'This audit maps `4 -> N5`, `3 -> N4`, `2 -> N2/old`, '
          '`1 -> N1`; it does not pretend to solve the modern N3/N2 split.',
      '',
      '| Metric | Count |',
      '|---|---:|',
      '| Current unique kanji | $currentUniqueTotal |',
      '| KANJIDIC2 old-JLPT unique kanji | $sourceUniqueTotal |',
      '',
      '| Level | Current unique | Source unique | Missing from app | Incomplete current |',
      '|---|---:|---:|---:|---:|',
      for (final level in levels.values)
        '| ${level.level} | ${level.currentUnique} | ${level.sourceUnique} | '
            '${level.missingCharacters.length} | '
            '${level.missingCompleteness.length} |',
      '',
      '## Missing Source Kanji Samples',
      '',
    ];

    for (final level in levels.values) {
      final sample = level.missingCharacters.take(sampleSize).join(' ');
      lines.add('- ${level.level}: ${sample.isEmpty ? 'none' : sample}');
    }

    lines.addAll(['', '## Incomplete Current Kanji Samples', '']);
    for (final level in levels.values) {
      final sample = level.missingCompleteness
          .take(sampleSize)
          .map(
            (entry) => '${entry.character}(${entry.missingFields.join('+')})',
          )
          .join(', ');
      lines.add('- ${level.level}: ${sample.isEmpty ? 'none' : sample}');
    }

    return lines.join('\n');
  }
}

class KanjiCoverageLevelReport {
  const KanjiCoverageLevelReport({
    required this.level,
    required this.currentUnique,
    required this.sourceUnique,
    required this.missingCharacters,
    required this.missingCompleteness,
  });

  final String level;
  final int currentUnique;
  final int sourceUnique;
  final List<String> missingCharacters;
  final List<CurrentKanjiEntry> missingCompleteness;
}

class CurrentKanjiEntry {
  const CurrentKanjiEntry({
    required this.level,
    required this.character,
    required this.missingFields,
  });

  final String level;
  final String character;
  final List<String> missingFields;
}

class Kanjidic2Entry {
  const Kanjidic2Entry({
    required this.character,
    required this.oldJlpt,
    required this.strokeCount,
    required this.hanViet,
    required this.onyomi,
    required this.kunyomi,
    required this.meaningsEn,
  });

  final String character;
  final int oldJlpt;
  final int? strokeCount;
  final String? hanViet;
  final List<String> onyomi;
  final List<String> kunyomi;
  final List<String> meaningsEn;
}

class _Kanjidic2Index {
  const _Kanjidic2Index(this.byLevel);

  final Map<String, Map<String, Kanjidic2Entry>> byLevel;
}

_Kanjidic2Index _parseKanjidic2(File file) {
  final xml = file.readAsStringSync();
  final byLevel = <String, Map<String, Kanjidic2Entry>>{
    for (final level in const ['N5', 'N4', 'N3', 'N2', 'N1'])
      level: <String, Kanjidic2Entry>{},
  };
  final characterBlocks = RegExp(
    r'<character>([\s\S]*?)</character>',
  ).allMatches(xml);

  for (final match in characterBlocks) {
    final block = match.group(1)!;
    final character = _firstText(block, 'literal');
    final oldJlpt = int.tryParse(_firstText(block, 'jlpt') ?? '');
    if (character == null || oldJlpt == null) continue;
    final level = _levelForOldJlpt(oldJlpt);
    if (level == null) continue;
    byLevel[level]![character] = Kanjidic2Entry(
      character: character,
      oldJlpt: oldJlpt,
      strokeCount: int.tryParse(_firstText(block, 'stroke_count') ?? ''),
      hanViet: _firstReading(block, 'vietnam'),
      onyomi: _readings(block, 'ja_on'),
      kunyomi: _readings(block, 'ja_kun'),
      meaningsEn: RegExp(
        r'<meaning>([^<]+)</meaning>',
      ).allMatches(block).map((m) => _decodeXml(m.group(1)!)).toList(),
    );
  }

  return _Kanjidic2Index(byLevel);
}

Map<String, Map<String, CurrentKanjiEntry>> _parseCurrentKanji(
  Directory contentRoot,
) {
  final byLevel = <String, Map<String, CurrentKanjiEntry>>{};
  final kanjiRoot = Directory('${contentRoot.path}/kanji');
  if (!kanjiRoot.existsSync()) return byLevel;
  final files =
      kanjiRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final level = _levelFromPath(file);
    if (level == null) continue;
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map || decoded['entries'] is! List) continue;
    final levelEntries = byLevel.putIfAbsent(
      level,
      () => <String, CurrentKanjiEntry>{},
    );
    for (final rawEntry in decoded['entries'] as List) {
      if (rawEntry is! Map) continue;
      final entry = Map<String, Object?>.from(rawEntry);
      final character = _string(entry['character']);
      if (character == null || character.isEmpty) continue;
      levelEntries[character] = CurrentKanjiEntry(
        level: level,
        character: character,
        missingFields: _missingFields(entry),
      );
    }
  }

  return byLevel;
}

List<String> _missingFields(Map<String, Object?> entry) {
  final labels = _map(entry['labels']);
  final readings = _map(entry['readings']);
  final decomposition = _map(entry['decomposition']);
  final missing = <String>[];
  if (_blank(labels['hanViet'])) missing.add('hanViet');
  if (_blank(labels['meaningVi'])) missing.add('meaningVi');
  if (_blank(labels['meaningEn'])) missing.add('meaningEn');
  final onyomi = _stringList(readings['onyomi']);
  final kunyomi = _stringList(readings['kunyomi']);
  if (onyomi.isEmpty && kunyomi.isEmpty) missing.add('onyomi/kunyomi');
  final strokeCount = entry['strokeCount'];
  if (strokeCount is! int || strokeCount <= 0) missing.add('strokeCount');
  final examples = entry['examples'];
  if (examples is! List || examples.isEmpty) missing.add('examples');
  final related = _stringList(decomposition['relatedKanji']);
  if (related.isEmpty) missing.add('relatedKanji');
  return missing;
}

String? _levelForOldJlpt(int oldJlpt) => switch (oldJlpt) {
  4 => 'N5',
  3 => 'N4',
  2 => 'N2',
  1 => 'N1',
  _ => null,
};

String? _levelFromPath(File file) {
  final parts = file.path.replaceAll('\\', '/').split('/');
  final index = parts.indexOf('kanji');
  if (index == -1 || index + 1 >= parts.length) return null;
  final level = parts[index + 1].toUpperCase();
  return RegExp(r'^N[1-5]$').hasMatch(level) ? level : null;
}

String? _firstText(String source, String tag) {
  final match = RegExp('<$tag>([^<]+)</$tag>').firstMatch(source);
  return match == null ? null : _decodeXml(match.group(1)!);
}

String? _firstReading(String source, String type) {
  final match = RegExp(
    '<reading r_type="$type">([^<]+)</reading>',
  ).firstMatch(source);
  return match == null ? null : _decodeXml(match.group(1)!);
}

List<String> _readings(String source, String type) => RegExp(
  '<reading r_type="$type">([^<]+)</reading>',
).allMatches(source).map((m) => _decodeXml(m.group(1)!)).toList();

Map<String, Object?> _map(Object? value) =>
    value is Map ? Map<String, Object?>.from(value) : const {};

List<String> _stringList(Object? value) => value is List
    ? value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList()
    : const [];

String? _string(Object? value) => value is String ? value.trim() : null;

bool _blank(Object? value) => value is! String || value.trim().isEmpty;

String _decodeXml(String value) => value
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'");
