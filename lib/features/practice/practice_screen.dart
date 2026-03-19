import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';

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
      appBar: AppBar(
        title: Text(_title(language)),
        actions: [
          IconButton(
            tooltip: _searchLabel(language),
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final featuredColumns =
                constraints.maxWidth >= AppBreakpoints.desktop
                ? 3
                : constraints.maxWidth >= 680
                ? 2
                : 1;
            final featuredLimit = featuredColumns == 2 ? 4 : 3;
            final goalColumns = constraints.maxWidth >= 1180
                ? 4
                : constraints.maxWidth >= AppBreakpoints.tablet
                ? 2
                : 1;
            final toolColumns = constraints.maxWidth >= AppBreakpoints.desktop
                ? 2
                : 1;
            final featuredTools = selectFocusPracticeDestinations(
              rankedDestinations: items,
              limit: featuredLimit,
            );
            final featuredIds = featuredTools.map((item) => item.id).toSet();
            final remainingTools = items
                .where((item) => !featuredIds.contains(item.id))
                .toList(growable: false);
            final bestTool = items.isNotEmpty ? items.first : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StudyHero(
                  language: language,
                  level: level,
                  dueCount: dueCount,
                  mistakeCount: mistakeCount,
                  vocabDue: vocabDue,
                  grammarDue: grammarDue,
                  kanjiDue: kanjiDue,
                  bestTool: bestTool,
                  onPrimaryTap: () =>
                      _openPrimaryGoal(context, dueCount, mistakeCount),
                  onSecondaryTap: () => context.push('/jlpt/coach'),
                ),
                const SizedBox(height: AppSpacing.md),
                _StudyPanel(
                  title: _featuredTitle(language),
                  caption: _featuredCaption(language),
                  child: LayoutBuilder(
                    builder: (context, sectionConstraints) {
                      final itemWidth = _itemWidth(
                        sectionConstraints.maxWidth,
                        featuredColumns,
                      );
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          for (final item in featuredTools)
                            SizedBox(
                              width: itemWidth,
                              child: _PracticeSpotlightCard(
                                item: item,
                                openLabel: _openLabel(language),
                                status: _toolStatusChip(item),
                                onTap: () =>
                                    context.push(item.route, extra: item.extra),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _StudyPanel(
                  title: _goalsTitle(language),
                  caption: _goalsCaption(language),
                  child: LayoutBuilder(
                    builder: (context, sectionConstraints) {
                      final itemWidth = _itemWidth(
                        sectionConstraints.maxWidth,
                        goalColumns,
                      );
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: _GoalCard(
                              color: context.appPalette.warning,
                              icon: Icons.schedule_rounded,
                              title: _goalDueTitle(language),
                              subtitle: _goalDueSubtitle(language, dueCount),
                              detail: _goalDueDetail(
                                language,
                                dueCount: dueCount,
                                vocabDue: vocabDue,
                                grammarDue: grammarDue,
                                kanjiDue: kanjiDue,
                              ),
                              ctaLabel: _openLaneLabel(language),
                              status: AppStatusChip(
                                label: dueCount > 0
                                    ? _dueBadge(language, dueCount)
                                    : _readyBadge(language),
                                tone: dueCount > 0
                                    ? AppStatusTone.warning
                                    : AppStatusTone.success,
                              ),
                              onTap: () => _openPrimaryGoal(
                                context,
                                dueCount,
                                mistakeCount,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: _GoalCard(
                              color: const Color(0xFFD66A3D),
                              icon: Icons.auto_fix_high_rounded,
                              title: _goalFixTitle(language),
                              subtitle: _goalFixSubtitle(
                                language,
                                mistakeCount,
                              ),
                              detail: _goalFixDetail(language, mistakeCount),
                              ctaLabel: _openLaneLabel(language),
                              status: AppStatusChip(
                                label: mistakeCount > 0
                                    ? _weakBadge(language, mistakeCount)
                                    : _readyBadge(language),
                                tone: mistakeCount > 0
                                    ? AppStatusTone.warning
                                    : AppStatusTone.success,
                              ),
                              onTap: () => context.push('/mistakes'),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: _GoalCard(
                              color: context.appPalette.info,
                              icon: Icons.speed_rounded,
                              title: _goalSpeedTitle(language),
                              subtitle: _goalSpeedSubtitle(language),
                              detail: _goalSpeedDetail(language, dueCount),
                              ctaLabel: _openLaneLabel(language),
                              status: AppStatusChip(
                                label: _speedBadge(language),
                                tone: AppStatusTone.primary,
                              ),
                              onTap: () => context.push('/immersion'),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: _GoalCard(
                              color: context.appPalette.secondary,
                              icon: Icons.quiz_rounded,
                              title: _goalTestTitle(language),
                              subtitle: _goalTestSubtitle(language),
                              detail: _goalTestDetail(language, level),
                              ctaLabel: _openLaneLabel(language),
                              status: AppStatusChip(
                                label: level?.shortLabel ?? 'N5',
                                tone: AppStatusTone.neutral,
                              ),
                              onTap: () => context.push('/jlpt/coach'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (remainingTools.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _StudyPanel(
                    title: _toolsTitle(language),
                    caption: _toolsCaption(language),
                    child: LayoutBuilder(
                      builder: (context, sectionConstraints) {
                        final itemWidth = _itemWidth(
                          sectionConstraints.maxWidth,
                          toolColumns,
                        );
                        return Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          children: [
                            for (final item in remainingTools)
                              SizedBox(
                                width: itemWidth,
                                child: AppCompactRow(
                                  icon: item.icon,
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  status: _toolStatusChip(item),
                                  onTap: () => context.push(
                                    item.route,
                                    extra: item.extra,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _openPrimaryGoal(BuildContext context, int dueCount, int mistakeCount) {
    if (dueCount > 0) {
      context.push('/practice/recall-sprint');
      return;
    }
    if (mistakeCount > 0) {
      context.push('/mistakes');
      return;
    }
    context.push('/immersion');
  }

  Widget? _toolStatusChip(PracticeDestination item) {
    if (item.badgeCount != null) {
      return AppStatusChip(
        label: '${item.badgeCount}',
        tone: item.badgeCount! > 0
            ? AppStatusTone.warning
            : AppStatusTone.neutral,
      );
    }
    if (item.estimatedMinutes != null) {
      return AppStatusChip(
        label: '${item.estimatedMinutes}m',
        tone: AppStatusTone.neutral,
      );
    }
    return null;
  }

  double _itemWidth(double maxWidth, int columns) {
    if (columns <= 1) {
      return maxWidth;
    }
    return (maxWidth - (AppSpacing.md * (columns - 1))) / columns;
  }

  String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Study',
    AppLanguage.vi => 'Học',
    AppLanguage.ja => '学習',
  };

  String _searchLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Search',
    AppLanguage.vi => 'Tìm kiếm',
    AppLanguage.ja => '検索',
  };

  String _featuredTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Start here',
    AppLanguage.vi => 'Bắt đầu từ đây',
    AppLanguage.ja => 'まずここから',
  };

  String _featuredCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Recommended from your queue, weak points, and level.',
    AppLanguage.vi => 'Gợi ý theo hàng đợi ôn tập, điểm yếu và level hiện tại.',
    AppLanguage.ja => '復習キュー、苦手、現在のレベルからおすすめしています。',
  };

  String _dueBadge(AppLanguage language, int dueCount) => switch (language) {
    AppLanguage.en => '$dueCount due',
    AppLanguage.vi => '$dueCount đến hạn',
    AppLanguage.ja => '$dueCount 件',
  };

  String _weakBadge(AppLanguage language, int count) => switch (language) {
    AppLanguage.en => '$count weak',
    AppLanguage.vi => '$count yếu',
    AppLanguage.ja => '$count 件',
  };

  String _speedBadge(AppLanguage language) => switch (language) {
    AppLanguage.en => '15m',
    AppLanguage.vi => '15p',
    AppLanguage.ja => '15分',
  };

  String _readyBadge(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Ready',
    AppLanguage.vi => 'Sẵn sàng',
    AppLanguage.ja => '準備完了',
  };

  String _openLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open',
    AppLanguage.vi => 'Mở',
    AppLanguage.ja => '開く',
  };

  String _openLaneLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open lane',
    AppLanguage.vi => 'Mở lane',
    AppLanguage.ja => 'レーンを開く',
  };

  String _goalsTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Goals',
    AppLanguage.vi => 'Mục tiêu',
    AppLanguage.ja => '目標',
  };

  String _goalsCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Choose the kind of progress you want next.',
    AppLanguage.vi => 'Chọn đúng kiểu tiến bộ bạn muốn làm tiếp theo.',
    AppLanguage.ja => '次に進めたい方向から選べます。',
  };

  String _goalDueTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due review',
    AppLanguage.vi => 'Ôn đến hạn',
    AppLanguage.ja => '期限の復習',
  };

  String _goalDueSubtitle(AppLanguage language, int dueCount) =>
      switch (language) {
        AppLanguage.en =>
          dueCount > 0
              ? '$dueCount items are waiting now.'
              : 'No review queue is waiting right now.',
        AppLanguage.vi =>
          dueCount > 0
              ? '$dueCount mục đang chờ ôn ngay bây giờ.'
              : 'Hiện chưa có hàng đợi ôn tập nào đang chờ.',
        AppLanguage.ja =>
          dueCount > 0 ? '$dueCount 件が今すぐ待っています。' : '今は復習キューがありません。',
      };

  String _goalDueDetail(
    AppLanguage language, {
    required int dueCount,
    required int vocabDue,
    required int grammarDue,
    required int kanjiDue,
  }) {
    if (dueCount == 0) {
      return switch (language) {
        AppLanguage.en =>
          'Use this lane whenever the queue returns. Until then, move into reading or drills.',
        AppLanguage.vi =>
          'Khi hàng đợi quay lại thì ưu tiên lane này. Còn hiện tại bạn có thể chuyển sang đọc hoặc drill.',
        AppLanguage.ja => 'キューが戻ったらここを優先。今は読解やドリルへ進めます。',
      };
    }
    return switch (language) {
      AppLanguage.en =>
        '$vocabDue vocab • $grammarDue grammar • $kanjiDue kanji. Start with the fastest sweep first.',
      AppLanguage.vi =>
        '$vocabDue từ vựng • $grammarDue ngữ pháp • $kanjiDue kanji. Hãy quét nhanh phần đến hạn trước.',
      AppLanguage.ja =>
        '語彙 $vocabDue ・文法 $grammarDue ・漢字 $kanjiDue。まずは短く一周しましょう。',
    };
  }

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
              : 'Hiện chưa có mục yếu nào đang chờ.',
        AppLanguage.ja => count > 0 ? '$count 件の苦手項目が残っています。' : '苦手項目はありません。',
      };

  String _goalFixDetail(AppLanguage language, int count) => switch (language) {
    AppLanguage.en =>
      count > 0
          ? 'Review the freshest misses first so they do not harden into habits.'
          : 'Keep this lane as your safety net after a rough lesson or mock exam.',
    AppLanguage.vi =>
      count > 0
          ? 'Xử lý các lỗi mới nhất trước để chúng không kịp thành thói quen xấu.'
          : 'Giữ lane này làm lưới an toàn sau các buổi học hoặc mock exam bị hụt.',
    AppLanguage.ja =>
      count > 0 ? '新しいミスから先に直して、癖になる前に止めましょう。' : 'レッスンや模試で崩れた後の安全網として使えます。',
  };

  String _goalSpeedTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Build speed',
    AppLanguage.vi => 'Tăng tốc độ',
    AppLanguage.ja => '読む速度',
  };

  String _goalSpeedSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Read, save words, and measure progress.',
    AppLanguage.vi => 'Đọc, lưu từ, và đo tiến độ.',
    AppLanguage.ja => '読んで、単語を保存して、進みを測る。',
  };

  String _goalSpeedDetail(
    AppLanguage language,
    int dueCount,
  ) => switch (language) {
    AppLanguage.en =>
      dueCount == 0
          ? 'Your queue is calm enough for a focused reading block.'
          : 'Use reading after the queue is clear to keep comprehension moving.',
    AppLanguage.vi =>
      dueCount == 0
          ? 'Hàng đợi đang đủ nhẹ để vào một block đọc tập trung.'
          : 'Sau khi dọn xong hàng đợi, hãy dùng phần đọc để giữ nhịp hiểu bài.',
    AppLanguage.ja =>
      dueCount == 0 ? '今は読解ブロックに入りやすい状態です。' : '復習を片づけた後に読むと、理解の流れを保てます。',
  };

  String _goalTestTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT prep',
    AppLanguage.vi => 'Ôn thi JLPT',
    AppLanguage.ja => 'JLPT試験対策',
  };

  String _goalTestSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'Full mock, quick mock, reading drill, diagnosis, and plan.',
    AppLanguage.vi =>
      'Thi thử đầy đủ, kiểm tra nhanh, đọc hiểu, chẩn đoán và kế hoạch.',
    AppLanguage.ja => 'フル模試、クイック模試、読解、診断、計画。',
  };

  String _goalTestDetail(
    AppLanguage language,
    StudyLevel? level,
  ) => switch (language) {
    AppLanguage.en =>
      'Open JLPT prep when you want one exam-focused hub for ${level?.shortLabel ?? 'N5'}.',
    AppLanguage.vi =>
      'Mở ôn thi JLPT khi bạn muốn một hub tập trung hoàn toàn vào bài thi ${level?.shortLabel ?? 'N5'}.',
    AppLanguage.ja => '${level?.shortLabel ?? 'N5'} 向けの試験対策ハブへ入る入口です。',
  };

  String _toolsTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Tools',
    AppLanguage.vi => 'Công cụ',
    AppLanguage.ja => 'ツール',
  };

  String _toolsCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Everything else is still here, but out of the way.',
    AppLanguage.vi => 'Các phần còn lại vẫn ở đây, nhưng gọn và đỡ rối hơn.',
    AppLanguage.ja => 'そのほかの入口も、散らからない形で残しています。',
  };
}

class _StudyPanel extends StatelessWidget {
  const _StudyPanel({
    required this.title,
    required this.caption,
    required this.child,
  });

  final String title;
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: HomeSurface.softPanel(radius: AppSpacing.radiusXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title, caption: caption),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _StudyHero extends StatelessWidget {
  const _StudyHero({
    required this.language,
    required this.level,
    required this.dueCount,
    required this.mistakeCount,
    required this.vocabDue,
    required this.grammarDue,
    required this.kanjiDue,
    required this.bestTool,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
  final StudyLevel? level;
  final int dueCount;
  final int mistakeCount;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;
  final PracticeDestination? bestTool;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.heroGradient.first,
            palette.heroGradient.last,
            palette.accent.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              top: -18,
              right: -10,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.11),
                ),
              ),
            ),
            Positioned(
              bottom: -22,
              left: -10,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 760;
                  final main = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.16),
                              ),
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _eyebrow(language),
                                  style: const TextStyle(
                                    color: Color(0xFFFFF7ED),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _headline(
                                    language,
                                    dueCount: dueCount,
                                    mistakeCount: mistakeCount,
                                  ),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _HeroLevelBadge(label: level?.shortLabel ?? 'N5'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _subtitle(
                          language,
                          dueCount: dueCount,
                          mistakeCount: mistakeCount,
                          level: level,
                        ),
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (bestTool != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  bestTool!.icon,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _recommendationLabel(language),
                                      style: const TextStyle(
                                        color: Color(0xFFE2E8F0),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      bestTool!.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFFFFE4BF),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HeroStatChip(
                            icon: Icons.history_edu_rounded,
                            label: _dueLabel(language),
                            value: '$dueCount',
                          ),
                          _HeroStatChip(
                            icon: Icons.auto_fix_high_rounded,
                            label: _weakLabel(language),
                            value: '$mistakeCount',
                          ),
                          _HeroStatChip(
                            icon: Icons.school_rounded,
                            label: _levelLabel(language),
                            value: level?.shortLabel ?? 'N5',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: onPrimaryTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF12324B),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                            ),
                            label: Text(_primaryLabel(language)),
                          ),
                          OutlinedButton.icon(
                            onPressed: onSecondaryTap,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.32),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.quiz_rounded, size: 18),
                            label: Text(_secondaryLabel(language)),
                          ),
                        ],
                      ),
                    ],
                  );

                  final side = _HeroFocusPanel(
                    language: language,
                    bestTool: bestTool,
                    dueCount: dueCount,
                    vocabDue: vocabDue,
                    grammarDue: grammarDue,
                    kanjiDue: kanjiDue,
                  );

                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        main,
                        const SizedBox(height: AppSpacing.md),
                        side,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: main),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(flex: 4, child: side),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _eyebrow(AppLanguage language) => switch (language) {
    AppLanguage.en => 'STUDY DOJO • 日本語 TRAINING',
    AppLanguage.vi => 'DOJO HỌC • LUYỆN NHẬT NGỮ',
    AppLanguage.ja => '学習道場 • 日本語トレーニング',
  };

  String _headline(
    AppLanguage language, {
    required int dueCount,
    required int mistakeCount,
  }) {
    if (dueCount > 0) {
      return switch (language) {
        AppLanguage.en => 'Clear the review queue first',
        AppLanguage.vi => 'Dọn hàng review trước',
        AppLanguage.ja => 'まず復習キューを片づける',
      };
    }
    if (mistakeCount > 0) {
      return switch (language) {
        AppLanguage.en => 'Lock in weak points today',
        AppLanguage.vi => 'Khóa lại điểm yếu hôm nay',
        AppLanguage.ja => '今日は弱点を締め直す',
      };
    }
    return switch (language) {
      AppLanguage.en => 'Open a clean Japanese study session',
      AppLanguage.vi => 'Mở một session học tiếng Nhật thật gọn',
      AppLanguage.ja => '気持ちよく学習セッションを始める',
    };
  }

  String _subtitle(
    AppLanguage language, {
    required int dueCount,
    required int mistakeCount,
    required StudyLevel? level,
  }) {
    if (dueCount > 0) {
      return switch (language) {
        AppLanguage.en =>
          '$dueCount reviews are waiting in ${level?.shortLabel ?? 'N5'}. Finish them early, then the rest of Study feels lighter.',
        AppLanguage.vi =>
          'Có $dueCount lượt review đang chờ ở ${level?.shortLabel ?? 'N5'}. Dọn sớm phần này thì toàn bộ màn Study sẽ nhẹ hơn hẳn.',
        AppLanguage.ja =>
          '${level?.shortLabel ?? 'N5'} で $dueCount 件の復習が待っています。先に終えると、そのあとの学習がずっと軽くなります。',
      };
    }
    if (mistakeCount > 0) {
      return switch (language) {
        AppLanguage.en =>
          '$mistakeCount weak spots are still warm. Repair them now while recall is still close.',
        AppLanguage.vi =>
          'Còn $mistakeCount điểm yếu đang “nóng”. Vá ngay lúc này sẽ nhớ sâu hơn.',
        AppLanguage.ja => '$mistakeCount 件の弱点がまだ新しいうちに補強すると、記憶が安定しやすくなります。',
      };
    }
    return switch (language) {
      AppLanguage.en =>
        'No urgent queue right now. Use this space for reading, timed drills, and more intentional practice.',
      AppLanguage.vi =>
        'Hiện chưa có hàng chờ gấp. Đây là lúc đẹp để đọc hiểu, luyện có nhịp và học tập trung hơn.',
      AppLanguage.ja => '急ぎのキューはありません。今は読解や時間付きドリル、集中した練習に向いています。',
    };
  }

  String _recommendationLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Recommended now',
    AppLanguage.vi => 'Gợi ý lúc này',
    AppLanguage.ja => '今のおすすめ',
  };

  String _dueLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Due',
    AppLanguage.vi => 'Đến hạn',
    AppLanguage.ja => '期限',
  };

  String _weakLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Weak',
    AppLanguage.vi => 'Điểm yếu',
    AppLanguage.ja => '苦手',
  };

  String _levelLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Level',
    AppLanguage.vi => 'Trình độ',
    AppLanguage.ja => 'レベル',
  };

  String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Start session',
    AppLanguage.vi => 'Bắt đầu session',
    AppLanguage.ja => 'セッション開始',
  };

  String _secondaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT prep',
    AppLanguage.vi => 'Ôn thi JLPT',
    AppLanguage.ja => 'JLPT試験対策',
  };
}

class _HeroFocusPanel extends StatelessWidget {
  const _HeroFocusPanel({
    required this.language,
    required this.bestTool,
    required this.dueCount,
    required this.vocabDue,
    required this.grammarDue,
    required this.kanjiDue,
  });

  final AppLanguage language;
  final PracticeDestination? bestTool;
  final int dueCount;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _nextUp(language),
            style: const TextStyle(
              color: Color(0xFFFFE4BF),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            bestTool?.title ?? _restTitle(language),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            bestTool?.subtitle ?? _restSubtitle(language),
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _mixTitle(language),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (dueCount == 0)
            Text(
              _emptyMix(language),
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            )
          else ...[
            _MixRow(label: _vocab(language), count: vocabDue, light: true),
            const SizedBox(height: AppSpacing.xs),
            _MixRow(label: _grammar(language), count: grammarDue, light: true),
            const SizedBox(height: AppSpacing.xs),
            _MixRow(label: _kanji(language), count: kanjiDue, light: true),
          ],
        ],
      ),
    );
  }

  String _nextUp(AppLanguage language) => switch (language) {
    AppLanguage.en => 'BEST NEXT MOVE',
    AppLanguage.vi => 'BƯỚC KẾ TIẾP',
    AppLanguage.ja => '次にやること',
  };

  String _restTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'You are clear to explore',
    AppLanguage.vi => 'Bạn đang rảnh để mở rộng',
    AppLanguage.ja => '今は余裕があります',
  };

  String _restSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'When the queue is quiet, use immersion or a mock block to deepen comprehension.',
    AppLanguage.vi =>
      'Khi hàng đợi yên, hãy dùng đọc hiểu hoặc một block mock để đào sâu khả năng hiểu bài.',
    AppLanguage.ja => 'キューが静かな時は、読解や模試で理解を深めるのに向いています。',
  };

  String _mixTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Review mix',
    AppLanguage.vi => 'Cơ cấu hàng đợi',
    AppLanguage.ja => '復習の内訳',
  };

  String _emptyMix(AppLanguage language) => switch (language) {
    AppLanguage.en => 'No due review is waiting right now.',
    AppLanguage.vi => 'Hiện chưa có mục ôn tập nào đến hạn.',
    AppLanguage.ja => '今は期限の復習はありません。',
  };

  String _vocab(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Vocabulary',
    AppLanguage.vi => 'Từ vựng',
    AppLanguage.ja => '語彙',
  };

  String _grammar(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Grammar',
    AppLanguage.vi => 'Ngữ pháp',
    AppLanguage.ja => '文法',
  };

  String _kanji(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Kanji',
    AppLanguage.vi => 'Kanji',
    AppLanguage.ja => '漢字',
  };
}

class _MixRow extends StatelessWidget {
  const _MixRow({required this.label, required this.count, this.light = false});

  final String label;
  final int count;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final dividerColor = light
        ? Colors.white.withValues(alpha: 0.14)
        : HomeSurface.panelBorder;
    final lineColor = light
        ? const Color(0xFFFFE4BF)
        : palette.primary.withValues(alpha: 0.6);
    final labelColor = light
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF475569);
    final pillColor = light
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.92);
    final pillBorder = light
        ? Colors.white.withValues(alpha: 0.14)
        : HomeSurface.panelBorder;
    final pillTextColor = light ? Colors.white : const Color(0xFF0F172A);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dividerColor)),
            ),
            child: Row(
              children: [
                Container(width: 14, height: 1.5, color: lineColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: pillBorder),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: pillTextColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.ctaLabel,
    required this.status,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final String ctaLabel;
  final Widget status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.16), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.26)),
            boxShadow: HomeSurface.panelShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  status,
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13.2,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11.8,
                  height: 1.42,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ctaLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_outward_rounded, color: color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeSpotlightCard extends StatelessWidget {
  const _PracticeSpotlightCard({
    required this.item,
    required this.openLabel,
    required this.status,
    required this.onTap,
  });

  final PracticeDestination item;
  final String openLabel;
  final Widget? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [item.color.withValues(alpha: 0.16), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: item.color.withValues(alpha: 0.24)),
            boxShadow: HomeSurface.panelShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 19),
                  ),
                  const Spacer(),
                  if (status != null) status!,
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      openLabel,
                      style: TextStyle(
                        color: item.color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: item.color,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroLevelBadge extends StatelessWidget {
  const _HeroLevelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFFE4BF)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
