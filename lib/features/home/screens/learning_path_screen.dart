import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final continueAction = ref.watch(continueActionProvider).valueOrNull;

    final streak = dashboard?.streak ?? 0;
    final todayXp = dashboard?.todayXp ?? 0;
    final dueCount =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final weakCount = dashboard?.totalMistakeCount ?? 0;
    final hasStartedToday = todayXp > 0;
    final progressValue = hasStartedToday ? (todayXp / 30).clamp(0.12, 1.0) : 0.08;

    return AppPageShell(
      topPadding: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFeatureCard(
            icon: Icons.auto_stories_rounded,
            title: continueAction?.label ?? _heroTitle(language),
            subtitle: _heroSubtitle(language, dueCount: dueCount, weakCount: weakCount),
            primaryLabel: _continueLabel(language),
            onPrimaryTap: () => _openContinueAction(context, continueAction),
            secondaryLabel: _changeActivityLabel(language),
            onSecondaryTap: () => context.push('/study'),
            status: AppStatusChip(
              label: hasStartedToday ? _todayStartedLabel(language) : _todayReadyLabel(language),
              tone: hasStartedToday ? AppStatusTone.success : AppStatusTone.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppMetricPill(
                  label: _streakLabel(language),
                  value: '$streak',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricPill(
                  label: _todayLabel(language),
                  value: '$todayXp XP',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricPill(
                  label: _reviewLabel(language),
                  value: '$dueCount',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSectionCard(
            child: AppProgressStrip(
              value: progressValue,
              label: _progressCaption(language, hasStartedToday: hasStartedToday),
            ),
          ),
          const SizedBox(height: 20),
          AppSectionHeader(
            title: 'Why',
            caption: _whyCaption(language),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.auto_fix_high_rounded,
            title: 'Fix weak points',
            subtitle: _fixWeakPointsSubtitle(language, weakCount),
            status: AppStatusChip(
              label: '$weakCount',
              tone: weakCount > 0 ? AppStatusTone.warning : AppStatusTone.neutral,
            ),
            onTap: () => context.push('/mistakes'),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.schedule_rounded,
            title: _dueInsightTitle(language),
            subtitle: _dueInsightSubtitle(language, dueCount),
            status: AppStatusChip(
              label: '$dueCount',
              tone: dueCount > 0 ? AppStatusTone.warning : AppStatusTone.neutral,
            ),
            onTap: () => context.push('/study'),
          ),
          const SizedBox(height: 20),
          AppSectionHeader(
            title: _exploreTitle(language),
            caption: _exploreCaption(language),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.play_lesson_rounded,
            title: _studyHubTitle(language),
            subtitle: _studyHubSubtitle(language),
            onTap: () => context.push('/study'),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.quiz_rounded,
            title: _jlptTitle(language),
            subtitle: _jlptSubtitle(language),
            onTap: () => context.push('/jlpt/coach'),
          ),
          const SizedBox(height: 10),
          AppCompactRow(
            icon: Icons.newspaper_rounded,
            title: _immersionTitle(language),
            subtitle: _immersionSubtitle(language),
            onTap: () => context.push('/immersion'),
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
    );
  }

  void _openContinueAction(BuildContext context, ContinueAction? action) {
    if (action == null) {
      context.push('/study');
      return;
    }
    switch (action.type) {
      case ContinueActionType.grammarReview:
        context.push('/grammar-practice', extra: action.data);
        return;
      case ContinueActionType.vocabReview:
        context.push('/vocab/review');
        return;
      case ContinueActionType.kanjiReview:
        context.push('/practice/kanji-reading');
        return;
      case ContinueActionType.fixMistakes:
        context.push('/mistakes');
        return;
      case ContinueActionType.practiceMixed:
        context.push('/study');
        return;
      case ContinueActionType.nextLesson:
        final lessonId = action.data as int?;
        if (lessonId != null) {
          context.push('/lesson/$lessonId');
        } else {
          context.push('/library');
        }
        return;
    }
  }

  String _heroTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Study now',
    AppLanguage.vi => 'Học ngay',
    AppLanguage.ja => '今すぐ学ぶ',
  };

  String _heroSubtitle(AppLanguage language, {required int dueCount, required int weakCount}) {
    if (dueCount > 0) {
      return switch (language) {
        AppLanguage.en => '$dueCount review items are ready right now. Clear them first for the smoothest study flow.',
        AppLanguage.vi => 'Hiện có $dueCount mục đến hạn. Ôn trước để luồng học hôm nay mượt hơn.',
        AppLanguage.ja => '今は $dueCount 件の復習が待っています。先に片づけると今日の学習が進めやすくなります。',
      };
    }
    if (weakCount > 0) {
      return switch (language) {
        AppLanguage.en => '$weakCount weak spots still need repair. One short pass will tighten your recall.',
        AppLanguage.vi => 'Vẫn còn $weakCount điểm yếu cần xử lý. Chỉ một lượt ngắn là đủ để kéo trí nhớ lên lại.',
        AppLanguage.ja => '$weakCount 件の弱点が残っています。短い 1 セッションで思い出しを立て直せます。',
      };
    }
    return switch (language) {
      AppLanguage.en => 'You are free to build momentum with vocab, immersion, or a mock-style session.',
      AppLanguage.vi => 'Bạn đang trống review nên có thể tăng nhịp bằng từ vựng, immersion hoặc một lượt thi thử.',
      AppLanguage.ja => '期限の復習はないので、単語・イマージョン・模試で勢いを作れます。',
    };
  }

  String _continueLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Continue',
    AppLanguage.vi => 'Tiếp tục',
    AppLanguage.ja => '続ける',
  };

  String _changeActivityLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Change activity',
    AppLanguage.vi => 'Đổi hoạt động',
    AppLanguage.ja => '学習を切り替える',
  };

  String _todayStartedLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'In progress',
    AppLanguage.vi => 'Đang học',
    AppLanguage.ja => '進行中',
  };

  String _todayReadyLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Ready',
    AppLanguage.vi => 'Sẵn sàng',
    AppLanguage.ja => '準備完了',
  };

  String _streakLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Streak',
    AppLanguage.vi => 'Chuỗi ngày',
    AppLanguage.ja => '連続日数',
  };

  String _todayLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Today',
    AppLanguage.vi => 'Hôm nay',
    AppLanguage.ja => '今日',
  };

  String _reviewLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Review',
    AppLanguage.vi => 'Ôn tập',
    AppLanguage.ja => '復習',
  };

  String _progressCaption(AppLanguage language, {required bool hasStartedToday}) => switch (language) {
    AppLanguage.en => hasStartedToday ? 'Today plan is moving.' : 'Start with one focused block to open today.',
    AppLanguage.vi => hasStartedToday ? 'Kế hoạch hôm nay đang tiến lên.' : 'Bắt đầu bằng một block tập trung để mở nhịp học hôm nay.',
    AppLanguage.ja => hasStartedToday ? '今日の学習は進んでいます。' : '短い 1 ブロックから始めて今日の流れを作りましょう。',
  };

  String _whyCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'A young, guided study flow that still respects serious Japanese learning.',
    AppLanguage.vi => 'Một luồng học trẻ trung nhưng vẫn giữ cảm giác học tiếng Nhật nghiêm túc.',
    AppLanguage.ja => '若々しく親しみやすい一方で、日本語学習としての真面目さも保つ導線です。',
  };

  String _fixWeakPointsSubtitle(AppLanguage language, int weakCount) => switch (language) {
    AppLanguage.en => weakCount > 0 ? '$weakCount weak items still need work.' : 'No weak items are waiting.',
    AppLanguage.vi => weakCount > 0 ? '$weakCount mục yếu vẫn cần xử lý.' : 'Hiện chưa có mục yếu chờ xử lý.',
    AppLanguage.ja => weakCount > 0 ? '$weakCount 件の弱点が残っています。' : '今は弱点項目がありません。',
  };

  String _dueInsightTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due review',
    AppLanguage.vi => 'Ôn đến hạn',
    AppLanguage.ja => '期限の復習',
  };

  String _dueInsightSubtitle(AppLanguage language, int dueCount) => switch (language) {
    AppLanguage.en => dueCount > 0 ? '$dueCount items are waiting now.' : 'No due review right now.',
    AppLanguage.vi => dueCount > 0 ? '$dueCount mục đang chờ ôn.' : 'Hiện chưa có mục đến hạn.',
    AppLanguage.ja => dueCount > 0 ? '$dueCount 件が待っています。' : '今は期限の復習はありません。',
  };

  String _exploreTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Explore',
    AppLanguage.vi => 'Khám phá',
    AppLanguage.ja => '広げる',
  };

  String _exploreCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Pick the next study surface by intent.',
    AppLanguage.vi => 'Chọn bề mặt học tiếp theo theo đúng mục tiêu.',
    AppLanguage.ja => '次の学習面を目的から選びます。',
  };

  String _studyHubTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Study hub',
    AppLanguage.vi => 'Study hub',
    AppLanguage.ja => '学習ハブ',
  };

  String _studyHubSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Vocab, review, weak points, speed, and quick drills.',
    AppLanguage.vi => 'Từ vựng, review, điểm yếu, tăng tốc và drill nhanh.',
    AppLanguage.ja => '単語、復習、弱点補強、速度強化、クイックドリル。',
  };

  String _jlptTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT coach',
    AppLanguage.vi => 'Trợ lý JLPT',
    AppLanguage.ja => 'JLPTコーチ',
  };

  String _jlptSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Mock exam, reading, diagnosis, and a 7-day plan.',
    AppLanguage.vi => 'Thi thử, đọc hiểu, chẩn đoán và kế hoạch 7 ngày.',
    AppLanguage.ja => '模試、読解、診断、7日プラン。',
  };

  String _immersionTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Immersion',
    AppLanguage.vi => 'Immersion',
    AppLanguage.ja => 'イマージョン',
  };

  String _immersionSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Read naturally, save words, and build real speed.',
    AppLanguage.vi => 'Đọc tự nhiên, lưu từ mới và tăng tốc độ thật.',
    AppLanguage.ja => '自然に読み、単語を保存し、本物の読解速度を作る。',
  };

  String _searchTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Search',
    AppLanguage.vi => 'Tìm kiếm',
    AppLanguage.ja => '検索',
  };

  String _searchSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Jump straight to a term, kanji, or lesson.',
    AppLanguage.vi => 'Nhảy thẳng tới từ, kanji hoặc bài học bạn cần.',
    AppLanguage.ja => '単語・漢字・レッスンへすぐ移動できます。',
  };
}
