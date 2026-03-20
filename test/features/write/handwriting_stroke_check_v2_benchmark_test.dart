import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/write/services/handwriting_evaluator.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

import 'handwriting_scoring_test_utils.dart';

const _printStrokeBenchmark = bool.fromEnvironment(
  'JPSTUDY_PRINT_STROKE_BENCHMARK',
);

void main() {
  test('offline benchmark reports before/after metrics by quality tier', () {
    const canvas = Size(220, 220);
    final templatesByQuality = loadTemplatesByQuality();
    final report = <String, dynamic>{};

    final tierPlan = <String, int>{
      'manual': 40,
      'curated': 13,
      'generated': 40,
    };

    for (final tier in tierPlan.keys) {
      final templates =
          (templatesByQuality[tier] ?? const <KanjiStrokeTemplate>[])
              .take(tierPlan[tier]!)
              .toList();
      expect(templates, isNotEmpty, reason: 'Missing templates for tier=$tier');

      final legacy = _runBenchmark(
        templates: templates,
        canvasSize: canvas,
        scoringVersion: HandwritingScoringVersion.legacy,
      );
      final v2 = _runBenchmark(
        templates: templates,
        canvasSize: canvas,
        scoringVersion: HandwritingScoringVersion.v2,
      );

      report[tier] = {
        'sampleTemplates': templates.length,
        'legacy': legacy.toJson(),
        'v2': v2.toJson(),
      };

      expect(
        v2.falsePositiveRate,
        lessThanOrEqualTo(legacy.falsePositiveRate + 1e-9),
        reason: 'Expected FPR not worse for tier=$tier',
      );
      expect(
        v2.top1PassRate,
        greaterThanOrEqualTo(0.70),
        reason: 'Expected positive pass rate >= 70% for tier=$tier',
      );
      final maxAcceptedFalsePositiveRate = switch (tier) {
        'manual' => 0.08,
        'curated' => 0.25,
        'generated' => 0.25,
        _ => 0.25,
      };
      expect(
        v2.falsePositiveRate,
        lessThanOrEqualTo(maxAcceptedFalsePositiveRate),
        reason:
            'Expected stronger false-positive ceiling for tier=$tier, '
            'got ${v2.falsePositiveRate.toStringAsFixed(4)}',
      );
    }

    if (_printStrokeBenchmark) {
      // ignore: avoid_print
      print('stroke_check_v2_benchmark=${jsonEncode(report)}');
    }
  });
}

_BenchmarkMetrics _runBenchmark({
  required List<KanjiStrokeTemplate> templates,
  required Size canvasSize,
  required HandwritingScoringVersion scoringVersion,
}) {
  var positiveTotal = 0;
  var positivePass = 0;
  var negativeTotal = 0;
  var falsePositive = 0;

  for (var i = 0; i < templates.length; i++) {
    final template = templates[i];
    final positives = <StrokeSequence>[
      buildStrokesFromTemplate(template, jitter: 0.25, seed: 10 + i),
      buildStrokesFromTemplate(
        template,
        jitter: 0.65,
        seed: 100 + i,
        translate: const Offset(6, -4),
      ),
      buildStrokesFromTemplate(
        template,
        jitter: 0.55,
        seed: 200 + i,
        scaleX: 0.92,
        scaleY: 1.08,
      ),
    ];
    final negatives = buildRegressionNegativeCases(
      template,
    ).values.take(10).toList();

    for (final sample in positives) {
      final result = HandwritingEvaluator.evaluate(
        strokes: sample,
        expectedStrokes: template.strokes.length,
        canvasSize: canvasSize,
        showGuide: false,
        template: template,
        scoringVersion: scoringVersion,
      );
      positiveTotal += 1;
      if (result.isCorrect) {
        positivePass += 1;
      }
    }

    for (final sample in negatives) {
      final result = HandwritingEvaluator.evaluate(
        strokes: sample,
        expectedStrokes: template.strokes.length,
        canvasSize: canvasSize,
        showGuide: false,
        template: template,
        scoringVersion: scoringVersion,
      );
      negativeTotal += 1;
      if (result.isCorrect) {
        falsePositive += 1;
      }
    }
  }

  return _BenchmarkMetrics(
    positiveTotal: positiveTotal,
    positivePass: positivePass,
    negativeTotal: negativeTotal,
    falsePositive: falsePositive,
  );
}

class _BenchmarkMetrics {
  const _BenchmarkMetrics({
    required this.positiveTotal,
    required this.positivePass,
    required this.negativeTotal,
    required this.falsePositive,
  });

  final int positiveTotal;
  final int positivePass;
  final int negativeTotal;
  final int falsePositive;

  double get top1PassRate {
    if (positiveTotal == 0) return 0;
    return positivePass / positiveTotal;
  }

  double get falsePositiveRate {
    if (negativeTotal == 0) return 0;
    return falsePositive / negativeTotal;
  }

  Map<String, dynamic> toJson() {
    return {
      'positiveTotal': positiveTotal,
      'positivePass': positivePass,
      'top1PassRate': double.parse(top1PassRate.toStringAsFixed(4)),
      'negativeTotal': negativeTotal,
      'falsePositive': falsePositive,
      'falsePositiveRate': double.parse(falsePositiveRate.toStringAsFixed(4)),
    };
  }
}
