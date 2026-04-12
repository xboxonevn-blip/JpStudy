import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

class HandwritingCanvas extends StatelessWidget {
  const HandwritingCanvas({
    super.key,
    required this.strokes,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
    required this.showGuide,
    required this.guideText,
    this.guideSlotCount = 1,
    this.enabled = true,
  });

  final List<List<Offset>> strokes;
  final ValueChanged<Offset> onStrokeStart;
  final ValueChanged<Offset> onStrokeUpdate;
  final VoidCallback onStrokeEnd;
  final bool showGuide;
  final String guideText;
  final int guideSlotCount;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: enabled
          ? (details) => onStrokeStart(details.localPosition)
          : null,
      onPanUpdate: enabled
          ? (details) => onStrokeUpdate(details.localPosition)
          : null,
      onPanEnd: enabled ? (_) => onStrokeEnd() : null,
      child: CustomPaint(
        painter: _HandwritingPainter(
          strokes: strokes,
          showGuide: showGuide,
          guideText: guideText,
          guideSlotCount: guideSlotCount,
          textStyle: Theme.of(context).textTheme.displayMedium,
          gridColor: context.appPalette.outline,
          guideColor: context.appPalette.ink.withValues(alpha: 0.12),
          strokeColor: context.appPalette.ink,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HandwritingPainter extends CustomPainter {
  _HandwritingPainter({
    required this.strokes,
    required this.showGuide,
    required this.guideText,
    required this.guideSlotCount,
    required this.textStyle,
    required this.gridColor,
    required this.guideColor,
    required this.strokeColor,
  });

  final List<List<Offset>> strokes;
  final bool showGuide;
  final String guideText;
  final int guideSlotCount;
  final TextStyle? textStyle;
  final Color gridColor;
  final Color guideColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    if (showGuide && guideText.trim().isNotEmpty) {
      _drawGuide(canvas, size);
    }
    _drawStrokes(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final slotCount = math.max(1, guideSlotCount);
    final slotWidth = size.width / slotCount;
    final thirdH = size.height / 3;

    for (int row = 1; row < 3; row++) {
      canvas.drawLine(
        Offset(0, thirdH * row),
        Offset(size.width, thirdH * row),
        paint,
      );
    }

    for (int slot = 0; slot < slotCount; slot++) {
      final startX = slot * slotWidth;
      for (int col = 1; col < 3; col++) {
        final x = startX + (slotWidth * col / 3);
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }

    for (int slot = 1; slot < slotCount; slot++) {
      final x = slot * slotWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final borderPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  void _drawGuide(Canvas canvas, Size size) {
    final slotCount = math.max(1, guideSlotCount);
    final characters = guideText.runes
        .map(String.fromCharCode)
        .toList(growable: false);
    final color = guideColor;

    if (slotCount <= 1 || characters.length <= 1) {
      final style = (textStyle ?? const TextStyle()).copyWith(
        fontSize: size.shortestSide * 0.6,
        color: color,
        fontWeight: FontWeight.w600,
      );
      final painter = TextPainter(
        text: TextSpan(text: guideText, style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      final offset = Offset(
        (size.width - painter.width) / 2,
        (size.height - painter.height) / 2,
      );
      painter.paint(canvas, offset);
      return;
    }

    final slotWidth = size.width / slotCount;
    final fontSize = math.min(size.height, slotWidth) * 0.58;
    final style = (textStyle ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.w600,
    );
    final guideCount = math.min(slotCount, characters.length);
    for (var i = 0; i < guideCount; i++) {
      final painter = TextPainter(
        text: TextSpan(text: characters[i], style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slotWidth);
      final dx = (slotWidth * i) + ((slotWidth - painter.width) / 2);
      final dy = (size.height - painter.height) / 2;
      painter.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawStrokes(Canvas canvas) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandwritingPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.showGuide != showGuide ||
        oldDelegate.guideText != guideText ||
        oldDelegate.guideSlotCount != guideSlotCount ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.guideColor != guideColor ||
        oldDelegate.strokeColor != strokeColor;
  }
}
