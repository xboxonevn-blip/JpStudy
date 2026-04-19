import 'package:flutter/material.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/jlpt/models/jlpt_coach_models.dart';
import 'package:jpstudy/features/jlpt/widgets/jlpt_coach_shared.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

class JlptSupportPanel extends StatelessWidget {
  const JlptSupportPanel({
    super.key,
    required this.language,
    required this.level,
    required this.dueCount,
    required this.vocabDue,
    required this.grammarDue,
    required this.kanjiDue,
    required this.mistakeStream,
  });

  final AppLanguage language;
  final StudyLevel level;
  final int dueCount;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;
  final Stream<List<UserMistake>> mistakeStream;

  @override
  Widget build(BuildContext context) {
    return JlptCoachPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _supportTitle(language),
            caption: _supportCaption(language),
          ),
          const SizedBox(height: AppSpacing.sm),
          JlptCoachSectionAccent(accent: context.appPalette.secondary),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<UserMistake>>(
            stream: mistakeStream,
            builder: (context, snapshot) {
              final mistakes = snapshot.data ?? const <UserMistake>[];
              final buckets = computeMistakeDueBuckets(
                mistakes,
                DateTime.now(),
              );

              return Column(
                children: [
                  AppCompactRow(
                    icon: Icons.auto_fix_high_rounded,
                    title: _weakPointsTitle(language),
                    subtitle: _weakPointsSubtitle(language, buckets),
                    status: AppStatusChip(
                      label: mistakes.isEmpty
                          ? _readyShortLabel(language)
                          : '${mistakes.length}',
                      tone: mistakes.isEmpty
                          ? AppStatusTone.success
                          : AppStatusTone.warning,
                    ),
                    onTap: () => context.openMistakes(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCompactRow(
                    icon: Icons.hub_rounded,
                    title: _studyLaneTitle(language),
                    subtitle: _studyLaneSubtitle(
                      language,
                      vocabDue,
                      grammarDue,
                      kanjiDue,
                      dueCount,
                    ),
                    status: AppStatusChip(
                      label: dueCount > 0
                          ? '$dueCount'
                          : _readyShortLabel(language),
                      tone: dueCount > 0
                          ? AppStatusTone.warning
                          : AppStatusTone.success,
                    ),
                    onTap: () => context.openStudy(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCompactRow(
                    icon: Icons.local_florist_rounded,
                    title: _immersionTitle(language),
                    subtitle: _immersionSubtitle(language, level),
                    status: AppStatusChip(
                      label: level.shortLabel,
                      tone: AppStatusTone.primary,
                    ),
                    onTap: () => context.openImmersion(),
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

String _supportTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Support lanes',
  AppLanguage.vi => 'Lane hỗ trợ',
  AppLanguage.ja => '補助レーン',
};

String _supportCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'These lanes help you repair what the mock and reading flow expose.',
  AppLanguage.vi =>
    'Đây là các lane để vá lại những chỗ mock và reading đang làm lộ ra.',
  AppLanguage.ja => '模試や読解で出た弱点を、ここから埋め直します。',
};

String _weakPointsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Weak points notebook',
  AppLanguage.vi => 'Sổ tay điểm yếu',
  AppLanguage.ja => '弱点ノート',
};

String _weakPointsSubtitle(
  AppLanguage language,
  MistakeDueBuckets buckets,
) => switch (language) {
  AppLanguage.en =>
    buckets.totalDue > 0
        ? 'D1 ${buckets.due1d} • D3 ${buckets.due3d} • D7 ${buckets.due7d} are ready for repair.'
        : 'No urgent weak points right now. Keep this lane for post-mock repair.',
  AppLanguage.vi =>
    buckets.totalDue > 0
        ? 'D1 ${buckets.due1d} • D3 ${buckets.due3d} • D7 ${buckets.due7d} đang chờ xử lý.'
        : 'Chưa có điểm yếu gấp. Giữ lane này để sửa sau mỗi lần mock.',
  AppLanguage.ja =>
    buckets.totalDue > 0
        ? 'D1 ${buckets.due1d} • D3 ${buckets.due3d} • D7 ${buckets.due7d} を補強できます。'
        : '今すぐ直す弱点はありません。模試後の補強用に残しておけます。',
};

String _readyShortLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Ready',
  AppLanguage.vi => 'Sẵn sàng',
  AppLanguage.ja => '準備OK',
};

String _studyLaneTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Focused drill hub',
  AppLanguage.vi => 'Hub drill tập trung',
  AppLanguage.ja => '集中ドリルハブ',
};

String _studyLaneSubtitle(
  AppLanguage language,
  int vocabDue,
  int grammarDue,
  int kanjiDue,
  int dueCount,
) => switch (language) {
  AppLanguage.en =>
    dueCount > 0
        ? 'Due now: vocab $vocabDue • grammar $grammarDue • kanji $kanjiDue.'
        : 'Queue is calm, so this is a clean place to tighten weak skills between mock runs.',
  AppLanguage.vi =>
    dueCount > 0
        ? 'Đến hạn: từ vựng $vocabDue • ngữ pháp $grammarDue • kanji $kanjiDue.'
        : 'Hàng đợi đang nhẹ, hợp để siết các kỹ năng yếu giữa hai lần thi thử.',
  AppLanguage.ja =>
    dueCount > 0
        ? '期限あり: 語彙 $vocabDue • 文法 $grammarDue • 漢字 $kanjiDue'
        : 'キューが落ち着いているので、模試の合間の補強に向いています。',
};

String _immersionTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Reading speed lab',
  AppLanguage.vi => 'Phòng tăng tốc đọc',
  AppLanguage.ja => '読解スピードラボ',
};

String _immersionSubtitle(AppLanguage language, StudyLevel level) =>
    switch (language) {
      AppLanguage.en =>
        'Read real Japanese on the ${level.shortLabel} lane, save words, and keep exam stamina natural.',
      AppLanguage.vi =>
        'Đọc tiếng Nhật thật trên lane ${level.shortLabel}, lưu từ và giữ sức bền khi vào đề.',
      AppLanguage.ja =>
        '${level.shortLabel} レーンで実際の日本語を読み、語彙を保存しながら本番の持久力を整えます。',
    };
