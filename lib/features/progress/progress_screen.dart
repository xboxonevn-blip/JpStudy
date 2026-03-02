import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

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
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _ActivityCalendar(),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              _SectionHeader(label: language.reviewHistoryLabel),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(language.loadErrorLabel)),
              ),
              const SizedBox(height: 16),
              _SectionHeader(label: language.attemptHistoryLabel),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Center(child: Text(language.loadErrorLabel)),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(language.loadErrorLabel)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(color: Color(0xFF6B7390))),
    );
  }
}

class _ReviewHistoryCard extends StatelessWidget {
  const _ReviewHistoryCard({required this.language, required this.summary});

  final AppLanguage language;
  final ReviewDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(summary.day);
    return _HistoryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${language.reviewedLabel}: ${summary.reviewed}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _MiniChip(label: language.reviewAgainLabel, value: summary.again),
              _MiniChip(label: language.reviewHardLabel, value: summary.hard),
              _MiniChip(label: language.reviewGoodLabel, value: summary.good),
              _MiniChip(label: language.reviewEasyLabel, value: summary.easy),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttemptHistoryCard extends StatelessWidget {
  const _AttemptHistoryCard({required this.language, required this.attempt});

  final AppLanguage language;
  final AttemptSummary attempt;

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(attempt.startedAt);
    final accuracy = attempt.total == 0
        ? 0
        : (attempt.score / attempt.total * 100).round();
    final scoreLabel = language.attemptScoreLabel(
      attempt.score,
      attempt.total,
      accuracy,
    );
    final modeLabel = _modeLabel(language, attempt.mode);
    final durationLabel = attempt.duration == null
        ? '-'
        : _formatDuration(attempt.duration!);
    return _HistoryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dateLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                scoreLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${language.attemptModeLabel}: $modeLabel (${attempt.level})',
            style: const TextStyle(color: Color(0xFF6B7390)),
          ),
          const SizedBox(height: 2),
          Text(
            '${language.attemptDurationLabel}: $durationLabel',
            style: const TextStyle(color: Color(0xFF6B7390)),
          ),
        ],
      ),
    );
  }

  String _modeLabel(AppLanguage language, String mode) {
    switch (mode) {
      case 'learn':
        return language.learnModeLabel;
      case 'test':
        return language.testModeLabel;
      case 'match':
        return language.matchModeLabel;
      case 'write':
        return language.writeModeLabel;
      case 'spell':
        return language.spellModeLabel;
    }
    return mode;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final minuteText = minutes.toString().padLeft(2, '0');
    final secondText = seconds.toString().padLeft(2, '0');
    return '$minuteText:$secondText';
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E6F0)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7390)),
      ),
    );
  }
}

class _ActivityCalendar extends ConsumerWidget {
  const _ActivityCalendar();

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

  String _shortMonth(int month) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarAsync = ref.watch(activityCalendarProvider);
    final streak = ref.watch(progressSummaryProvider).asData?.value.streak ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A2E3A59), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          calendarAsync.when(
            data: (history) => _buildGrid(context, history),
            loading: () => const SizedBox(
              height: 88,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox(height: 88),
          ),
          const SizedBox(height: 10),
          _buildBottomRow(streak),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<ReviewDaySummary> history) {
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
              for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S']) ...[
                SizedBox(
                  height: _cellSize,
                  width: 12,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 8, color: Color(0xFF6B7390)),
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
            _buildWeekColumn(context, col, startDate, map, today),
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
  ) {
    final weekMonday = startDate.add(Duration(days: col * 7));

    // Month label: show when this column starts a new month
    String? monthLabel;
    if (col == 0) {
      monthLabel = _shortMonth(weekMonday.month);
    } else {
      final prevMonday = startDate.add(Duration(days: (col - 1) * 7));
      if (weekMonday.month != prevMonday.month) {
        monthLabel = _shortMonth(weekMonday.month);
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
          _buildCell(context, weekMonday.add(Duration(days: row)), map, today),
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
    final tooltip = reviewed > 0 ? '$dateLabel — $reviewed reviews' : dateLabel;

    return Tooltip(message: tooltip, child: box);
  }

  Widget _buildBottomRow(int streak) {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department_rounded,
          size: 14,
          color: Color(0xFFF97316),
        ),
        const SizedBox(width: 4),
        Text(
          '$streak-day streak',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF97316),
          ),
        ),
        const Spacer(),
        const Text('Ít', style: TextStyle(fontSize: 10, color: Color(0xFF6B7390))),
        const SizedBox(width: 4),
        for (final color in _palette) ...[
          Container(
            width: _cellSize,
            height: _cellSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: _cellGap),
        ],
        const Text('Nhiều', style: TextStyle(fontSize: 10, color: Color(0xFF6B7390))),
      ],
    );
  }
}
