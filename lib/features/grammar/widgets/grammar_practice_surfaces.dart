import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';

enum GrammarOptionState { idle, selected, correct, incorrect }

class GrammarPracticePanel extends StatelessWidget {
  const GrammarPracticePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final background = backgroundColor ?? palette.elevated;
    final border = borderColor ?? palette.outline;
    final shadow = shadowColor ?? palette.ink.withValues(alpha: 0.08);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class GrammarPromptCard extends StatelessWidget {
  const GrammarPromptCard({
    super.key,
    required this.eyebrow,
    required this.title,
    this.detail,
    this.trailing,
    this.centerContent = false,
  });

  final String eyebrow;
  final String title;
  final String? detail;
  final Widget? trailing;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: palette.ink,
      fontWeight: FontWeight.w800,
      height: 1.3,
    );
    final detailStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: palette.ink.withValues(alpha: 0.7),
      height: 1.55,
      fontWeight: FontWeight.w600,
    );

    return GrammarPracticePanel(
      backgroundColor: palette.elevated,
      child: Column(
        crossAxisAlignment: centerContent
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  eyebrow,
                  textAlign: centerContent ? TextAlign.center : TextAlign.left,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: palette.accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: centerContent ? TextAlign.center : TextAlign.left,
            style: titleStyle,
          ),
          if ((detail ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              detail!,
              textAlign: centerContent ? TextAlign.center : TextAlign.left,
              style: detailStyle,
            ),
          ],
        ],
      ),
    );
  }
}

class GrammarOptionTile extends StatelessWidget {
  const GrammarOptionTile({
    super.key,
    required this.marker,
    required this.label,
    required this.state,
    required this.onTap,
    this.compact = false,
  });

  final String marker;
  final String label;
  final GrammarOptionState state;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final scheme = _schemeForState(palette);
    final icon = switch (state) {
      GrammarOptionState.correct => Icons.check_circle_rounded,
      GrammarOptionState.incorrect => Icons.cancel_rounded,
      GrammarOptionState.selected => Icons.radio_button_checked_rounded,
      GrammarOptionState.idle => Icons.radio_button_unchecked_rounded,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 16 : 22),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: compact ? 52 : 0),
          child: AnimatedContainer(
            duration: reducedMotionDuration(
              context,
              const Duration(milliseconds: 180),
            ),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 9 : 15,
            ),
            decoration: BoxDecoration(
              color: scheme.background,
              borderRadius: BorderRadius.circular(compact ? 16 : 22),
              border: Border.all(color: scheme.border),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow,
                  blurRadius: compact ? 8 : 16,
                  offset: Offset(0, compact ? 3 : 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 28 : 34,
                  height: compact ? 28 : 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: scheme.badgeBorder),
                  ),
                  child: Text(
                    marker,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.badgeText,
                      fontWeight: FontWeight.w900,
                      fontSize: compact ? 12 : null,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 10 : 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: compact ? 3 : null,
                    overflow: compact ? TextOverflow.ellipsis : null,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.bodyMedium
                                : Theme.of(context).textTheme.bodyLarge)
                            ?.copyWith(
                              color: scheme.text,
                              height: compact ? 1.24 : 1.45,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                ),
                SizedBox(width: compact ? 8 : 12),
                Icon(icon, color: scheme.icon, size: compact ? 20 : 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _OptionScheme _schemeForState(AppThemePalette palette) {
    return switch (state) {
      GrammarOptionState.correct => _OptionScheme(
        background: palette.success.withValues(alpha: 0.06),
        border: palette.success.withValues(alpha: 0.32),
        shadow: palette.success.withValues(alpha: 0.075),
        badgeBackground: palette.success.withValues(alpha: 0.14),
        badgeBorder: palette.success.withValues(alpha: 0.32),
        badgeText: palette.success,
        icon: palette.success,
        text: palette.success,
      ),
      GrammarOptionState.incorrect => _OptionScheme(
        background: palette.error.withValues(alpha: 0.05),
        border: palette.error.withValues(alpha: 0.28),
        shadow: palette.error.withValues(alpha: 0.08),
        badgeBackground: palette.error.withValues(alpha: 0.12),
        badgeBorder: palette.error.withValues(alpha: 0.28),
        badgeText: palette.error,
        icon: palette.error,
        text: palette.error,
      ),
      GrammarOptionState.selected => _OptionScheme(
        background: palette.primary.withValues(alpha: 0.06),
        border: palette.primary.withValues(alpha: 0.24),
        shadow: palette.primary.withValues(alpha: 0.065),
        badgeBackground: palette.primary.withValues(alpha: 0.12),
        badgeBorder: palette.primary.withValues(alpha: 0.24),
        badgeText: palette.primary,
        icon: palette.primary,
        text: palette.ink,
      ),
      GrammarOptionState.idle => _OptionScheme(
        background: palette.elevated,
        border: palette.outline,
        shadow: palette.ink.withValues(alpha: 0.06),
        badgeBackground: palette.surface,
        badgeBorder: palette.outlineSoft,
        badgeText: palette.ink.withValues(alpha: 0.72),
        icon: palette.ink.withValues(alpha: 0.44),
        text: palette.ink,
      ),
    };
  }
}

String grammarChoiceMarker(int index) => String.fromCharCode(65 + (index % 26));

class _OptionScheme {
  const _OptionScheme({
    required this.background,
    required this.border,
    required this.shadow,
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
    required this.icon,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color shadow;
  final Color badgeBackground;
  final Color badgeBorder;
  final Color badgeText;
  final Color icon;
  final Color text;
}
