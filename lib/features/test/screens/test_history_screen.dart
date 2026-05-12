import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';

import '../providers/test_providers.dart';
import '../services/test_history_service.dart';

/// Widget to display test history and progress
class TestHistoryScreen extends ConsumerWidget {
  final int lessonId;
  final String lessonTitle;

  const TestHistoryScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyService = ref.watch(testHistoryServiceProvider);
    final language = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${language.attemptHistoryLabel}: $lessonTitle'),
      ),
      body: FutureBuilder<_HistoryData>(
        future: _loadData(historyService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(language.loadErrorLabel));
          }

          final data = snapshot.data!;
          final history = data.history;

          if (history.isEmpty) {
            return _buildEmptyState(context, language);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats summary
                _buildStatsSummary(
                  context,
                  history.length,
                  data.bestScore,
                  data.averageScore,
                  language,
                ),
                const SizedBox(height: 24),

                // Progress chart
                if (data.progressData.length >= 2) ...[
                  _buildProgressChart(context, data.progressData, language),
                  const SizedBox(height: 24),
                ],

                // History list
                _buildHistoryList(context, history, language),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_HistoryData> _loadData(TestHistoryService service) async {
    final results = await Future.wait([
      service.getHistory(lessonId),
      service.getProgressData(lessonId),
      service.getBestScore(
        lessonId,
      ), // Returns nullable, so handle carefully if Future.wait disallows different types? No, it returns List<dynamic> or typed if consistent.
      service.getAverageScore(lessonId),
    ]);

    return _HistoryData(
      history: results[0] as List<TestHistoryRecord>,
      progressData: results[1] as List<ProgressPoint>,
      bestScore: results[2] as TestHistoryRecord?,
      averageScore: results[3] as double,
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLanguage language) {
    final palette = context.appPalette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: palette.ink.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            language.attemptHistoryEmptyLabel,
            style: TextStyle(
              fontSize: 18,
              color: palette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language.testHistoryEmptyHintLabel,
            style: TextStyle(color: palette.ink.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(
    BuildContext context,
    int testCount,
    TestHistoryRecord? bestScore,
    double averageScore,
    AppLanguage language,
  ) {
    final palette = context.appPalette;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.quiz,
            label: language.testHistoryTestsTakenLabel,
            value: testCount.toString(),
            color: palette.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            label: language.testHistoryBestScoreLabel,
            value: bestScore != null ? '${bestScore.score.toInt()}%' : '-',
            color: palette.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.analytics,
            label: language.testHistoryAverageLabel,
            value: '${averageScore.toInt()}%',
            color: palette.success,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(
    BuildContext context,
    List<ProgressPoint> data,
    AppLanguage language,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appPalette.elevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.testHistoryProgressOverTimeLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Simple bar chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((point) {
                final height = (point.score / 100) * 100;
                final color = _getScoreColor(context, point.score);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${point.score.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                language.testHistoryOldestLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: context.appPalette.ink.withValues(alpha: 0.55),
                ),
              ),
              Text(
                language.testHistoryLatestLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: context.appPalette.ink.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    List<TestHistoryRecord> history,
    AppLanguage language,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.attemptHistoryLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...history.asMap().entries.map((entry) {
          final index = entry.key;
          final record = entry.value;
          final showComparison = index > 0;

          return _HistoryItem(
            record: record,
            previousRecord: showComparison ? history[index - 1] : null,
          );
        }),
      ],
    );
  }

  Color _getScoreColor(BuildContext context, double score) {
    final palette = context.appPalette;
    if (score >= 90) return palette.success;
    if (score >= 70) return palette.info;
    if (score >= 50) return palette.warning;
    return palette.error;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.appPalette.ink.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final TestHistoryRecord record;
  final TestHistoryRecord? previousRecord;

  const _HistoryItem({required this.record, this.previousRecord});

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final scoreDiff = previousRecord != null
        ? record.score - previousRecord!.score
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Grade circle
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getGradeColor(
                context,
                record.grade,
              ).withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                record.grade,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(context, record.grade),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.score.toInt()}% (${record.correctCount}/${record.totalQuestions})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(record.completedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: palette.ink.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),

          // Comparison badge
          if (scoreDiff != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scoreDiff >= 0
                    ? palette.success.withValues(alpha: 0.1)
                    : palette.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    scoreDiff >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: scoreDiff >= 0 ? palette.success : palette.error,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${scoreDiff.abs().toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scoreDiff >= 0 ? palette.success : palette.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getGradeColor(BuildContext context, String grade) {
    final palette = context.appPalette;
    switch (grade) {
      case 'A':
        return palette.success;
      case 'B':
        return palette.info;
      case 'C':
        return palette.warning;
      case 'D':
        return Color.lerp(palette.warning, palette.error, 0.55)!;
      default:
        return palette.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _HistoryData {
  final List<TestHistoryRecord> history;
  final List<ProgressPoint> progressData;
  final TestHistoryRecord? bestScore;
  final double averageScore;

  _HistoryData({
    required this.history,
    required this.progressData,
    this.bestScore,
    required this.averageScore,
  });
}
