import 'package:flutter/material.dart';
import '../../../app/theme/app_theme_palette.dart';

class ClayCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ClayCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  static Color _depthColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final baseColor = color ?? palette.elevated;
    final isDefault = color == null;
    final depthColor = _depthColor(isDefault ? palette.outline : baseColor);
    final borderColor = isDefault ? palette.outline : depthColor;

    return Semantics(
      container: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
