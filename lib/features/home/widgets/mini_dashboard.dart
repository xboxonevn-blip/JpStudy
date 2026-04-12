import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../grammar/grammar_providers.dart';
import '../providers/dashboard_provider.dart';
import 'home_surface.dart';

class MiniDashboard extends ConsumerWidget {
  const MiniDashboard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final language = ref.watch(appLanguageProvider);
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);

    return dashboardAsync.when(
      data: (state) =>
          _buildContent(context, state, language, ghostCount, compact: compact),
      loading: () => SizedBox(
        height: compact ? 62 : 88,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => EmptyStateWidget(
        icon: Icons.cloud_off_rounded,
        title: ref.watch(appLanguageProvider).loadErrorLabel,
        compact: true,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DashboardState state,
    AppLanguage language,
    int ghostCount, {
    required bool compact,
  }) {
    final palette = context.appPalette;
    final totalDue = state.vocabDue + state.grammarDue + state.kanjiDue;
    final focusCount = state.totalMistakeCount + ghostCount;
    final headerTitle = language.progressTitle;
    final headerSubtitle = language.continueJourneyLabel;
    final compactStats = [
      _CompactStatCard(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFF97316),
        value: '${state.streak}',
        label: language.streakLabel,
      ),
      _CompactStatCard(
        icon: Icons.star_rounded,
        iconColor: const Color(0xFFF59E0B),
        value: '${state.todayXp}',
        label: language.xpLabel,
      ),
      _CompactStatCard(
        icon: Icons.history_edu_rounded,
        iconColor: const Color(0xFF0EA5E9),
        value: '$totalDue',
        label: language.reviewsLabel,
      ),
      _CompactStatCard(
        icon: Icons.tips_and_updates_rounded,
        iconColor: const Color(0xFFEC4899),
        value: '$focusCount',
        label: language.fixMistakesLabel,
      ),
    ];

    if (compact) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
        decoration: HomeSurface.softPanel(
          colors: [palette.elevated, palette.base],
          radius: 18,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final statColumns = constraints.maxWidth >= 760
                ? 4
                : constraints.maxWidth >= 360
                ? 2
                : 1;
            final spacing = 8.0;
            final statWidth = statColumns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (spacing * (statColumns - 1))) /
                      statColumns;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: LinearGradient(
                          colors: [
                            palette.warning.withValues(alpha: 0.14),
                            palette.warning.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: palette.warning.withValues(alpha: 0.25)),
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        color: palette.warning,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _compactEyebrow(language),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.22,
                              color: palette.ink.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            headerTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final stat in compactStats)
                      SizedBox(width: statWidth, child: stat),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        HomeSurface.pageHorizontalPadding,
        10,
        HomeSurface.pageHorizontalPadding,
        12,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 880
              ? 4
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          return Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: HomeSurface.softPanel(
              colors: [palette.elevated, palette.base],
              radius: 28,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headerSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.35,
                              color: palette.ink.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            headerTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: palette.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            palette.warning.withValues(alpha: 0.14),
                            palette.warning.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: palette.warning.withValues(alpha: 0.25)),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: palette.warning,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.45,
                  children: [
                    _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: const Color(0xFFF97316),
                      value: '${state.streak}',
                      suffix: language.streakLabel.toUpperCase(),
                    ),
                    _StatTile(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      value: '${state.todayXp}',
                      suffix: language.xpLabel.toUpperCase(),
                    ),
                    _StatTile(
                      icon: Icons.history_edu_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      value: '$totalDue',
                      suffix: language.reviewsLabel.toUpperCase(),
                    ),
                    _StatTile(
                      icon: Icons.tips_and_updates_rounded,
                      iconColor: const Color(0xFFEC4899),
                      value: '$focusCount',
                      suffix: language.fixMistakesLabel.toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _compactEyebrow(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Today snapshot',
    AppLanguage.vi => 'Tổng quan hôm nay',
    AppLanguage.ja => '今日のスナップショット',
  };
}

class _CompactStatCard extends StatelessWidget {
  const _CompactStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: palette.elevated,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.8,
                    fontWeight: FontWeight.w700,
                    color: palette.ink.withValues(alpha: 0.55),
                    letterSpacing: 0.12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1,
                    fontWeight: FontWeight.w900,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.suffix,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeSurface.panelBorderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suffix,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: palette.ink.withValues(alpha: 0.55),
                    letterSpacing: 0.28,
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
