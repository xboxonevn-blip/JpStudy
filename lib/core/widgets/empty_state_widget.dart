import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// A reusable empty / error state widget.
///
/// Use [EmptyStateWidget] anywhere data is absent or unavailable:
///   - async error cases (`error: (e, s) => EmptyStateWidget(...)`)
///   - filtered lists that return zero results
///   - first-launch placeholders
///
/// [compact] shrinks the widget for inline use inside cards.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.color,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? color;

  /// When true, reduces padding and font sizes for use inside cards/panels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? const Color(0xFF94A3B8);
    final double iconSize = compact ? 32 : 48;
    final double titleSize = compact ? 13 : 16;
    final double subtitleSize = compact ? 11 : 13;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxxl,
            vertical: AppSpacing.xxl,
          );

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 48 : 72,
            height: compact ? 48 : 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: subtitleSize,
                color: const Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
          if (action != null) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
