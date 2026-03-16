import 'package:flutter/material.dart';

enum AppStatusTone { primary, success, warning, neutral }

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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (caption != null && caption!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
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
    final palette = switch (tone) {
      AppStatusTone.primary => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1D4ED8),
      ),
      AppStatusTone.success => (
        const Color(0xFFDCFCE7),
        const Color(0xFF15803D),
      ),
      AppStatusTone.warning => (
        const Color(0xFFFEF3C7),
        const Color(0xFFB45309),
      ),
      AppStatusTone.neutral => (
        const Color(0xFFF1F5F9),
        const Color(0xFF475569),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.$2.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.$2,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
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
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(color: const Color(0xFFDCE8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 36 : 40,
                height: compact ? 36 : 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF0369A1), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (status != null) ...[const SizedBox(width: 8), status!],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (primaryLabel != null || secondaryLabel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (primaryLabel != null && onPrimaryTap != null)
                  FilledButton(
                    onPressed: onPrimaryTap,
                    child: Text(primaryLabel!),
                  ),
                if (secondaryLabel != null && onSecondaryTap != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onSecondaryTap,
                    child: Text(secondaryLabel!),
                  ),
                ],
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE8F8)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF334155), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null) ...[const SizedBox(width: 8), status!],
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
