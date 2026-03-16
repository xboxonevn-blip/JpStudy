import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final continueAction = ref.watch(continueActionProvider).valueOrNull;
    final dueCount =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final weakCount = dashboard?.totalMistakeCount ?? 0;
    final hasStartedToday = (dashboard?.todayXp ?? 0) > 0;

    return JapaneseBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 84, 16, 100),
          children: [
            AppFeatureCard(
              icon: Icons.play_circle_rounded,
              title: _heroTitle(language, continueAction),
              subtitle: _heroSubtitle(
                language,
                continueAction,
                dueCount,
                weakCount,
              ),
              primaryLabel: _continueLabel(language),
              onPrimaryTap: () =>
                  _handleContinue(context, continueAction, dashboard),
              secondaryLabel: _changeActivityLabel(language),
              onSecondaryTap: () => context.go('/study'),
              status: AppStatusChip(
                label: _heroStatus(
                  language,
                  dueCount,
                  weakCount,
                  hasStartedToday,
                ),
                tone: dueCount > 0
                    ? AppStatusTone.warning
                    : hasStartedToday
                    ? AppStatusTone.success
                    : AppStatusTone.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusChip(
                  label: _dueLabel(language, dueCount),
                  tone: dueCount > 0
                      ? AppStatusTone.warning
                      : AppStatusTone.success,
                ),
                AppStatusChip(
                  label: _streakLabel(language, dashboard?.streak ?? 0),
                  tone: AppStatusTone.primary,
                ),
                AppStatusChip(
                  label: _todayLabel(language, dashboard?.todayXp ?? 0),
                  tone: hasStartedToday
                      ? AppStatusTone.success
                      : AppStatusTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppSectionHeader(
              title: _whyTitle(language),
              caption: _whyCaption(language),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.schedule_rounded,
              title: _dueInsightTitle(language),
              subtitle: _dueInsightSubtitle(language, dueCount),
              status: AppStatusChip(
                label: '$dueCount',
                tone: dueCount > 0
                    ? AppStatusTone.warning
                    : AppStatusTone.success,
              ),
              onTap: () => _handleContinue(context, continueAction, dashboard),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.auto_fix_high_rounded,
              title: _weakInsightTitle(language),
              subtitle: _weakInsightSubtitle(language, weakCount),
              status: AppStatusChip(
                label: '$weakCount',
                tone: weakCount > 0
                    ? AppStatusTone.warning
                    : AppStatusTone.success,
              ),
              onTap: () => context.push('/mistakes'),
            ),
            const SizedBox(height: 20),
            AppSectionHeader(
              title: _moreTitle(language),
              caption: _moreCaption(language),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.play_lesson_rounded,
              title: _studyHubTitle(language),
              subtitle: _studyHubSubtitle(language),
              onTap: () => context.go('/study'),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.school_rounded,
              title: _jlptTitle(language),
              subtitle: _jlptSubtitle(language),
              onTap: () => context.push('/jlpt/coach'),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.article_rounded,
              title: _immersionTitle(language),
              subtitle: _immersionSubtitle(language),
              onTap: () => context.push('/immersion'),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.layers_rounded,
              title: _libraryTitle(language),
              subtitle: _librarySubtitle(language),
              onTap: () => context.go('/library'),
            ),
            const SizedBox(height: 10),
            AppCompactRow(
              icon: Icons.search_rounded,
              title: _searchTitle(language),
              subtitle: _searchSubtitle(language),
              onTap: () => context.push('/search'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue(
    BuildContext context,
    ContinueAction? continueAction,
    DashboardState? dashboard,
  ) {
    switch (continueAction?.type) {
      case ContinueActionType.grammarReview:
        final ids = continueAction?.data;
        if (ids is List<int> && ids.isNotEmpty) {
          context.push('/grammar-practice', extra: ids);
        } else {
          context.go('/study');
        }
        return;
      case ContinueActionType.vocabReview:
        context.push('/vocab/review');
        return;
      case ContinueActionType.kanjiReview:
        final lessonId = continueAction?.data;
        if (lessonId is int) {
          context.push('/lesson/$lessonId');
        } else {
          context.push('/kanji-dash');
        }
        return;
      case ContinueActionType.fixMistakes:
        context.push('/mistakes');
        return;
      case ContinueActionType.nextLesson:
        final lessonId = continueAction?.data;
        if (lessonId is int) {
          context.push('/lesson/$lessonId');
        } else {
          context.go('/study');
        }
        return;
      case ContinueActionType.practiceMixed:
      case null:
        if ((dashboard?.totalMistakeCount ?? 0) > 0) {
          context.push('/mistakes');
        } else {
          context.go('/study');
        }
        return;
    }
  }

  String _continueLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Continue',
    AppLanguage.vi => 'Tiếp tục',
    AppLanguage.ja => '続ける',
  };

  String _changeActivityLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Change',
    AppLanguage.vi => 'Đổi hoạt động',
    AppLanguage.ja => '切り替え',
  };

  String _heroTitle(AppLanguage language, ContinueAction? action) =>
      switch (language) {
        AppLanguage.en => action?.label ?? 'Study now',
        AppLanguage.vi => action?.label ?? 'Học ngay',
        AppLanguage.ja => action?.label ?? '今すぐ学ぶ',
      };

  String _heroSubtitle(
    AppLanguage language,
    ContinueAction? action,
    int dueCount,
    int weakCount,
  ) {
    switch (language) {
      case AppLanguage.en:
        return dueCount > 0
            ? 'Clear due review first, then continue your next block.'
            : weakCount > 0
            ? 'Fix weak points first, then move on.'
            : 'Your next best step is ready.';
      case AppLanguage.vi:
        return dueCount > 0
            ? 'Xử lý phần đến hạn trước, rồi học tiếp.'
            : weakCount > 0
            ? 'Sửa điểm yếu trước, rồi học tiếp.'
            : 'Bước học tiếp theo đã sẵn sàng.';
      case AppLanguage.ja:
        return dueCount > 0
            ? '期限のある復習を先に片づけましょう。'
            : weakCount > 0
            ? '苦手な項目を先に直しましょう。'
            : '次にやることはもう決まっています。';
    }
  }

  String _heroStatus(
    AppLanguage language,
    int dueCount,
    int weakCount,
    bool hasStartedToday,
  ) {
    if (dueCount > 0) {
      return switch (language) {
        AppLanguage.en => 'Due now',
        AppLanguage.vi => 'Đến hạn',
        AppLanguage.ja => '期限あり',
      };
    }
    if (weakCount > 0) {
      return switch (language) {
        AppLanguage.en => 'Weak points',
        AppLanguage.vi => 'Điểm yếu',
        AppLanguage.ja => '苦手',
      };
    }
    if (hasStartedToday) {
      return switch (language) {
        AppLanguage.en => 'Started',
        AppLanguage.vi => 'Đã học',
        AppLanguage.ja => '開始済み',
      };
    }
    return switch (language) {
      AppLanguage.en => 'Ready',
      AppLanguage.vi => 'Sẵn sàng',
      AppLanguage.ja => '準備完了',
    };
  }

  String _dueLabel(AppLanguage language, int dueCount) => switch (language) {
    AppLanguage.en => '$dueCount due',
    AppLanguage.vi => '$dueCount đến hạn',
    AppLanguage.ja => '$dueCount 件',
  };

  String _streakLabel(AppLanguage language, int streak) => switch (language) {
    AppLanguage.en => '$streak streak',
    AppLanguage.vi => '$streak ngày',
    AppLanguage.ja => '$streak 日',
  };

  String _todayLabel(AppLanguage language, int xp) => switch (language) {
    AppLanguage.en => '$xp XP today',
    AppLanguage.vi => '$xp XP hôm nay',
    AppLanguage.ja => '今日 $xp XP',
  };

  String _whyTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Why',
    AppLanguage.vi => 'Vì sao',
    AppLanguage.ja => '理由',
  };

  String _whyCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'What needs attention now',
    AppLanguage.vi => 'Những gì cần xử lý ngay',
    AppLanguage.ja => '今すぐ見るべきこと',
  };

  String _dueInsightTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due review',
    AppLanguage.vi => 'Ôn đến hạn',
    AppLanguage.ja => '期限の復習',
  };

  String _dueInsightSubtitle(AppLanguage language, int dueCount) {
    switch (language) {
      case AppLanguage.en:
        return dueCount > 0
            ? 'You have $dueCount items waiting now.'
            : 'No review is waiting right now.';
      case AppLanguage.vi:
        return dueCount > 0
            ? 'Hiện có $dueCount mục đang chờ ôn.'
            : 'Hiện chưa có mục đến hạn.';
      case AppLanguage.ja:
        return dueCount > 0 ? '$dueCount 件が待っています。' : '今は期限の復習はありません。';
    }
  }

  String _weakInsightTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Fix weak points',
    AppLanguage.vi => 'Sửa điểm yếu',
    AppLanguage.ja => '苦手を直す',
  };

  String _weakInsightSubtitle(AppLanguage language, int weakCount) {
    switch (language) {
      case AppLanguage.en:
        return weakCount > 0
            ? '$weakCount weak items still need another pass.'
            : 'Your weak-item queue is clear.';
      case AppLanguage.vi:
        return weakCount > 0
            ? '$weakCount mục yếu vẫn cần thêm một lượt.'
            : 'Hàng đợi mục yếu đang trống.';
      case AppLanguage.ja:
        return weakCount > 0 ? '$weakCount 件の苦手項目が残っています。' : '苦手キューは空です。';
    }
  }

  String _moreTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'More',
    AppLanguage.vi => 'Đi tiếp',
    AppLanguage.ja => 'その他',
  };

  String _moreCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Other ways to keep momentum',
    AppLanguage.vi => 'Các đường học khác',
    AppLanguage.ja => '他の進め方',
  };

  String _studyHubTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Study',
    AppLanguage.vi => 'Học',
    AppLanguage.ja => '学習',
  };

  String _studyHubSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Review, fix, speed, or test',
    AppLanguage.vi => 'Ôn, sửa, tăng tốc, thi thử',
    AppLanguage.ja => '復習、修正、速度、模試',
  };

  String _jlptTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT Coach',
    AppLanguage.vi => 'JLPT Coach',
    AppLanguage.ja => 'JLPTコーチ',
  };

  String _jlptSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading, mock, diagnosis',
    AppLanguage.vi => 'Đọc hiểu, mock, chẩn đoán',
    AppLanguage.ja => '読解、模試、診断',
  };

  String _immersionTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Immersion',
    AppLanguage.vi => 'Immersion',
    AppLanguage.ja => '多読',
  };

  String _immersionSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Read, save, measure',
    AppLanguage.vi => 'Đọc, lưu, đo tiến độ',
    AppLanguage.ja => '読む、保存、測る',
  };

  String _libraryTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Library',
    AppLanguage.vi => 'Thư viện',
    AppLanguage.ja => 'ライブラリ',
  };

  String _librarySubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Browse lessons and content',
    AppLanguage.vi => 'Duyệt bài học và nội dung',
    AppLanguage.ja => 'レッスンと教材を見る',
  };

  String _searchTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Search',
    AppLanguage.vi => 'Tìm kiếm',
    AppLanguage.ja => '検索',
  };

  String _searchSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Look up vocab and kanji',
    AppLanguage.vi => 'Tra từ vựng và kanji',
    AppLanguage.ja => '語彙と漢字を調べる',
  };
}
