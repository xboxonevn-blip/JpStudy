import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:jpstudy/features/progress/providers/review_forecast_provider.dart';

String _tr(
  AppLanguage l, {
  required String en,
  required String vi,
  required String ja,
}) => switch (l) {
  AppLanguage.en => en,
  AppLanguage.vi => vi,
  AppLanguage.ja => ja,
};

class ReviewForecastScreen extends ConsumerWidget {
  const ReviewForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final forecastAsync = ref.watch(reviewForecastProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _tr(language, en: 'Review Forecast', vi: 'Dự báo ôn tập', ja: '復習予報'),
        ),
      ),
      body: forecastAsync.when(
        data: (data) => _ForecastBody(data: data, language: language),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateWidget(error: error),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ForecastBody extends StatelessWidget {
  const _ForecastBody({required this.data, required this.language});

  final ReviewForecast data;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppPageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Summary hero ──────────────────────────────────────────
          _SummaryHero(data: data, language: language, palette: palette),
          const SizedBox(height: 16),

          // ── 14-day forecast chart ─────────────────────────────────
          _ForecastChart(days: data.days, language: language, palette: palette),
          const SizedBox(height: 16),

          // ── Stability distribution ────────────────────────────────
          _StabilitySection(
            buckets: data.stabilityBuckets,
            language: language,
            palette: palette,
          ),
          const SizedBox(height: 16),

          // ── Confidence breakdown ──────────────────────────────────
          if (data.confidence.total > 0)
            _ConfidenceSection(
              confidence: data.confidence,
              language: language,
              palette: palette,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary hero
// ---------------------------------------------------------------------------

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({
    required this.data,
    required this.language,
    required this.palette,
  });

  final ReviewForecast data;
  final AppLanguage language;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final weekTotal = data.days.take(7).fold<int>(0, (sum, d) => sum + d.total);

    return AppSectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  value: '${data.totalDueNow}',
                  label: _tr(
                    language,
                    en: 'Due Today',
                    vi: 'Đến hạn hôm nay',
                    ja: '今日の復習',
                  ),
                  color: data.totalDueNow > 0
                      ? palette.warning
                      : palette.success,
                  palette: palette,
                ),
              ),
              Expanded(
                child: _HeroStat(
                  value: '$weekTotal',
                  label: _tr(
                    language,
                    en: 'This Week',
                    vi: 'Tuần này',
                    ja: '今週',
                  ),
                  color: palette.info,
                  palette: palette,
                ),
              ),
              Expanded(
                child: _HeroStat(
                  value: '${data.totalTracked}',
                  label: _tr(
                    language,
                    en: 'Tracked',
                    vi: 'Đang theo dõi',
                    ja: '追跡中',
                  ),
                  color: palette.primary,
                  palette: palette,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.speed_rounded,
                  size: 18,
                  color: palette.ink.withValues(alpha: 0.50),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_tr(language, en: 'Avg Stability', vi: 'Ổn định TB', ja: '平均安定度')}: ${data.avgStability.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: palette.ink.withValues(alpha: 0.65),
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.color,
    required this.palette,
  });

  final String value;
  final String label;
  final Color color;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: palette.ink.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 14-day forecast bar chart
// ---------------------------------------------------------------------------

class _ForecastChart extends StatelessWidget {
  const _ForecastChart({
    required this.days,
    required this.language,
    required this.palette,
  });

  final List<ForecastDay> days;
  final AppLanguage language;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final maxTotal = days.fold<int>(1, (m, d) => math.max(m, d.total));

    return AppSectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: _tr(
              language,
              en: '14-Day Forecast',
              vi: 'Dự báo 14 ngày',
              ja: '14日間の予報',
            ),
            palette: palette,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < days.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    child: _ForecastBar(
                      day: days[i],
                      maxTotal: maxTotal,
                      isToday: i == 0,
                      palette: palette,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Day labels
          Row(
            children: [
              for (int i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    i == 0
                        ? _tr(language, en: 'T', vi: 'H', ja: '今')
                        : '${days[i].date.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: i == 0 ? FontWeight.w800 : FontWeight.w500,
                      color: i == 0
                          ? palette.accent
                          : palette.ink.withValues(alpha: 0.40),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: palette.primary,
                label: _tr(language, en: 'Vocab', vi: 'Từ vựng', ja: '語彙'),
              ),
              const SizedBox(width: 16),
              _LegendDot(
                color: palette.secondary,
                label: _tr(language, en: 'Grammar', vi: 'Ngữ pháp', ja: '文法'),
              ),
              const SizedBox(width: 16),
              _LegendDot(
                color: palette.accent,
                label: _tr(language, en: 'Kanji', vi: 'Kanji', ja: '漢字'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForecastBar extends StatelessWidget {
  const _ForecastBar({
    required this.day,
    required this.maxTotal,
    required this.isToday,
    required this.palette,
  });

  final ForecastDay day;
  final int maxTotal;
  final bool isToday;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final fraction = maxTotal > 0 ? day.total / maxTotal : 0.0;
    final minBarHeight = day.total > 0 ? 8.0 : 2.0;
    final barHeight = math.max(minBarHeight, fraction * 140);

    // Stacked: vocab (bottom) + grammar (mid) + kanji (top)
    final totalH = barHeight;
    final vocabH = day.total > 0 ? (day.vocabDue / day.total) * totalH : 0.0;
    final grammarH = day.total > 0
        ? (day.grammarDue / day.total) * totalH
        : 0.0;
    final kanjiH = totalH - vocabH - grammarH;

    return Tooltip(
      message:
          '${day.date.month}/${day.date.day}: ${day.vocabDue}V + ${day.grammarDue}G + ${day.kanjiDue}K',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (day.total > 0)
            Text(
              '${day.total}',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: isToday
                    ? palette.accent
                    : palette.ink.withValues(alpha: 0.45),
              ),
            ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: barHeight,
              child: Column(
                children: [
                  if (kanjiH > 0)
                    Expanded(
                      flex: (kanjiH * 100).round().clamp(1, 10000),
                      child: Container(color: palette.accent),
                    ),
                  if (grammarH > 0)
                    Expanded(
                      flex: (grammarH * 100).round().clamp(1, 10000),
                      child: Container(color: palette.secondary),
                    ),
                  if (vocabH > 0)
                    Expanded(
                      flex: (vocabH * 100).round().clamp(1, 10000),
                      child: Container(color: palette.primary),
                    ),
                  if (day.total == 0)
                    Expanded(
                      child: Container(
                        color: palette.outline.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

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
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(
              context,
            ).extension<AppThemePalette>()!.ink.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stability distribution
// ---------------------------------------------------------------------------

class _StabilitySection extends StatelessWidget {
  const _StabilitySection({
    required this.buckets,
    required this.language,
    required this.palette,
  });

  final List<StabilityBucket> buckets;
  final AppLanguage language;
  final AppThemePalette palette;

  List<Color> get _bucketColors => [
    palette.error, // Critical - red
    palette.warning, // Weak - amber
    palette.info, // Growing - blue
    palette.success, // Strong - green
    palette.accent, // Mastered - purple
  ];

  @override
  Widget build(BuildContext context) {
    final totalItems = buckets.fold<int>(0, (sum, b) => sum + b.total);

    return AppSectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: _tr(
              language,
              en: 'Memory Strength',
              vi: 'Sức mạnh trí nhớ',
              ja: '記憶の強さ',
            ),
            palette: palette,
          ),
          const SizedBox(height: 14),

          // Stacked horizontal bar
          if (totalItems > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 28,
                child: Row(
                  children: [
                    for (int i = 0; i < buckets.length; i++)
                      if (buckets[i].total > 0)
                        Expanded(
                          flex: buckets[i].total,
                          child: Container(color: _bucketColors[i]),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Bucket rows
          for (int i = 0; i < buckets.length; i++) ...[
            _BucketRow(
              bucket: buckets[i],
              color: _bucketColors[i],
              totalItems: totalItems,
              language: language,
              palette: palette,
            ),
            if (i < buckets.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _BucketRow extends StatelessWidget {
  const _BucketRow({
    required this.bucket,
    required this.color,
    required this.totalItems,
    required this.language,
    required this.palette,
  });

  final StabilityBucket bucket;
  final Color color;
  final int totalItems;
  final AppLanguage language;
  final AppThemePalette palette;

  String _localizedLabel() {
    switch (bucket.label) {
      case 'Critical':
        return _tr(language, en: 'Critical', vi: 'Nguy cấp', ja: '危険');
      case 'Weak':
        return _tr(language, en: 'Weak', vi: 'Yếu', ja: '弱い');
      case 'Growing':
        return _tr(language, en: 'Growing', vi: 'Đang phát triển', ja: '成長中');
      case 'Strong':
        return _tr(language, en: 'Strong', vi: 'Mạnh', ja: '強い');
      case 'Mastered':
        return _tr(language, en: 'Mastered', vi: 'Thành thạo', ja: '習得済み');
      default:
        return bucket.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = totalItems > 0 ? (bucket.total / totalItems * 100).round() : 0;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _localizedLabel(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
        ),
        Text(
          '${bucket.total}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: palette.ink,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 40,
          child: Text(
            '$pct%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: palette.ink.withValues(alpha: 0.45),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Confidence breakdown
// ---------------------------------------------------------------------------

class _ConfidenceSection extends StatelessWidget {
  const _ConfidenceSection({
    required this.confidence,
    required this.language,
    required this.palette,
  });

  final ConfidenceBreakdown confidence;
  final AppLanguage language;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final total = confidence.total;
    if (total == 0) return const SizedBox.shrink();

    return AppSectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: _tr(
              language,
              en: 'Review Confidence',
              vi: 'Tự tin khi ôn',
              ja: '復習の自信度',
            ),
            palette: palette,
          ),
          const SizedBox(height: 14),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  if (confidence.again > 0)
                    Expanded(
                      flex: confidence.again,
                      child: Container(color: palette.error),
                    ),
                  if (confidence.hard > 0)
                    Expanded(
                      flex: confidence.hard,
                      child: Container(color: palette.warning),
                    ),
                  if (confidence.good > 0)
                    Expanded(
                      flex: confidence.good,
                      child: Container(color: palette.success),
                    ),
                  if (confidence.easy > 0)
                    Expanded(
                      flex: confidence.easy,
                      child: Container(color: palette.info),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ConfidencePill(
                label: _tr(language, en: 'Again', vi: 'Làm lại', ja: 'もう一度'),
                count: confidence.again,
                total: total,
                color: palette.error,
                palette: palette,
              ),
              const SizedBox(width: 8),
              _ConfidencePill(
                label: _tr(language, en: 'Hard', vi: 'Khó', ja: '難しい'),
                count: confidence.hard,
                total: total,
                color: palette.warning,
                palette: palette,
              ),
              const SizedBox(width: 8),
              _ConfidencePill(
                label: _tr(language, en: 'Good', vi: 'T?t', ja: '??'),
                count: confidence.good,
                total: total,
                color: palette.success,
                palette: palette,
              ),
              const SizedBox(width: 8),
              _ConfidencePill(
                label: _tr(language, en: 'Easy', vi: 'D?', ja: '??'),
                count: confidence.easy,
                total: total,
                color: palette.info,
                palette: palette,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  const _ConfidencePill({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.palette,
  });

  final String label;
  final int count;
  final int total;
  final Color color;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: palette.ink.withValues(alpha: 0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.palette});

  final String label;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: palette.ink.withValues(alpha: 0.65),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
