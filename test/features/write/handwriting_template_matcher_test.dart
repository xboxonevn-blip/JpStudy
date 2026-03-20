import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/write/services/handwriting_template_matcher.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

void main() {
  KanjiStrokeTemplate buildTwoStrokeTemplate() {
    return KanjiStrokeTemplate(
      character: 'T',
      quality: 'manual',
      strokes: const [
        StrokeTemplate(start: Point(0, 0), end: Point(0, 1)),
        StrokeTemplate(start: Point(1, 0), end: Point(1, 1)),
      ],
    );
  }

  List<List<Offset>> goodUserStrokes() => const [
    [Offset(10, 10), Offset(10, 90)],
    [Offset(90, 10), Offset(90, 90)],
  ];

  test('template score is high for matching strokes', () {
    final template = buildTwoStrokeTemplate();
    final score = HandwritingTemplateMatcher.templateScore(
      strokes: goodUserStrokes(),
      template: template,
    );
    final orderScore = HandwritingTemplateMatcher.templateOrderScore(
      strokes: goodUserStrokes(),
      template: template,
    );

    expect(score, greaterThan(0.95));
    expect(orderScore, greaterThan(0.95));
  });

  test('order score drops when stroke order is reversed', () {
    final template = buildTwoStrokeTemplate();
    final reversedOrder = const [
      [Offset(90, 10), Offset(90, 90)],
      [Offset(10, 10), Offset(10, 90)],
    ];
    final orderScore = HandwritingTemplateMatcher.templateOrderScore(
      strokes: reversedOrder,
      template: template,
    );

    expect(orderScore, lessThan(0.5));
  });

  test('order score drops when a three-stroke pattern is scrambled', () {
    final template = KanjiStrokeTemplate(
      character: 'E',
      quality: 'generated',
      strokes: const [
        StrokeTemplate(start: Point(0.1, 0.2), end: Point(0.1, 0.8)),
        StrokeTemplate(start: Point(0.5, 0.2), end: Point(0.5, 0.8)),
        StrokeTemplate(start: Point(0.9, 0.2), end: Point(0.9, 0.8)),
      ],
    );
    final scrambled = const [
      [Offset(90, 10), Offset(90, 90)],
      [Offset(10, 10), Offset(10, 90)],
      [Offset(50, 10), Offset(50, 90)],
    ];

    final orderScore = HandwritingTemplateMatcher.templateOrderScore(
      strokes: scrambled,
      template: template,
    );

    expect(orderScore, lessThan(0.6));
  });

  test('direction score drops when one stroke is drawn backwards', () {
    final template = buildTwoStrokeTemplate();
    final reversedFirst = const [
      [Offset(10, 90), Offset(10, 10)],
      [Offset(90, 10), Offset(90, 90)],
    ];
    final directionScore = HandwritingTemplateMatcher.templateDirectionScore(
      strokes: reversedFirst,
      template: template,
    );

    expect(directionScore, lessThan(0.75));
  });

  test('template score drops for wrong direction and endpoints', () {
    final template = buildTwoStrokeTemplate();
    final badShape = const [
      [Offset(90, 90), Offset(10, 10)],
      [Offset(10, 90), Offset(90, 10)],
    ];
    final score = HandwritingTemplateMatcher.templateScore(
      strokes: badShape,
      template: template,
    );

    expect(score, lessThan(0.65));
  });

  test('template score stays high for a slightly wobbly matching stroke', () {
    final template = KanjiStrokeTemplate(
      character: 'H',
      quality: 'manual',
      strokes: const [
        StrokeTemplate(start: Point(0.0, 0.0), end: Point(0.0, 1.0)),
        StrokeTemplate(start: Point(1.0, 0.0), end: Point(1.0, 1.0)),
      ],
    );
    final wobblyStroke = const [
      [
        Offset(32, 20),
        Offset(35, 40),
        Offset(30, 60),
        Offset(34, 84),
        Offset(31, 112),
        Offset(33, 144),
        Offset(30, 180),
      ],
      [
        Offset(178, 20),
        Offset(178, 60),
        Offset(178, 100),
        Offset(178, 140),
        Offset(178, 180),
      ],
    ];

    final score = HandwritingTemplateMatcher.templateScore(
      strokes: wobblyStroke,
      template: template,
    );

    expect(score, greaterThan(0.68));
  });

  test(
    'template score drops for a bowed stroke even when endpoints still match',
    () {
      final template = KanjiStrokeTemplate(
        character: 'H',
        quality: 'manual',
        strokes: const [
          StrokeTemplate(start: Point(0.0, 0.0), end: Point(0.0, 1.0)),
          StrokeTemplate(start: Point(1.0, 0.0), end: Point(1.0, 1.0)),
        ],
      );
      final bowedStroke = const [
        [
          Offset(32, 20),
          Offset(68, 52),
          Offset(74, 96),
          Offset(56, 136),
          Offset(32, 180),
        ],
        [
          Offset(178, 20),
          Offset(178, 60),
          Offset(178, 100),
          Offset(178, 140),
          Offset(178, 180),
        ],
      ];
      final straightStroke = const [
        [
          Offset(32, 20),
          Offset(32, 60),
          Offset(32, 100),
          Offset(32, 140),
          Offset(32, 180),
        ],
        [
          Offset(178, 20),
          Offset(178, 60),
          Offset(178, 100),
          Offset(178, 140),
          Offset(178, 180),
        ],
      ];

      final score = HandwritingTemplateMatcher.templateScore(
        strokes: bowedStroke,
        template: template,
      );
      final straightScore = HandwritingTemplateMatcher.templateScore(
        strokes: straightStroke,
        template: template,
      );

      expect(score, lessThan(0.90));
      expect(score, lessThan(straightScore - 0.08));
    },
  );
}
