import 'dart:convert';
import 'dart:io';

class RadicalsHanVietAuditRunner {
  const RadicalsHanVietAuditRunner._();

  static Future<RadicalsHanVietAuditReport> run({
    required File radicalsFile,
    required File unihanReadings,
    int topLimit = 30,
  }) async {
    final unihan = _parseUnihanVietnamese(unihanReadings);
    final decoded = jsonDecode(await radicalsFile.readAsString());
    if (decoded is! List) {
      throw const FormatException('radicals file must contain a JSON list');
    }

    final rows = <RadicalAuditRow>[];
    for (final rawItem in decoded) {
      if (rawItem is! Map) continue;
      final item = Map<String, Object?>.from(rawItem);
      final id = _intValue(item['id']) ?? 0;
      final kanji = _stringValue(item['kanji']) ?? '';
      final display = _stringValue(item['vi_meaning']) ?? '';
      final raw = _stringValue(item['vi_meaning_raw']) ?? '';
      final parts = _displayParts(display);
      final unihanValues = unihan[kanji] ?? const <String>[];
      final status = _status(parts.head, display, unihanValues);
      final patterns = _patterns(
        head: parts.head,
        gloss: parts.gloss,
        raw: raw,
        display: display,
        unihanValues: unihanValues,
      );

      rows.add(
        RadicalAuditRow(
          id: id,
          kanji: kanji,
          display: display,
          raw: raw,
          localHead: parts.head,
          localGloss: parts.gloss,
          unihanVietnamese: unihanValues,
          status: status,
          patterns: patterns,
        ),
      );
    }

    rows.sort((a, b) => a.id.compareTo(b.id));
    final topCorrections = rows
        .where(
          (row) =>
              row.status == RadicalAuditStatus.mismatch ||
              row.status == RadicalAuditStatus.missing ||
              row.patterns.isNotEmpty,
        )
        .toList()
      ..sort((a, b) {
        final severity = _severity(a).compareTo(_severity(b));
        if (severity != 0) return severity;
        return a.id.compareTo(b.id);
      });

    return RadicalsHanVietAuditReport(
      rows: rows,
      topCorrections: topCorrections.take(topLimit).toList(growable: false),
    );
  }
}

class RadicalsHanVietAuditReport {
  const RadicalsHanVietAuditReport({
    required this.rows,
    required this.topCorrections,
  });

  final List<RadicalAuditRow> rows;
  final List<RadicalAuditRow> topCorrections;

  int get totalChecked => rows.length;
  int get exactMatches => _count(RadicalAuditStatus.exact);
  int get nearMatches => _count(RadicalAuditStatus.nearMatch);
  int get mismatches => _count(RadicalAuditStatus.mismatch);
  int get missing => _count(RadicalAuditStatus.missing);

  Map<String, int> get patterns {
    final counts = <String, int>{};
    for (final row in rows) {
      for (final pattern in row.patterns) {
        counts.update(pattern, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  String toMarkdown({
    required String radicalsPath,
    required String unihanReadingsPath,
  }) {
    final patternEntries = patterns.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });

    return [
      '# D2.Q2.7 Radicals Han-Viet Audit',
      '',
      'Radicals source: `$radicalsPath`',
      'Unihan readings: `$unihanReadingsPath`',
      '',
      'Status definitions: `exact` means the whole display equals Unihan `kVietnamese`; `near-match` means the leading Han-Viet label matches but the display also has a local gloss; `mismatch` means the leading label differs from Unihan; `missing` means either side is absent.',
      '',
      '| Metric | Count |',
      '|---|---:|',
      '| Total checked | $totalChecked |',
      '| Exact match | $exactMatches |',
      '| Near-match | $nearMatches |',
      '| Mismatch | $mismatches |',
      '| Missing | $missing |',
      '',
      '## Pattern Analysis',
      '',
      '| Pattern | Count |',
      '|---|---:|',
      if (patternEntries.isEmpty) '| none | 0 |',
      for (final entry in patternEntries) '| ${entry.key} | ${entry.value} |',
      '',
      '## Top Corrections',
      '',
      '| ID | Radical | Current display | Unihan kVietnamese | Status | Patterns |',
      '|---:|---|---|---|---|---|',
      for (final row in topCorrections)
        '| ${row.id} | ${row.kanji} | ${_escape(row.display)} | ${_escape(row.unihanVietnamese.join(', '))} | ${row.status.label} | ${row.patterns.join(', ')} |',
      '',
      '## Full Audit Rows',
      '',
      '| ID | Radical | Current display | Raw source | Unihan kVietnamese | Status |',
      '|---:|---|---|---|---|---|',
      for (final row in rows)
        '| ${row.id} | ${row.kanji} | ${_escape(row.display)} | ${_escape(row.raw)} | ${_escape(row.unihanVietnamese.join(', '))} | ${row.status.label} |',
      '',
    ].join('\n');
  }

  int _count(RadicalAuditStatus status) =>
      rows.where((row) => row.status == status).length;
}

class RadicalAuditRow {
  const RadicalAuditRow({
    required this.id,
    required this.kanji,
    required this.display,
    required this.raw,
    required this.localHead,
    required this.localGloss,
    required this.unihanVietnamese,
    required this.status,
    required this.patterns,
  });

  final int id;
  final String kanji;
  final String display;
  final String raw;
  final String localHead;
  final String localGloss;
  final List<String> unihanVietnamese;
  final RadicalAuditStatus status;
  final List<String> patterns;
}

enum RadicalAuditStatus {
  exact('exact'),
  nearMatch('near-match'),
  mismatch('mismatch'),
  missing('missing');

  const RadicalAuditStatus(this.label);

  final String label;
}

({String head, String gloss}) _displayParts(String display) {
  final parts = display.split('·');
  final head = parts.first.trim();
  final gloss = parts.length <= 1 ? '' : parts.skip(1).join('·').trim();
  return (head: head, gloss: gloss);
}

RadicalAuditStatus _status(
  String localHead,
  String display,
  List<String> unihanValues,
) {
  if (localHead.trim().isEmpty || unihanValues.isEmpty) {
    return RadicalAuditStatus.missing;
  }
  final normalizedDisplay = _normalize(display);
  if (unihanValues.any((value) => _normalize(value) == normalizedDisplay)) {
    return RadicalAuditStatus.exact;
  }
  final normalizedHead = _normalize(localHead);
  if (unihanValues.any((value) => _normalize(value) == normalizedHead)) {
    return RadicalAuditStatus.nearMatch;
  }
  return RadicalAuditStatus.mismatch;
}

List<String> _patterns({
  required String head,
  required String gloss,
  required String raw,
  required String display,
  required List<String> unihanValues,
}) {
  final patterns = <String>{};
  if (gloss.trim().isNotEmpty) {
    patterns.add('extra-gloss');
  }
  if (gloss.trim().isNotEmpty &&
      _containsToken(_normalizePlain(gloss), _normalizePlain(head))) {
    patterns.add('duplicate-gloss');
  }
  if (unihanValues.isNotEmpty &&
      unihanValues.any(
        (value) =>
            _normalizePlain(value) == _normalizePlain(head) &&
            _normalize(value) != _normalize(head),
      )) {
    patterns.add('tone-mark-delta');
  }
  if (RegExp(r'[�ÃÄÅÆÐÑØÙÞß]').hasMatch(display)) {
    patterns.add('mojibake');
  }
  if (raw.isNotEmpty && RegExp(r'^[\x00-\x7F]+$').hasMatch(raw)) {
    patterns.add('ascii-raw-source');
  }
  return patterns.toList()..sort();
}

bool _containsToken(String text, String token) {
  if (token.isEmpty) return false;
  final tokens = text.split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty);
  return tokens.contains(token);
}

Map<String, List<String>> _parseUnihanVietnamese(File file) {
  final values = <String, List<String>>{};
  for (final line in file.readAsLinesSync()) {
    if (line.isEmpty || line.startsWith('#')) continue;
    final parts = line.split('\t');
    if (parts.length != 3 || parts[1] != 'kVietnamese') continue;
    final codepoint = int.tryParse(parts[0].replaceFirst('U+', ''), radix: 16);
    if (codepoint == null) continue;
    final character = String.fromCharCode(codepoint);
    final readings = parts[2]
        .split(RegExp(r'\s+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (readings.isNotEmpty) values[character] = readings;
  }
  return values;
}

int? _intValue(Object? value) => value is int ? value : null;

String? _stringValue(Object? value) => value is String ? value : null;

String _normalize(String value) =>
    value.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

String _normalizePlain(String value) {
  const from =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const to =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  final lower = _normalize(value);
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer.toString();
}

int _severity(RadicalAuditRow row) {
  if (row.status == RadicalAuditStatus.mismatch) return 0;
  if (row.status == RadicalAuditStatus.missing) return 1;
  if (row.patterns.contains('mojibake')) return 2;
  if (row.patterns.contains('duplicate-gloss')) return 3;
  return 4;
}

String _escape(String value) => value.replaceAll('|', r'\|');
