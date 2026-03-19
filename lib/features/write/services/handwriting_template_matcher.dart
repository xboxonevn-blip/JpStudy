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
    final normalizedUser = _normalizeStrokeEndpoints(strokes);
    final expected = template.strokes.length;
    final paired = min(normalizedUser.length, expected);
    if (paired == 0) return 0;

    const maxDistance = 1.41421356237; // sqrt(2)
    double pairScore = 0;
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
      pairScore += (startEndScore * 0.7) + (directionScore * 0.3);
    }
    pairScore /= paired;
    final countPenalty =
        1.0 -
        (strokes.length - expected).abs() / max(1.0, expected.toDouble() + 1.0);
    return (pairScore * 0.85) + (countPenalty.clamp(0.0, 1.0) * 0.15);
  }

  static double templateOrderScore({
    required List<List<Offset>> strokes,
    required KanjiStrokeTemplate template,
  }) {
    if (strokes.isEmpty || template.strokes.isEmpty) return 0;
    final normalizedUser = _normalizeStrokeEndpoints(strokes);
    final paired = min(normalizedUser.length, template.strokes.length);
    if (paired == 0) return 0;
    const maxDistance = 1.41421356237; // sqrt(2)
    double total = 0;
    for (var i = 0; i < paired; i++) {
      final userStart = normalizedUser[i].start;
      final specStart = template.strokes[i].start;
      final distance = _pointDistance(userStart, specStart.x, specStart.y);
      total += 1.0 - (distance / maxDistance).clamp(0.0, 1.0);
    }
    return total / paired;
  }

  static double templateDirectionScore({
    required List<List<Offset>> strokes,
    required KanjiStrokeTemplate template,
  }) {
    if (strokes.isEmpty || template.strokes.isEmpty) return 0;
    final normalizedUser = _normalizeStrokeEndpoints(strokes);
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

  static List<_StrokeEndpoints> _normalizeStrokeEndpoints(
    List<List<Offset>> strokes,
  ) {
    final meaningful = strokes.where((stroke) => stroke.length > 1).toList();
    if (meaningful.isEmpty) return const [];
    final points = <Offset>[for (final stroke in meaningful) ...stroke];
    final minX = points.map((p) => p.dx).reduce(min);
    final maxX = points.map((p) => p.dx).reduce(max);
    final minY = points.map((p) => p.dy).reduce(min);
    final maxY = points.map((p) => p.dy).reduce(max);
    final width = max(1e-6, maxX - minX);
    final height = max(1e-6, maxY - minY);

    return meaningful
        .map(
          (stroke) => _StrokeEndpoints(
            start: Offset(
              ((stroke.first.dx - minX) / width).clamp(0.0, 1.0),
              ((stroke.first.dy - minY) / height).clamp(0.0, 1.0),
            ),
            end: Offset(
              ((stroke.last.dx - minX) / width).clamp(0.0, 1.0),
              ((stroke.last.dy - minY) / height).clamp(0.0, 1.0),
            ),
          ),
        )
        .toList();
  }

  static double _pointDistance(Offset point, double x, double y) {
    return sqrt(pow(point.dx - x, 2) + pow(point.dy - y, 2));
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

class _StrokeEndpoints {
  const _StrokeEndpoints({required this.start, required this.end});

  final Offset start;
  final Offset end;
}
