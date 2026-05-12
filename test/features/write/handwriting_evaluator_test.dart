import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/write/services/handwriting_evaluator.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Five horizontal strokes for a 6-stroke expected count.
/// Produces totalScore≈0.651 — above 0.58 (showGuide) but below 0.68 (no guide).
List<List<Offset>> _horizontalStrokes(int count, {double startY = 100}) {
  return List.generate(
    count,
    (i) => [Offset(50, startY + i * 10), Offset(150, startY + i * 10)],
  );
}

/// Single diagonal stroke centered in a 200×200 canvas.
List<List<Offset>> _diagonalStroke() => [
  [const Offset(40, 40), const Offset(160, 160)],
];

/// Two vertical strokes that normalize to exactly (0,0)→(0,1) and (1,0)→(1,1).
/// Use with _twoStrokeManualTemplate() on canvas Size(300,300).
List<List<Offset>> _perfectTwoStrokeStrokes() => [
  [const Offset(50, 50), const Offset(50, 250)],
  [const Offset(250, 50), const Offset(250, 250)],
];

KanjiStrokeTemplate _twoStrokeManualTemplate({String character = '門'}) =>
    KanjiStrokeTemplate(
      character: character,
      quality: 'manual',
      targetArea: 0.34,
      targetAspect: 0.95,
      strokes: const [
        StrokeTemplate(start: Point(0.0, 0.0), end: Point(0.0, 1.0)),
        StrokeTemplate(start: Point(1.0, 0.0), end: Point(1.0, 1.0)),
      ],
    );

KanjiStrokeTemplate _oneStrokeTemplate(String quality) => KanjiStrokeTemplate(
  character: '一',
  quality: quality,
  strokes: const [StrokeTemplate(start: Point(0.0, 0.0), end: Point(1.0, 1.0))],
);

/// Perfect diagonal — normalized start=(0,0), end=(1,1) matches template.
List<List<Offset>> _perfectDiagonalStroke() => [
  [const Offset(50, 50), const Offset(250, 250)],
];

/// Reversed diagonal — normalized start=(0,1), end=(1,0), opposite of template.
List<List<Offset>> _reversedDiagonalStroke() => [
  [const Offset(50, 250), const Offset(250, 50)],
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('strokeToleranceForExpectedCount', () {
    test('returns 0 for expected < 6', () {
      expect(HandwritingEvaluator.strokeToleranceForExpectedCount(1), 0);
      expect(HandwritingEvaluator.strokeToleranceForExpectedCount(5), 0);
    });

    test('returns 1 for 6 <= expected < 12', () {
      expect(HandwritingEvaluator.strokeToleranceForExpectedCount(6), 1);
      expect(HandwritingEvaluator.strokeToleranceForExpectedCount(11), 1);
    });

    test('returns 2 for expected >= 12', () {
      expect(HandwritingEvaluator.strokeToleranceForExpectedCount(12), 2);
      expect(HandwritingEvaluator.strokeToleranceForExpectedCount(20), 2);
    });
  });

  group('strokeScoreForCounts', () {
    test('exact match returns 1.0', () {
      expect(
        HandwritingEvaluator.strokeScoreForCounts(
          drawnStrokes: 3,
          expectedStrokes: 3,
        ),
        1.0,
      );
    });

    test('1 under with tolerance=0 (expected=5) returns 0.0', () {
      expect(
        HandwritingEvaluator.strokeScoreForCounts(
          drawnStrokes: 4,
          expectedStrokes: 5,
        ),
        0.0,
      );
    });

    test(
      '1 over with tolerance=0 (expected=5) returns 0.0 — ×2 over-penalty',
      () {
        // effectiveDelta = 1×2 = 2, denom = 1 → 1−2 = clamped 0
        expect(
          HandwritingEvaluator.strokeScoreForCounts(
            drawnStrokes: 6,
            expectedStrokes: 5,
          ),
          0.0,
        );
      },
    );

    test('1 under with tolerance=1 (expected=6) returns 0.5', () {
      // effectiveDelta = 1, denom = 2 → 1−0.5 = 0.5
      expect(
        HandwritingEvaluator.strokeScoreForCounts(
          drawnStrokes: 5,
          expectedStrokes: 6,
        ),
        0.5,
      );
    });

    test(
      '1 over with tolerance=1 (expected=6) returns 0.0 — ×2 over-penalty',
      () {
        // effectiveDelta = 1×2 = 2, denom = 2 → 1−1 = 0
        expect(
          HandwritingEvaluator.strokeScoreForCounts(
            drawnStrokes: 7,
            expectedStrokes: 6,
          ),
          0.0,
        );
      },
    );

    test('2 under with tolerance=2 (expected=12) returns ~0.333', () {
      // effectiveDelta = 2, denom = 3 → 1−2/3 ≈ 0.333
      expect(
        HandwritingEvaluator.strokeScoreForCounts(
          drawnStrokes: 10,
          expectedStrokes: 12,
        ),
        closeTo(1.0 - 2.0 / 3.0, 1e-9),
      );
    });
  });

  group('evaluate — tier=none, no template', () {
    const canvas = Size(200, 200);

    test('correct single diagonal stroke is accepted', () {
      final result = HandwritingEvaluator.evaluate(
        strokes: _diagonalStroke(),
        expectedStrokes: 1,
        canvasSize: canvas,
        showGuide: false,
      );
      expect(result.isCorrect, isTrue);
      expect(result.strokeScore, 1.0);
    });

    test('empty strokes are rejected — minStrokeScore gate', () {
      final result = HandwritingEvaluator.evaluate(
        strokes: const [],
        expectedStrokes: 1,
        canvasSize: canvas,
        showGuide: false,
      );
      expect(result.isCorrect, isFalse);
      expect(result.strokeScore, 0.0);
    });

    test('extra strokes trigger over-penalty and are rejected', () {
      // 3 drawn, 1 expected → over-penalty: effectiveDelta=2×2=4, score=clamped 0
      final result = HandwritingEvaluator.evaluate(
        strokes: [
          [const Offset(20, 20), const Offset(80, 80)],
          [const Offset(20, 80), const Offset(80, 20)],
          [const Offset(50, 10), const Offset(50, 90)],
        ],
        expectedStrokes: 1,
        canvasSize: canvas,
        showGuide: false,
      );
      expect(result.isCorrect, isFalse);
      expect(result.strokeScore, 0.0);
    });

    test('showGuide=true lowers required threshold — borderline case', () {
      // 5 strokes for 6-stroke char → strokeScore=0.5 ≥ minStrokeScore=0.45
      // totalScore≈0.651: above 0.58 (guide) but below 0.68 (no guide)
      final withGuide = HandwritingEvaluator.evaluate(
        strokes: _horizontalStrokes(5),
        expectedStrokes: 6,
        canvasSize: canvas,
        showGuide: true,
      );
      final withoutGuide = HandwritingEvaluator.evaluate(
        strokes: _horizontalStrokes(5),
        expectedStrokes: 6,
        canvasSize: canvas,
        showGuide: false,
      );
      expect(withGuide.isCorrect, isTrue);
      expect(withoutGuide.isCorrect, isFalse);
      expect(withGuide.score, closeTo(withoutGuide.score, 1e-9));
    });
  });

  group('evaluate — 2-stroke manual template', () {
    const canvas = Size(300, 300);

    test('perfect strokes are accepted', () {
      final result = HandwritingEvaluator.evaluate(
        strokes: _perfectTwoStrokeStrokes(),
        expectedStrokes: 2,
        canvasSize: canvas,
        showGuide: false,
        template: _twoStrokeManualTemplate(),
      );
      expect(result.isCorrect, isTrue);
      expect(result.templateScore, greaterThan(0.95));
      expect(result.strokeScore, 1.0);
    });

    test('drawing only 1 stroke for a 2-stroke kanji is rejected', () {
      final result = HandwritingEvaluator.evaluate(
        strokes: [
          [const Offset(50, 50), const Offset(50, 250)],
        ],
        expectedStrokes: 2,
        canvasSize: canvas,
        showGuide: false,
        template: _twoStrokeManualTemplate(),
      );
      expect(result.isCorrect, isFalse);
      // 1 under, tolerance=0 → strokeScore = 0.0
      expect(result.strokeScore, 0.0);
    });

    test(
      'legacy and v2 scoring both accept perfect strokes but produce different scores',
      () {
        final v2 = HandwritingEvaluator.evaluate(
          strokes: _perfectTwoStrokeStrokes(),
          expectedStrokes: 2,
          canvasSize: canvas,
          showGuide: false,
          template: _twoStrokeManualTemplate(),
          scoringVersion: HandwritingScoringVersion.v2,
        );
        final legacy = HandwritingEvaluator.evaluate(
          strokes: _perfectTwoStrokeStrokes(),
          expectedStrokes: 2,
          canvasSize: canvas,
          showGuide: false,
          template: _twoStrokeManualTemplate(),
          scoringVersion: HandwritingScoringVersion.legacy,
        );
        expect(v2.isCorrect, isTrue);
        expect(legacy.isCorrect, isTrue);
        expect(v2.score, isNot(equals(legacy.score)));
      },
    );
  });

  group('simple template gate — 1-stroke template, unguided', () {
    const canvas = Size(300, 300);

    for (final quality in ['manual', 'curated', 'generated']) {
      test('$quality: perfect diagonal passes gate', () {
        final result = HandwritingEvaluator.evaluate(
          strokes: _perfectDiagonalStroke(),
          expectedStrokes: 1,
          canvasSize: canvas,
          showGuide: false,
          template: _oneStrokeTemplate(quality),
        );
        expect(
          result.isCorrect,
          isTrue,
          reason: '$quality with perfect strokes should pass',
        );
      });

      test(
        '$quality: reversed diagonal fails simple gate (templateScore≈0.574)',
        () {
          final result = HandwritingEvaluator.evaluate(
            strokes: _reversedDiagonalStroke(),
            expectedStrokes: 1,
            canvasSize: canvas,
            showGuide: false,
            template: _oneStrokeTemplate(quality),
          );
          expect(
            result.isCorrect,
            isFalse,
            reason: '$quality reversed diagonal should fail simple gate',
          );
        },
      );
    }

    test('gate is skipped when showGuide=true — no crash, result returned', () {
      // _passesSimpleTemplateGate returns true when showGuide=true.
      final result = HandwritingEvaluator.evaluate(
        strokes: _reversedDiagonalStroke(),
        expectedStrokes: 1,
        canvasSize: canvas,
        showGuide: true,
        template: _oneStrokeTemplate('manual'),
      );
      // Simple gate is bypassed — result is non-null regardless of direction.
      expect(result, isNotNull);
    });
  });
}
