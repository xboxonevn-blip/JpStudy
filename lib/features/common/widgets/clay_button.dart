import 'package:flutter/material.dart';
import '../../../app/theme/app_theme.dart';

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

  Color get _baseColor {
    switch (widget.style) {
      case ClayButtonStyle.primary:
        return AppTheme.primary;
      case ClayButtonStyle.secondary:
        return AppTheme.secondary;
      case ClayButtonStyle.tertiary:
        return AppTheme.tertiary;
      case ClayButtonStyle.neutral:
        return Colors.white;
      case ClayButtonStyle.error:
        return AppTheme.error;
    }
  }

  Color get _textColor {
    switch (widget.style) {
      case ClayButtonStyle.neutral:
        return AppTheme.textSub;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _baseColor;
    final depthColor = AppTheme.getDepthColor(
      baseColor == Colors.white ? AppTheme.neutral : baseColor,
    );
    final borderColor = baseColor == Colors.white
        ? AppTheme.neutral
        : depthColor;

    // When pressed, we translate Y by 4px and remove shadow to simulate depression

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: _textColor, size: (widget.fontSize ?? 14) + 4),
          const SizedBox(width: 8),
        ],
        Text(
          widget.upperCase ? widget.label.toUpperCase() : widget.label,
          style: TextStyle(
            color: _textColor,
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
            border: Border.all(
              color: borderColor,
              width: 2, // Thicker border for cartoon look
            ),
            boxShadow: [
              if (!_isPressed)
                BoxShadow(
                  color: borderColor,
                  offset: const Offset(0, 4), // The "height" of the button
                  blurRadius: 0, // Sharp shadow for flat/clay look
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
