import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/home/widgets/weakness_radar_card.dart';
import 'package:jpstudy/features/progress/providers/mastery_provider.dart';
import 'package:jpstudy/features/progress/providers/progress_coach_provider.dart';
import 'package:jpstudy/features/progress/providers/review_forecast_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final levelSuffix = level == null ? '' : ' (${level.shortLabel})';
    final summaryAsync = ref.watch(progressSummaryProvider);
    final reviewHistoryAsync = ref.watch(reviewHistoryProvider);
    final attemptHistoryAsync = ref.watch(attemptHistoryProvider);
    final coachBoardAsync = ref.watch(progressCoachBoardProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${language.progressTitle}$levelSuffix')),
      body: summaryAsync.when(
        data: (summary) {
          final accuracy = summary.totalQuestions == 0
              ? 0
              : (summary.totalCorrect / summary.totalQuestions * 100).round();
          final accuracyRatio = summary.totalQuestions == 0
              ? 0.0
              : summary.totalCorrect / summary.totalQuestions;
          final overviewSection = AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: _overviewTitle(language),
                  caption: _overviewCaption(language),
                ),
                const SizedBox(height: 14),
                AppProgressStrip(
                  value: accuracyRatio,
                  label: language.progressAccuracyLabel,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(
                      label: language.progressStreakLabel,
                      value: summary.streak.toString(),
                    ),
                    _StatCard(
                      label: _tr(
                        language,
                        'Best Streak',
                        'Streak cao nhất',
                        '最長連続',
                      ),
                      value: summary.longestStreak.toString(),
                    ),
                    _StatCard(
                      label: _tr(
                        language,
                        'Days Studied',
                        'Số ngày học',
                        '学習日数',
                      ),
                      value: summary.totalDaysStudied.toString(),
                    ),
                    _StatCard(
                      label: language.progressTodayXpLabel,
                      value: summary.todayXp.toString(),
                    ),
                    _StatCard(
                      label: language.progressTotalXpLabel,
                      value: summary.totalXp.toString(),
                    ),
                    _StatCard(
                      label: language.progressAttemptsLabel,
                      value: summary.totalAttempts.toString(),
                    ),
                    _StatCard(
                      label: language.progressAccuracyLabel,
                      value: '$accuracy%',
                    ),
                  ],
                ),
              ],
            ),
          );
          final reviewSection = AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(title: language.reviewHistoryLabel),
                const SizedBox(height: 12),
                reviewHistoryAsync.when(
                  data: (history) => history.isEmpty
                      ? _EmptyState(label: language.reviewHistoryEmptyLabel)
                      : Column(
                          children: [
                            for (final day in history)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ReviewHistoryCard(
                                  language: language,
                                  summary: day,
                                ),
                              ),
                          ],
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ErrorStateWidget(error: e, compact: true),
                ),
              ],
            ),
          );
          final attemptSection = AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(title: language.attemptHistoryLabel),
                const SizedBox(height: 12),
                attemptHistoryAsync.when(
                  data: (attempts) => attempts.isEmpty
                      ? _EmptyState(label: language.attemptHistoryEmptyLabel)
                      : Column(
                          children: [
                            for (final attempt in attempts)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AttemptHistoryCard(
                                  language: language,
                                  attempt: attempt,
                                ),
                              ),
                          ],
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => ErrorStateWidget(error: e, compact: true),
                ),
              ],
            ),
          );
          final coachSection = coachBoardAsync.when(
            data: (board) =>
                _CoachBoardSection(language: language, board: board),
            loading: () => _CoachBoardSkeleton(language: language),
            error: (_, _) => _CoachBoardFallback(language: language),
          );

          return AppPageShell(
            topPadding: AppSpacing.lg,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useDesktopSplit =
                    constraints.maxWidth >= AppBreakpoints.desktop;

                if (!useDesktopSplit) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppFeatureCard(
                        icon: Icons.insights_rounded,
                        title: '${language.progressTitle}$levelSuffix',
                        subtitle: _progressHeroSubtitle(
                          language,
                          summary,
                          accuracy,
                        ),
                        status: AppStatusChip(
                          label: '${summary.streak}',
                          tone: AppStatusTone.warning,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      coachSection,
                      const SizedBox(height: AppSpacing.lg),
                      overviewSection,
                      const SizedBox(height: AppSpacing.lg),
                      _ActivityCalendar(streak: summary.streak),
                      const SizedBox(height: AppSpacing.lg),
                      const _SrsRetentionCard(),
                      const SizedBox(height: AppSpacing.lg),
                      const _MasterySummaryCard(),
                      const SizedBox(height: AppSpacing.lg),
                      const _ForecastPreviewCard(),
                      const SizedBox(height: AppSpacing.lg),
                      const WeaknessRadarCard(compact: true),
                      const SizedBox(height: AppSpacing.lg),
                      reviewSection,
                      const SizedBox(height: AppSpacing.lg),
                      attemptSection,
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFeatureCard(
                      icon: Icons.insights_rounded,
                      title: '${language.progressTitle}$levelSuffix',
                      subtitle: _progressHeroSubtitle(
                        language,
                        summary,
                        accuracy,
                      ),
                      status: AppStatusChip(
                        label: '${summary.streak}',
                        tone: AppStatusTone.warning,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    coachSection,
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              overviewSection,
                              const SizedBox(height: AppSpacing.lg),
                              _ActivityCalendar(streak: summary.streak),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        const Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _SrsRetentionCard(),
                              SizedBox(height: AppSpacing.lg),
                              _MasterySummaryCard(),
                              SizedBox(height: AppSpacing.lg),
                              _ForecastPreviewCard(),
                              SizedBox(height: AppSpacing.lg),
                              WeaknessRadarCard(compact: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: reviewSection),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: attemptSection),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(error: e, compact: true),
      ),
    );
  }
}

class _CoachBoardSection extends StatelessWidget {
  const _CoachBoardSection({required this.language, required this.board});

  final AppLanguage language;
  final ProgressCoachBoard board;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _coachSectionLabel(language).toUpperCase(),
                      style: TextStyle(
                        color: palette.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      board.headline,
                      key: const ValueKey('progress_focus_headline'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      board.caption,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.ink.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (board.primaryAction.badge != null) ...[
                const SizedBox(width: AppSpacing.md),
                AppStatusChip(
                  label: board.primaryAction.badge!,
                  tone: AppStatusTone.primary,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final useSplit = constraints.maxWidth >= 980;
              final secondaryColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CoachSignalsWrap(signals: board.signals, compact: useSplit),
                  if (board.recoveryItems.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _RecoveryPriorityCard(
                      language: language,
                      items: board.recoveryItems,
                    ),
                  ],
                ],
              );

              if (!useSplit) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrimaryCoachActionCard(
                      language: language,
                      action: board.primaryAction,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    secondaryColumn,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _PrimaryCoachActionCard(
                      language: language,
                      action: board.primaryAction,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 5, child: secondaryColumn),
                ],
              );
            },
          ),
          if (board.quickActions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              _quickActionsTitle(language),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1180
                    ? 3
                    : constraints.maxWidth >= 720
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - ((columns - 1) * AppSpacing.md)) /
                    columns;
                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final action in board.quickActions)
                      SizedBox(
                        width: width,
                        child: _QuickActionCard(action: action),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  static void openAction(BuildContext context, ProgressCoachAction action) {
    if (action.extra != null) {
      context.push(action.route, extra: action.extra);
    } else {
      context.push(action.route);
    }
  }
}

class _PrimaryCoachActionCard extends StatelessWidget {
  const _PrimaryCoachActionCard({required this.language, required this.action});

  final AppLanguage language;
  final ProgressCoachAction action;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [action.color.withValues(alpha: 0.16), palette.base],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: action.color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(action.icon, color: action.color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            action.title,
            key: const ValueKey('progress_primary_action_title'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: palette.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            action.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: palette.ink.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: const ValueKey('progress_primary_action_button'),
            onPressed: () => _CoachBoardSection.openAction(context, action),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(action.ctaLabel),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _primaryActionFooter(language),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.ink.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachSignalsWrap extends StatelessWidget {
  const _CoachSignalsWrap({required this.signals, required this.compact});

  final List<ProgressCoachSignal> signals;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = compact && constraints.maxWidth >= 320 ? 2 : 1;
        final width =
            (constraints.maxWidth - ((columns - 1) * AppSpacing.md)) / columns;
        return Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final signal in signals)
              SizedBox(
                width: width,
                child: _CoachSignalCard(signal: signal),
              ),
          ],
        );
      },
    );
  }
}

class _CoachSignalCard extends StatelessWidget {
  const _CoachSignalCard({required this.signal});

  final ProgressCoachSignal signal;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: signal.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(signal.icon, color: signal.color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  signal.value,
                  key: ValueKey('progress_signal_${signal.id}'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  signal.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.ink.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
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

class _RecoveryPriorityCard extends StatelessWidget {
  const _RecoveryPriorityCard({required this.language, required this.items});

  final AppLanguage language;
  final List<WeaknessRadarItem> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _recoveryTitle(language),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _recoveryCaption(language),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _RecoveryPriorityTile(item: item, language: language),
            ),
        ],
      ),
    );
  }
}

class _RecoveryPriorityTile extends StatelessWidget {
  const _RecoveryPriorityTile({required this.item, required this.language});

  final WeaknessRadarItem item;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (item.extra != null) {
            context.push(item.route, extra: item.extra);
          } else {
            context.push(item.route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: context.appPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appPalette.ink.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _drillNowLabel(language),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: item.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final ProgressCoachAction action;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action.icon, color: action.color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            action.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: palette.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            action.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: () => _CoachBoardSection.openAction(context, action),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(action.ctaLabel),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
        ],
      ),
    );
  }
}

class _CoachBoardSkeleton extends StatelessWidget {
  const _CoachBoardSkeleton({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _coachSectionLabel(language),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _coachLoadingLabel(language),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appPalette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const LinearProgressIndicator(minHeight: 5),
        ],
      ),
    );
  }
}

class _CoachBoardFallback extends StatelessWidget {
  const _CoachBoardFallback({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _coachSectionLabel(language),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _coachFallbackLabel(language),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appPalette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: () => context.openStudy(),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(_coachFallbackCta(language)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      constraints: const BoxConstraints(minWidth: 148),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.base,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: palette.ink.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: palette.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SrsRetentionCard extends ConsumerWidget {
  const _SrsRetentionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final breakdownAsync = ref.watch(srsRetentionProvider);

    final palette = context.appPalette;
    return AppSectionCard(
      child: breakdownAsync.when(
        data: (bd) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              language.vocabularySrsTitle,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              language.itemsReviewedViaSrsLabel(bd.total),
              style: TextStyle(
                fontSize: 12,
                color: palette.ink.withValues(alpha: 0.64),
              ),
            ),
            const SizedBox(height: 10),
            if (bd.total > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      if (bd.learning > 0)
                        Expanded(
                          flex: bd.learning,
                          child: Container(color: palette.error),
                        ),
                      if (bd.young > 0)
                        Expanded(
                          flex: bd.young,
                          child: Container(color: palette.warning),
                        ),
                      if (bd.mature > 0)
                        Expanded(
                          flex: bd.mature,
                          child: Container(color: palette.success),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              spacing: 12,
              children: [
                _StageLabel(
                  label: language.progressLearningStageLabel,
                  count: bd.learning,
                  color: palette.error,
                ),
                _StageLabel(
                  label: language.progressYoungStageLabel,
                  count: bd.young,
                  color: palette.warning,
                ),
                _StageLabel(
                  label: language.progressMatureStageLabel,
                  count: bd.mature,
                  color: palette.success,
                ),
              ],
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => ErrorStateWidget(error: e, compact: true),
      ),
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $count',
          style: TextStyle(
            fontSize: 11,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

String _tr(AppLanguage language, String en, String vi, String ja) {
  switch (language) {
    case AppLanguage.en:
      return en;
    case AppLanguage.vi:
      return vi;
    case AppLanguage.ja:
      return ja;
  }
}

String _progressHeroSubtitle(
  AppLanguage language,
  ProgressSummary summary,
  int accuracy,
) {
  switch (language) {
    case AppLanguage.en:
      return 'Today ${summary.todayXp} XP / ${summary.streak}-day streak / $accuracy% accuracy';
    case AppLanguage.vi:
      return 'Hôm nay ${summary.todayXp} XP / chuỗi ${summary.streak} ngày / chính xác $accuracy%';
    case AppLanguage.ja:
      return '今日 ${summary.todayXp} XP / ${summary.streak}日連続 / 正答率 $accuracy%';
  }
}

String _overviewTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Overview';
    case AppLanguage.vi:
      return 'Tổng quan';
    case AppLanguage.ja:
      return '概要';
  }
}

String _overviewCaption(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Track streak, XP, attempts, and long-term retention in one place.';
    case AppLanguage.vi:
      return 'Theo dõi chuỗi học, XP, số lần luyện và độ nhớ dài hạn trong một màn hình.';
    case AppLanguage.ja:
      return '1画面でストリーク、XP、試行回数、長期記憶をまとめて追跡します。';
  }
}

String _coachSectionLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Coach view';
    case AppLanguage.vi:
      return 'Góc nhìn huấn luyện';
    case AppLanguage.ja:
      return 'コーチ視点';
  }
}

String _quickActionsTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Other useful moves';
    case AppLanguage.vi:
      return 'Các bước khác cũng hữu ích';
    case AppLanguage.ja:
      return '他の有効な一手';
  }
}

String _recoveryTitle(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Top recovery priorities';
    case AppLanguage.vi:
      return 'Ưu tiên sửa gấp';
    case AppLanguage.ja:
      return '優先して補強したい弱点';
  }
}

String _recoveryCaption(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'These weak spots have the clearest payoff if you tackle them next.';
    case AppLanguage.vi:
      return 'Đây là những điểm yếu cho hiệu quả rõ nhất nếu xử lý tiếp theo.';
    case AppLanguage.ja:
      return '次に手を入れると効果が出やすい弱点です。';
  }
}

String _drillNowLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Drill now';
    case AppLanguage.vi:
      return 'Luyện ngay';
    case AppLanguage.ja:
      return '今すぐ補強';
  }
}

String _primaryActionFooter(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'The goal is not to do everything. It is to pick the move that changes the dashboard fastest.';
    case AppLanguage.vi:
      return 'Mục tiêu không phải làm hết mọi thứ, mà là chọn nước đi đổi dashboard nhanh nhất.';
    case AppLanguage.ja:
      return '全部やることではなく、最も早く状況を変える一手を選ぶことが目的です。';
  }
}

String _coachLoadingLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Preparing the strongest next move from your progress signals...';
    case AppLanguage.vi:
      return 'Đang ghép nước đi tiếp theo mạnh nhất từ các tín hiệu tiến độ...';
    case AppLanguage.ja:
      return '進捗シグナルから次の最善手を準備しています...';
  }
}

String _coachFallbackLabel(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Progress details are still loading, but you can jump straight into a short study block.';
    case AppLanguage.vi:
      return 'Chi tiết tiến độ đang tải, nhưng bạn vẫn có thể vào thẳng một block học ngắn.';
    case AppLanguage.ja:
      return '進捗詳細は読み込み中ですが、短い学習ブロックにはすぐ入れます。';
  }
}

String _coachFallbackCta(AppLanguage language) {
  switch (language) {
    case AppLanguage.en:
      return 'Open study';
    case AppLanguage.vi:
      return 'Mở khu học';
    case AppLanguage.ja:
      return '学習へ進む';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.ink.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReviewHistoryCard extends StatelessWidget {
  const _ReviewHistoryCard({required this.language, required this.summary});

  final AppLanguage language;
  final ReviewDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(summary.day);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(date),
      subtitle: Text(switch (language) {
        AppLanguage.en =>
          '${summary.reviewed} reviews / Again ${summary.again} / Hard ${summary.hard}',
        AppLanguage.vi =>
          '${summary.reviewed} lượt ôn / Sai ${summary.again} / Khó ${summary.hard}',
        AppLanguage.ja =>
          '${summary.reviewed}回復習 / もう一度 ${summary.again} / 難しい ${summary.hard}',
      }),
      trailing: Text('${summary.good + summary.easy}/${summary.reviewed}'),
    );
  }
}

class _AttemptHistoryCard extends StatelessWidget {
  const _AttemptHistoryCard({required this.language, required this.attempt});

  final AppLanguage language;
  final AttemptSummary attempt;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(attempt.startedAt);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(attempt.startedAt),
    );
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${attempt.mode} / ${attempt.level}'),
      subtitle: Text('$date $time'),
      trailing: Text('${attempt.score}/${attempt.total}'),
    );
  }
}

class _ActivityCalendar extends ConsumerWidget {
  const _ActivityCalendar({required this.streak});

  final int streak;

  static const int _weeks = 16;
  static const double _cellSize = 10;
  static const double _cellGap = 3;
  List<Color> _paletteFor(BuildContext context) {
    final p = context.appPalette;
    return [
      p.outline, // 0 reviews
      p.info.withValues(alpha: 0.35), // 1–5
      p.info.withValues(alpha: 0.65), // 6–15
      p.info, // 16+
    ];
  }

  Color _color(BuildContext context, int reviewed) {
    final pal = _paletteFor(context);
    if (reviewed <= 0) return pal[0];
    if (reviewed <= 5) return pal[1];
    if (reviewed <= 15) return pal[2];
    return pal[3];
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _shortMonth(int month, AppLanguage language) {
    const en = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const vi = [
      'Th1',
      'Th2',
      'Th3',
      'Th4',
      'Th5',
      'Th6',
      'Th7',
      'Th8',
      'Th9',
      'Th10',
      'Th11',
      'Th12',
    ];
    const ja = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ];
    switch (language) {
      case AppLanguage.en:
        return en[month - 1];
      case AppLanguage.vi:
        return vi[month - 1];
      case AppLanguage.ja:
        return ja[month - 1];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final calendarAsync = ref.watch(activityCalendarProvider);

    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(language, 'Activity', 'Hoạt động', '活動'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          calendarAsync.when(
            data: (history) => _buildGrid(context, history, language),
            loading: () => const SizedBox(
              height: 88,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => ErrorStateWidget(error: e, compact: true),
          ),
          const SizedBox(height: 10),
          _buildBottomRow(context, streak, language),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<ReviewDaySummary> history,
    AppLanguage language,
  ) {
    // Build sparse lookup map
    final map = <String, int>{};
    for (final s in history) {
      map[_dateKey(s.day)] = s.reviewed;
    }

    final today = DateTime.now();
    // Monday of current week
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));
    // Start = Monday 15 weeks ago
    final startDate = mondayThisWeek.subtract(const Duration(days: 15 * 7));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels (M T W T F S S)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 14), // spacer for month row
              for (final label in const [
                'M',
                'T',
                'W',
                'T',
                'F',
                'S',
                'S',
              ]) ...[
                SizedBox(
                  height: _cellSize,
                  width: 12,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 8,
                      color: context.appPalette.ink.withValues(alpha: 0.55),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: _cellGap),
              ],
            ],
          ),
          const SizedBox(width: _cellGap + 2),
          // Week columns
          for (int col = 0; col < _weeks; col++) ...[
            _buildWeekColumn(context, col, startDate, map, today, language),
            if (col < _weeks - 1) const SizedBox(width: _cellGap),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekColumn(
    BuildContext context,
    int col,
    DateTime startDate,
    Map<String, int> map,
    DateTime today,
    AppLanguage language,
  ) {
    final weekMonday = startDate.add(Duration(days: col * 7));

    // Month label: show when this column starts a new month
    String? monthLabel;
    if (col == 0) {
      monthLabel = _shortMonth(weekMonday.month, language);
    } else {
      final prevMonday = startDate.add(Duration(days: (col - 1) * 7));
      if (weekMonday.month != prevMonday.month) {
        monthLabel = _shortMonth(weekMonday.month, language);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 14,
          child: monthLabel != null
              ? Text(
                  monthLabel,
                  style: TextStyle(
                    fontSize: 8,
                    color: context.appPalette.ink.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        for (int row = 0; row < 7; row++) ...[
          _buildCell(
            context,
            weekMonday.add(Duration(days: row)),
            map,
            today,
            language,
          ),
          if (row < 6) const SizedBox(height: _cellGap),
        ],
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    DateTime date,
    Map<String, int> map,
    DateTime today,
    AppLanguage language,
  ) {
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final isFuture = dateOnly.isAfter(todayOnly);
    final isToday = dateOnly == todayOnly;
    final key = _dateKey(date);
    final reviewed = isFuture ? 0 : (map[key] ?? 0);

    final box = Container(
      width: _cellSize,
      height: _cellSize,
      decoration: BoxDecoration(
        color: isFuture ? Colors.transparent : _color(context, reviewed),
        borderRadius: BorderRadius.circular(3),
        border: isToday
            ? Border.all(color: context.appPalette.info, width: 1.5)
            : null,
      ),
    );

    if (isFuture) return box;

    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatMediumDate(date);
    final tooltip = reviewed > 0
        ? _tr(
            language,
            '$dateLabel — $reviewed reviews',
            '$dateLabel — $reviewed lượt ôn',
            '$dateLabel — $reviewed回復習',
          )
        : dateLabel;

    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.tap,
      child: box,
    );
  }

  Widget _buildBottomRow(
    BuildContext context,
    int streak,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    return Row(
      children: [
        Icon(
          Icons.local_fire_department_rounded,
          size: 14,
          color: palette.accent,
        ),
        const SizedBox(width: 4),
        Text(
          _tr(
            language,
            '$streak-day streak',
            'Chuỗi $streak ngày',
            '$streak日連続',
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: palette.accent,
          ),
        ),
        const Spacer(),
        Text(
          _tr(language, 'Less', 'Ít', '少'),
          style: TextStyle(
            fontSize: 10,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(width: 4),
        for (int i = 0; i < _paletteFor(context).length; i++) ...[
          Container(
            width: _cellSize,
            height: _cellSize,
            decoration: BoxDecoration(
              color: _paletteFor(context)[i],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i < _paletteFor(context).length - 1) const SizedBox(width: _cellGap),
        ],
        const SizedBox(width: 4),
        Text(
          _tr(language, 'More', 'Nhiều', '多'),
          style: TextStyle(
            fontSize: 10,
            color: palette.ink.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _MasterySummaryCard extends ConsumerWidget {
  const _MasterySummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final snapshotAsync = ref.watch(masterySnapshotProvider);
    final palette = context.appPalette;

    return GestureDetector(
      onTap: () => context.openMastery(),
      child: AppSectionCard(
        child: snapshotAsync.when(
          data: (snapshot) {
            int totalItems = 0, totalMature = 0;
            for (final lm in snapshot.levels) {
              totalItems += lm.totalItems;
              totalMature += lm.totalMature;
            }
            final masteryPct = totalItems == 0
                ? 0
                : (totalMature / totalItems * 100).round();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tr(
                          language,
                          'JLPT Mastery',
                          'Tiến độ JLPT',
                          'JLPT 習熟度',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: palette.ink.withValues(alpha: 0.4),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _tr(
                    language,
                    '$totalMature / $totalItems mastered ($masteryPct%)',
                    '$totalMature / $totalItems thuộc ($masteryPct%)',
                    '$totalItems中$totalMature習得 ($masteryPct%)',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.ink.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 10),
                // Mini bars per level
                for (final lm in snapshot.levels) ...[
                  _MasteryMiniBar(mastery: lm, palette: palette),
                  const SizedBox(height: 6),
                ],
              ],
            );
          },
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => ErrorStateWidget(error: e, compact: true),
        ),
      ),
    );
  }
}

class _MasteryMiniBar extends StatelessWidget {
  const _MasteryMiniBar({required this.mastery, required this.palette});

  final LevelMastery mastery;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final pct = (mastery.overallMasteryRatio * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(
            mastery.level,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.ink.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 8,
              child: mastery.totalItems == 0
                  ? Container(color: palette.outline.withValues(alpha: 0.2))
                  : Row(
                      children: [
                        if (mastery.totalMature > 0)
                          Expanded(
                            flex: mastery.totalMature,
                            child: Container(color: palette.success),
                          ),
                        if (mastery.totalStudied - mastery.totalMature > 0)
                          Expanded(
                            flex: mastery.totalStudied - mastery.totalMature,
                            child: Container(color: palette.warning),
                          ),
                        if (mastery.totalItems - mastery.totalStudied > 0)
                          Expanded(
                            flex: mastery.totalItems - mastery.totalStudied,
                            child: Container(
                              color: palette.outline.withValues(alpha: 0.2),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: palette.ink.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Forecast preview card — compact 7-day bar chart linking to full screen
// ---------------------------------------------------------------------------

class _ForecastPreviewCard extends ConsumerWidget {
  const _ForecastPreviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final forecastAsync = ref.watch(reviewForecastProvider);
    final palette = context.appPalette;

    return GestureDetector(
      onTap: () => context.openForecast(),
      child: AppSectionCard(
        child: forecastAsync.when(
          data: (forecast) {
            final week = forecast.days.take(7).toList();
            final maxTotal = week.fold<int>(
              1,
              (m, d) => d.total > m ? d.total : m,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _tr(
                          language,
                          'Review Forecast',
                          'Dự báo ôn tập',
                          '復習予報',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: palette.ink.withValues(alpha: 0.35),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _tr(
                    language,
                    '${forecast.totalDueNow} due today · ${forecast.totalTracked} tracked',
                    '${forecast.totalDueNow} đến hạn hôm nay · ${forecast.totalTracked} đang theo dõi',
                    '今日${forecast.totalDueNow}件 · 追跡中${forecast.totalTracked}件',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.ink.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (int i = 0; i < week.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: _MiniBar(
                            value: week[i].total,
                            max: maxTotal,
                            isToday: i == 0,
                            palette: palette,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (int i = 0; i < week.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          i == 0
                              ? _tr(language, 'T', 'H', '今')
                              : '${week[i].date.day}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: i == 0
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: i == 0
                                ? palette.accent
                                : palette.ink.withValues(alpha: 0.40),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.max,
    required this.isToday,
    required this.palette,
  });

  final int value;
  final int max;
  final bool isToday;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? value / max : 0.0;
    final barHeight = value > 0 ? (fraction * 40).clamp(4.0, 40.0) : 2.0;
    final color = isToday ? palette.accent : palette.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isToday ? 0.85 : 0.50),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}
