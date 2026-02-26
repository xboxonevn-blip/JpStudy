import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Legacy primary-action button with squish + haptic animation.
///
/// Prefer [ClayButton] (`features/common/widgets/clay_button.dart`) for new
/// code — it is the project-standard button with 5 style variants and
/// consistent clay-morphism aesthetics.
@Deprecated('Use ClayButton instead.')
class JuicyButton extends StatefulWidget {
  const JuicyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.height = 56.0,
    this.width,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final double height;
  final double? width;
  final bool enabled;

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animate down
    await _controller.forward();
    // Animate up
    await _controller.reverse();

    // Execute callback
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.color ?? theme.colorScheme.primary;
    final shadowColor = HSLColor.fromColor(
      baseColor,
    ).withLightness(0.4).toColor();

    return GestureDetector(
      onTapDown: (_) => widget.enabled ? _controller.forward() : null,
      onTapUp: (_) => widget.enabled ? _controller.reverse() : null,
      onTapCancel: () => widget.enabled ? _controller.reverse() : null,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(scale: _scale.value, child: child);
        },
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.enabled
                ? baseColor
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.enabled
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.enabled
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
