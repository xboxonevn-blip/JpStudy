import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

import 'kanji_stroke_vector_layout.dart';
import 'kanji_stroke_vector_service.dart';

class KanjiStrokeTemplateService {
  KanjiStrokeTemplateService._();

  static final KanjiStrokeTemplateService instance =
      KanjiStrokeTemplateService._();

  // Test-only override to avoid rootBundle dependency in widget tests.
  static Map<String, KanjiStrokeTemplate>? debugTemplateOverrides;

  static const _assetPath = 'assets/data/support/kanji/stroke_templates.json';

  Map<String, KanjiStrokeTemplate>? _templates;

  static void setDebugTemplateOverrides(
    Map<String, KanjiStrokeTemplate>? templates,
  ) {
    debugTemplateOverrides = templates;
    instance._templates = templates;
  }

  static void clearCache() {
    instance._templates = null;
  }

  Future<KanjiStrokeTemplate?> getTemplate(String character) async {
    await _ensureLoaded();
    return _templates?[character];
  }

  Future<Map<String, KanjiStrokeTemplate>> getAllTemplates() async {
    await _ensureLoaded();
    return _templates ?? const {};
  }

  Future<void> _ensureLoaded() async {
    if (_templates != null) return;
    if (debugTemplateOverrides != null) {
      _templates = _mergeTemplatesWithVectors(
        baseTemplates: Map<String, KanjiStrokeTemplate>.from(
          debugTemplateOverrides!,
        ),
        vectors: KanjiStrokeVectorService.debugVectorOverrides ?? const {},
      );
      return;
    }
    final raw = (await rootBundle.loadString(
      _assetPath,
    )).replaceFirst('\uFEFF', '');
    final decoded = jsonDecode(raw) as List<dynamic>;
    final templates = decoded
        .map(
          (entry) =>
              KanjiStrokeTemplate.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
    final baseTemplates = {
      for (final template in templates) template.character: template,
    };
    final vectors = await KanjiStrokeVectorService.instance.getAllVectors();
    _templates = _mergeTemplatesWithVectors(
      baseTemplates: baseTemplates,
      vectors: vectors,
    );
  }

  static Map<String, KanjiStrokeTemplate> _mergeTemplatesWithVectors({
    required Map<String, KanjiStrokeTemplate> baseTemplates,
    required Map<String, KanjiStrokeVector> vectors,
  }) {
    if (vectors.isEmpty) {
      return baseTemplates;
    }

    final merged = Map<String, KanjiStrokeTemplate>.from(baseTemplates);
    for (final entry in vectors.entries) {
      final existing = merged[entry.key];
      final projected = projectTemplateFromVector(
        entry.value,
        quality: existing?.quality ?? 'generated',
      );
      if (projected == null) {
        continue;
      }
      if (existing == null) {
        merged[entry.key] = projected;
        continue;
      }

      final similarity = _templateGeometrySimilarity(existing, projected);
      final useProjectedShape = similarity < 0.78;
      merged[entry.key] = existing.copyWith(
        strokes: projected.strokes,
        targetArea: useProjectedShape ? projected.targetArea : null,
        targetAspect: useProjectedShape ? projected.targetAspect : null,
      );
    }
    return merged;
  }

  static KanjiStrokeTemplate? projectTemplateFromVector(
    KanjiStrokeVector vector, {
    String quality = 'generated',
  }) {
    if (vector.strokes.isEmpty) {
      return null;
    }

    final layout = computeKanjiStrokeVectorLayout(vector, const Size(1, 1));
    final projectedStrokes = <_ProjectedStroke>[];
    final projectedPoints = <Offset>[];

    for (final pathData in vector.strokes) {
      final Path path;
      try {
        path = parseSvgPathData(pathData);
      } on Object {
        continue;
      }

      final metrics = path.computeMetrics().toList(growable: false);
      final rawBounds = path.getBounds();
      final fallbackAnchor = rawBounds.isEmpty
          ? Offset(
              vector.minX + (vector.width / 2),
              vector.minY + (vector.height / 2),
            )
          : rawBounds.center;
      final rawStart = _pathStart(metrics, fallbackAnchor);
      final rawEnd = _pathEnd(metrics, fallbackAnchor);
      final projectedStart = layout.transformOffset(rawStart);
      final projectedEnd = layout.transformOffset(rawEnd);

      projectedStrokes.add(
        _ProjectedStroke(start: projectedStart, end: projectedEnd),
      );
      projectedPoints
        ..add(projectedStart)
        ..add(projectedEnd);
    }

    if (projectedStrokes.isEmpty || projectedPoints.isEmpty) {
      return null;
    }

    final bounds = _boundsForPoints(projectedPoints);
    final width = max(1e-6, bounds.width);
    final height = max(1e-6, bounds.height);
    final strokes = projectedStrokes
        .map(
          (stroke) => StrokeTemplate(
            start: Point(
              _normalizeToBounds(stroke.start.dx, bounds.left, width),
              _normalizeToBounds(stroke.start.dy, bounds.top, height),
            ),
            end: Point(
              _normalizeToBounds(stroke.end.dx, bounds.left, width),
              _normalizeToBounds(stroke.end.dy, bounds.top, height),
            ),
          ),
        )
        .toList(growable: false);

    return KanjiStrokeTemplate(
      character: vector.character,
      quality: quality,
      strokes: strokes,
      targetArea: (bounds.width * bounds.height).clamp(0.01, 0.92).toDouble(),
      targetAspect: (bounds.width / height).clamp(0.45, 1.8).toDouble(),
    );
  }

  static Offset _pathStart(List<PathMetric> metrics, Offset fallback) {
    for (final metric in metrics) {
      if (metric.length <= 0) {
        continue;
      }
      final tangent = metric.getTangentForOffset(0);
      if (tangent != null) {
        return tangent.position;
      }
    }
    return fallback;
  }

  static Offset _pathEnd(List<PathMetric> metrics, Offset fallback) {
    for (var i = metrics.length - 1; i >= 0; i--) {
      final metric = metrics[i];
      if (metric.length <= 0) {
        continue;
      }
      final tangent = metric.getTangentForOffset(metric.length);
      if (tangent != null) {
        return tangent.position;
      }
    }
    return fallback;
  }

  static Rect _boundsForPoints(List<Offset> points) {
    if (points.isEmpty) {
      return Rect.zero;
    }
    var minX = points.first.dx;
    var maxX = points.first.dx;
    var minY = points.first.dy;
    var maxY = points.first.dy;
    for (final point in points.skip(1)) {
      minX = min(minX, point.dx);
      maxX = max(maxX, point.dx);
      minY = min(minY, point.dy);
      maxY = max(maxY, point.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _normalizeToBounds(double value, double minValue, double span) {
    if (span <= 1e-6) {
      return 0.5;
    }
    return ((value - minValue) / span).clamp(0.0, 1.0).toDouble();
  }

  static double _templateGeometrySimilarity(
    KanjiStrokeTemplate expected,
    KanjiStrokeTemplate actual,
  ) {
    final paired = min(expected.strokes.length, actual.strokes.length);
    if (paired == 0) {
      return 0;
    }

    const maxDistance = 1.41421356237;
    double total = 0;
    for (var i = 0; i < paired; i++) {
      final expectedStroke = expected.strokes[i];
      final actualStroke = actual.strokes[i];
      final startDistance = _pointDistance(
        expectedStroke.start.x,
        expectedStroke.start.y,
        actualStroke.start.x,
        actualStroke.start.y,
      );
      final endDistance = _pointDistance(
        expectedStroke.end.x,
        expectedStroke.end.y,
        actualStroke.end.x,
        actualStroke.end.y,
      );
      final endpointScore =
          1.0 -
          ((startDistance + endDistance) / (2 * maxDistance)).clamp(0.0, 1.0);

      final expectedVector = Offset(
        expectedStroke.end.x - expectedStroke.start.x,
        expectedStroke.end.y - expectedStroke.start.y,
      );
      final actualVector = Offset(
        actualStroke.end.x - actualStroke.start.x,
        actualStroke.end.y - actualStroke.start.y,
      );
      total +=
          (endpointScore * 0.75) +
          (_directionSimilarity(expectedVector, actualVector) * 0.25);
    }

    final countPenalty =
        1.0 -
        (expected.strokes.length - actual.strokes.length).abs() /
            max(1.0, expected.strokes.length.toDouble() + 1.0);
    return ((total / paired) * 0.9) + (countPenalty.clamp(0.0, 1.0) * 0.1);
  }

  static double _pointDistance(double ax, double ay, double bx, double by) {
    return sqrt(pow(ax - bx, 2) + pow(ay - by, 2));
  }

  static double _directionSimilarity(Offset a, Offset b) {
    final aLength = a.distance;
    final bLength = b.distance;
    if (aLength < 1e-6 || bLength < 1e-6) {
      return 0.5;
    }
    final cos = ((a.dx * b.dx) + (a.dy * b.dy)) / (aLength * bLength);
    return ((cos.clamp(-1.0, 1.0) + 1) / 2).toDouble();
  }
}

class KanjiStrokeTemplate {
  const KanjiStrokeTemplate({
    required this.character,
    required this.strokes,
    this.targetArea = 0.32,
    this.targetAspect = 1.0,
    this.quality = 'manual',
  });

  final String character;
  final List<StrokeTemplate> strokes;
  final double targetArea;
  final double targetAspect;
  final String quality;

  String get normalizedQuality => quality.toLowerCase().trim();

  bool get isHighConfidence => normalizedQuality == 'manual';

  bool get isMediumConfidence => normalizedQuality == 'curated';

  KanjiStrokeTemplate copyWith({
    List<StrokeTemplate>? strokes,
    double? targetArea,
    double? targetAspect,
    String? quality,
  }) {
    return KanjiStrokeTemplate(
      character: character,
      strokes: strokes ?? this.strokes,
      targetArea: targetArea ?? this.targetArea,
      targetAspect: targetAspect ?? this.targetAspect,
      quality: quality ?? this.quality,
    );
  }

  factory KanjiStrokeTemplate.fromJson(Map<String, dynamic> json) {
    return KanjiStrokeTemplate(
      character: json['character'] as String,
      strokes: (json['strokes'] as List<dynamic>)
          .map((e) => StrokeTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      targetArea: (json['targetArea'] as num?)?.toDouble() ?? 0.32,
      targetAspect: (json['targetAspect'] as num?)?.toDouble() ?? 1.0,
      quality: (json['quality'] as String?)?.trim().isNotEmpty == true
          ? (json['quality'] as String).trim()
          : 'manual',
    );
  }
}

class StrokeTemplate {
  const StrokeTemplate({required this.start, required this.end});

  final Point<double> start;
  final Point<double> end;

  factory StrokeTemplate.fromJson(Map<String, dynamic> json) {
    final start = (json['start'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final end = (json['end'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    return StrokeTemplate(
      start: Point(start[0], start[1]),
      end: Point(end[0], end[1]),
    );
  }
}

class _ProjectedStroke {
  const _ProjectedStroke({required this.start, required this.end});

  final Offset start;
  final Offset end;
}
