import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';

import '../providers/dashboard_provider.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.level,
    required this.language,
    required this.onLanguageTap,
    required this.onLevelChanged,
    required this.onSettingsTap,
  });

  final StudyLevel? level;
  final AppLanguage language;
  final VoidCallback onLanguageTap;
  final ValueChanged<StudyLevel> onLevelChanged;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xF7FFFFFF), Color(0xECF7FCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFDDEAF8), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12203A53),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _HeaderStats(level: level, language: language),
              ),
              const SizedBox(width: 8),
              _ActionPill(
                icon: Icons.language_rounded,
                label: language.shortCode,
                tooltip: language.languageMenuLabel,
                onTap: onLanguageTap,
              ),
              const SizedBox(width: 8),
              PopupMenuButton<StudyLevel>(
                tooltip: language.changeLevelLabel,
                onSelected: onLevelChanged,
                itemBuilder: (context) {
                  return StudyLevel.values
                      .map(
                        (item) => PopupMenuItem<StudyLevel>(
                          value: item,
                          child: Text(item.shortLabel),
                        ),
                      )
                      .toList();
                },
                child: _MenuPill(
                  icon: Icons.school_rounded,
                  label: level?.shortLabel ?? 'JLPT',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onSettingsTap,
                tooltip: language.settingsLabel,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F6FF),
                  shape: const CircleBorder(),
                ),
                icon: const Icon(
                  Icons.settings_rounded,
                  color: Color(0xFF3A4A63),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Daily XP target — reaching this marks the day's micro-goal as complete.
const int _kDailyXpGoal = 50;

class _HeaderStats extends ConsumerWidget {
  const _HeaderStats({required this.level, required this.language});

  final StudyLevel? level;
  final AppLanguage language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final stats = dashboardAsync.asData?.value;

    final streak = stats?.streak ?? 0;
    final xp = stats?.todayXp ?? 0;
    final due = (stats?.vocabDue ?? 0) + (stats?.grammarDue ?? 0);

    // Streak is "at risk" when user has an active streak but hasn't earned
    // any XP today — they need to study to keep it alive.
    final streakAtRisk = streak > 0 && xp == 0;
    final streakColor =
        streakAtRisk ? const Color(0xFFEF4444) : const Color(0xFFF97316);

    // XP micro-goal: show "done/goal" until target is reached, then just done.
    final xpGoalReached = xp >= _kDailyXpGoal;
    final xpColor =
        xpGoalReached ? const Color(0xFF22C55E) : const Color(0xFFEAB308);
    final xpLabel = xpGoalReached ? '$xp' : '$xp/$_kDailyXpGoal';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatCapsule(
            icon: Icons.local_fire_department_rounded,
            color: streakColor,
            label: streak.toString(),
            tooltip: language.streakLabel,
            urgent: streakAtRisk,
          ),
          const SizedBox(width: 6),
          _StatCapsule(
            icon: Icons.bolt_rounded,
            color: xpColor,
            label: xpLabel,
            tooltip: language.xpLabel,
          ),
          const SizedBox(width: 6),
          _StatCapsule(
            icon: Icons.history_edu_rounded,
            color: const Color(0xFF0EA5E9),
            label: due.toString(),
            tooltip: language.reviewsLabel,
            showPlus: due > 99,
          ),
          if (level != null) ...[
            const SizedBox(width: 6),
            _StatCapsule(
              icon: Icons.flag_rounded,
              color: const Color(0xFF14B8A6),
              label: level!.shortLabel,
              tooltip: language.levelMenuTitle,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCapsule extends StatelessWidget {
  const _StatCapsule({
    required this.icon,
    required this.color,
    required this.label,
    required this.tooltip,
    this.showPlus = false,
    this.urgent = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String tooltip;
  final bool showPlus;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: urgent
              ? const Color(0xFFFEE2E2)
              : Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: urgent ? const Color(0xFFFCA5A5) : const Color(0xFFDCE8F8),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D2F3D54),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              showPlus ? '$label+' : label,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F6FF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFDCE8F8)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: const Color(0xFF3A4A63)),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuPill extends StatelessWidget {
  const _MenuPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEFFCF8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFCBEBDD)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF0F766E)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F766E),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
