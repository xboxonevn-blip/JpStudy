import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../grammar/grammar_providers.dart';
import '../providers/dashboard_provider.dart';
import 'home_surface.dart';

class MiniDashboard extends ConsumerWidget {
  const MiniDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final language = ref.watch(appLanguageProvider);
    final ghostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (count) => count, orElse: () => 0);

    return dashboardAsync.when(
      data: (state) => _buildContent(state, language, ghostCount),
      loading: () => const SizedBox(
        height: 88,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    DashboardState state,
    AppLanguage language,
    int ghostCount,
  ) {
    final totalDue = state.vocabDue + state.grammarDue + state.kanjiDue;
    final focusCount = state.totalMistakeCount + ghostCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: HomeSurface.softPanel(
              colors: const [Color(0xFFFFFFFF), Color(0xFFF4FAFF)],
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
                            language.continueJourneyLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.35,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            language.progressTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFEDD5), Color(0xFFFFFBEB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFEA580C),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeSurface.panelBorder),
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
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  suffix,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
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
