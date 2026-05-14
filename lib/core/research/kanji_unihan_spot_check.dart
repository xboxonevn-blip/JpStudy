import 'dart:convert';
import 'dart:io';

class KanjiUnihanSpotCheckRunner {
  const KanjiUnihanSpotCheckRunner._();

  static Future<KanjiUnihanSpotCheckReport> run({
    required Directory contentRoot,
    required File unihanReadings,
    int sampleSize = 50,
    String seed = 'jpstudy-d2-q2.6-v1',
    List<String> levels = const ['N3', 'N2', 'N1'],
  }) async {
    final unihan = _parseUnihanVietnamese(unihanReadings);
    final levelSet = levels.map((level) => level.toUpperCase()).toSet();
    final candidates = <KanjiUnihanSpotCheckRow>[];

    for (final level in levelSet) {
      final dir = Directory('${contentRoot.path}/kanji/${level.toLowerCase()}');
      if (!dir.existsSync()) continue;
      final files =
          dir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      for (final file in files) {
        final decoded = jsonDecode(file.readAsStringSync());
        if (decoded is! Map || decoded['entries'] is! List) continue;
        for (final rawEntry in decoded['entries'] as List) {
          if (rawEntry is! Map) continue;
          final entry = Map<String, Object?>.from(rawEntry);
          final character = _stringValue(entry['character']);
          if (character == null || character.isEmpty) continue;
          final labels = entry['labels'] is Map
              ? Map<String, Object?>.from(entry['labels'] as Map)
              : const <String, Object?>{};
          final local = _stringValue(labels['hanViet']);
          final unihanValue = unihan[character];
          candidates.add(
            KanjiUnihanSpotCheckRow(
              level: _stringValue(entry['level']) ?? level,
              kanjiId: _stringValue(entry['kanjiId']) ?? '',
              character: character,
              localHanViet: local,
              unihanVietnamese: unihanValue,
              status: _status(local, unihanValue),
            ),
          );
        }
      }
    }

    candidates.sort((a, b) {
      final scoreA = _stableHash(
        '$seed|${a.level}|${a.kanjiId}|${a.character}',
      );
      final scoreB = _stableHash(
        '$seed|${b.level}|${b.kanjiId}|${b.character}',
      );
      final byScore = scoreA.compareTo(scoreB);
      if (byScore != 0) return byScore;
      final byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) return byLevel;
      return a.kanjiId.compareTo(b.kanjiId);
    });

    final sampled = candidates.take(sampleSize).toList();
    return KanjiUnihanSpotCheckReport(
      seed: seed,
      requestedSampleSize: sampleSize,
      totalCandidates: candidates.length,
      sampled: sampled,
    );
  }
}

class KanjiUnihanSpotCheckReport {
  const KanjiUnihanSpotCheckReport({
    required this.seed,
    required this.requestedSampleSize,
    required this.totalCandidates,
    required this.sampled,
  });

  final String seed;
  final int requestedSampleSize;
  final int totalCandidates;
  final List<KanjiUnihanSpotCheckRow> sampled;

  int get exactMatches => _count(KanjiUnihanSpotCheckStatus.match);
  int get mismatches => _count(KanjiUnihanSpotCheckStatus.mismatch);
  int get missingLocalHanViet =>
      _count(KanjiUnihanSpotCheckStatus.missingLocalHanViet);
  int get missingUnihanVietnamese =>
      _count(KanjiUnihanSpotCheckStatus.missingUnihanVietnamese);

  String toMarkdown({
    required String contentRoot,
    required String unihanReadings,
  }) {
    return [
      '# Kanji Unihan Spot Check',
      '',
      'Content root: `$contentRoot`',
      'Unihan readings: `$unihanReadings`',
      'Seed: `$seed`',
      'Requested sample size: `$requestedSampleSize`',
      'Total candidates: `$totalCandidates`',
      '',
      '| Metric | Count |',
      '|---|---:|',
      '| Sampled | ${sampled.length} |',
      '| Exact matches | $exactMatches |',
      '| Mismatches | $mismatches |',
      '| Missing local Han-Viet | $missingLocalHanViet |',
      '| Missing Unihan kVietnamese | $missingUnihanVietnamese |',
      '',
      '| Level | Kanji ID | Character | Local Han-Viet | Unihan kVietnamese | Status |',
      '|---|---|---|---|---|---|',
      for (final row in sampled)
        '| ${row.level} | ${row.kanjiId} | ${row.character} | '
            '${row.localHanViet ?? ''} | '
            '${row.unihanVietnamese ?? ''} | ${row.status.label} |',
    ].join('\n');
  }

  int _count(KanjiUnihanSpotCheckStatus status) =>
      sampled.where((row) => row.status == status).length;
}

class KanjiUnihanSpotCheckRow {
  const KanjiUnihanSpotCheckRow({
    required this.level,
    required this.kanjiId,
    required this.character,
    required this.localHanViet,
    required this.unihanVietnamese,
    required this.status,
  });

  final String level;
  final String kanjiId;
  final String character;
  final String? localHanViet;
  final String? unihanVietnamese;
  final KanjiUnihanSpotCheckStatus status;
}

enum KanjiUnihanSpotCheckStatus {
  match('match'),
  mismatch('mismatch'),
  missingLocalHanViet('missing-local-han-viet'),
  missingUnihanVietnamese('missing-unihan-kVietnamese');

  const KanjiUnihanSpotCheckStatus(this.label);

  final String label;
}

Map<String, String> _parseUnihanVietnamese(File file) {
  final values = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split('\t');
    if (parts.length != 3 || parts[1] != 'kVietnamese') continue;
    final codepoint = int.tryParse(parts[0].replaceFirst('U+', ''), radix: 16);
    if (codepoint == null) continue;
    values[String.fromCharCode(codepoint)] = parts[2].trim();
  }
  return values;
}

KanjiUnihanSpotCheckStatus _status(String? local, String? unihan) {
  if (local == null || local.trim().isEmpty) {
    return KanjiUnihanSpotCheckStatus.missingLocalHanViet;
  }
  if (unihan == null || unihan.trim().isEmpty) {
    return KanjiUnihanSpotCheckStatus.missingUnihanVietnamese;
  }
  return _normalize(local) == _normalize(unihan)
      ? KanjiUnihanSpotCheckStatus.match
      : KanjiUnihanSpotCheckStatus.mismatch;
}

String? _stringValue(Object? value) => value is String ? value : null;

String _normalize(String value) =>
    value.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

int _stableHash(String value) {
  var hash = 2166136261;
  for (var index = 0; index < value.length; index++) {
    hash ^= value.codeUnitAt(index);
    hash = (hash * 16777619) & 0xffffffff;
  }
  return hash;
}
