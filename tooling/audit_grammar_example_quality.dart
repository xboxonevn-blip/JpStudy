import 'dart:convert';
import 'dart:io';

import 'package:jpstudy/data/utils/grammar_example_quality.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

final _levels = <String>['n5', 'n4', 'n3'];

void main(List<String> args) {
  final root = Directory.fromUri(
    File(Platform.script.toFilePath()).parent.parent.uri,
  );
  final locale = _parseLocale(args);
  final reportPath = File(
    '${root.path}${Platform.pathSeparator}docs${Platform.pathSeparator}'
    'reports${Platform.pathSeparator}grammar-example-quality-report.json',
  );

  final blocks = <Map<String, Object?>>[];
  final summaryByLevel = <Map<String, Object?>>[];
  final flaggedBlocks = <Map<String, Object?>>[];

  for (final level in _levels) {
    final grammarDir = Directory(
      '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'data${Platform.pathSeparator}content${Platform.pathSeparator}'
      'grammar${Platform.pathSeparator}$level',
    );
    final exampleDir = Directory(
      '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'data${Platform.pathSeparator}content${Platform.pathSeparator}'
      'grammar_examples${Platform.pathSeparator}$level',
    );

    final grammarFiles = grammarDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList(growable: false);

    var levelScoreTotal = 0;
    var levelBlocks = 0;
    var blocksMissingContext = 0;
    var blocksMissingReplacement = 0;
    var blocksMissingTransformation = 0;
    var blocksWithExpectedMissing = 0;
    var blocksWithRealQualityGap = 0;
    var blocksMissingReplacementExpected = 0;
    var blocksMissingReplacementReal = 0;
    var blocksMissingTransformationExpected = 0;
    var blocksMissingTransformationReal = 0;

    for (final grammarFile in grammarFiles) {
      final lesson = _lessonNumberFromPath(grammarFile.path);
      final exampleFile = File(
        '${exampleDir.path}${Platform.pathSeparator}lesson_$lesson.json',
      );
      if (!exampleFile.existsSync()) continue;

      final definitions = _readJsonList(grammarFile);
      final exampleBlocks = _readJsonList(exampleFile);

      for (final block in exampleBlocks) {
        final blockLabel = '${block['grammarPoint'] ?? ''}'.trim();
        final definition = _matchDefinition(definitions, blockLabel);
        final rawPattern = resolveCanonicalGrammarPointSource(
          grammarPoint: definition?['grammarPoint']?.toString(),
          structure: definition?['structure']?.toString(),
          title: definition?['title']?.toString() ?? blockLabel,
          structureEn: definition?['structureEn']?.toString(),
          titleEn: definition?['titleEn']?.toString(),
        );
        final title = stripNonCanonicalGrammarNotes(
          '${definition?['title'] ?? blockLabel}'.trim(),
        );
        final examplesRaw = (block['examples'] as List<dynamic>? ?? const []);
        final examples = examplesRaw
            .whereType<Map>()
            .map(
              (item) => GrammarExampleSeedData(
                sentence: '${item['sentence'] ?? ''}'.trim(),
                translation: '${item['translation'] ?? ''}'.trim(),
                translationEn: item['translationEn']?.toString().trim(),
                translationVi: item['translationVi']?.toString().trim(),
              ),
            )
            .toList(growable: false);

        final quality = GrammarExampleQualityAssessor.assessBlock(
          grammarPoint: rawPattern,
          examples: examples,
          locale: locale,
        );

        final coverageCounts = {
          for (final entry in quality.coverageCounts.entries)
            entry.key.name: entry.value,
        };
        final priorityByQuestionType = {
          for (final kind in GrammarExampleQuestionKind.values)
            kind.name: quality
                .prioritizedFor(kind, limit: 3)
                .map((item) => item.example.sentence)
                .toList(growable: false),
        };

        final reasons = _classifyFlaggedReasons(
          grammarPoint: rawPattern,
          quality: quality,
        );
        final hasExpectedMissing = reasons.any(
          (reason) => reason['classification'] == 'expected-missing',
        );
        final hasRealQualityGap = reasons.any(
          (reason) => reason['classification'] == 'real-quality-gap',
        );

        if (reasons.isNotEmpty) {
          flaggedBlocks.add({
            'level': level.toUpperCase(),
            'lesson': lesson,
            'title': title,
            'grammarPoint': rawPattern,
            'blockScore': quality.blockScore,
            'hasExpectedMissing': hasExpectedMissing,
            'hasRealQualityGap': hasRealQualityGap,
            'reasons': reasons,
          });
        }

        if (hasExpectedMissing) {
          blocksWithExpectedMissing += 1;
        }
        if (hasRealQualityGap) {
          blocksWithRealQualityGap += 1;
        }

        if ((quality.coverageCounts[GrammarExampleQuestionKind.contextChoice] ??
                0) ==
            0) {
          blocksMissingContext += 1;
        }
        if ((quality.coverageCounts[GrammarExampleQuestionKind
                    .errorCorrection] ??
                0) ==
            0) {
          blocksMissingReplacement += 1;
          final replacementReason = reasons.firstWhere(
            (reason) => reason['code'] == 'missing_replacement_ready_examples',
            orElse: () => const <String, Object?>{},
          );
          if (replacementReason['classification'] == 'expected-missing') {
            blocksMissingReplacementExpected += 1;
          } else if (replacementReason['classification'] ==
              'real-quality-gap') {
            blocksMissingReplacementReal += 1;
          }
        }
        if ((quality.coverageCounts[GrammarExampleQuestionKind
                    .transformation] ??
                0) ==
            0) {
          blocksMissingTransformation += 1;
          final transformationReason = reasons.firstWhere(
            (reason) =>
                reason['code'] == 'missing_transformation_ready_examples',
            orElse: () => const <String, Object?>{},
          );
          if (transformationReason['classification'] == 'expected-missing') {
            blocksMissingTransformationExpected += 1;
          } else if (transformationReason['classification'] ==
              'real-quality-gap') {
            blocksMissingTransformationReal += 1;
          }
        }

        levelBlocks += 1;
        levelScoreTotal += quality.blockScore;

        blocks.add({
          'level': level.toUpperCase(),
          'lesson': lesson,
          'title': title,
          'grammarPoint': rawPattern,
          'blockLabel': blockLabel,
          'sourceFile': _relativePath(root, exampleFile),
          'locale': locale.name,
          'blockScore': quality.blockScore,
          'exampleCount': examples.length,
          'coverageCounts': coverageCounts,
          'priorityByQuestionType': priorityByQuestionType,
          'exampleAssessments': [
            for (final item in quality.examples)
              {
                'index': item.index,
                'sentence': item.example.sentence,
                'localizedPrompt': item.localizedPrompt,
                'surfaceFamily': item.surfaceFamily.name,
                'hasUsablePrompt': item.hasUsablePrompt,
                'overallScore': item.overallScore,
                'allowedQuestionTypes': item.supportedKinds(),
                'questionScores': {
                  for (final entry in item.questionScores.entries)
                    entry.key.name: entry.value,
                },
                'notes': item.notes,
              },
          ],
        });
      }
    }

    summaryByLevel.add({
      'level': level.toUpperCase(),
      'locale': locale.name,
      'blocks': levelBlocks,
      'averageBlockScore': levelBlocks == 0
          ? 0
          : double.parse((levelScoreTotal / levelBlocks).toStringAsFixed(2)),
      'blocksMissingContextChoice': blocksMissingContext,
      'blocksMissingReplacement': blocksMissingReplacement,
      'blocksMissingReplacementExpected': blocksMissingReplacementExpected,
      'blocksMissingReplacementReal': blocksMissingReplacementReal,
      'blocksMissingTransformation': blocksMissingTransformation,
      'blocksMissingTransformationExpected':
          blocksMissingTransformationExpected,
      'blocksMissingTransformationReal': blocksMissingTransformationReal,
      'blocksWithExpectedMissing': blocksWithExpectedMissing,
      'blocksWithRealQualityGap': blocksWithRealQualityGap,
    });
  }

  final report = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'locale': locale.name,
    'summaryByLevel': summaryByLevel,
    'flaggedBlocks': flaggedBlocks,
    'blocks': blocks,
  };

  reportPath.parent.createSync(recursive: true);
  reportPath.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(report)}\n',
  );
  stdout.writeln('Wrote ${_relativePath(root, reportPath)}');
}

List<Map<String, Object?>> _classifyFlaggedReasons({
  required String grammarPoint,
  required GrammarExampleBlockQualityAssessment quality,
}) {
  final reasons = <Map<String, Object?>>[];

  if ((quality.coverageCounts[GrammarExampleQuestionKind.contextChoice] ?? 0) ==
      0) {
    reasons.add({
      'code': 'missing_context_ready_examples',
      'classification': 'real-quality-gap',
      'questionType': GrammarExampleQuestionKind.contextChoice.name,
    });
  }

  if ((quality.coverageCounts[GrammarExampleQuestionKind.errorCorrection] ??
          0) ==
      0) {
    reasons.add({
      'code': 'missing_replacement_ready_examples',
      'classification': _isExpectedReplacementGap(grammarPoint, quality)
          ? 'expected-missing'
          : 'real-quality-gap',
      'questionType': GrammarExampleQuestionKind.errorCorrection.name,
    });
  }

  if ((quality.coverageCounts[GrammarExampleQuestionKind.transformation] ??
          0) ==
      0) {
    reasons.add({
      'code': 'missing_transformation_ready_examples',
      'classification': _isExpectedTransformationGap(grammarPoint, quality)
          ? 'expected-missing'
          : 'real-quality-gap',
      'questionType': GrammarExampleQuestionKind.transformation.name,
    });
  }

  if (quality.blockScore < 70) {
    reasons.add({
      'code': 'low_block_score',
      'classification': 'real-quality-gap',
    });
  }

  return reasons;
}

bool _isExpectedReplacementGap(
  String grammarPoint,
  GrammarExampleBlockQualityAssessment quality,
) {
  final normalizedPattern = grammarPoint.trim();
  if (normalizedPattern.isEmpty) {
    return false;
  }

  if (!GrammarExampleQualityAssessor.isEmbeddableSurfacePattern(
    normalizedPattern,
  )) {
    return true;
  }

  if (_patternMissingFromAllExamples(normalizedPattern, quality)) {
    return true;
  }

  if (GrammarExampleQualityAssessor.looksLikeExchangePrompt(
    normalizedPattern,
  )) {
    return true;
  }

  return quality.examples.every(
    (item) => item.surfaceFamily == GrammarExampleSurfaceFamily.dialogue,
  );
}

bool _isExpectedTransformationGap(
  String grammarPoint,
  GrammarExampleBlockQualityAssessment quality,
) {
  final normalizedPattern = grammarPoint.trim();
  if (_looksLikeExpectedTransformationPattern(normalizedPattern)) {
    return true;
  }

  if (normalizedPattern.isNotEmpty &&
      GrammarExampleQualityAssessor.looksLikeExchangePrompt(
        normalizedPattern,
      )) {
    return true;
  }

  final statementExamples = quality.examples
      .where((item) => item.surfaceFamily == GrammarExampleSurfaceFamily.statement)
      .toList(growable: false);
  if (statementExamples.isEmpty) {
    return true;
  }

  return statementExamples.every(
    (item) =>
        GrammarExampleQualityAssessor.isAlreadyNegativeStatement(
          item.example.sentence,
        ) ||
        _isRequestLikeStatement(item.example.sentence),
  );
}

bool _patternMissingFromAllExamples(
  String grammarPoint,
  GrammarExampleBlockQualityAssessment quality,
) {
  final normalizedPattern = grammarPoint.trim();
  if (normalizedPattern.isEmpty) return true;

  return quality.examples.every(
    (item) => !item.example.sentence.contains(normalizedPattern),
  );
}

bool _looksLikeExpectedTransformationPattern(String grammarPoint) {
  if (grammarPoint.isEmpty) return false;
  final normalized = grammarPoint.toLowerCase();
  const fragments = <String>[
    'ください',
    'ましょう',
    'たらいいですか',
    'た らいいですか',
    'なければ',
    'なくてはいけません',
    'なくてもかまいません',
    'てもかまいません',
    'てはいけません',
    'ないで',
    'しか',
    'かもしれ',
    'でしょう',
    'わけではない',
    'わけにはいかない',
    'はずがない',
    'ことはない',
    'そうにない',
    'に違いない',
    'といいな',
    'とのこと',
    'べきではない',
    'てはならない',
    'drop ',
    'bỏ ',
  ];
  return fragments.any((fragment) => normalized.contains(fragment));
}

bool _isRequestLikeStatement(String sentence) {
  final trimmed = sentence.trim();
  if (trimmed.isEmpty) return false;
  final punctuation = RegExp(r'[。！？?!]+$');
  final core = trimmed.replaceFirst(punctuation, '');
  const endings = <String>[
    'ください',
    'くださいませ',
    'ましょう',
    'ましょうか',
    'てもかまいません',
    'なくてもかまいません',
    'てはいけません',
    'ないでください',
      'なければなりません',
      'なくてはいけません',
      'べきではない',
      'てはならない',
      'て',
      'で',
    ];
  return endings.any(core.endsWith);
}

GrammarExampleLocale _parseLocale(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] != '--locale' || i + 1 >= args.length) continue;
    switch (args[i + 1].trim().toLowerCase()) {
      case 'en':
        return GrammarExampleLocale.en;
      case 'vi':
        return GrammarExampleLocale.vi;
      case 'ja':
        return GrammarExampleLocale.ja;
    }
  }
  return GrammarExampleLocale.en;
}

List<dynamic> _readJsonList(File file) {
  return jsonDecode(file.readAsStringSync()) as List<dynamic>;
}

Map<String, dynamic>? _matchDefinition(
  List<dynamic> definitions,
  String label,
) {
  final normalizedLabel = _compactLabel(label);
  if (normalizedLabel.isEmpty) return null;

  for (final item in definitions) {
    if (item is! Map) continue;
    final title = _compactLabel('${item['title'] ?? ''}');
    final grammarPoint = _compactLabel('${item['grammarPoint'] ?? ''}');
    if (title == normalizedLabel || grammarPoint == normalizedLabel) {
      return item.cast<String, dynamic>();
    }
  }

  final japaneseCore = _extractJapaneseCore(label);
  if (japaneseCore.isEmpty) return null;
  final matches = <Map<String, dynamic>>[];

  for (final item in definitions) {
    if (item is! Map) continue;
    final titleCore = _extractJapaneseCore('${item['title'] ?? ''}');
    final grammarCore = _extractJapaneseCore('${item['grammarPoint'] ?? ''}');
    if (titleCore == japaneseCore || grammarCore == japaneseCore) {
      matches.add(item.cast<String, dynamic>());
    }
  }

  return matches.length == 1 ? matches.first : null;
}

String _compactLabel(String value) {
  return value
      .replaceAll(RegExp(r'[~～]'), '〜')
      .toLowerCase()
      .replaceAll(RegExp(r'[\s\u3000\(\)（）\[\]【】「」『』:：,，.．/／・\-\+]+'), '')
      .trim();
}

String _extractJapaneseCore(String value) {
  return RegExp(r'[〜ぁ-ゖァ-ヶ一-龯々ー]')
      .allMatches(value.replaceAll(RegExp(r'[~～]'), '〜'))
      .map((match) => match.group(0)!)
      .join()
      .trim();
}

int _lessonNumberFromPath(String path) {
  final filename = path.split(Platform.pathSeparator).last;
  final match = RegExp(r'_(\d+)\.json$').firstMatch(filename);
  return int.parse(match!.group(1)!);
}

String _relativePath(Directory root, FileSystemEntity entity) {
  final rootPath = root.path;
  final entityPath = entity.path;
  if (!entityPath.startsWith(rootPath)) return entityPath;
  return entityPath
      .substring(rootPath.length + 1)
      .replaceAll(Platform.pathSeparator, '/');
}
