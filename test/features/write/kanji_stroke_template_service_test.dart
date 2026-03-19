import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/write/services/handwriting_evaluator.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_template_service.dart';
import 'package:jpstudy/features/write/services/kanji_stroke_vector_service.dart';

void main() {
  List<Offset> line(Offset start, Offset end, {int points = 9}) {
    return List<Offset>.generate(points, (i) {
      final t = points <= 1 ? 1.0 : i / (points - 1);
      return Offset(
        start.dx + ((end.dx - start.dx) * t),
        start.dy + ((end.dy - start.dy) * t),
      );
    });
  }

  tearDown(() {
    KanjiStrokeTemplateService.setDebugTemplateOverrides(null);
    KanjiStrokeTemplateService.clearCache();
    KanjiStrokeVectorService.setDebugVectorOverrides(null);
  });

  test(
    'projectTemplateFromVector builds guide-aligned normalized endpoints',
    () {
      const vector = KanjiStrokeVector(
        character: 'T',
        strokes: ['M10,10 L10,90', 'M90,10 L90,90'],
        viewBox: [0, 0, 100, 100],
      );

      final template = KanjiStrokeTemplateService.projectTemplateFromVector(
        vector,
        quality: 'manual',
      );

      expect(template, isNotNull);
      expect(template!.quality, equals('manual'));
      expect(template.strokes, hasLength(2));
      expect(template.strokes[0].start.x, closeTo(0.0, 0.001));
      expect(template.strokes[0].end.x, closeTo(0.0, 0.001));
      expect(template.strokes[1].start.x, closeTo(1.0, 0.001));
      expect(template.strokes[1].end.x, closeTo(1.0, 0.001));
      expect(template.targetArea, closeTo(0.430, 0.01));
      expect(template.targetAspect, closeTo(1.0, 0.01));
    },
  );

  test(
    'service merges debug vector geometry while preserving template quality',
    () async {
      KanjiStrokeTemplateService.setDebugTemplateOverrides({
        'T': const KanjiStrokeTemplate(
          character: 'T',
          quality: 'manual',
          targetArea: 0.32,
          targetAspect: 1.0,
          strokes: [
            StrokeTemplate(start: Point(0.5, 0.0), end: Point(0.5, 1.0)),
            StrokeTemplate(start: Point(0.5, 0.0), end: Point(0.5, 1.0)),
          ],
        ),
      });
      KanjiStrokeVectorService.setDebugVectorOverrides({
        'T': const KanjiStrokeVector(
          character: 'T',
          strokes: ['M10,10 L10,90', 'M90,10 L90,90'],
          viewBox: [0, 0, 100, 100],
        ),
      });
      KanjiStrokeTemplateService.clearCache();

      final merged = await KanjiStrokeTemplateService.instance.getTemplate('T');

      expect(merged, isNotNull);
      expect(merged!.quality, equals('manual'));
      expect(merged.strokes[0].start.x, closeTo(0.0, 0.001));
      expect(merged.strokes[1].start.x, closeTo(1.0, 0.001));
    },
  );

  test(
    'projected 四 template from live vector accepts guide-aligned rough writing',
    () {
      final raw = File(
        'assets/data/support/kanji/kanjivg_stroke_paths_n5n4.json',
      ).readAsStringSync();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final entries = decoded['entries'] as Map<String, dynamic>;
      final vector = KanjiStrokeVector.fromJson(
        character: '四',
        json: entries['四'] as Map<String, dynamic>,
      );
      final template = KanjiStrokeTemplateService.projectTemplateFromVector(
        vector,
        quality: 'manual',
      );

      expect(template, isNotNull);

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
        expectedStrokes: template!.strokes.length,
        canvasSize: const Size(220, 220),
        showGuide: true,
        template: template,
        scoringVersion: HandwritingScoringVersion.v2,
      );

      expect(
        result.isCorrect,
        isTrue,
        reason:
            'Guide-derived 四 template should accept guide-faithful rough '
            'writing instead of requiring per-character patching.',
      );
    },
  );
}
