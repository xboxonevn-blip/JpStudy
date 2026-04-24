import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';

const _testFrameProgress = 0.35;
bool get _isWidgetTestBinding => WidgetsBinding.instance.runtimeType
    .toString()
    .contains('TestWidgetsFlutterBinding');

class SakuraParticles extends StatefulWidget {
  const SakuraParticles({super.key, this.petalCount = 20});

  final int petalCount;

  @override
  State<SakuraParticles> createState() => _SakuraParticlesState();
}

class _SakuraParticlesState extends State<SakuraParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Petal> _petals;
  bool _reduceMotion = false;
  bool _motionPreferenceInitialized = false;

  @override
  void initState() {
    super.initState();
    _seedPetals();
    final isWidgetTest = _isWidgetTestBinding;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      value: isWidgetTest ? _testFrameProgress : 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotionPreference();
  }

  @override
  void didUpdateWidget(covariant SakuraParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.petalCount != widget.petalCount) {
      _seedPetals();
    }
  }

  void _syncMotionPreference() {
    final reduceMotion = reducedMotionEnabled(context);
    if (_motionPreferenceInitialized && _reduceMotion == reduceMotion) {
      return;
    }
    _motionPreferenceInitialized = true;
    _reduceMotion = reduceMotion;
    if (_reduceMotion || _isWidgetTestBinding) {
      _controller.stop();
      _controller.value = _isWidgetTestBinding ? _testFrameProgress : 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _seedPetals() {
    final rng = Random();
    _petals = List.generate(widget.petalCount, (_) => _Petal(rng));
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) return const SizedBox.shrink();
    if (_isWidgetTestBinding) {
      return IgnorePointer(
        child: CustomPaint(
          painter: _SakuraPainter(_petals, _testFrameProgress),
          size: Size.infinite,
        ),
      );
    }

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
    final paint = Paint()..color = const Color(0x5CFFB7C5);

    for (final petal in petals) {
      final progress = (t * petal.speed + petal.phase) % 1.0;
      final y = -20 + progress * (size.height + 40);
      final x =
          petal.startX * size.width +
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
