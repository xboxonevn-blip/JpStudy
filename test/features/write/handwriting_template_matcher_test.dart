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
}
