import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final vocabDue = dashboard?.vocabDue ?? 0;
    final grammarDue = dashboard?.grammarDue ?? 0;
    final kanjiDue = dashboard?.kanjiDue ?? 0;
    final dueCount = vocabDue + grammarDue + kanjiDue;
    final mistakeCount = dashboard?.totalMistakeCount ?? 0;
    final items = buildPracticeDestinations(
      language: language,
      dueReviewCount: dueCount,
      vocabDue: vocabDue,
      grammarDue: grammarDue,
      kanjiDue: kanjiDue,
      mistakeCount: mistakeCount,
      level: level,
      preferImmersion: dueCount == 0 && mistakeCount == 0,
    );

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: JapaneseBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              AppFeatureCard(
                icon: Icons.play_lesson_rounded,
                title: _title(language),
                subtitle: _subtitle(language),
                primaryLabel: _primaryCta(language),
                onPrimaryTap: () =>
                    _openPrimaryGoal(context, dueCount, mistakeCount),
                secondaryLabel: _searchLabel(language),
                onSecondaryTap: () => context.push('/search'),
                status: AppStatusChip(
                  label: dueCount > 0
                      ? _dueBadge(language, dueCount)
                      : _readyBadge(language),
                  tone: dueCount > 0
                      ? AppStatusTone.warning
                      : AppStatusTone.success,
                ),
              ),
              const SizedBox(height: 20),
              AppSectionHeader(
                title: _goalsTitle(language),
                caption: _goalsCaption(language),
              ),
              const SizedBox(height: 10),
              _GoalTile(
                icon: Icons.schedule_rounded,
                title: _goalDueTitle(language),
                subtitle: _goalDueSubtitle(language, dueCount),
                onTap: () => _openPrimaryGoal(context, dueCount, mistakeCount),
                status: AppStatusChip(
                  label: '$dueCount',
                  tone: dueCount > 0
                      ? AppStatusTone.warning
                      : AppStatusTone.neutral,
                ),
              ),
              const SizedBox(height: 10),
              _GoalTile(
                icon: Icons.auto_fix_high_rounded,
                title: _goalFixTitle(language),
                subtitle: _goalFixSubtitle(language, mistakeCount),
                onTap: () => context.push('/mistakes'),
                status: AppStatusChip(
                  label: '$mistakeCount',
                  tone: mistakeCount > 0
                      ? AppStatusTone.warning
                      : AppStatusTone.neutral,
                ),
              ),
              const SizedBox(height: 10),
              _GoalTile(
                icon: Icons.speed_rounded,
                title: _goalSpeedTitle(language),
                subtitle: _goalSpeedSubtitle(language),
                onTap: () => context.push('/immersion'),
              ),
              const SizedBox(height: 10),
              _GoalTile(
                icon: Icons.quiz_rounded,
                title: _goalTestTitle(language),
                subtitle: _goalTestSubtitle(language),
                onTap: () => context.push('/jlpt/coach'),
              ),
              const SizedBox(height: 20),
              AppSectionHeader(
                title: _toolsTitle(language),
                caption: _toolsCaption(language),
              ),
              const SizedBox(height: 10),
              ...items
                  .take(4)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCompactRow(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        status: item.badgeCount != null
                            ? AppStatusChip(
                                label: '${item.badgeCount}',
                                tone: AppStatusTone.warning,
                              )
                            : item.estimatedMinutes != null
                            ? AppStatusChip(
                                label: '~${item.estimatedMinutes}m',
                                tone: AppStatusTone.neutral,
                              )
                            : null,
                        onTap: () {
                          if (item.extra != null) {
                            context.push(item.route, extra: item.extra);
                          } else {
                            context.push(item.route);
                          }
                        },
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPrimaryGoal(BuildContext context, int dueCount, int mistakeCount) {
    if (dueCount > 0) {
      context.push('/vocab/review');
      return;
    }
    if (mistakeCount > 0) {
      context.push('/mistakes');
      return;
    }
    context.push('/immersion');
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Study',
    AppLanguage.vi => 'Học',
    AppLanguage.ja => '学習',
  };
  String _subtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Pick one clear goal and keep moving.',
    AppLanguage.vi => 'Chọn một mục tiêu rõ ràng rồi học tiếp.',
    AppLanguage.ja => '目的をひとつ選んで進めましょう。',
  };
  String _primaryCta(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Start now',
    AppLanguage.vi => 'Bắt đầu',
    AppLanguage.ja => '始める',
  };
  String _searchLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Search',
    AppLanguage.vi => 'Tìm kiếm',
    AppLanguage.ja => '検索',
  };
  String _dueBadge(AppLanguage language, int dueCount) => switch (language) {
    AppLanguage.en => '$dueCount due',
    AppLanguage.vi => '$dueCount đến hạn',
    AppLanguage.ja => '$dueCount 件',
  };
  String _readyBadge(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Ready',
    AppLanguage.vi => 'Sẵn sàng',
    AppLanguage.ja => '準備完了',
  };
  String _goalsTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Goals',
    AppLanguage.vi => 'Mục tiêu',
    AppLanguage.ja => '目標',
  };
  String _goalsCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Choose by outcome, not by feature',
    AppLanguage.vi => 'Chọn theo kết quả, không theo tính năng',
    AppLanguage.ja => '機能ではなく結果で選ぶ',
  };
  String _goalDueTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due review',
    AppLanguage.vi => 'Ôn đến hạn',
    AppLanguage.ja => '期限の復習',
  };
  String _goalDueSubtitle(
    AppLanguage language,
    int dueCount,
  ) => switch (language) {
    AppLanguage.en =>
      dueCount > 0
          ? '$dueCount items are waiting now.'
          : 'No due review right now.',
    AppLanguage.vi =>
      dueCount > 0 ? '$dueCount mục đang chờ ôn.' : 'Hiện chưa có mục đến hạn.',
    AppLanguage.ja => dueCount > 0 ? '$dueCount 件が待っています。' : '今は期限の復習はありません。',
  };
  String _goalFixTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Fix weak points',
    AppLanguage.vi => 'Sửa điểm yếu',
    AppLanguage.ja => '苦手を直す',
  };
  String _goalFixSubtitle(AppLanguage language, int count) =>
      switch (language) {
        AppLanguage.en =>
          count > 0
              ? '$count weak items still need work.'
              : 'No weak items are waiting.',
        AppLanguage.vi =>
          count > 0
              ? '$count mục yếu vẫn cần xử lý.'
              : 'Hiện chưa có mục yếu chờ xử lý.',
        AppLanguage.ja => count > 0 ? '$count 件の苦手項目が残っています。' : '苦手項目はありません。',
      };
  String _goalSpeedTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Build speed',
    AppLanguage.vi => 'Tăng tốc độ',
    AppLanguage.ja => '読む速さ',
  };
  String _goalSpeedSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Read, save words, and measure progress.',
    AppLanguage.vi => 'Đọc, lưu từ, và đo tiến độ.',
    AppLanguage.ja => '読んで、単語を保存して、進みを測る。',
  };
  String _goalTestTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Mock exam',
    AppLanguage.vi => 'Thi thử',
    AppLanguage.ja => '模試',
  };
  String _goalTestSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading, mock, diagnosis, and plan.',
    AppLanguage.vi => 'Đọc hiểu, mock, chẩn đoán, kèm kế hoạch.',
    AppLanguage.ja => '読解、模試、診断、計画。',
  };
  String _toolsTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Tools',
    AppLanguage.vi => 'Công cụ',
    AppLanguage.ja => 'ツール',
  };
  String _toolsCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Compact routes for the rest',
    AppLanguage.vi => 'Lối vào gọn cho các phần còn lại',
    AppLanguage.ja => '残りの入口をまとめる',
  };
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    return AppCompactRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      status: status,
      onTap: onTap,
    );
  }
}
