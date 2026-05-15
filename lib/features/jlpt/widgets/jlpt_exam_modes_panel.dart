import 'package:flutter/material.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_coach_shared.dart';

class JlptExamModesPanel extends StatelessWidget {
  const JlptExamModesPanel({
    super.key,
    required this.language,
    required this.level,
    required this.snapshot,
    required this.fullMockSectionCount,
    required this.fullMockQuestionCount,
    required this.fullMockMinutes,
    required this.quickMockQuestionCount,
    required this.readingPassageCount,
    required this.readingQuestionCount,
    required this.isLoading,
  });

  final AppLanguage language;
  final StudyLevel level;
  final JlptCoachSnapshot? snapshot;
  final int fullMockSectionCount;
  final int fullMockQuestionCount;
  final int fullMockMinutes;
  final int quickMockQuestionCount;
  final int readingPassageCount;
  final int readingQuestionCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final readinessValue = jlptReadinessValue(language, snapshot);
    final readinessTone = snapshot == null
        ? AppStatusTone.warning
        : jlptIsReadyForExam(snapshot!)
        ? AppStatusTone.success
        : AppStatusTone.primary;

    final cards = [
      _PrepModeCardData(
        icon: Icons.fact_check_rounded,
        title: _fullMockTitle(language),
        subtitle: _fullMockSubtitle(language),
        meta:
            '$fullMockSectionCount phần • $fullMockQuestionCount câu • $fullMockMinutes phút',
        statusLabel: readinessValue,
        statusTone: readinessTone,
        accent: context.appPalette.accent,
        onTap: () => context.openJlptMockPro(),
      ),
      _PrepModeCardData(
        icon: Icons.timer_rounded,
        title: _quickMockTitle(language),
        subtitle: _quickMockSubtitle(language, level),
        meta: isLoading
            ? _loadingLabel(language)
            : _quickMockMeta(language, quickMockQuestionCount),
        statusLabel: quickMockQuestionCount > 0
            ? level.shortLabel
            : _comingSoonLabel(language),
        statusTone: quickMockQuestionCount > 0
            ? AppStatusTone.neutral
            : AppStatusTone.warning,
        accent: context.appPalette.primary,
        onTap: quickMockQuestionCount > 0
            ? () => context.openPracticeMockExam()
            : null,
      ),
      _PrepModeCardData(
        icon: Icons.menu_book_rounded,
        title: _readingDrillTitle(language),
        subtitle: _readingDrillSubtitle(language, level),
        meta: isLoading
            ? _loadingLabel(language)
            : _readingDrillMeta(
                language,
                passages: readingPassageCount,
                questions: readingQuestionCount,
              ),
        statusLabel: level.shortLabel,
        statusTone: AppStatusTone.primary,
        accent: context.appPalette.secondary,
        onTap: () => context.openJlptReading(),
      ),
    ];

    return JlptCoachPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _modesTitle(language),
            caption: _modesCaption(language, level),
          ),
          const SizedBox(height: AppSpacing.sm),
          JlptCoachSectionAccent(accent: context.appPalette.accent),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              final width = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - ((columns - 1) * AppSpacing.md)) /
                        columns;

              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width: width,
                      child: _PrepModeCard(data: card, language: language),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PrepModeCardData {
  const _PrepModeCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.statusLabel,
    required this.statusTone,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final String statusLabel;
  final AppStatusTone statusTone;
  final Color accent;
  final VoidCallback? onTap;
}

class _PrepModeCard extends StatelessWidget {
  const _PrepModeCard({required this.data, required this.language});

  final _PrepModeCardData data;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = data.onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration:
              HomeSurface.softPanel(
                radius: AppSpacing.radiusXxl,
                colors: [
                  palette.elevated,
                  Color.lerp(
                        palette.base,
                        data.accent.withValues(alpha: 0.04),
                        0.45,
                      ) ??
                      palette.base,
                ],
              ).copyWith(
                boxShadow: [
                  BoxShadow(
                    color: data.accent.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
          child: Opacity(
            opacity: enabled ? 1 : 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 3,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            data.accent.withValues(alpha: 0.16),
                            data.accent.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(data.icon, color: data.accent),
                    ),
                    const Spacer(),
                    AppStatusChip(
                      label: data.statusLabel,
                      tone: data.statusTone,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  data.title,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                    height: 1.40,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    data.meta,
                    style: TextStyle(
                      color: data.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        enabled
                            ? _openLaneLabel(language)
                            : _preparingDataLabel(language),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.ink.withValues(alpha: 0.56),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: palette.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        enabled
                            ? Icons.arrow_outward_rounded
                            : Icons.schedule_rounded,
                        size: 18,
                        color: palette.ink.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _modesTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Exam modes',
  AppLanguage.vi => 'Chế độ ôn thi',
  AppLanguage.ja => '試験モード',
};

String _modesCaption(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'Everything below stays locked to ${level.shortLabel}, so mock, reading, and diagnosis all speak the same level.',
  AppLanguage.vi =>
    'Tất cả chế độ bên dưới đều bám đúng ${level.shortLabel}, để thi thử, đọc hiểu và chẩn đoán nói cùng một mức độ.',
  AppLanguage.ja =>
    '下のモードはすべて ${level.shortLabel} にそろえてあり、模試・読解・診断が同じ難度でつながります。',
};

String _fullMockTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Full mock',
  AppLanguage.vi => 'Thi thử đầy đủ',
  AppLanguage.ja => 'フル模試',
};

String _fullMockSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Run the full exam flow with section timing, scoring, and instant diagnosis.',
  AppLanguage.vi =>
    'Chạy đủ luồng thi với timer theo từng phần, chấm điểm và chẩn đoán ngay.',
  AppLanguage.ja => 'セクション時間、採点、診断つきで本番に近い流れを回します。',
};

String _quickMockTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick mock',
  AppLanguage.vi => 'Kiểm tra nhanh',
  AppLanguage.ja => 'クイック模試',
};

String _quickMockSubtitle(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'A shorter timed check built from the ${level.shortLabel} vocabulary bank already in the app.',
  AppLanguage.vi =>
    'Bài kiểm tra ngắn có bấm giờ, dùng từ vựng ${level.shortLabel} đã có sẵn trong app.',
  AppLanguage.ja => 'アプリ内の ${level.shortLabel} 語彙バンクから作る短い時間制チェックです。',
};

String _quickMockMeta(
  AppLanguage language,
  int questionCount,
) => switch (language) {
  AppLanguage.en =>
    '${AppLanguage.en.questionsCountLabel(questionCount)} ready from your level bank',
  AppLanguage.vi => '$questionCount câu hỏi sẵn sàng từ bank hiện tại',
  AppLanguage.ja => '$questionCount 問を現在レベルから使用',
};

String _comingSoonLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No bank yet',
  AppLanguage.vi => 'Chưa có bank',
  AppLanguage.ja => '未準備',
};

String _readingDrillTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Reading drill',
  AppLanguage.vi => 'Đọc hiểu mục tiêu',
  AppLanguage.ja => '読解ドリル',
};

String _readingDrillSubtitle(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'Practice timed passages that stay on the ${level.shortLabel} track only.',
  AppLanguage.vi =>
    'Luyện bài đọc có bấm giờ, chỉ giữ đúng track ${level.shortLabel}.',
  AppLanguage.ja => '${level.shortLabel} だけに絞った時間つき読解を回します。',
};

String _readingDrillMeta(
  AppLanguage language, {
  required int passages,
  required int questions,
}) => switch (language) {
  AppLanguage.en => '$passages passages • $questions questions',
  AppLanguage.vi => '$passages bài đọc • $questions câu hỏi',
  AppLanguage.ja => '$passages 本 • $questions 問',
};

String _openLaneLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open lane',
  AppLanguage.vi => 'Mở lane',
  AppLanguage.ja => '開く',
};

String _preparingDataLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Preparing data',
  AppLanguage.vi => 'Đang chuẩn bị dữ liệu',
  AppLanguage.ja => 'データ準備中',
};

String _loadingLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Loading',
  AppLanguage.vi => 'Đang tải',
  AppLanguage.ja => '読み込み中',
};
