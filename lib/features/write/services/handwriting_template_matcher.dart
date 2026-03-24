import 'dart:math';

import 'package:flutter/material.dart';

import 'kanji_stroke_template_service.dart';

class HandwritingTemplateMatcher {
  const HandwritingTemplateMatcher._();

  static double templateScore({
    required List<List<Offset>> strokes,
    required KanjiStrokeTemplate template,
  }) {
    if (strokes.isEmpty || template.strokes.isEmpty) {
      return 0;
    }
    final normalizedUser = _normalizeStrokes(strokes);
    final expected = template.strokes.length;
    final paired = min(normalizedUser.length, expected);
    if (paired == 0) return 0;

    const maxDistance = 1.41421356237; // sqrt(2)
    double pairScore = 0;
    final usesStrictPathScore = expected <= 2;
    for (var i = 0; i < paired; i++) {
      final user = normalizedUser[i];
      final spec = template.strokes[i];
      final startDistance = _pointDistance(
        user.start,
        spec.start.x,
        spec.start.y,
      );
      final endDistance = _pointDistance(user.end, spec.end.x, spec.end.y);
      final startEndScore =
          1.0 -
          ((startDistance + endDistance) / (2 * maxDistance)).clamp(0.0, 1.0);

      final userVector = Offset(
        user.end.dx - user.start.dx,
        user.end.dy - user.start.dy,
      );
      final templateVector = Offset(
        spec.end.x - spec.start.x,
        spec.end.y - spec.start.y,
      );
      final directionScore = _directionSimilarity(userVector, templateVector);
      final templateCenter = Offset(
        (spec.start.x + spec.end.x) / 2,
        (spec.start.y + spec.end.y) / 2,
      );
      final centerScore =
          1.0 -
          (_pointDistance(user.center, templateCenter.dx, templateCenter.dy) /
                  0.75)
              .clamp(0.0, 1.0);
      final lineScore = _lineProximityScore(
        user.points,
        Offset(spec.start.x, spec.start.y),
        Offset(spec.end.x, spec.end.y),
      );
      final lengthScore = _lengthSimilarity(
        user.pathLength,
        templateVector.distance,
      );
      if (usesStrictPathScore) {
        pairScore +=
            (startEndScore * 0.28) +
            (directionScore * 0.18) +
            (centerScore * 0.14) +
            (lineScore * 0.28) +
            (lengthScore * 0.12);
      } else {
        pairScore +=
            (startEndScore * 0.44) +
            (directionScore * 0.24) +
            (centerScore * 0.18) +
            (lengthScore * 0.14);
      }
    }
    pairScore /= paired;
    final countPenalty =
        1.0 -
        (strokes.length - expected).abs() / max(1.0, expected.toDouble() + 1.0);
    return (pairScore * 0.75) + (countPenalty.clamp(0.0, 1.0) * 0.25);
  }

  static double templateOrderScore({
    required List<List<Offset>> strokes,
    required KanjiStrokeTemplate template,
  }) {
    if (strokes.isEmpty || template.strokes.isEmpty) return 0;
    final normalizedUser = _normalizeStrokes(strokes);
    final paired = min(normalizedUser.length, template.strokes.length);
    if (paired == 0) return 0;
    const maxDistance = 1.41421356237; // sqrt(2)
    double total = 0;
    for (var i = 0; i < paired; i++) {
      final user = normalizedUser[i];
      final spec = template.strokes[i];
      final startDistance = _pointDistance(
        user.start,
        spec.start.x,
        spec.start.y,
      );
      final endDistance = _pointDistance(user.end, spec.end.x, spec.end.y);
      final templateCenter = Offset(
        (spec.start.x + spec.end.x) / 2,
        (spec.start.y + spec.end.y) / 2,
      );
      final endpointScore =
          1.0 -
          ((startDistance + endDistance) / (2 * maxDistance)).clamp(0.0, 1.0);
      final centerScore =
          1.0 -
          (_pointDistance(user.center, templateCenter.dx, templateCenter.dy) /
                  0.75)
              .clamp(0.0, 1.0);
      final expectedIndex = _bestTemplateStrokeIndex(
        stroke: user,
        templates: template.strokes,
      );
      final alignmentPenalty = expectedIndex == i ? 1.0 : 0.52;
      total +=
          ((endpointScore * 0.74) + (centerScore * 0.26)) * alignmentPenalty;
    }
    return total / paired;
  }

  static double templateDirectionScore({
    required List<List<Offset>> strokes,
    required KanjiStrokeTemplate template,
  }) {
    if (strokes.isEmpty || template.strokes.isEmpty) return 0;
    final normalizedUser = _normalizeStrokes(strokes);
    final paired = min(normalizedUser.length, template.strokes.length);
    if (paired == 0) return 0;

    double total = 0;
    for (var i = 0; i < paired; i++) {
      final user = normalizedUser[i];
      final spec = template.strokes[i];
      final userVector = Offset(
        user.end.dx - user.start.dx,
        user.end.dy - user.start.dy,
      );
      final templateVector = Offset(
        spec.end.x - spec.start.x,
        spec.end.y - spec.start.y,
      );
      total += _directionSimilarity(userVector, templateVector);
    }
    return total / paired;
  }

  static List<_NormalizedStroke> _normalizeStrokes(List<List<Offset>> strokes) {
    final meaningful = strokes.where((stroke) => stroke.length > 1).toList();
    if (meaningful.isEmpty) return const [];
    final points = <Offset>[for (final stroke in meaningful) ...stroke];
    final minX = points.map((p) => p.dx).reduce(min);
    final maxX = points.map((p) => p.dx).reduce(max);
    final minY = points.map((p) => p.dy).reduce(min);
    final maxY = points.map((p) => p.dy).reduce(max);
    final width = max(1e-6, maxX - minX);
    final height = max(1e-6, maxY - minY);

    return meaningful.map((stroke) {
      final normalizedPoints = stroke
          .map(
            (point) => Offset(
              ((point.dx - minX) / width).clamp(0.0, 1.0),
              ((point.dy - minY) / height).clamp(0.0, 1.0),
            ),
          )
          .toList(growable: false);
      final pathLength = _pathLength(normalizedPoints);
      final center = _centerOfPoints(normalizedPoints);
      return _NormalizedStroke(
        points: normalizedPoints,
        start: normalizedPoints.first,
        end: normalizedPoints.last,
        center: center,
        pathLength: pathLength,
      );
    }).toList();
  }

  static double _pointDistance(Offset point, double x, double y) {
    return sqrt(pow(point.dx - x, 2) + pow(point.dy - y, 2));
  }

  static double _lineProximityScore(
    List<Offset> points,
    Offset start,
    Offset end,
  ) {
    if (points.isEmpty) return 0;
    final averageDistance =
        points
            .map((point) => _distanceToSegment(point, start, end))
            .reduce((sum, value) => sum + value) /
        points.length;
    return 1.0 - (averageDistance / 0.18).clamp(0.0, 1.0);
  }

  static double _distanceToSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;
    final lengthSquared = (segment.dx * segment.dx) + (segment.dy * segment.dy);
    if (lengthSquared < 1e-6) {
      return (point - start).distance;
    }
    final projection =
        (((point.dx - start.dx) * segment.dx) +
            ((point.dy - start.dy) * segment.dy)) /
        lengthSquared;
    final clampedProjection = projection.clamp(0.0, 1.0);
    final closest = Offset(
      start.dx + (segment.dx * clampedProjection),
      start.dy + (segment.dy * clampedProjection),
    );
    return (point - closest).distance;
  }

  static int _bestTemplateStrokeIndex({
    required _NormalizedStroke stroke,
    required List<StrokeTemplate> templates,
  }) {
    var bestIndex = 0;
    var bestScore = -1.0;
    for (var i = 0; i < templates.length; i++) {
      final spec = templates[i];
      final startDistance = _pointDistance(
        stroke.start,
        spec.start.x,
        spec.start.y,
      );
      final endDistance = _pointDistance(stroke.end, spec.end.x, spec.end.y);
      final templateCenter = Offset(
        (spec.start.x + spec.end.x) / 2,
        (spec.start.y + spec.end.y) / 2,
      );
      final centerDistance = _pointDistance(
        stroke.center,
        templateCenter.dx,
        templateCenter.dy,
      );
      final score =
          (1.0 - ((startDistance + endDistance) / 2).clamp(0.0, 1.0)) * 0.8 +
          (1.0 - centerDistance.clamp(0.0, 1.0)) * 0.2;
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static double _lengthSimilarity(double userLength, double templateLength) {
    if (templateLength < 1e-6) return 0.5;
    final delta = (userLength - templateLength).abs();
    final tolerance = max(0.18, templateLength * 0.55);
    return 1.0 - (delta / tolerance).clamp(0.0, 1.0);
  }

  static double _pathLength(List<Offset> points) {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  static Offset _centerOfPoints(List<Offset> points) {
    if (points.isEmpty) return Offset.zero;
    var totalX = 0.0;
    var totalY = 0.0;
    for (final point in points) {
      totalX += point.dx;
      totalY += point.dy;
    }
    return Offset(totalX / points.length, totalY / points.length);
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

class _NormalizedStroke {
  const _NormalizedStroke({
    required this.points,
    required this.start,
    required this.end,
    required this.center,
    required this.pathLength,
  });

  final List<Offset> points;
  final Offset start;
  final Offset end;
  final Offset center;
  final double pathLength;
}
