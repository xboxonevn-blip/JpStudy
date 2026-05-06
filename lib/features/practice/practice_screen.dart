import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
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
import 'package:jpstudy/features/practice/providers/practice_session_board_provider.dart';

Color _practiceAccent(BuildContext context, Color color) {
  final palette = context.appPalette;
  final mix = Theme.of(context).brightness == Brightness.dark ? 0.38 : 0.14;
  return Color.lerp(color, palette.primary, mix) ?? color;
}

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final (vocabDue, grammarDue, kanjiDue, mistakeCount) = ref.watch(
      dashboardProvider.select((v) {
        final d = v.value;
        return (
          d?.vocabDue ?? 0,
          d?.grammarDue ?? 0,
          d?.kanjiDue ?? 0,
          d?.totalMistakeCount ?? 0,
        );
      }),
    );
    final dueCount = vocabDue + grammarDue + kanjiDue;
    final sessionBoard = ref.watch(practiceSessionBoardProvider);
    final grammarGhostCount = sessionBoard.grammarGhostCount;
    final repairCount = sessionBoard.repairCount;

    final items = buildPracticeDestinations(
      language: language,
      ghostCount: grammarGhostCount,
      dueReviewCount: dueCount,
      vocabDue: vocabDue,
      grammarDue: grammarDue,
      kanjiDue: kanjiDue,
      mistakeCount: mistakeCount,
      level: level,
      preferImmersion: dueCount == 0 && repairCount == 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(language)),
        actions: [
          IconButton(
            tooltip: _searchLabel(language),
            onPressed: () => context.openSearch(),
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StudyHero(
                  language: language,
                  level: level,
                  dueCount: dueCount,
                  repairCount: repairCount,
                  grammarGhostCount: grammarGhostCount,
                  vocabDue: vocabDue,
                  grammarDue: grammarDue,
                  kanjiDue: kanjiDue,
                  headline: sessionBoard.headline,
                  caption: sessionBoard.caption,
                  primaryAction: sessionBoard.primaryAction,
                  onPrimaryTap: () =>
                      _openAction(context, sessionBoard.primaryAction),
                  onSecondaryTap: () => context.openJlptCoach(),
                ),
                const SizedBox(height: AppSpacing.md),
                _StudyPanel(
                  title: _planTitle(language),
                  caption: _planCaption(language),
                  child: _SessionPlanBoard(
                    language: language,
                    board: sessionBoard,
                    onOpenAction: (action) => _openAction(context, action),
                  ),
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
                  title: _studyHubTitle(language),
                  caption: _studyHubCaption(language),
                  child: AppCompactRow(
                    icon: Icons.library_books_rounded,
                    title: _studyHubLabel(language),
                    subtitle: _studyHubSubtitle(language),
                    onTap: () => context.openStudyHub(),
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

  void _openAction(BuildContext context, PracticeSessionAction action) {
    context.push(action.route, extra: action.extra);
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
    AppLanguage.en => 'Focus tools',
    AppLanguage.vi => 'Công cụ trọng tâm',
    AppLanguage.ja => '集中ツール',
  };

  String _featuredCaption(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'The best lanes to switch into without scanning the full shelf.',
    AppLanguage.vi =>
      'Các lane đáng mở nhất nếu bạn muốn đổi nhịp mà không phải quét hết toàn bộ công cụ.',
    AppLanguage.ja => '全体を見渡さなくても切り替えやすい集中レーンです。',
  };

  String _planTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Today plan',
    AppLanguage.vi => 'Kế hoạch hôm nay',
    AppLanguage.ja => '今日のプラン',
  };

  String _planCaption(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'A short sequence to protect recall, repair weak spots, and keep momentum.',
    AppLanguage.vi =>
      'Một chuỗi ngắn để chặn rơi nhớ, vá điểm yếu, và giữ đà học tiếp.',
    AppLanguage.ja => '記憶を守り、弱点を補強し、勢いを保つための短い流れです。',
  };

  String _openLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open',
    AppLanguage.vi => 'Mở',
    AppLanguage.ja => '開く',
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

  String _studyHubTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Study Hub',
    AppLanguage.vi => 'Trung tâm học tập',
    AppLanguage.ja => 'スタディHub',
  };

  String _studyHubCaption(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Resources, textbook tracker, and exam checklist.',
    AppLanguage.vi =>
      'Tài nguyên, theo dõi giáo trình và danh sách chuẩn bị thi.',
    AppLanguage.ja => 'リソース、教材トラッカー、試験チェックリスト。',
  };

  String _studyHubLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open Study Hub',
    AppLanguage.vi => 'Mở Trung tâm học tập',
    AppLanguage.ja => 'スタディHubを開く',
  };

  String _studyHubSubtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Textbooks, guides, JLPT prep, and your exam checklist.',
    AppLanguage.vi => 'Giáo trình, hướng dẫn, ôn JLPT và danh sách thi.',
    AppLanguage.ja => '教材・ガイド・JLPT対策・試験チェックリスト。',
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
      decoration: HomeSurface.softPanel(radius: AppSpacing.radiusXxl, context: context),
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
    required this.repairCount,
    required this.grammarGhostCount,
    required this.vocabDue,
    required this.grammarDue,
    required this.kanjiDue,
    required this.headline,
    required this.caption,
    required this.primaryAction,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
  final StudyLevel? level;
  final int dueCount;
  final int repairCount;
  final int grammarGhostCount;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;
  final String headline;
  final String caption;
  final PracticeSessionAction primaryAction;
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
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
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
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
                                  headline,
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
                        caption,
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
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
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                              child: Icon(
                                primaryAction.icon,
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
                                    primaryAction.title,
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
                            label: _repairLabel(language),
                            value: '$repairCount',
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
                            label: Text(primaryAction.ctaLabel),
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
                    primaryAction: primaryAction,
                    dueCount: dueCount,
                    grammarGhostCount: grammarGhostCount,
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

  String _repairLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Repair',
    AppLanguage.vi => 'Sửa',
    AppLanguage.ja => '補強',
  };

  String _levelLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Level',
    AppLanguage.vi => 'Trình độ',
    AppLanguage.ja => 'レベル',
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
    required this.primaryAction,
    required this.dueCount,
    required this.grammarGhostCount,
    required this.vocabDue,
    required this.grammarDue,
    required this.kanjiDue,
  });

  final AppLanguage language;
  final PracticeSessionAction primaryAction;
  final int dueCount;
  final int grammarGhostCount;
  final int vocabDue;
  final int grammarDue;
  final int kanjiDue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
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
            primaryAction.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            primaryAction.subtitle,
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
          if (dueCount == 0 && grammarGhostCount == 0)
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
            if (grammarGhostCount > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              _MixRow(
                label: _grammarGhosts(language),
                count: grammarGhostCount,
                light: true,
              ),
            ],
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

  String _mixTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Queue and repair',
    AppLanguage.vi => 'Hàng đợi và sửa lỗi',
    AppLanguage.ja => 'キューと補強',
  };

  String _emptyMix(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'No active due queue or grammar ghosts are waiting right now.',
    AppLanguage.vi =>
      'Hiện chưa có hàng đến hạn hay grammar ghost nào đang chờ.',
    AppLanguage.ja => '今は期限キューも文法ゴーストも待っていません。',
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

  String _grammarGhosts(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Grammar ghosts',
    AppLanguage.vi => 'Grammar ghost',
    AppLanguage.ja => '文法ゴースト',
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
        : palette.outlineSoft;
    final lineColor = light
        ? const Color(0xFFFFE4BF)
        : palette.primary.withValues(alpha: 0.6);
    final labelColor = light
        ? const Color(0xFFE2E8F0)
        : palette.ink.withValues(alpha: 0.68);
    final pillColor = light
        ? Colors.white.withValues(alpha: 0.12)
        : palette.elevated;
    final pillBorder = light
        ? Colors.white.withValues(alpha: 0.14)
        : palette.outlineSoft;
    final pillTextColor = light ? Colors.white : palette.ink;

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

class _SessionPlanBoard extends StatelessWidget {
  const _SessionPlanBoard({
    required this.language,
    required this.board,
    required this.onOpenAction,
  });

  final AppLanguage language;
  final PracticeSessionBoard board;
  final ValueChanged<PracticeSessionAction> onOpenAction;

  @override
  Widget build(BuildContext context) {
    final followUps = board.steps.skip(1).toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= AppBreakpoints.tablet;
        final main = _SessionPrimaryCard(
          language: language,
          action: board.primaryAction,
          onTap: () => onOpenAction(board.primaryAction),
        );
        final side = Column(
          children: [
            for (var index = 0; index < followUps.length; index++) ...[
              _SessionStepTile(
                language: language,
                action: followUps[index],
                stageIndex: index + 1,
                onTap: () => onOpenAction(followUps[index]),
              ),
              if (index != followUps.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: main),
                  if (followUps.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 5, child: side),
                  ],
                ],
              )
            else ...[
              main,
              if (followUps.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                side,
              ],
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final signal in board.signals)
                  SizedBox(
                    width: wide
                        ? (constraints.maxWidth - (AppSpacing.md * 2)) / 3
                        : constraints.maxWidth,
                    child: _SessionSignalTile(signal: signal),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SessionPrimaryCard extends StatelessWidget {
  const _SessionPrimaryCard({
    required this.language,
    required this.action,
    required this.onTap,
  });

  final AppLanguage language;
  final PracticeSessionAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accent = _practiceAccent(context, action.color);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.16), palette.elevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(action.icon, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nowLabel(language),
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.title,
                      style: TextStyle(
                        color: palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
              if (action.badge != null)
                AppStatusChip(
                  label: action.badge!,
                  tone: AppStatusTone.primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            action.subtitle,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.72),
              fontSize: 12.7,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(action.ctaLabel),
              ),
              if (action.estimatedMinutes != null)
                AppStatusChip(
                  label: _minutesLabel(language, action.estimatedMinutes!),
                  tone: AppStatusTone.neutral,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _nowLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'DO THIS NOW',
    AppLanguage.vi => 'LÀM NGAY BÂY GIỜ',
    AppLanguage.ja => '今やること',
  };

  String _minutesLabel(AppLanguage language, int minutes) => switch (language) {
    AppLanguage.en => '~${minutes}m',
    AppLanguage.vi => '~${minutes}p',
    AppLanguage.ja => '~$minutes分',
  };
}

class _SessionStepTile extends StatelessWidget {
  const _SessionStepTile({
    required this.language,
    required this.action,
    required this.stageIndex,
    required this.onTap,
  });

  final AppLanguage language;
  final PracticeSessionAction action;
  final int stageIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accent = _practiceAccent(context, action.color);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: Text(
                '${stageIndex + 1}',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stageLabel(language, stageIndex),
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  action.title,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.68),
                    fontSize: 11.7,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                  label: Text(action.ctaLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stageLabel(AppLanguage language, int stageIndex) {
    if (stageIndex == 1) {
      return switch (language) {
        AppLanguage.en => 'NEXT',
        AppLanguage.vi => 'KẾ TIẾP',
        AppLanguage.ja => '次',
      };
    }
    return switch (language) {
      AppLanguage.en => 'THEN',
      AppLanguage.vi => 'SAU ĐÓ',
      AppLanguage.ja => 'その後',
    };
  }
}

class _SessionSignalTile extends StatelessWidget {
  const _SessionSignalTile({required this.signal});

  final PracticeSessionSignal signal;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accent = _practiceAccent(context, signal.color);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: palette.outlineSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(signal.icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${signal.label} · ${signal.value}',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  signal.detail,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.68),
                    fontSize: 11.6,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final palette = context.appPalette;
    final accent = _practiceAccent(context, item.color);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent.withValues(alpha: 0.16), palette.elevated],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
            boxShadow: HomeSurface.panelShadowFor(context),
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
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(item.icon, color: accent, size: 19),
                  ),
                  const Spacer(),
                  ?status,
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: palette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.68),
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
                        color: accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_outward_rounded, color: accent, size: 16),
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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


