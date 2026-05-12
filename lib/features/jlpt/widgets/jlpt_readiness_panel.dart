import 'package:flutter/material.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_coach_shared.dart';

class JlptReadinessPanel extends StatelessWidget {
  const JlptReadinessPanel({
    super.key,
    required this.language,
    required this.snapshot,
  });

  final AppLanguage language;
  final JlptCoachSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return JlptCoachPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _readinessTitle(language),
            caption: _readinessCaption(language),
          ),
          const SizedBox(height: AppSpacing.sm),
          JlptCoachSectionAccent(accent: palette.primary),
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
                    _readinessEmptyTitle(language),
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _readinessEmptyBody(language),
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.72),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppStatusChip(
                        label: _baselineChip(language),
                        tone: AppStatusTone.warning,
                      ),
                      AppStatusChip(
                        label: _passRuleLabel(language),
                        tone: AppStatusTone.neutral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            AppProgressStrip(
              value: snapshot!.profile.overallAccuracy.clamp(0.06, 1.0),
              label: _readinessSummary(language, snapshot!),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppStatusChip(
                  label: _snapshotSourceLabel(
                    language,
                    snapshot!.profile.source,
                  ),
                  tone: AppStatusTone.neutral,
                ),
                AppStatusChip(
                  label: _lastUpdatedLabel(
                    language,
                    snapshot!.profile.generatedAt,
                  ),
                  tone: AppStatusTone.primary,
                ),
                AppStatusChip(
                  label: jlptIsReadyForExam(snapshot!)
                      ? _passStatusLabel(language)
                      : _repairStatusLabel(language),
                  tone: jlptIsReadyForExam(snapshot!)
                      ? AppStatusTone.success
                      : AppStatusTone.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final area in JlptSkillArea.values) ...[
              _ReadinessBar(
                label: jlptAreaLabel(language, area),
                value: snapshot!.profile.statFor(area).accuracy,
                accent: jlptAreaColor(context, area),
              ),
              if (area != JlptSkillArea.values.last)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        ],
      ),
    );
  }
}

class _ReadinessBar extends StatelessWidget {
  const _ReadinessBar({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final normalized = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${(normalized * 100).round()}%',
              style: TextStyle(color: accent, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: palette.outlineSoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: normalized,
              child: Container(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _readinessTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Readiness and diagnosis',
  AppLanguage.vi => 'Độ sẵn sàng và chẩn đoán',
  AppLanguage.ja => '準備度と診断',
};

String _readinessCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Your latest exam baseline is translated into skill-by-skill weak points.',
  AppLanguage.vi =>
    'Baseline gần nhất được đổi thành các điểm yếu rõ ràng theo từng kỹ năng.',
  AppLanguage.ja => '直近の結果を技能ごとの弱点として見やすく整理します。',
};

String _readinessEmptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No personal baseline yet',
  AppLanguage.vi => 'Chưa có baseline cá nhân',
  AppLanguage.ja => '個人ベースラインはまだありません',
};

String _readinessEmptyBody(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Finish one reading drill or one full mock and this area will turn into a personalized readiness map with a repair plan.',
  AppLanguage.vi =>
    'Hoàn thành 1 bài reading drill hoặc 1 full mock, khu vực này sẽ đổi thành readiness map và kế hoạch sửa lỗ hổng cho riêng bạn.',
  AppLanguage.ja => '読解ドリルかフル模試を1回終えると、ここが個別の準備度マップと補強プランに変わります。',
};

String _baselineChip(AppLanguage language) => switch (language) {
  AppLanguage.en => 'First run creates the baseline',
  AppLanguage.vi => 'Lần đầu sẽ tạo baseline',
  AppLanguage.ja => '初回で基準を作成',
};

String _passRuleLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Pass rule: 60% overall, no area below 40%',
  AppLanguage.vi => 'Mốc đạt: tổng 60%, không kỹ năng nào dưới 40%',
  AppLanguage.ja => '合格目安: 総合60%、各技能40%以上',
};

String _readinessSummary(AppLanguage language, JlptCoachSnapshot snapshot) {
  final percent = (snapshot.profile.overallAccuracy * 100).round();
  return jlptIsReadyForExam(snapshot)
      ? switch (language) {
          AppLanguage.en => '$percent% readiness • projected pass zone',
          AppLanguage.vi => '$percent% độ sẵn sàng • đang ở ngưỡng đậu',
          AppLanguage.ja => '準備度 $percent% • 合格圏',
        }
      : switch (language) {
          AppLanguage.en => '$percent% readiness • still needs repair',
          AppLanguage.vi => '$percent% độ sẵn sàng • vẫn cần vá thêm',
          AppLanguage.ja => '準備度 $percent% • まだ補強が必要',
        };
}

String _snapshotSourceLabel(AppLanguage language, String source) {
  switch (source) {
    case 'jlpt_mock_pro':
      return switch (language) {
        AppLanguage.en => 'Source: full mock',
        AppLanguage.vi => 'Nguồn: full mock',
        AppLanguage.ja => '元データ: フル模試',
      };
    case 'jlpt_reading':
      return switch (language) {
        AppLanguage.en => 'Source: reading drill',
        AppLanguage.vi => 'Nguồn: reading drill',
        AppLanguage.ja => '元データ: 読解ドリル',
      };
    default:
      return switch (language) {
        AppLanguage.en => 'Source: JLPT prep',
        AppLanguage.vi => 'Nguồn: JLPT prep',
        AppLanguage.ja => '元データ: JLPT対策',
      };
  }
}

String _lastUpdatedLabel(AppLanguage language, DateTime date) {
  final text =
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  return switch (language) {
    AppLanguage.en => 'Updated $text',
    AppLanguage.vi => 'Cập nhật $text',
    AppLanguage.ja => '$text 更新',
  };
}

String _passStatusLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Projected pass',
  AppLanguage.vi => 'Dự đoán đạt',
  AppLanguage.ja => '合格予測',
};

String _repairStatusLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Repair first',
  AppLanguage.vi => 'Cần sửa trước',
  AppLanguage.ja => '先に補強',
};
