import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jpstudy/features/write/services/handwriting_evaluator.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

Future<void> main() async {
  await runHandwritingMeasurementAudit();
}

Future<Map<String, dynamic>> runHandwritingMeasurementAudit({
  String inputPath = 'tooling/handwriting_audit_cases.v4.json',
  String outputPath = 'docs/reports/handwriting-measurement-audit-report.json',
  String templatePath = 'assets/data/support/kanji/stroke_templates.json',
  bool showGuide = false,
}) async {
  final options = _AuditOptions(
    inputPath: inputPath,
    outputPath: outputPath,
    templatePath: templatePath,
    showGuide: showGuide,
  );
  final sampleSet = _SampleSet.load(options.inputPath);
  final templates = _TemplateCatalog.load(options.templatePath);

  final evaluator = _MeasurementAuditRunner(
    sampleSet: sampleSet,
    templates: templates,
    showGuide: options.showGuide,
  );

  final report = evaluator.run();
  final outputFile = File(options.outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(report),
  );

  final markdownFile = File(_markdownPathFor(outputFile.path));
  markdownFile.parent.createSync(recursive: true);
  markdownFile.writeAsStringSync(_buildMarkdownSummary(report));

  stdout.writeln(
    'Wrote handwriting audit report to ${outputFile.path} '
    '(${report['summary']['sampleCount']} cases).',
  );
  stdout.writeln('Wrote handwriting audit summary to ${markdownFile.path}.');

  return report;
}

String _markdownPathFor(String jsonPath) {
  if (jsonPath.toLowerCase().endsWith('.json')) {
    return '${jsonPath.substring(0, jsonPath.length - 5)}.md';
  }
  return '$jsonPath.md';
}

String _buildMarkdownSummary(Map<String, dynamic> report) {
  final summary = report['summary'] as Map<String, dynamic>? ?? const {};
  final cases = (report['cases'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
  final failedCases = cases
      .where((caseReport) => caseReport['passed'] != true)
      .toList(growable: false);
  final topFailureBuckets =
      (summary['topFailureBuckets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final caseCountByExpectedBucket =
      (summary['caseCountByExpectedBucket'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final passRateByExpectedBucket =
      (summary['passRateByExpectedBucket'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final caseCountBySourceLesson =
      (summary['caseCountBySourceLesson'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final passRateBySourceLesson =
      (summary['passRateBySourceLesson'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final caseCountByGeneratorKind =
      (summary['caseCountByGeneratorKind'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final passRateByGeneratorKind =
      (summary['passRateByGeneratorKind'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final generatorKindMatrix =
      (summary['generatorKindMatrix'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
  final buffer = StringBuffer()
    ..writeln('# Handwriting Measurement Audit Summary')
    ..writeln()
    ..writeln('- Sample set: `${report['sampleSetVersion'] ?? 'unknown'}`')
    ..writeln(
      '- Generated at (UTC): `${report['generatedAtUtc'] ?? 'unknown'}`',
    )
    ..writeln('- Scoring version: `${report['scoringVersion'] ?? 'unknown'}`')
    ..writeln(
      '- Template dataset: `${report['templateDatasetVersion'] ?? 'unknown'}`',
    )
    ..writeln('- Samples: `${summary['sampleCount'] ?? 0}`')
    ..writeln(
      '- False positives: `${summary['falsePositiveCount'] ?? 0}` (${_formatRate(summary['falsePositiveRate'])})',
    )
    ..writeln(
      '- False negatives: `${summary['falseNegativeCount'] ?? 0}` (${_formatRate(summary['falseNegativeRate'])})',
    )
    ..writeln()
    ..writeln('## Pass Rates by Mode')
    ..writeln()
    ..writeln('| Mode | Pass Rate |')
    ..writeln('| --- | ---: |');

  final passRateByMode =
      (summary['passRateByMode'] as Map<String, dynamic>? ?? const {});
  for (final entry in passRateByMode.entries) {
    buffer.writeln(
      '| `${_escapeMarkdown(entry.key)}` | ${_formatRate(entry.value)} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Pass Rates by Level')
    ..writeln()
    ..writeln('| Level | Pass Rate |')
    ..writeln('| --- | ---: |');

  final passRateByLevel =
      (summary['passRateByLevel'] as Map<String, dynamic>? ?? const {});
  for (final entry in passRateByLevel.entries) {
    buffer.writeln(
      '| `${_escapeMarkdown(entry.key)}` | ${_formatRate(entry.value)} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Expected Buckets')
    ..writeln();
  if (caseCountByExpectedBucket.isEmpty) {
    buffer.writeln('- None');
  } else {
    buffer
      ..writeln('| Expected Bucket | Cases | Pass Rate |')
      ..writeln('| --- | ---: | ---: |');
    for (final bucket in caseCountByExpectedBucket) {
      final passRate = passRateByExpectedBucket.firstWhere(
        (entry) => entry['bucket'] == bucket['bucket'],
        orElse: () => const {'bucket': 'unknown', 'passRate': null},
      );
      buffer.writeln(
        '| `${_escapeMarkdown(bucket['bucket']?.toString() ?? 'unknown')}` | '
        '${bucket['count'] ?? 0} | ${_formatRate(passRate['passRate'])} |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Top Failure Buckets')
    ..writeln();
  if (topFailureBuckets.isEmpty) {
    buffer.writeln('- None');
  } else {
    for (final bucket in topFailureBuckets) {
      buffer.writeln(
        '- `${bucket['bucket'] ?? 'unknown'}`: ${bucket['count'] ?? 0}',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Failed Cases')
    ..writeln();
  if (failedCases.isEmpty) {
    buffer.writeln('- None');
  } else {
    buffer
      ..writeln('| Case | Word | Expected | Actual | Bucket | Score | Source |')
      ..writeln('| --- | --- | --- | --- | --- | ---: | --- |');
    for (final caseReport in failedCases) {
      final metadata =
          (caseReport['metadata'] as Map<String, dynamic>? ?? const {});
      final word =
          metadata['word'] ??
          (caseReport['kanjiIds'] as List<dynamic>? ?? const []).join('');
      final source =
          metadata['sourceSenseId'] ?? metadata['sourceVocabId'] ?? 'n/a';
      final score = caseReport['score'];
      buffer.writeln(
        '| `${_escapeMarkdown(caseReport['id']?.toString() ?? 'unknown')}` | '
        '${_escapeMarkdown(word.toString())} | '
        '`${_escapeMarkdown(caseReport['expectedVerdict']?.toString() ?? 'unknown')}` | '
        '`${_escapeMarkdown(caseReport['actualVerdict']?.toString() ?? 'unknown')}` | '
        '`${_escapeMarkdown(caseReport['likelyFailureBucket']?.toString() ?? 'unknown')}` | '
        '${score is num ? score.toStringAsFixed(3) : 'n/a'} | '
        '`${_escapeMarkdown(source.toString())}` |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Generator Kinds')
    ..writeln();
  if (caseCountByGeneratorKind.isEmpty) {
    buffer.writeln('- None');
  } else {
    buffer
      ..writeln('| Generator Kind | Cases | Pass Rate |')
      ..writeln('| --- | ---: | ---: |');
    for (final generator in caseCountByGeneratorKind) {
      final passRate = passRateByGeneratorKind.firstWhere(
        (entry) => entry['generatorKind'] == generator['generatorKind'],
        orElse: () => const {'generatorKind': 'unknown', 'passRate': null},
      );
      buffer.writeln(
        '| `${_escapeMarkdown(generator['generatorKind']?.toString() ?? 'unknown')}` | '
        '${generator['count'] ?? 0} | ${_formatRate(passRate['passRate'])} |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Generator Kind Matrix')
    ..writeln();
  if (generatorKindMatrix.isEmpty) {
    buffer.writeln('- None');
  } else {
    buffer
      ..writeln('| Generator Kind | Expected Bucket | Cases | Pass Rate |')
      ..writeln('| --- | --- | ---: | ---: |');
    for (final row in generatorKindMatrix) {
      buffer.writeln(
        '| `${_escapeMarkdown(row['generatorKind']?.toString() ?? 'unknown')}` | '
        '`${_escapeMarkdown(row['expectedBucket']?.toString() ?? 'unknown')}` | '
        '${row['count'] ?? 0} | ${_formatRate(row['passRate'])} |',
      );
    }
  }

  buffer
    ..writeln()
    ..writeln('## Source Lessons')
    ..writeln();
  if (caseCountBySourceLesson.isEmpty) {
    buffer.writeln('- None');
  } else {
    buffer
      ..writeln('| Source Lesson | Cases | Pass Rate |')
      ..writeln('| --- | ---: | ---: |');
    for (final lesson in caseCountBySourceLesson) {
      final passRate = passRateBySourceLesson.firstWhere(
        (entry) => entry['sourceLesson'] == lesson['sourceLesson'],
        orElse: () => const {'sourceLesson': 'unknown', 'passRate': null},
      );
      buffer.writeln(
        '| `${_escapeMarkdown(lesson['sourceLesson']?.toString() ?? 'unknown')}` | '
        '${lesson['count'] ?? 0} | ${_formatRate(passRate['passRate'])} |',
      );
    }
  }

  return buffer.toString();
}

String _formatRate(Object? value) {
  if (value is num) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  return 'n/a';
}

String _escapeMarkdown(String value) {
  return value
      .replaceAll('|', r'\|')
      .replaceAll('`', r'\`')
      .replaceAll('\n', ' ');
}

class _AuditOptions {
  const _AuditOptions({
    required this.inputPath,
    required this.outputPath,
    required this.templatePath,
    required this.showGuide,
  });

  final String inputPath;
  final String outputPath;
  final String templatePath;
  final bool showGuide;
}

class _SampleSet {
  const _SampleSet({
    required this.version,
    required this.canvasSize,
    required this.cases,
  });

  final String version;
  final Size canvasSize;
  final List<_AuditCase> cases;

  static _SampleSet load(String path) {
    final decoded =
        jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
    final canvas = decoded['canvas'] as Map<String, dynamic>;
    return _SampleSet(
      version: decoded['version'] as String,
      canvasSize: Size(
        (canvas['width'] as num).toDouble(),
        (canvas['height'] as num).toDouble(),
      ),
      cases: (decoded['cases'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_AuditCase.fromJson)
          .toList(growable: false),
    );
  }
}

class _AuditCase {
  const _AuditCase({
    required this.id,
    required this.sessionMode,
    required this.targetType,
    required this.level,
    required this.characters,
    required this.expectedVerdict,
    required this.expectedFailureBucket,
    required this.generator,
    required this.metadata,
  });

  final String id;
  final String sessionMode;
  final String targetType;
  final String level;
  final List<String> characters;
  final String expectedVerdict;
  final String expectedFailureBucket;
  final _GeneratorSpec generator;
  final Map<String, dynamic> metadata;

  static _AuditCase fromJson(Map<String, dynamic> json) {
    return _AuditCase(
      id: json['id'] as String,
      sessionMode: json['sessionMode'] as String,
      targetType: json['targetType'] as String,
      level: json['level'] as String,
      characters: (json['characters'] as List<dynamic>).cast<String>(),
      expectedVerdict: json['expectedVerdict'] as String,
      expectedFailureBucket: json['expectedFailureBucket'] as String,
      generator: _GeneratorSpec.fromJson(
        json['generator'] as Map<String, dynamic>,
      ),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
}

class _GeneratorSpec {
  const _GeneratorSpec({
    required this.kind,
    this.seed = 0,
    this.jitter = 0,
    this.characterIndex,
    this.noiseCount,
  });

  final String kind;
  final int seed;
  final double jitter;
  final int? characterIndex;
  final int? noiseCount;

  static _GeneratorSpec fromJson(Map<String, dynamic> json) {
    return _GeneratorSpec(
      kind: json['kind'] as String,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      jitter: (json['jitter'] as num?)?.toDouble() ?? 0,
      characterIndex: (json['characterIndex'] as num?)?.toInt(),
      noiseCount: (json['noiseCount'] as num?)?.toInt(),
    );
  }
}

class _TemplateCatalog {
  const _TemplateCatalog({required this.entries, required this.datasetVersion});

  final Map<String, _TemplateEntry> entries;
  final String datasetVersion;

  static _TemplateCatalog load(String path) {
    final file = File(path);
    final raw = file.readAsStringSync();
    final decoded = (jsonDecode(raw) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final entries = <String, _TemplateEntry>{};
    for (final row in decoded) {
      final character = row['character'] as String;
      entries[character] = _TemplateEntry(
        level: (row['level'] as String?) ?? 'UNK',
        quality: (row['quality'] as String?) ?? 'manual',
        template: KanjiStrokeTemplate.fromJson(row),
      );
    }
    final stat = file.statSync();
    return _TemplateCatalog(
      entries: entries,
      datasetVersion: '${stat.size}-${stat.modified.toUtc().toIso8601String()}',
    );
  }
}

class _TemplateEntry {
  const _TemplateEntry({
    required this.level,
    required this.quality,
    required this.template,
  });

  final String level;
  final String quality;
  final KanjiStrokeTemplate template;
}

class _MeasurementAuditRunner {
  const _MeasurementAuditRunner({
    required this.sampleSet,
    required this.templates,
    required this.showGuide,
  });

  final _SampleSet sampleSet;
  final _TemplateCatalog templates;
  final bool showGuide;

  Map<String, dynamic> run() {
    final caseReports = <Map<String, dynamic>>[];
    var falsePositives = 0;
    var falseNegatives = 0;
    final passByMode = <String, List<bool>>{};
    final passByLevel = <String, List<bool>>{};
    final passByExpectedBucket = <String, List<bool>>{};
    final passBySourceLesson = <String, List<bool>>{};
    final passByGeneratorKind = <String, List<bool>>{};
    final passByGeneratorExpectedBucket = <String, List<bool>>{};
    final failureBuckets = <String, int>{};

    for (final auditCase in sampleSet.cases) {
      final report = _runCase(auditCase);
      caseReports.add(report);

      final passed = report['passed'] as bool;
      passByMode.putIfAbsent(auditCase.sessionMode, () => <bool>[]).add(passed);
      passByLevel.putIfAbsent(auditCase.level, () => <bool>[]).add(passed);
      passByExpectedBucket
          .putIfAbsent(auditCase.expectedFailureBucket, () => <bool>[])
          .add(passed);
      final sourceLesson = _sourceLessonKey(auditCase.metadata);
      passBySourceLesson.putIfAbsent(sourceLesson, () => <bool>[]).add(passed);
      final generatorKind = auditCase.generator.kind;
      passByGeneratorKind
          .putIfAbsent(generatorKind, () => <bool>[])
          .add(passed);
      final generatorExpectedBucketKey =
          '${auditCase.generator.kind}::${auditCase.expectedFailureBucket}';
      passByGeneratorExpectedBucket
          .putIfAbsent(generatorExpectedBucketKey, () => <bool>[])
          .add(passed);

      if (!passed) {
        final bucket = report['likelyFailureBucket'] as String;
        failureBuckets[bucket] = (failureBuckets[bucket] ?? 0) + 1;
        if (auditCase.expectedVerdict == 'reject') {
          falsePositives += 1;
        } else {
          falseNegatives += 1;
        }
      }
    }

    return {
      'sampleSetVersion': sampleSet.version,
      'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'scoringVersion': HandwritingScoringVersion.v2.name,
      'showGuide': showGuide,
      'templateDatasetVersion': templates.datasetVersion,
      'summary': {
        'sampleCount': caseReports.length,
        'falsePositiveCount': falsePositives,
        'falseNegativeCount': falseNegatives,
        'falsePositiveRate': _rate(
          falsePositives,
          sampleSet.cases.where((c) => c.expectedVerdict == 'reject').length,
        ),
        'falseNegativeRate': _rate(
          falseNegatives,
          sampleSet.cases.where((c) => c.expectedVerdict == 'accept').length,
        ),
        'passRateByMode': {
          for (final entry in passByMode.entries)
            entry.key: _rate(
              entry.value.where((v) => v).length,
              entry.value.length,
            ),
        },
        'passRateByLevel': {
          for (final entry in passByLevel.entries)
            entry.key: _rate(
              entry.value.where((v) => v).length,
              entry.value.length,
            ),
        },
        'caseCountByExpectedBucket': _countSummary(
          passByExpectedBucket,
          keyName: 'bucket',
        ),
        'passRateByExpectedBucket': _rateSummary(
          passByExpectedBucket,
          keyName: 'bucket',
        ),
        'caseCountBySourceLesson': _countSummary(
          passBySourceLesson,
          keyName: 'sourceLesson',
          numericSort: true,
        ),
        'passRateBySourceLesson': _rateSummary(
          passBySourceLesson,
          keyName: 'sourceLesson',
          numericSort: true,
        ),
        'caseCountByGeneratorKind': _countSummary(
          passByGeneratorKind,
          keyName: 'generatorKind',
        ),
        'passRateByGeneratorKind': _rateSummary(
          passByGeneratorKind,
          keyName: 'generatorKind',
        ),
        'generatorKindMatrix': _matrixSummary(passByGeneratorExpectedBucket),
        'topFailureBuckets': [
          for (final entry
              in (failureBuckets.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value))))
            {'bucket': entry.key, 'count': entry.value},
        ],
      },
      'cases': caseReports,
    };
  }

  String _sourceLessonKey(Map<String, dynamic> metadata) {
    final value = metadata['sourceLessonId'];
    if (value is int) {
      return value.toString();
    }
    if (value is num) {
      return value.toInt().toString();
    }
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? 'unknown' : text;
  }

  Map<String, dynamic> _runCase(_AuditCase auditCase) {
    final selected = auditCase.characters
        .map((char) => MapEntry(char, templates.entries[char]))
        .toList(growable: false);
    final missing = [
      for (final entry in selected)
        if (entry.value == null) entry.key,
    ];

    if (missing.isNotEmpty) {
      return {
        'id': auditCase.id,
        'promptId': auditCase.id,
        'kanjiIds': auditCase.characters,
        'sessionMode': auditCase.sessionMode,
        'targetType': auditCase.targetType,
        'level': auditCase.level,
        'expectedVerdict': auditCase.expectedVerdict,
        'actualVerdict': 'reject',
        'passed': auditCase.expectedVerdict == 'reject',
        'templateVersion': templates.datasetVersion,
        'scoringVersion': HandwritingScoringVersion.v2.name,
        'likelyFailureBucket': 'template',
        'missingTemplates': missing,
        if (auditCase.metadata.isNotEmpty) 'metadata': auditCase.metadata,
      };
    }

    final templateEntries = selected
        .map((entry) => entry.value!)
        .toList(growable: false);
    final strokes = _buildStrokes(auditCase, templateEntries);

    final result = auditCase.targetType == 'compound'
        ? _evaluateCompound(
            strokes,
            templateEntries.map((e) => e.template).toList(growable: false),
            sampleSet.canvasSize,
          )
        : HandwritingEvaluator.evaluate(
            strokes: strokes,
            expectedStrokes: templateEntries.first.template.strokes.length,
            canvasSize: sampleSet.canvasSize,
            showGuide: showGuide,
            template: templateEntries.first.template,
            scoringVersion: HandwritingScoringVersion.v2,
          );

    final actualVerdict = result.isCorrect ? 'accept' : 'reject';
    final passed = actualVerdict == auditCase.expectedVerdict;
    return {
      'id': auditCase.id,
      'promptId': auditCase.id,
      'kanjiIds': auditCase.characters,
      'sessionMode': auditCase.sessionMode,
      'targetType': auditCase.targetType,
      'level': auditCase.level,
      'expectedVerdict': auditCase.expectedVerdict,
      'actualVerdict': actualVerdict,
      'passed': passed,
      'templateVersion': templates.datasetVersion,
      'scoringVersion': HandwritingScoringVersion.v2.name,
      'templateQuality': result.templateQuality,
      'score': result.score,
      'strokeScore': result.strokeScore,
      'shapeScore': result.shapeScore,
      'orderScore': result.orderScore,
      'templateScore': result.templateScore,
      'expectedStrokes': result.expectedStrokes,
      'drawnStrokes': result.drawnStrokes,
      'likelyFailureBucket': _classifyFailureBucket(auditCase, result, passed),
      if (auditCase.metadata.isNotEmpty) 'metadata': auditCase.metadata,
      'characterResults': [
        for (final charResult in result.characterResults)
          {
            'character': charResult.character,
            'expectedStrokes': charResult.expectedStrokes,
            'drawnStrokes': charResult.drawnStrokes,
            'score': charResult.score,
            'isCorrect': charResult.isCorrect,
          },
      ],
    };
  }

  List<List<Offset>> _buildStrokes(
    _AuditCase auditCase,
    List<_TemplateEntry> templatesForCase,
  ) {
    final kind = auditCase.generator.kind;
    if (kind == 'noise_random') {
      return _randomNoise(
        count: auditCase.generator.noiseCount ?? 6,
        width: sampleSet.canvasSize.width,
        height: sampleSet.canvasSize.height,
        seed: auditCase.generator.seed,
      );
    }

    final base = auditCase.targetType == 'compound'
        ? _buildCompoundBase(
            templatesForCase.map((e) => e.template).toList(growable: false),
            jitter: auditCase.generator.jitter,
            seed: auditCase.generator.seed,
          )
        : _buildSingleBase(
            templatesForCase.first.template,
            width: sampleSet.canvasSize.width,
            height: sampleSet.canvasSize.height,
            jitter: auditCase.generator.jitter,
            seed: auditCase.generator.seed,
          );

    switch (kind) {
      case 'template_match':
        return base;
      case 'reverse_all':
        return [
          for (final stroke in base) stroke.reversed.toList(growable: false),
        ];
      case 'mirror_horizontal':
        return _mirrorCompoundOrSingle(
          auditCase,
          base,
          templatesForCase.length,
        );
      case 'missing_last':
        return base.sublist(0, max(1, base.length - 1));
      case 'extra_stroke':
        return [
          ...base,
          _linePath(
            const Offset(24, 24),
            Offset(
              sampleSet.canvasSize.width - 24,
              sampleSet.canvasSize.height - 24,
            ),
          ),
        ];
      case 'reverse_character':
        return _reverseCharacter(auditCase, base, templatesForCase);
      default:
        throw UnsupportedError('Unknown generator kind: $kind');
    }
  }

  List<List<Offset>> _buildSingleBase(
    KanjiStrokeTemplate template, {
    required double width,
    required double height,
    required double jitter,
    required int seed,
  }) {
    final random = Random(seed);
    return [
      for (final stroke in template.strokes)
        _linePath(
          _mapPoint(stroke.start, width: width, height: height),
          _mapPoint(stroke.end, width: width, height: height),
          jitter: jitter,
          random: random,
        ),
    ];
  }

  List<List<Offset>> _buildCompoundBase(
    List<KanjiStrokeTemplate> templates, {
    required double jitter,
    required int seed,
  }) {
    final slotCount = max(1, templates.length);
    final slotWidth = sampleSet.canvasSize.width / slotCount;
    final random = Random(seed);
    final strokes = <List<Offset>>[];
    for (var index = 0; index < templates.length; index++) {
      final template = templates[index];
      final offsetX = slotWidth * index;
      for (final stroke in template.strokes) {
        final local = _linePath(
          _mapPoint(
            stroke.start,
            width: slotWidth,
            height: sampleSet.canvasSize.height,
          ),
          _mapPoint(
            stroke.end,
            width: slotWidth,
            height: sampleSet.canvasSize.height,
          ),
          jitter: jitter,
          random: random,
        );
        strokes.add([
          for (final point in local) Offset(point.dx + offsetX, point.dy),
        ]);
      }
    }
    return strokes;
  }

  List<List<Offset>> _mirrorCompoundOrSingle(
    _AuditCase auditCase,
    List<List<Offset>> base,
    int slotCount,
  ) {
    if (auditCase.targetType != 'compound') {
      return [
        for (final stroke in base)
          [
            for (final point in stroke)
              Offset(sampleSet.canvasSize.width - point.dx, point.dy),
          ],
      ];
    }

    final slotWidth = sampleSet.canvasSize.width / max(1, slotCount);
    final mirrored = <List<Offset>>[];
    var cursor = 0;
    for (var i = 0; i < slotCount; i++) {
      final offsetX = slotWidth * i;
      final segment = <List<Offset>>[];
      while (cursor < base.length) {
        final stroke = base[cursor];
        final firstX = stroke.first.dx;
        if (firstX < offsetX || firstX >= offsetX + slotWidth) {
          break;
        }
        segment.add(stroke);
        cursor += 1;
      }
      mirrored.addAll([
        for (final stroke in segment)
          [
            for (final point in stroke)
              Offset(offsetX + (slotWidth - (point.dx - offsetX)), point.dy),
          ],
      ]);
    }
    return mirrored;
  }

  List<List<Offset>> _reverseCharacter(
    _AuditCase auditCase,
    List<List<Offset>> base,
    List<_TemplateEntry> templateEntries,
  ) {
    final targetIndex = auditCase.generator.characterIndex ?? 0;
    final result = <List<Offset>>[];
    var cursor = 0;
    for (var i = 0; i < templateEntries.length; i++) {
      final strokeCount = templateEntries[i].template.strokes.length;
      final segment = base.sublist(cursor, cursor + strokeCount);
      cursor += strokeCount;
      if (i == targetIndex) {
        result.addAll([
          for (final stroke in segment) stroke.reversed.toList(growable: false),
        ]);
      } else {
        result.addAll(segment.map((stroke) => [...stroke]));
      }
    }
    return result;
  }

  HandwritingEvaluationResult _evaluateCompound(
    List<List<Offset>> strokes,
    List<KanjiStrokeTemplate> templatesForCase,
    Size canvasSize,
  ) {
    final meaningfulStrokes = strokes
        .where((stroke) => stroke.length > 1)
        .toList();
    final expectedTotal = templatesForCase.fold<int>(
      0,
      (sum, template) => sum + template.strokes.length,
    );
    final drawnStrokes = meaningfulStrokes.length;
    final slotCount = max(1, templatesForCase.length);
    final slotWidth = canvasSize.width / slotCount;
    final slotSize = Size(slotWidth, canvasSize.height);

    var strokeCursor = 0;
    var weightedShape = 0.0;
    var weightedOrder = 0.0;
    var weightedTemplate = 0.0;
    var usedTemplate = false;
    var characterCount = 0;
    var correctCharacters = 0;
    final templateQualities = <String>{};
    final characterResults = <HandwritingCharacterResult>[];

    for (var i = 0; i < templatesForCase.length; i++) {
      final template = templatesForCase[i];
      final expected = template.strokes.length;
      final available = meaningfulStrokes.length - strokeCursor;
      final segmentCount = available <= 0 ? 0 : min(expected, available);
      final segment = segmentCount <= 0
          ? const <List<Offset>>[]
          : meaningfulStrokes.sublist(
              strokeCursor,
              strokeCursor + segmentCount,
            );
      strokeCursor += expected;
      final local = [
        for (final stroke in segment)
          [
            for (final point in stroke)
              Offset(point.dx - (slotWidth * i), point.dy),
          ],
      ];
      final result = HandwritingEvaluator.evaluate(
        strokes: local,
        expectedStrokes: expected,
        canvasSize: slotSize,
        showGuide: showGuide,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );

      final weight = expected / max(1, expectedTotal);
      weightedShape += result.shapeScore * weight;
      weightedOrder += result.orderScore * weight;
      weightedTemplate += result.templateScore * weight;
      if (result.usedTemplate) {
        usedTemplate = true;
        templateQualities.add(result.templateQuality);
      }
      if (result.isCorrect) {
        correctCharacters += 1;
      }
      characterCount += 1;
      characterResults.add(
        HandwritingCharacterResult(
          character: template.character,
          expectedStrokes: expected,
          drawnStrokes: result.drawnStrokes,
          score: result.score,
          isCorrect: result.isCorrect,
        ),
      );
    }

    final strokeDelta = (drawnStrokes - expectedTotal).abs().toDouble();
    final tolerance = HandwritingEvaluator.strokeToleranceForExpectedCount(
      expectedTotal,
    );
    final strokeScore = HandwritingEvaluator.strokeScoreForCounts(
      drawnStrokes: drawnStrokes,
      expectedStrokes: expectedTotal,
    );
    final shapeScore = weightedShape.clamp(0.0, 1.0);
    final orderScore = weightedOrder.clamp(0.0, 1.0);
    final templateScore = weightedTemplate.clamp(0.0, 1.0);
    final totalScore = usedTemplate
        ? ((strokeScore * 0.32) +
                  (shapeScore * 0.23) +
                  (orderScore * 0.17) +
                  (templateScore * 0.28))
              .clamp(0.0, 1.0)
        : ((strokeScore * 0.40) + (shapeScore * 0.35) + (orderScore * 0.25))
              .clamp(0.0, 1.0);
    final requiredScore = showGuide ? 0.58 : 0.68;
    final maxStrokeDelta = tolerance + max(0, templatesForCase.length - 1);
    final charPassRatio = characterCount == 0
        ? 0.0
        : (correctCharacters / characterCount);
    final isCorrect =
        totalScore >= requiredScore &&
        strokeDelta <= maxStrokeDelta &&
        charPassRatio >= 0.6;

    return HandwritingEvaluationResult(
      expectedStrokes: expectedTotal,
      drawnStrokes: drawnStrokes,
      score: totalScore,
      strokeScore: strokeScore,
      shapeScore: shapeScore,
      orderScore: orderScore,
      templateScore: templateScore,
      usedTemplate: usedTemplate,
      templateQuality: !usedTemplate
          ? 'none'
          : (templateQualities.length == 1 ? templateQualities.first : 'mixed'),
      isCorrect: isCorrect,
      characterResults: characterResults,
    );
  }

  String _classifyFailureBucket(
    _AuditCase auditCase,
    HandwritingEvaluationResult result,
    bool passed,
  ) {
    if (passed) {
      return 'none';
    }
    if (auditCase.expectedVerdict == 'reject') {
      return auditCase.expectedFailureBucket;
    }
    if (!result.usedTemplate || result.templateQuality == 'none') {
      return 'template';
    }
    if (result.templateScore < 0.45 ||
        result.orderScore < 0.45 ||
        result.shapeScore < 0.45) {
      return 'normalization';
    }
    return 'threshold';
  }
}

List<Map<String, dynamic>> _matrixSummary(Map<String, List<bool>> grouped) {
  final entries = grouped.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return [
    for (final entry in entries)
      {
        'generatorKind': entry.key.split('::').first,
        'expectedBucket': entry.key.split('::').skip(1).join('::'),
        'count': entry.value.length,
        'passRate': _rate(
          entry.value.where((value) => value).length,
          entry.value.length,
        ),
      },
  ];
}

List<Map<String, dynamic>> _countSummary(
  Map<String, List<bool>> grouped, {
  required String keyName,
  bool numericSort = false,
}) {
  final entries = grouped.entries.toList();
  _sortSummaryEntries(entries, numericSort: numericSort);
  return [
    for (final entry in entries)
      {keyName: entry.key, 'count': entry.value.length},
  ];
}

List<Map<String, dynamic>> _rateSummary(
  Map<String, List<bool>> grouped, {
  required String keyName,
  bool numericSort = false,
}) {
  final entries = grouped.entries.toList();
  _sortSummaryEntries(entries, numericSort: numericSort);
  return [
    for (final entry in entries)
      {
        keyName: entry.key,
        'passRate': _rate(
          entry.value.where((value) => value).length,
          entry.value.length,
        ),
      },
  ];
}

void _sortSummaryEntries(
  List<MapEntry<String, List<bool>>> entries, {
  required bool numericSort,
}) {
  entries.sort((a, b) {
    if (numericSort) {
      final left = int.tryParse(a.key);
      final right = int.tryParse(b.key);
      if (left != null && right != null) {
        return left.compareTo(right);
      }
      if (left != null) return -1;
      if (right != null) return 1;
    }
    return a.key.compareTo(b.key);
  });
}

double _rate(int numerator, int denominator) {
  if (denominator == 0) {
    return 0;
  }
  return numerator / denominator;
}

Offset _mapPoint(
  Point<double> point, {
  required double width,
  required double height,
}) {
  final marginX = width * 0.09;
  final marginY = height * 0.09;
  final usableWidth = width - (marginX * 2);
  final usableHeight = height - (marginY * 2);
  return Offset(
    marginX + (point.x.clamp(0.0, 1.0) * usableWidth),
    marginY + (point.y.clamp(0.0, 1.0) * usableHeight),
  );
}

List<Offset> _linePath(
  Offset start,
  Offset end, {
  int points = 9,
  double jitter = 0,
  Random? random,
}) {
  return List<Offset>.generate(points, (i) {
    final t = points <= 1 ? 1.0 : i / (points - 1);
    final point = Offset(
      start.dx + ((end.dx - start.dx) * t),
      start.dy + ((end.dy - start.dy) * t),
    );
    if (jitter <= 0 || random == null) {
      return point;
    }
    return Offset(
      point.dx + ((random.nextDouble() * 2 - 1) * jitter),
      point.dy + ((random.nextDouble() * 2 - 1) * jitter),
    );
  });
}

List<List<Offset>> _randomNoise({
  required int count,
  required double width,
  required double height,
  required int seed,
}) {
  final random = Random(seed);
  return List<List<Offset>>.generate(count, (_) {
    final pointCount = 4 + random.nextInt(4);
    return List<Offset>.generate(
      pointCount,
      (_) => Offset(
        18 + (random.nextDouble() * max(1, width - 36)),
        18 + (random.nextDouble() * max(1, height - 36)),
      ),
    );
  });
}
