import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/features/common/widgets/sakura_particles.dart';

class JapaneseBackground extends StatelessWidget {
  const JapaneseBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final gradientColors = [palette.bg, palette.surface, palette.base];
    // Subtle repeating arc pattern — low-alpha ink ensures correct contrast
    // on both light (warm-tinted surfaces) and dark themes.
    final patternColor = palette.ink.withValues(alpha: 0.07);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WavePatternPainter(color: patternColor),
            ),
          ),
        ),
        Positioned(
          top: -72,
          right: -40,
          child: _Orb(
            size: 220,
            colors: [
              palette.warning.withValues(alpha: 0.28),
              palette.warning.withValues(alpha: 0),
            ],
          ),
        ),
        Positioned(
          bottom: -96,
          left: -60,
          child: _Orb(
            size: 260,
            colors: [
              palette.info.withValues(alpha: 0.28),
              palette.info.withValues(alpha: 0),
            ],
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final petalCount = constraints.maxWidth >= 1200
                  ? 34
                  : constraints.maxWidth >= 800
                  ? 28
                  : 20;
              return SakuraParticles(petalCount: petalCount);
            },
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}

class _WavePatternPainter extends CustomPainter {
  const _WavePatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const cellSize = 40.0;
    const arcs = 4;

    var row = 0;
    for (double y = -cellSize; y < size.height + cellSize * 2; y += cellSize) {
      final xShift = row.isEven ? 0.0 : cellSize;
      for (
        double x = -cellSize * 2;
        x < size.width + cellSize * 2;
        x += cellSize * 2
      ) {
        final cx = x + xShift;
        final cy = y;
        for (var i = 1; i <= arcs; i++) {
          final r = cellSize * i / arcs;
          canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy), radius: r),
            3.14159, // pi — start from bottom
            3.14159, // pi — sweep half circle
            false,
            paint,
          );
        }
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _WavePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
