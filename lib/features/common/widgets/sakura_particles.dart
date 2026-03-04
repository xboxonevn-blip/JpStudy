import 'dart:math';
import 'package:flutter/material.dart';

class SakuraParticles extends StatefulWidget {
  const SakuraParticles({super.key});

  @override
  State<SakuraParticles> createState() => _SakuraParticlesState();
}

class _SakuraParticlesState extends State<SakuraParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Petal> _petals;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _petals = List.generate(7, (_) => _Petal(rng));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    if (reducedMotion) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SakuraPainter(_petals, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Petal {
  _Petal(Random rng)
      : startX = rng.nextDouble(),
        speed = 0.6 + rng.nextDouble() * 0.4,
        drift = 0.02 + rng.nextDouble() * 0.06,
        phase = rng.nextDouble(),
        size = 4.0 + rng.nextDouble() * 4.0,
        rotationSpeed = 0.5 + rng.nextDouble();

  final double startX;
  final double speed;
  final double drift;
  final double phase;
  final double size;
  final double rotationSpeed;
}

class _SakuraPainter extends CustomPainter {
  _SakuraPainter(this.petals, this.t);

  final List<_Petal> petals;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x40FFB7C5);

    for (final petal in petals) {
      final progress = (t * petal.speed + petal.phase) % 1.0;
      final y = -20 + progress * (size.height + 40);
      final x = petal.startX * size.width +
          sin(progress * 3.14159 * 2 * petal.rotationSpeed) *
              size.width *
              petal.drift;
      final rotation = progress * 3.14159 * 2 * petal.rotationSpeed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petal.size,
          height: petal.size * 1.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SakuraPainter oldDelegate) => true;
}
