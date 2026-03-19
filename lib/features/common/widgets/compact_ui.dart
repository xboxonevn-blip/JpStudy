import 'package:flutter/material.dart';
import 'package:jpstudy/app/layout/app_responsive_frame.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

enum AppStatusTone { primary, success, warning, neutral }

class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.child,
    this.topPadding = 12,
    this.bottomPadding = AppSpacing.pageBottom,
  });

  final Widget child;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return JapaneseBackground(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          children: [AppResponsiveFrame(child: child)],
        ),
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.elevated, palette.base],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline.withValues(alpha: 0.95)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.caption,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? caption;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: palette.ink,
                ),
              ),
              if (caption != null && caption!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  caption!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(onPressed: onActionTap, child: Text(actionLabel!)),
      ],
    );
  }
}

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    this.tone = AppStatusTone.neutral,
  });

  final String label;
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final colors = switch (tone) {
      AppStatusTone.primary => (
        palette.primary.withValues(alpha: 0.12),
        palette.primary,
      ),
      AppStatusTone.success => (
        palette.success.withValues(alpha: 0.14),
        palette.success,
      ),
      AppStatusTone.warning => (
        palette.warning.withValues(alpha: 0.16),
        palette.warning,
      ),
      AppStatusTone.neutral => (
        palette.outlineSoft,
        palette.ink.withValues(alpha: 0.72),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: colors.$2.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class AppProgressStrip extends StatelessWidget {
  const AppProgressStrip({super.key, required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final normalized = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: palette.ink.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: palette.outlineSoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: normalized,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette.accent, palette.secondary],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppFeatureCard extends StatelessWidget {
  const AppFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.primaryLabel,
    this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? status;
  final String? primaryLabel;
  final VoidCallback? onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppSectionCard(
      padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -22,
            child: _AmbientOrb(
              size: compact ? 120 : 150,
              colors: [
                palette.accent.withValues(alpha: 0.16),
                palette.accent.withValues(alpha: 0.02),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: compact ? 46 : 54,
                    height: compact ? 46 : 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.primary, palette.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: compact ? 22 : 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: compact ? 18 : 24,
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                        height: 1.15,
                      ),
                    ),
                  ),
                  if (status != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    status!,
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [palette.accent, palette.secondary],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  color: palette.ink.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (primaryLabel != null || secondaryLabel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (primaryLabel != null && onPrimaryTap != null)
                      FilledButton(
                        onPressed: onPrimaryTap,
                        child: Text(primaryLabel!),
                      ),
                    if (secondaryLabel != null && onSecondaryTap != null)
                      OutlinedButton(
                        onPressed: onSecondaryTap,
                        child: Text(secondaryLabel!),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AppCompactRow extends StatelessWidget {
  const AppCompactRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.elevated, palette.base],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.outline),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.primary.withValues(alpha: 0.14),
                      palette.secondary.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: palette.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.ink.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: AppSpacing.sm),
                status!,
              ],
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: palette.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: palette.ink.withValues(alpha: 0.48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppMetricPill extends StatelessWidget {
  const AppMetricPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.surface, palette.elevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.ink.withValues(alpha: 0.58),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
