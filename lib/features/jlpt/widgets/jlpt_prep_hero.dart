import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_coach_shared.dart';

class JlptPrepHero extends StatelessWidget {
  const JlptPrepHero({
    super.key,
    required this.language,
    required this.level,
    required this.snapshot,
    required this.fullMockQuestionCount,
    required this.fullMockMinutes,
    required this.quickMockQuestionCount,
    required this.readingPassageCount,
    required this.isLoading,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
  final StudyLevel level;
  final JlptCoachSnapshot? snapshot;
  final int fullMockQuestionCount;
  final int fullMockMinutes;
  final int quickMockQuestionCount;
  final int readingPassageCount;
  final bool isLoading;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final highlight =
        Color.lerp(palette.heroGradient.last, palette.accent, 0.32) ??
        palette.accent;
    final readinessLabel = _readinessLabel(language, snapshot);
    final readinessTone = snapshot == null
        ? AppStatusTone.warning
        : jlptIsReadyForExam(snapshot!)
        ? AppStatusTone.success
        : AppStatusTone.primary;
    final metrics = [
      _HeroMetricData(
        label: _metricReadiness(language),
        value: jlptReadinessValue(language, snapshot),
      ),
      _HeroMetricData(
        label: _metricFullMock(language),
        value: isLoading
            ? _loadingLabel(language)
            : '${fullMockQuestionCount}Q • ${fullMockMinutes}m',
      ),
      _HeroMetricData(
        label: _metricLevelBank(language),
        value: isLoading
            ? _loadingLabel(language)
            : '${quickMockQuestionCount}Q • $readingPassageCount bài',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroGradient.first, highlight],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -12,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -26,
            left: -16,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF8D7AE).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 820;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _eyebrow(language),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _title(language, level),
                          style: TextStyle(
                            fontSize: wide ? 30 : 24,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        AppStatusChip(
                          label: readinessLabel,
                          tone: readinessTone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: wide ? 560 : constraints.maxWidth,
                      ),
                      child: Text(
                        _subtitle(language),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          height: 1.52,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: onPrimaryTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: palette.primary,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(_startFullMockLabel(language)),
                        ),
                        OutlinedButton.icon(
                          onPressed: onSecondaryTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: Text(_startReadingLabel(language)),
                        ),
                      ],
                    ),
                  ],
                );

                final stats = Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _HeroMetricBoard(
                      metrics: metrics,
                      wide: wide,
                      language: language,
                    ),
                  ],
                );

                final iconBlock = Container(
                  width: wide ? 88 : 72,
                  height: wide ? 88 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.09),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: wide ? 40 : 32,
                  ),
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconBlock,
                      const SizedBox(height: AppSpacing.lg),
                      copy,
                      const SizedBox(height: AppSpacing.lg),
                      stats,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: iconBlock,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          stats,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricData {
  const _HeroMetricData({required this.label, required this.value});

  final String label;
  final String value;
}

class _HeroMetricBoard extends StatelessWidget {
  const _HeroMetricBoard({
    required this.metrics,
    required this.wide,
    required this.language,
  });

  final List<_HeroMetricData> metrics;
  final bool wide;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: wide ? 240 : double.infinity),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _boardLabel(language),
            style: const TextStyle(
              color: Color(0xFFFFE4BF),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < metrics.length; index++) ...[
            _HeroMetricRow(metric: metrics[index]),
            if (index != metrics.length - 1) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _HeroMetricRow extends StatelessWidget {
  const _HeroMetricRow({required this.metric});

  final _HeroMetricData metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            metric.label,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          metric.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String _eyebrow(AppLanguage language) => switch (language) {
  AppLanguage.en => 'EXAM PREP • JLPT TRACK',
  AppLanguage.vi => 'ÔN THI • JLPT TRACK',
  AppLanguage.ja => '試験対策 • JLPTトラック',
};

String _title(AppLanguage language, StudyLevel level) => switch (language) {
  AppLanguage.en => 'JLPT ${level.shortLabel} prep hub',
  AppLanguage.vi => 'Hub ôn thi ${level.shortLabel}',
  AppLanguage.ja => '${level.shortLabel} JLPT対策ハブ',
};

String _subtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'One focused hub for full mock, quick checks, reading drills, diagnosis, and a 7-day repair plan.',
  AppLanguage.vi =>
    'Một hub thống nhất cho thi thử đầy đủ, kiểm tra nhanh, đọc hiểu, chẩn đoán và kế hoạch vá lỗ hổng 7 ngày.',
  AppLanguage.ja =>
    'フル模試、クイックチェック、読解、診断、7日補強プランをひとつにまとめた入口です。',
};

String _readinessLabel(AppLanguage language, JlptCoachSnapshot? snapshot) {
  if (snapshot == null) {
    return switch (language) {
      AppLanguage.en => 'Need baseline',
      AppLanguage.vi => 'Cần baseline',
      AppLanguage.ja => '基準作成が必要',
    };
  }
  return jlptIsReadyForExam(snapshot)
      ? switch (language) {
          AppLanguage.en => 'Ready to push',
          AppLanguage.vi => 'Sẵn sàng tăng nhịp',
          AppLanguage.ja => '仕上げ段階',
        }
      : switch (language) {
          AppLanguage.en => 'Repair in progress',
          AppLanguage.vi => 'Đang vá lỗ hổng',
          AppLanguage.ja => '補強中',
        };
}

String _metricReadiness(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Readiness',
  AppLanguage.vi => 'Độ sẵn sàng',
  AppLanguage.ja => '準備度',
};

String _metricFullMock(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Full mock',
  AppLanguage.vi => 'Full mock',
  AppLanguage.ja => 'フル模試',
};

String _metricLevelBank(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Current level bank',
  AppLanguage.vi => 'Bank level hiện tại',
  AppLanguage.ja => '現在レベルのバンク',
};

String _boardLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'EXAM SNAPSHOT',
  AppLanguage.vi => 'TÓM TẮT NHANH',
  AppLanguage.ja => '試験スナップショット',
};

String _loadingLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Loading',
  AppLanguage.vi => 'Đang tải',
  AppLanguage.ja => '読み込み中',
};

String _startFullMockLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start full mock',
  AppLanguage.vi => 'Bắt đầu full mock',
  AppLanguage.ja => 'フル模試を開始',
};

String _startReadingLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start reading drill',
  AppLanguage.vi => 'Mở reading drill',
  AppLanguage.ja => '読解ドリルへ',
};
