import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_plan_playbook.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_coach_shared.dart';

class JlptPlanPanel extends StatelessWidget {
  const JlptPlanPanel({
    super.key,
    required this.language,
    required this.snapshot,
    required this.levelCode,
  });

  final AppLanguage language;
  final JlptCoachSnapshot? snapshot;
  final String levelCode;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return JlptCoachPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _planTitle(language),
            caption: _planCaption(language),
          ),
          const SizedBox(height: AppSpacing.sm),
          JlptCoachSectionAccent(accent: palette.accent),
          const SizedBox(height: AppSpacing.md),
          if (snapshot == null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: HomeSurface.softPanel(
                radius: AppSpacing.radiusXxl,
                colors: [palette.elevated, palette.base],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _planEmptyTitle(language),
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _planEmptyBody(language),
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.72),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final items = snapshot!.plan.items
                    .take(4)
                    .toList(growable: false);
                final columns = constraints.maxWidth >= 620 ? 2 : 1;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - AppSpacing.md) / columns;

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: _PlanCard(
                          language: language,
                          item: item,
                          levelCode: levelCode,
                        ),
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
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.language,
    required this.item,
    required this.levelCode,
  });

  final AppLanguage language;
  final JlptPlanItem item;
  final String levelCode;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accent = jlptAreaColor(context, item.area);
    final presentation = buildJlptPlanPresentation(
      language: language,
      item: item,
      levelCode: levelCode,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: HomeSurface.softPanel(
        radius: 24,
        colors: [
          palette.elevated,
          Color.lerp(palette.base, accent.withValues(alpha: 0.04), 0.5) ??
              palette.base,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 3,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  _planDayLabel(language, item.dayOffset),
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: palette.elevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Text(
                  presentation.phaseLabel,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${item.minutes}m',
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.52),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            presentation.title,
            style: TextStyle(
              color: palette.ink,
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            presentation.body,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.72),
              height: 1.48,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.push(
              presentation.launchTarget.route,
              extra: presentation.launchTarget.extra,
            ),
            icon: Icon(jlptIconForArea(item.area), color: accent),
            label: Text(presentation.actionLabel),
          ),
        ],
      ),
    );
  }
}

String _planTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => '7-day repair plan',
  AppLanguage.vi => 'Kế hoạch vá lỗ hổng 7 ngày',
  AppLanguage.ja => '7日補強プラン',
};

String _planCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Use the latest diagnosis to decide what to sharpen before the next mock.',
  AppLanguage.vi =>
    'Dùng chẩn đoán gần nhất để chốt xem cần sharpen điều gì trước lần mock tiếp theo.',
  AppLanguage.ja => '直近の診断をもとに、次の模試までに何を磨くかを決めます。',
};

String _planEmptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'The plan unlocks after your first serious run',
  AppLanguage.vi => 'Kế hoạch sẽ mở sau lần chạy nghiêm túc đầu tiên',
  AppLanguage.ja => '最初の本格ランのあとにプランが開きます',
};

String _planEmptyBody(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Once you finish a reading drill or full mock, this area becomes a compact plan that tells you what to repair day by day.',
  AppLanguage.vi =>
    'Sau khi bạn xong reading drill hoặc full mock, khu vực này sẽ thành một plan gọn, chỉ rõ mỗi ngày nên sửa cái gì.',
  AppLanguage.ja => '読解ドリルかフル模試を終えると、ここが日ごとの補強プランに変わります。',
};

String _planDayLabel(AppLanguage language, int dayOffset) => switch (language) {
  AppLanguage.en => 'Day ${dayOffset + 1}',
  AppLanguage.vi => 'Ngày ${dayOffset + 1}',
  AppLanguage.ja => '${dayOffset + 1}日目',
};
