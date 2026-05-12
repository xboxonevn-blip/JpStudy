import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/write/services/handwriting_evaluator.dart';
import 'package:jpstudy/features/write/services/handwriting_template_matcher.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';

const _canvas = Size(300, 300);

KanjiStrokeTemplate _template(
  String character,
  List<(Point<double>, Point<double>)> strokes,
) {
  return KanjiStrokeTemplate(
    character: character,
    quality: 'manual',
    strokes: [
      for (final (start, end) in strokes)
        StrokeTemplate(start: start, end: end),
    ],
  );
}

List<Offset> _trace(Point<double> start, Point<double> end) => [
  Offset(start.x * _canvas.width, start.y * _canvas.height),
  Offset(
    ((start.x + end.x) / 2) * _canvas.width,
    ((start.y + end.y) / 2) * _canvas.height,
  ),
  Offset(end.x * _canvas.width, end.y * _canvas.height),
];

List<List<Offset>> _pointerTrace(KanjiStrokeTemplate template) => [
  for (final stroke in template.strokes) _trace(stroke.start, stroke.end),
];

void main() {
  final one = String.fromCharCode(0x4e00);
  final gaku = String.fromCharCode(0x5b66);

  test('pointer trace for one horizontal stroke suggests ? first', () {
    final oneTemplate = _template(one, const [
      (Point(0.12, 0.5), Point(0.88, 0.5)),
    ]);
    final verticalTemplate = _template('?', const [
      (Point(0.5, 0.12), Point(0.5, 0.88)),
    ]);
    final trace = _pointerTrace(oneTemplate);

    final oneScore = HandwritingTemplateMatcher.templateScore(
      strokes: trace,
      template: oneTemplate,
    );
    final verticalScore = HandwritingTemplateMatcher.templateScore(
      strokes: trace,
      template: verticalTemplate,
    );

    expect(oneScore, greaterThan(0.55));
    expect(oneScore, greaterThan(verticalScore + 0.05));
  });

  test(
    'pointer trace for Ã¥Â­Â¦ rewards close 8-stroke shape and rejects unfair scribble',
    () {
      final gakuTemplate = _template(gaku, const [
        (Point(0.25, 0.18), Point(0.75, 0.18)),
        (Point(0.50, 0.18), Point(0.50, 0.30)),
        (Point(0.30, 0.32), Point(0.70, 0.32)),
        (Point(0.20, 0.44), Point(0.80, 0.44)),
        (Point(0.50, 0.44), Point(0.50, 0.58)),
        (Point(0.32, 0.62), Point(0.68, 0.62)),
        (Point(0.50, 0.62), Point(0.50, 0.82)),
        (Point(0.35, 0.82), Point(0.65, 0.82)),
      ]);
      final goodTrace = _pointerTrace(gakuTemplate);
      final scribbleTrace = [
        for (var i = 0; i < 8; i++)
          [Offset(30 + i * 6, 30), Offset(150, 150), Offset(270 - i * 4, 270)],
      ];

      final good = HandwritingEvaluator.evaluate(
        strokes: goodTrace,
        expectedStrokes: 8,
        canvasSize: _canvas,
        showGuide: true,
        template: gakuTemplate,
      );
      final scribble = HandwritingEvaluator.evaluate(
        strokes: scribbleTrace,
        expectedStrokes: 8,
        canvasSize: _canvas,
        showGuide: true,
        template: gakuTemplate,
      );

      expect(good.drawnStrokes, 8);
      expect(good.usedTemplate, isTrue);
      expect(good.score, greaterThan(0.70));
      expect(good.score, greaterThan(scribble.score + 0.10));
      expect(scribble.isCorrect, isFalse);
    },
  );
}
