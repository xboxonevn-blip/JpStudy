import 'package:flutter/material.dart';
import 'package:jpstudy/features/common/widgets/sakura_particles.dart';

class JapaneseBackground extends StatelessWidget {
  const JapaneseBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF111827), Color(0xFF1F2937), Color(0xFF0F172A)]
        : const [Color(0xFFF7F2E8), Color(0xFFFDF7EF), Color(0xFFF5EEE3)];
    final patternColor = isDark
        ? const Color(0x12FFFFFF)
        : const Color(0x120F172A);

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
            colors: isDark
                ? const [Color(0x4022D3EE), Color(0x00111827)]
                : const [Color(0x55F59E0B), Color(0x00FDE68A)],
          ),
        ),
        Positioned(
          bottom: -96,
          left: -60,
          child: _Orb(
            size: 260,
            colors: isDark
                ? const [Color(0x4034D399), Color(0x000F172A)]
                : const [Color(0x5538BDF8), Color(0x00BFDBFE)],
          ),
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 900) return const SizedBox.shrink();
              return const SakuraParticles();
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
      for (double x = -cellSize * 2; x < size.width + cellSize * 2; x += cellSize * 2) {
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
