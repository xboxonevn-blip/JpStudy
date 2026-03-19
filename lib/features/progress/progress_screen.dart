import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:jpstudy/features/home/widgets/weakness_radar_card.dart';

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
                      overviewSection,
                      const SizedBox(height: AppSpacing.lg),
                      _ActivityCalendar(streak: summary.streak),
                      const SizedBox(height: AppSpacing.lg),
                      const _SrsRetentionCard(),
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
                          child: Container(color: const Color(0xFFEF4444)),
                        ),
                      if (bd.young > 0)
                        Expanded(
                          flex: bd.young,
                          child: Container(color: const Color(0xFFEAB308)),
                        ),
                      if (bd.mature > 0)
                        Expanded(
                          flex: bd.mature,
                          child: Container(color: const Color(0xFF22C55E)),
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
                  color: const Color(0xFFEF4444),
                ),
                _StageLabel(
                  label: language.progressYoungStageLabel,
                  count: bd.young,
                  color: const Color(0xFFEAB308),
                ),
                _StageLabel(
                  label: language.progressMatureStageLabel,
                  count: bd.mature,
                  color: const Color(0xFF22C55E),
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
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7390)),
        ),
      ],
    );
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6B7390),
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
  static const List<Color> _palette = [
    Color(0xFFE8ECF5), // 0 reviews
    Color(0xFFBDD5F5), // 1–5
    Color(0xFF5B9FE8), // 6–15
    Color(0xFF1A6FD8), // 16+
  ];

  Color _color(int reviewed) {
    if (reviewed <= 0) return _palette[0];
    if (reviewed <= 5) return _palette[1];
    if (reviewed <= 15) return _palette[2];
    return _palette[3];
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final calendarAsync = ref.watch(activityCalendarProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E3A59),
            blurRadius: 18,
            offset: Offset(0, 6),
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
          _buildBottomRow(streak, language),
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
                    style: const TextStyle(
                      fontSize: 8,
                      color: Color(0xFF6B7390),
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
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF6B7390),
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
        color: isFuture ? Colors.transparent : _color(reviewed),
        borderRadius: BorderRadius.circular(3),
        border: isToday
            ? Border.all(color: const Color(0xFF1A6FD8), width: 1.5)
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

  Widget _buildBottomRow(int streak, AppLanguage language) {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department_rounded,
          size: 14,
          color: Color(0xFFF97316),
        ),
        const SizedBox(width: 4),
        Text(
          _tr(
            language,
            '$streak-day streak',
            'Chuỗi $streak ngày',
            '$streak日連続',
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF97316),
          ),
        ),
        const Spacer(),
        Text(
          _tr(language, 'Less', 'Ít', '少'),
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7390)),
        ),
        const SizedBox(width: 4),
        for (int i = 0; i < _palette.length; i++) ...[
          Container(
            width: _cellSize,
            height: _cellSize,
            decoration: BoxDecoration(
              color: _palette[i],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (i < _palette.length - 1) const SizedBox(width: _cellGap),
        ],
        const SizedBox(width: 4),
        Text(
          _tr(language, 'More', 'Nhiều', '多'),
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7390)),
        ),
      ],
    );
  }
}
