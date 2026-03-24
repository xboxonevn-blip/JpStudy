import 'package:flutter/material.dart';
import '../../../app/theme/app_theme_palette.dart';

enum ClayButtonStyle { primary, secondary, tertiary, neutral, error }

class ClayButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ClayButtonStyle style;
  final bool isExpanded;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final bool upperCase;

  const ClayButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = ClayButtonStyle.primary,
    this.isExpanded = false,
    this.width,
    this.height,
    this.padding,
    this.fontSize,
    this.upperCase = true,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  Color _baseColor(AppThemePalette palette) {
    switch (widget.style) {
      case ClayButtonStyle.primary:
        return palette.primary;
      case ClayButtonStyle.secondary:
        return palette.secondary;
      case ClayButtonStyle.tertiary:
        return palette.accent;
      case ClayButtonStyle.neutral:
        return palette.elevated;
      case ClayButtonStyle.error:
        return palette.error;
    }
  }

  Color _textColor(AppThemePalette palette) {
    switch (widget.style) {
      case ClayButtonStyle.neutral:
        return palette.ink.withValues(alpha: 0.6);
      default:
        return Colors.white;
    }
  }

  static Color _depthColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final baseColor = _baseColor(palette);
    final isNeutral = widget.style == ClayButtonStyle.neutral;
    final depthColor = _depthColor(isNeutral ? palette.outline : baseColor);
    final borderColor = isNeutral ? palette.outline : depthColor;

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: _textColor(palette),
            size: (widget.fontSize ?? 14) + 4,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          widget.upperCase ? widget.label.toUpperCase() : widget.label,
          style: TextStyle(
            color: _textColor(palette),
            fontWeight: FontWeight.w800,
            fontSize: widget.fontSize ?? 14,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    if (widget.isExpanded) {
      content = Center(child: content);
    }

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                if (!_isPressed)
                  BoxShadow(
                    color: borderColor,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
              ],
            ),
            child: widget.height != null || widget.width != null
                ? Center(child: content)
                : content,
          ),
        ),
      ),
    );
  }
}
