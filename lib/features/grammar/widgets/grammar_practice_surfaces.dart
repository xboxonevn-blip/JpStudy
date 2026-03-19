import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

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
  });

  final String marker;
  final String label;
  final GrammarOptionState state;
  final VoidCallback? onTap;

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
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: scheme.background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.border),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
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
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.text,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: scheme.icon, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  _OptionScheme _schemeForState(AppThemePalette palette) {
    return switch (state) {
      GrammarOptionState.correct => _OptionScheme(
        background: const Color(0xFFF1FBF6),
        border: const Color(0xFFB9E6CE),
        shadow: const Color(0x132D8A63),
        badgeBackground: const Color(0xFFE1F5EA),
        badgeBorder: const Color(0xFFB9E6CE),
        badgeText: const Color(0xFF1E6A4D),
        icon: const Color(0xFF2D8A63),
        text: const Color(0xFF1E6A4D),
      ),
      GrammarOptionState.incorrect => _OptionScheme(
        background: const Color(0xFFFFF5F5),
        border: const Color(0xFFF2C2C8),
        shadow: const Color(0x14C44F59),
        badgeBackground: const Color(0xFFFFE7EA),
        badgeBorder: const Color(0xFFF2C2C8),
        badgeText: const Color(0xFFA13C45),
        icon: const Color(0xFFC44F59),
        text: const Color(0xFF8F3942),
      ),
      GrammarOptionState.selected => _OptionScheme(
        background: const Color(0xFFF3F8FF),
        border: const Color(0xFFCFE0F7),
        shadow: const Color(0x112A5A8A),
        badgeBackground: const Color(0xFFE7F0FC),
        badgeBorder: const Color(0xFFCFE0F7),
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
