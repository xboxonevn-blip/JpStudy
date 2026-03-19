import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/write/services/handwriting_evaluator.dart';
import 'package:jpstudy/features/write/services/handwriting_template_matcher.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

import 'handwriting_scoring_test_utils.dart';

void main() {
  KanjiStrokeTemplate buildTemplate(String quality) {
    return KanjiStrokeTemplate(
      character: '木',
      quality: quality,
      targetArea: 0.33,
      targetAspect: 1.0,
      strokes: const [
        StrokeTemplate(start: Point(0.10, 0.15), end: Point(0.78, 0.18)),
        StrokeTemplate(start: Point(0.30, 0.32), end: Point(0.74, 0.36)),
        StrokeTemplate(start: Point(0.52, 0.08), end: Point(0.48, 0.88)),
        StrokeTemplate(start: Point(0.22, 0.56), end: Point(0.12, 0.84)),
        StrokeTemplate(start: Point(0.66, 0.58), end: Point(0.90, 0.82)),
      ],
    );
  }

  KanjiStrokeTemplate buildPersonTemplate(String quality) {
    return KanjiStrokeTemplate(
      character: '人',
      quality: quality,
      targetArea: 0.30,
      targetAspect: 0.85,
      strokes: const [
        StrokeTemplate(start: Point(0.46, 0.18), end: Point(0.30, 0.84)),
        StrokeTemplate(start: Point(0.54, 0.18), end: Point(0.74, 0.84)),
      ],
    );
  }

  KanjiStrokeTemplate buildSunTemplate(String quality) {
    return KanjiStrokeTemplate(
      character: '日',
      quality: quality,
      targetArea: 0.36,
      targetAspect: 0.75,
      strokes: const [
        StrokeTemplate(start: Point(0.30, 0.20), end: Point(0.30, 0.82)),
        StrokeTemplate(start: Point(0.30, 0.20), end: Point(0.70, 0.20)),
        StrokeTemplate(start: Point(0.32, 0.50), end: Point(0.68, 0.50)),
        StrokeTemplate(start: Point(0.70, 0.20), end: Point(0.30, 0.82)),
      ],
    );
  }

  KanjiStrokeTemplate buildFourTemplate(String quality) {
    return KanjiStrokeTemplate(
      character: '四',
      quality: quality,
      targetArea: 0.24,
      targetAspect: 1.18,
      strokes: const [
        StrokeTemplate(start: Point(0.133, 0.289), end: Point(0.202, 0.768)),
        StrokeTemplate(start: Point(0.164, 0.312), end: Point(0.771, 0.742)),
        StrokeTemplate(start: Point(0.372, 0.33), end: Point(0.248, 0.562)),
        StrokeTemplate(start: Point(0.548, 0.314), end: Point(0.743, 0.494)),
        StrokeTemplate(start: Point(0.209, 0.728), end: Point(0.77, 0.709)),
      ],
    );
  }

  List<Offset> line(Offset start, Offset end, {int points = 9}) {
    return List<Offset>.generate(points, (i) {
      final t = points <= 1 ? 1.0 : i / (points - 1);
      return Offset(
        start.dx + ((end.dx - start.dx) * t),
        start.dy + ((end.dy - start.dy) * t),
      );
    });
  }

  test('accepts clean template-like writing for all quality tiers (v2)', () {
    const canvas = Size(220, 220);
    for (final quality in ['manual', 'curated', 'generated']) {
      final template = buildTemplate(quality);
      final strokes = buildStrokesFromTemplate(
        template,
        jitter: 0.35,
        seed: 42,
      );
      final result = HandwritingEvaluator.evaluate(
        strokes: strokes,
        expectedStrokes: template.strokes.length,
        canvasSize: canvas,
        showGuide: false,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );
      expect(
        result.isCorrect,
        isTrue,
        reason: 'Expected accepted stroke for quality=$quality',
      );
    }
  });

  test(
    'rejects 20+ representative wrong stroke cases (order/shape/start-end)',
    () {
      const canvas = Size(220, 220);
      final template = buildTemplate('manual');
      final negatives = Map<String, StrokeSequence>.from(
        buildRegressionNegativeCases(template),
      )..remove('order_reverse_all');
      expect(negatives.length, greaterThanOrEqualTo(20));
      final rejected = <String>[];

      for (final entry in negatives.entries) {
        final result = HandwritingEvaluator.evaluate(
          strokes: entry.value,
          expectedStrokes: template.strokes.length,
          canvasSize: canvas,
          showGuide: false,
          template: template,
          scoringVersion: HandwritingScoringVersion.v2,
        );
        if (!result.isCorrect) {
          rejected.add(entry.key);
        }
      }

      final orderRejected = rejected
          .where((name) => name.startsWith('order_'))
          .length;
      final shapeRejected = rejected
          .where((name) => name.startsWith('shape_'))
          .length;
      final endpointRejected = rejected
          .where((name) => name.startsWith('endpoint_'))
          .length;

      expect(
        rejected.length,
        greaterThanOrEqualTo(20),
        reason: 'manual rejected=${rejected.join(',')}',
      );
      expect(
        orderRejected,
        greaterThanOrEqualTo(3),
        reason: 'manual orderRejected=$orderRejected',
      );
      expect(
        shapeRejected,
        greaterThanOrEqualTo(3),
        reason: 'manual shapeRejected=$shapeRejected',
      );
      expect(
        endpointRejected,
        greaterThanOrEqualTo(1),
        reason: 'manual endpointRejected=$endpointRejected',
      );
    },
  );

  test('rejects reversed opening stroke for 人 even when guide is visible', () {
    const canvas = Size(220, 220);
    final template = buildPersonTemplate('manual');
    final correct = buildStrokesFromTemplate(template, jitter: 0.25, seed: 21);
    final reversedFirst = <List<Offset>>[
      correct.first.reversed.toList(growable: false),
      correct[1],
    ];

    final correctResult = HandwritingEvaluator.evaluate(
      strokes: correct,
      expectedStrokes: template.strokes.length,
      canvasSize: canvas,
      showGuide: true,
      template: template,
      scoringVersion: HandwritingScoringVersion.v2,
    );
    final reversedResult = HandwritingEvaluator.evaluate(
      strokes: reversedFirst,
      expectedStrokes: template.strokes.length,
      canvasSize: canvas,
      showGuide: true,
      template: template,
      scoringVersion: HandwritingScoringVersion.v2,
    );

    expect(correctResult.isCorrect, isTrue);
    expect(
      reversedResult.isCorrect,
      isFalse,
      reason:
          'reversed human stroke should fail: '
          'score=${reversedResult.score.toStringAsFixed(3)} '
          'stroke=${reversedResult.strokeScore.toStringAsFixed(3)} '
          'shape=${reversedResult.shapeScore.toStringAsFixed(3)} '
          'order=${reversedResult.orderScore.toStringAsFixed(3)} '
          'template=${reversedResult.templateScore.toStringAsFixed(3)}',
    );
  });

  test(
    'accepts a slightly rough 日 sketch when the structure is still right',
    () {
      const canvas = Size(220, 220);
      final template = buildSunTemplate('manual');
      final roughSun = <List<Offset>>[
        [
          ...line(const Offset(82, 48), const Offset(156, 54), points: 6),
          ...line(
            const Offset(156, 54),
            const Offset(154, 186),
            points: 6,
          ).skip(1),
        ],
        line(const Offset(92, 52), const Offset(92, 184)),
        line(const Offset(92, 118), const Offset(150, 116)),
        [...line(const Offset(92, 184), const Offset(150, 186), points: 6)],
      ];

      final result = HandwritingEvaluator.evaluate(
        strokes: roughSun,
        expectedStrokes: template.strokes.length,
        canvasSize: canvas,
        showGuide: false,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );
      final directionScore = HandwritingTemplateMatcher.templateDirectionScore(
        strokes: roughSun,
        template: template,
      );

      expect(
        result.templateScore,
        lessThan(0.70),
        reason:
            'This sketch should stay slightly rough so the test covers the '
            'relaxed near-correct threshold for boxed kanji.',
      );
      expect(
        result.isCorrect,
        isTrue,
        reason:
            'A recognizably correct 日 should pass even when the stroke shape '
            'is a little rough: '
            'score=${result.score.toStringAsFixed(3)} '
            'stroke=${result.strokeScore.toStringAsFixed(3)} '
            'shape=${result.shapeScore.toStringAsFixed(3)} '
            'order=${result.orderScore.toStringAsFixed(3)} '
            'template=${result.templateScore.toStringAsFixed(3)} '
            'direction=${directionScore.toStringAsFixed(3)}',
      );
    },
  );

  test(
    'accepts a guide-aligned 四 sketch when guide is visible and order is right',
    () {
      const canvas = Size(220, 220);
      final template = buildFourTemplate('manual');
      final roughFour = <List<Offset>>[
        line(const Offset(48, 72), const Offset(58, 158)),
        [
          ...line(const Offset(54, 76), const Offset(156, 72), points: 6),
          ...line(
            const Offset(156, 72),
            const Offset(166, 152),
            points: 6,
          ).skip(1),
        ],
        [
          ...line(const Offset(90, 78), const Offset(84, 98), points: 4),
          ...line(
            const Offset(84, 98),
            const Offset(66, 120),
            points: 5,
          ).skip(1),
        ],
        [
          ...line(const Offset(122, 78), const Offset(124, 112), points: 5),
          ...line(
            const Offset(124, 112),
            const Offset(154, 108),
            points: 4,
          ).skip(1),
        ],
        line(const Offset(60, 150), const Offset(164, 146)),
      ];

      final result = HandwritingEvaluator.evaluate(
        strokes: roughFour,
        expectedStrokes: template.strokes.length,
        canvasSize: canvas,
        showGuide: true,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );
      final directionScore = HandwritingTemplateMatcher.templateDirectionScore(
        strokes: roughFour,
        template: template,
      );

      expect(
        result.templateScore,
        greaterThan(0.44),
        reason:
            'Guide-aligned 四 writing should no longer be punished by a '
            'mismatched template.',
      );
      expect(
        result.isCorrect,
        isTrue,
        reason:
            'A recognizably correct 四 should pass with guide visible when '
            'the learner follows the visible stroke order guide: '
            'score=${result.score.toStringAsFixed(3)} '
            'stroke=${result.strokeScore.toStringAsFixed(3)} '
            'shape=${result.shapeScore.toStringAsFixed(3)} '
            'order=${result.orderScore.toStringAsFixed(3)} '
            'template=${result.templateScore.toStringAsFixed(3)} '
            'direction=${directionScore.toStringAsFixed(3)}',
      );
    },
  );
}
