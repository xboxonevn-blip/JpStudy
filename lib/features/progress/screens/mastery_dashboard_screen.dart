import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:jpstudy/features/progress/providers/mastery_provider.dart';

class MasteryDashboardScreen extends ConsumerWidget {
  const MasteryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final snapshotAsync = ref.watch(masterySnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_tr(language, 'JLPT Mastery', 'Tiến độ JLPT', 'JLPT 習熟度'))),
      body: snapshotAsync.when(
        data: (snapshot) => _MasteryBody(snapshot: snapshot, language: language),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(error: e, compact: true),
      ),
    );
  }
}

class _MasteryBody extends StatelessWidget {
  const _MasteryBody({required this.snapshot, required this.language});

  final MasterySnapshot snapshot;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    // Compute overall stats
    int totalItems = 0, totalStudied = 0, totalMature = 0;
    for (final lm in snapshot.levels) {
      totalItems += lm.totalItems;
      totalStudied += lm.totalStudied;
      totalMature += lm.totalMature;
    }
    final overallRatio = totalItems == 0 ? 0.0 : totalMature / totalItems;

    return AppPageShell(
      topPadding: AppSpacing.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          AppFeatureCard(
            icon: Icons.military_tech_rounded,
            title: _tr(language, 'JLPT Mastery', 'Tiến độ JLPT', 'JLPT 習熟度'),
            subtitle: _tr(
              language,
              '$totalMature of $totalItems items mastered (${(overallRatio * 100).round()}%)',
              '$totalMature / $totalItems mục đã thuộc (${(overallRatio * 100).round()}%)',
              '$totalItems 項目中 $totalMature 習得済 (${(overallRatio * 100).round()}%)',
            ),
            status: AppStatusChip(
              label: '${(overallRatio * 100).round()}%',
              tone: overallRatio >= 0.8
                  ? AppStatusTone.success
                  : overallRatio >= 0.3
                      ? AppStatusTone.warning
                      : AppStatusTone.neutral,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Overall progress ring
          AppSectionCard(
            child: Column(
              children: [
                AppSectionHeader(
                  title: _tr(language, 'Overall Progress', 'Tổng tiến độ', '全体の進捗'),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MiniRing(
                      ratio: totalItems == 0 ? 0.0 : totalStudied / totalItems,
                      label: _tr(language, 'Studied', 'Đã học', '学習済'),
                      value: '$totalStudied',
                      color: palette.info,
                    ),
                    _MiniRing(
                      ratio: overallRatio,
                      label: _tr(language, 'Mastered', 'Thuộc', '習得'),
                      value: '$totalMature',
                      color: palette.success,
                    ),
                    _MiniRing(
                      ratio: 1.0,
                      label: _tr(language, 'Total', 'Tổng', '合計'),
                      value: '$totalItems',
                      color: palette.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Per-level cards
          for (final lm in snapshot.levels) ...[
            _LevelMasteryCard(mastery: lm, language: language),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _LevelMasteryCard extends StatelessWidget {
  const _LevelMasteryCard({required this.mastery, required this.language});

  final LevelMastery mastery;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final pct = (mastery.overallMasteryRatio * 100).round();

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LevelBadge(level: mastery.level, palette: palette),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mastery.level,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                      ),
                    ),
                    Text(
                      _tr(
                        language,
                        '${mastery.totalMature}/${mastery.totalItems} mastered ($pct%)',
                        '${mastery.totalMature}/${mastery.totalItems} thuộc ($pct%)',
                        '${mastery.totalItems}中${mastery.totalMature}習得 ($pct%)',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.ink.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _RingPainter(
                    ratio: mastery.overallMasteryRatio,
                    trackColor: palette.outline.withValues(alpha: 0.3),
                    fillColor: _levelColor(mastery.level),
                    strokeWidth: 5,
                  ),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: palette.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category breakdown
          _CategoryRow(
            icon: Icons.translate_rounded,
            label: _tr(language, 'Vocab', 'Từ vựng', '語彙'),
            mastery: mastery.vocab,
            color: const Color(0xFF4B74B7),
          ),
          const SizedBox(height: 10),
          _CategoryRow(
            icon: Icons.menu_book_rounded,
            label: _tr(language, 'Grammar', 'Ngữ pháp', '文法'),
            mastery: mastery.grammar,
            color: const Color(0xFF2D8A63),
          ),
          const SizedBox(height: 10),
          _CategoryRow(
            icon: Icons.brush_rounded,
            label: _tr(language, 'Kanji', 'Hán tự', '漢字'),
            mastery: mastery.kanji,
            color: const Color(0xFFD66A3D),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.icon,
    required this.label,
    required this.mastery,
    required this.color,
  });

  final IconData icon;
  final String label;
  final CategoryMastery mastery;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final pct = (mastery.masteryRatio * 100).round();
    final studiedPct = (mastery.studiedRatio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.ink,
              ),
            ),
            const Spacer(),
            Text(
              '${mastery.mature}/${mastery.total}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.ink.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Stacked progress bar: learning | young | mature | remaining
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 10,
            child: mastery.total == 0
                ? Container(color: palette.outline.withValues(alpha: 0.2))
                : Row(
                    children: [
                      if (mastery.mature > 0)
                        Expanded(
                          flex: mastery.mature,
                          child: Container(color: const Color(0xFF22C55E)),
                        ),
                      if (mastery.young > 0)
                        Expanded(
                          flex: mastery.young,
                          child: Container(color: const Color(0xFFEAB308)),
                        ),
                      if (mastery.learning > 0)
                        Expanded(
                          flex: mastery.learning,
                          child: Container(color: const Color(0xFFEF4444)),
                        ),
                      if (mastery.total - mastery.studied > 0)
                        Expanded(
                          flex: mastery.total - mastery.studied,
                          child: Container(
                            color: palette.outline.withValues(alpha: 0.2),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 4),
        // Legend row
        Row(
          children: [
            _LegendDot(
              color: const Color(0xFF22C55E),
              label: '${mastery.mature}',
            ),
            const SizedBox(width: 10),
            _LegendDot(
              color: const Color(0xFFEAB308),
              label: '${mastery.young}',
            ),
            const SizedBox(width: 10),
            _LegendDot(
              color: const Color(0xFFEF4444),
              label: '${mastery.learning}',
            ),
            const Spacer(),
            Text(
              '$studiedPct% studied',
              style: TextStyle(
                fontSize: 10,
                color: palette.ink.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ],
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7390)),
        ),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.palette});

  final String level;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(level);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          level,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MiniRing extends StatelessWidget {
  const _MiniRing({
    required this.ratio,
    required this.label,
    required this.value,
    required this.color,
  });

  final double ratio;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _RingPainter(
              ratio: ratio,
              trackColor: palette.outline.withValues(alpha: 0.25),
              fillColor: color,
              strokeWidth: 5,
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: palette.ink,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: palette.ink.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.ratio,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  final double ratio;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    // Fill arc
    if (ratio > 0) {
      final sweepAngle = 2 * math.pi * ratio.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // start at top
        sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = fillColor,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.ratio != ratio || old.fillColor != fillColor;
}

Color _levelColor(String level) {
  switch (level) {
    case 'N5':
      return const Color(0xFF4B74B7);
    case 'N4':
      return const Color(0xFF2D8A63);
    case 'N3':
      return const Color(0xFFD66A3D);
    case 'N2':
      return const Color(0xFFC44F59);
    case 'N1':
      return const Color(0xFF7C3AED);
    default:
      return const Color(0xFF6B7390);
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
