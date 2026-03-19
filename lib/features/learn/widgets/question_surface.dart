import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme_palette.dart';

class QuestionPromptCard extends StatelessWidget {
  const QuestionPromptCard({
    super.key,
    required this.label,
    required this.title,
    required this.prompt,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.centered = true,
  });

  final String label;
  final String title;
  final String prompt;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final alignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.elevated, palette.base],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: centered ? WrapAlignment.center : WrapAlignment.start,
            children: [
              _PromptChip(label: label, icon: icon, color: accentColor),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: centered ? 34 : 24,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: palette.ink,
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!.trim(),
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: palette.ink.withValues(alpha: 0.66),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
            ),
            child: Text(
              prompt,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionChoiceTile extends StatelessWidget {
  const QuestionChoiceTile({
    super.key,
    required this.title,
    required this.accentColor,
    this.leadingLabel,
    this.leadingIcon,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.onTap,
  });

  final String title;
  final Color accentColor;
  final String? leadingLabel;
  final IconData? leadingIcon;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final stateColor = isCorrect
        ? palette.success
        : isWrong
        ? palette.error
        : isSelected
        ? accentColor
        : palette.primary;
    final backgroundColor = isCorrect
        ? palette.success.withValues(alpha: 0.10)
        : isWrong
        ? palette.error.withValues(alpha: 0.10)
        : isSelected
        ? accentColor.withValues(alpha: 0.10)
        : palette.base;
    final borderColor = isCorrect
        ? palette.success.withValues(alpha: 0.26)
        : isWrong
        ? palette.error.withValues(alpha: 0.26)
        : isSelected
        ? accentColor.withValues(alpha: 0.22)
        : palette.outlineSoft;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _LeadingBadge(
                label: leadingLabel,
                icon: leadingIcon,
                color: stateColor,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: isWrong ? palette.error : palette.ink,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : isWrong
                    ? Icons.cancel_rounded
                    : isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: stateColor.withValues(
                  alpha: isSelected || isCorrect || isWrong ? 1 : 0.72,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionInfoCard extends StatelessWidget {
  const QuestionInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  const _LeadingBadge({this.label, this.icon, required this.color});

  final String? label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      alignment: Alignment.center,
      child: label != null
          ? Text(
              label!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            )
          : Icon(icon, color: color, size: 18),
    );
  }
}
