import 'dart:io';
import 'dart:math' as math;

class VietnameseTypographyAuditRunner {
  const VietnameseTypographyAuditRunner._();

  static VietnameseTypographyAuditReport scan({
    required File appLanguageFile,
    required Directory libRoot,
    int sampleSize = 100,
    int seed = 20260514,
  }) {
    final candidates = <VietnameseTypographyCandidate>[
      ..._scanAppLanguageViStrings(appLanguageFile),
      ..._scanHardcodedDartStrings(libRoot, excludedFile: appLanguageFile),
    ]..sort(_compareCandidate);
    final sampled = _fixedSeedSample(
      candidates,
      sampleSize: sampleSize,
      seed: seed,
    );
    return VietnameseTypographyAuditReport(
      candidates: candidates,
      sample: sampled,
      requestedSampleSize: sampleSize,
      seed: seed,
    );
  }
}

class VietnameseTypographyAuditReport {
  const VietnameseTypographyAuditReport({
    required this.candidates,
    required this.sample,
    required this.requestedSampleSize,
    required this.seed,
  });

  final List<VietnameseTypographyCandidate> candidates;
  final List<VietnameseTypographyCandidate> sample;
  final int requestedSampleSize;
  final int seed;

  double get averageScore {
    if (sample.isEmpty) return 0;
    final total = sample.fold<int>(
      0,
      (sum, candidate) => sum + candidate.score,
    );
    return total / sample.length;
  }

  Map<String, int> get issueCounts {
    final counts = <String, int>{};
    for (final candidate in sample) {
      for (final issue in candidate.issues) {
        counts.update(issue.code, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }

  String toMarkdown({
    required String appLanguagePath,
    required String libRootPath,
  }) {
    final issues = issueCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.compareTo(b.key);
      });
    return [
      '# Vietnamese Typography Audit',
      '',
      'App language: `$appLanguagePath`',
      'Lib root: `$libRootPath`',
      'Seed: `$seed`',
      '',
      '| Metric | Value |',
      '|---|---:|',
      '| Total candidates | ${candidates.length} |',
      '| Requested sample size | $requestedSampleSize |',
      '| Sample size | ${sample.length} |',
      '| Average score | ${averageScore.toStringAsFixed(2)} |',
      '',
      '| Issue | Count |',
      '|---|---:|',
      for (final entry in issues)
        '| ${_issueLabel(entry.key)} | ${entry.value} |',
      '',
      '| # | Score | Issues | Source | Text |',
      '|---:|---:|---|---|---|',
      for (var i = 0; i < sample.length; i++)
        '| ${i + 1} | ${sample[i].score} | ${_formatIssues(sample[i])} | ${sample[i].filePath}:${sample[i].lineNumber} | ${_escapeMarkdown(sample[i].text)} |',
    ].join('\n');
  }
}

class VietnameseTypographyCandidate {
  VietnameseTypographyCandidate({
    required this.root,
    required this.filePath,
    required this.lineNumber,
    required this.text,
    required this.source,
  }) : issues = _issuesFor(text),
       score = _scoreFor(_issuesFor(text));

  final String root;
  final String filePath;
  final int lineNumber;
  final String text;
  final String source;
  final List<VietnameseTypographyIssue> issues;
  final int score;
}

class VietnameseTypographyIssue {
  const VietnameseTypographyIssue(this.code);

  final String code;
}

List<VietnameseTypographyCandidate> _scanAppLanguageViStrings(File file) {
  if (!file.existsSync()) return const [];
  final hits = <VietnameseTypographyCandidate>[];
  final lines = file.readAsLinesSync();
  String? currentLocale;
  final casePattern = RegExp(r'case AppLanguage\.(en|vi|ja):');

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final caseMatch = casePattern.firstMatch(line);
    if (caseMatch != null) {
      currentLocale = caseMatch.group(1);
      continue;
    }
    if (line.contains('AppLanguage.vi =>')) {
      for (final text in _stringLiterals(line)) {
        _addCandidateIfVietnamese(
          hits,
          file,
          index,
          text,
          source: 'app_language_switch_expression',
        );
      }
      continue;
    }
    if (currentLocale != 'vi' || !line.contains('return')) continue;
    for (final text in _stringLiterals(line)) {
      _addCandidateIfVietnamese(
        hits,
        file,
        index,
        text,
        source: 'app_language_return',
      );
    }
    currentLocale = null;
  }
  return hits;
}

List<VietnameseTypographyCandidate> _scanHardcodedDartStrings(
  Directory root, {
  required File excludedFile,
}) {
  if (!root.existsSync()) return const [];
  final excludedPath = _normalizePath(excludedFile.path);
  final hits = <VietnameseTypographyCandidate>[];
  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final path = _normalizePath(file.path);
    if (path == excludedPath || path.endsWith('/core/app_language.dart')) {
      continue;
    }
    if (path.contains('/core/research/')) continue;
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      for (final text in _stringLiterals(lines[index])) {
        _addCandidateIfVietnamese(
          hits,
          file,
          index,
          text,
          source: 'hardcoded_dart_string',
        );
      }
    }
  }
  return hits;
}

void _addCandidateIfVietnamese(
  List<VietnameseTypographyCandidate> hits,
  File file,
  int index,
  String text, {
  required String source,
}) {
  if (!_vietnamesePattern.hasMatch(text)) return;
  hits.add(
    VietnameseTypographyCandidate(
      root: 'lib',
      filePath: _normalizePath(file.path),
      lineNumber: index + 1,
      text: text,
      source: source,
    ),
  );
}

List<String> _stringLiterals(String line) {
  final values = <String>[];
  for (final match in _singleQuotedPattern.allMatches(line)) {
    values.add(_unescape(match.group(1) ?? ''));
  }
  for (final match in _doubleQuotedPattern.allMatches(line)) {
    values.add(_unescape(match.group(1) ?? ''));
  }
  return values;
}

List<VietnameseTypographyCandidate> _fixedSeedSample(
  List<VietnameseTypographyCandidate> candidates, {
  required int sampleSize,
  required int seed,
}) {
  final sorted = candidates.toList()
    ..sort((a, b) {
      final aHash = _stableHash(
        '${a.filePath}:${a.lineNumber}:${a.text}',
        seed,
      );
      final bHash = _stableHash(
        '${b.filePath}:${b.lineNumber}:${b.text}',
        seed,
      );
      final byHash = aHash.compareTo(bHash);
      if (byHash != 0) return byHash;
      return _compareCandidate(a, b);
    });
  return sorted.take(math.max(0, sampleSize)).toList();
}

List<VietnameseTypographyIssue> _issuesFor(String text) {
  final visibleText = _visibleTextApproximation(text);
  final issues = <VietnameseTypographyIssue>[];
  if (_questionMarkMojibakePattern.hasMatch(visibleText)) {
    issues.add(const VietnameseTypographyIssue('question_mark_mojibake'));
  }
  if (visibleText.contains('...')) {
    issues.add(const VietnameseTypographyIssue('ascii_ellipsis'));
  }
  if (_spaceBeforePunctuationPattern.hasMatch(visibleText)) {
    issues.add(const VietnameseTypographyIssue('space_before_punctuation'));
  }
  if (visibleText.contains('--')) {
    issues.add(const VietnameseTypographyIssue('ascii_dash'));
  }
  if (_toneVariantPattern.hasMatch(visibleText)) {
    issues.add(const VietnameseTypographyIssue('tone_variant_review'));
  }
  if (_rawEnglishTermPattern.hasMatch(visibleText)) {
    issues.add(const VietnameseTypographyIssue('raw_english_term'));
  }
  return issues;
}

int _scoreFor(List<VietnameseTypographyIssue> issues) {
  var score = 5;
  for (final issue in issues) {
    score -= switch (issue.code) {
      'question_mark_mojibake' => 3,
      'raw_english_term' => 2,
      _ => 1,
    };
  }
  return math.max(1, score);
}

int _compareCandidate(
  VietnameseTypographyCandidate a,
  VietnameseTypographyCandidate b,
) {
  final byFile = a.filePath.compareTo(b.filePath);
  if (byFile != 0) return byFile;
  final byLine = a.lineNumber.compareTo(b.lineNumber);
  if (byLine != 0) return byLine;
  return a.text.compareTo(b.text);
}

int _stableHash(String value, int seed) {
  var hash = 0x811c9dc5 ^ seed;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

String _unescape(String text) {
  return text
      .replaceAll(r"\'", "'")
      .replaceAll(r'\"', '"')
      .replaceAll(r'\n', ' ')
      .replaceAll(r'\r', ' ')
      .replaceAll(r'\t', ' ');
}

String _formatIssues(VietnameseTypographyCandidate candidate) {
  if (candidate.issues.isEmpty) return 'none';
  return candidate.issues.map((issue) => _issueLabel(issue.code)).join(', ');
}

String _issueLabel(String code) {
  return switch (code) {
    'question_mark_mojibake' => 'question-mark mojibake',
    'ascii_ellipsis' => 'ASCII ellipsis',
    'space_before_punctuation' => 'space before punctuation',
    'ascii_dash' => 'ASCII dash',
    'tone_variant_review' => 'tone variant review',
    'raw_english_term' => 'raw English term',
    _ => code,
  };
}

String _escapeMarkdown(String text) => text.replaceAll('|', r'\|');

String _normalizePath(String path) => path.replaceAll('\\', '/');

String _visibleTextApproximation(String text) {
  return text.replaceAll(RegExp(r'\$\{[^}]*\}'), '0');
}

final _singleQuotedPattern = RegExp(r"'((?:\\.|[^'])*)'");
final _doubleQuotedPattern = RegExp(r'"((?:\\.|[^"])*)"');
final _vietnamesePattern = RegExp(
  r'[ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠƯàáâãèéêìíòóôõùúăđĩũơưẠ-ỹ]',
);
final _questionMarkMojibakePattern = RegExp(r'[A-Za-zÀ-ỹ]\?[A-Za-zÀ-ỹ]');
final _spaceBeforePunctuationPattern = RegExp(r'\s+[,.!;:]');
final _toneVariantPattern = RegExp(
  r'\b(thuỷ|Thuỷ|huỷ|Huỷ|tuỳ|Tuỳ|uỷ|Uỷ|quí|Quí|qúy|Qúy)\b',
);
final _rawEnglishTermPattern = RegExp(
  r'\b(deck|quiz|review|lane|workspace|flow|prompt|recall|drill|flashcard|block|starter pack|custom)\b',
  caseSensitive: false,
);
