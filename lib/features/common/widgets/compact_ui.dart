import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

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
    final palette = context.appPalette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.bg, palette.base],
        ),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageInset,
            topPadding,
            AppSpacing.pageInset,
            bottomPadding,
          ),
          children: [child],
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
        color: palette.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  fontSize: 18,
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
                    fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AppProgressStrip extends StatelessWidget {
  const AppProgressStrip({
    super.key,
    required this.value,
    required this.label,
  });

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
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 9,
            backgroundColor: palette.outlineSoft,
            valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 42 : 48,
                height: compact ? 42 : 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.primary.withValues(alpha: 0.14),
                      palette.accent.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(icon, color: palette.primary, size: compact ? 20 : 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: compact ? 17 : 20,
                    fontWeight: FontWeight.w900,
                    color: palette.ink,
                  ),
                ),
              ),
              if (status != null) ...[const SizedBox(width: AppSpacing.sm), status!],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: palette.ink.withValues(alpha: 0.74),
              fontWeight: FontWeight.w600,
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
            color: palette.elevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: palette.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.base,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              if (status != null) ...[const SizedBox(width: AppSpacing.sm), status!],
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.ink.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppMetricPill extends StatelessWidget {
  const AppMetricPill({
    super.key,
    required this.label,
    required this.value,
  });

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
        color: palette.base,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
            ),
          ),
        ],
      ),
    );
  }
}
