import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'kanji_stroke_vector_service.dart';

const double kanjiStrokeGuidePaddingRatio = 0.09;

KanjiStrokeVectorLayout computeKanjiStrokeVectorLayout(
  KanjiStrokeVector vector,
  Size size,
) {
  final viewBoxWidth = vector.width <= 0 ? 109.0 : vector.width;
  final viewBoxHeight = vector.height <= 0 ? 109.0 : vector.height;
  final padding = size.shortestSide * kanjiStrokeGuidePaddingRatio;
  final usableWidth = math.max(1e-6, size.width - (padding * 2));
  final usableHeight = math.max(1e-6, size.height - (padding * 2));
  final scale = math.min(
    usableWidth / viewBoxWidth,
    usableHeight / viewBoxHeight,
  );
  final drawWidth = viewBoxWidth * scale;
  final drawHeight = viewBoxHeight * scale;
  final translateX = (size.width - drawWidth) / 2 - (vector.minX * scale);
  final translateY = (size.height - drawHeight) / 2 - (vector.minY * scale);
  final matrix = Matrix4.identity()
    ..setEntry(0, 0, scale)
    ..setEntry(1, 1, scale)
    ..setEntry(0, 3, translateX)
    ..setEntry(1, 3, translateY);
  return KanjiStrokeVectorLayout(
    scale: scale,
    translateX: translateX,
    translateY: translateY,
    matrix: matrix,
  );
}

class KanjiStrokeVectorLayout {
  const KanjiStrokeVectorLayout({
    required this.scale,
    required this.translateX,
    required this.translateY,
    required this.matrix,
  });

  final double scale;
  final double translateX;
  final double translateY;
  final Matrix4 matrix;

  Offset transformOffset(Offset point) {
    return Offset(
      translateX + (point.dx * scale),
      translateY + (point.dy * scale),
    );
  }

  Rect transformRect(Rect rect) {
    return Rect.fromLTRB(
      translateX + (rect.left * scale),
      translateY + (rect.top * scale),
      translateX + (rect.right * scale),
      translateY + (rect.bottom * scale),
    );
  }
}
