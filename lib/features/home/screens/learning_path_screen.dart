import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/layout/app_responsive_frame.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/foundations/widgets/kana_review_due_card.dart';
import 'package:jpstudy/features/home/home_copy.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/daily_plan_card.dart';
import 'package:jpstudy/features/home/widgets/daily_session_card.dart';
import 'package:jpstudy/features/home/widgets/discover_practice_panel.dart';
import 'package:jpstudy/features/home/widgets/goal_selection_banner.dart';
import 'package:jpstudy/features/home/widgets/mini_dashboard.dart';
import 'package:jpstudy/features/home/widgets/weakness_radar_card.dart';
import 'package:jpstudy/features/home/widgets/weekly_challenge_card.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/vocab_copy.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final dashboard = ref.watch(dashboardProvider).value;
    final continueAction = ref.watch(continueActionProvider).value;
    final foundationsProgress = ref.watch(foundationsProgressProvider);

    final streak = dashboard?.streak ?? 0;
    final todayXp = dashboard?.todayXp ?? 0;
    final dueCount =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);
    final weakCount = dashboard?.totalMistakeCount ?? 0;
    final hasStartedToday = todayXp > 0;
    final showFoundationsCard = level == StudyLevel.n5;
    final foundationsCard = showFoundationsCard
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _FoundationsFeaturedCard(
              language: language,
              progress: foundationsProgress,
            ),
          )
        : const SizedBox.shrink();
    final studyPromptCard = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: AppSectionCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: _studyPromptTitle(language),
              caption: _studyPromptSubtitle(language),
            ),
            const SizedBox(height: 10),
            AppProgressStrip(
              value: hasStartedToday ? (todayXp / 30).clamp(0.18, 1.0) : 0.08,
              label: _studyPromptProgressLabel(
                language,
                hasStartedToday: hasStartedToday,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FocusChip(
                  icon: Icons.menu_book_rounded,
                  label: _focusChipLabel(language, dueCount),
                  color: palette.primary,
                ),
                _FocusChip(
                  icon: Icons.auto_fix_high_rounded,
                  label: _repairChipLabel(language, weakCount),
                  color: palette.accent,
                ),
                _FocusChip(
                  icon: Icons.rocket_launch_rounded,
                  label: _momentumChipLabel(language, level),
                  color: palette.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return JapaneseBackground(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 100, 0, AppSpacing.pageBottom),
          children: [
            AppResponsiveFrame(
              maxWidth: 1240,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useDesktopGrid =
                      constraints.maxWidth >= AppBreakpoints.desktop;

                  final hero =
                      Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: _DojoHeroCard(
                              language: language,
                              level: level,
                              streak: streak,
                              todayXp: todayXp,
                              dueCount: dueCount,
                              weakCount: weakCount,
                              hasStartedToday: hasStartedToday,
                              missionLabel: continueAction?.label,
                              onPrimaryTap: () => _openContinueAction(
                                context,
                                continueAction,
                                language: language,
                                level: level,
                              ),
                              onSecondaryTap: () => context.openJlptCoach(),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 360.ms)
                          .slideY(begin: 0.08, end: 0);

                  if (!useDesktopGrid) {
                    return Column(
                      children: [
                        const GoalSelectionBanner(),
                        if (showFoundationsCard) ...[
                          foundationsCard,
                          const SizedBox(height: 10),
                        ],
                        hero,
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: KanaReviewDueCard(),
                        ),
                        const SizedBox(height: 10),
                        const DailyPlanCard()
                            .animate(delay: 60.ms)
                            .fadeIn(duration: 340.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: 10),
                        const DailySessionCard(compact: true)
                            .animate(delay: 120.ms)
                            .fadeIn(duration: 340.ms)
                            .slideY(begin: 0.06, end: 0),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: const MiniDashboard(compact: true),
                        ).animate(delay: 140.ms).fadeIn(duration: 320.ms),
                        const SizedBox(height: 10),
                        const WeeklyChallengeCard(
                          compact: true,
                        ).animate(delay: 180.ms).fadeIn(duration: 320.ms),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: _LearningLanesPanel(
                            language: language,
                            level: level,
                            dueCount: dueCount,
                            weakCount: weakCount,
                          ),
                        ).animate(delay: 220.ms).fadeIn(duration: 340.ms),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: const WeaknessRadarCard(compact: true),
                        ).animate(delay: 280.ms).fadeIn(duration: 320.ms),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: const DiscoverPracticePanel(
                            initiallyExpanded: false,
                            dense: true,
                          ),
                        ).animate(delay: 340.ms).fadeIn(duration: 360.ms),
                        const SizedBox(height: 6),
                        studyPromptCard
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 320.ms),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      const GoalSelectionBanner(),
                      if (showFoundationsCard) ...[
                        foundationsCard,
                        const SizedBox(height: 10),
                      ],
                      hero,
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: KanaReviewDueCard(),
                      ),
                      const SizedBox(height: 10),
                      const DailyPlanCard()
                          .animate(delay: 60.ms)
                          .fadeIn(duration: 340.ms),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            flex: 8,
                            child: DailySessionCard(compact: true),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: MiniDashboard(compact: true),
                                ),
                                SizedBox(height: 10),
                                WeeklyChallengeCard(compact: true),
                              ],
                            ),
                          ),
                        ],
                      ).animate(delay: 80.ms).fadeIn(duration: 340.ms),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: _LearningLanesPanel(
                                language: language,
                                level: level,
                                dueCount: dueCount,
                                weakCount: weakCount,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(flex: 5, child: studyPromptCard),
                        ],
                      ).animate(delay: 180.ms).fadeIn(duration: 340.ms),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: const WeaknessRadarCard(compact: true),
                      ).animate(delay: 260.ms).fadeIn(duration: 320.ms),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: const DiscoverPracticePanel(
                          initiallyExpanded: false,
                          dense: true,
                        ),
                      ).animate(delay: 320.ms).fadeIn(duration: 320.ms),
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

  static void _openContinueAction(
    BuildContext context,
    ContinueAction? action, {
    required AppLanguage language,
    required StudyLevel level,
  }) {
    if (action == null) {
      context.openStudy();
      return;
    }
    switch (action.type) {
      case ContinueActionType.grammarReview:
        context.openGrammarPractice(extra: action.data);
        return;
      case ContinueActionType.vocabReview:
        context.push(
          '/vocab/review',
          extra: VocabReviewArgs(
            source: 'learning_path',
            levelCode: level.shortLabel,
            title: language.vocabReviewTitle(level.shortLabel),
            subtitle: switch (language) {
              AppLanguage.en => 'Due vocab queue for today',
              AppLanguage.vi => 'Hàng đợi từ vựng đến hạn hôm nay',
              AppLanguage.ja => '今日の語彙レビュー',
            },
          ),
        );
        return;
      case ContinueActionType.kanjiReview:
        context.push(
          '/kanji/practice',
          extra: KanjiPracticeArgs(
            mode: KanjiPracticeMode.both,
            levelCode: level.shortLabel,
            source: 'learning_path',
          ),
        );
        return;
      case ContinueActionType.fixMistakes:
        context.openMistakes();
        return;
      case ContinueActionType.practiceMixed:
        context.openStudy();
        return;
      case ContinueActionType.nextLesson:
        final lessonId = action.data as int?;
        if (lessonId != null) {
          context.openLesson(lessonId);
        } else {
          context.openLibrary();
        }
        return;
    }
  }

  static String _studyPromptTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Keep the Japanese rhythm',
    AppLanguage.vi => 'Giữ nhịp tiếng Nhật mỗi ngày',
    AppLanguage.ja => '毎日の日本語リズムを保つ',
  };

  static String _studyPromptSubtitle(AppLanguage language) =>
      language.learningPathStudyPromptSubtitle();

  static String _studyPromptProgressLabel(
    AppLanguage language, {
    required bool hasStartedToday,
  }) => language.learningPathProgressLabel(hasStartedToday: hasStartedToday);

  static String _focusChipLabel(AppLanguage language, int dueCount) =>
      language.learningPathFocusChipLabel(dueCount);

  static String _repairChipLabel(AppLanguage language, int weakCount) =>
      language.learningPathRepairChipLabel(weakCount);

  static String _momentumChipLabel(AppLanguage language, StudyLevel level) =>
      language.learningPathMomentumChipLabel(level.shortLabel);
}

class _FoundationsFeaturedCard extends StatelessWidget {
  const _FoundationsFeaturedCard({
    required this.language,
    required this.progress,
  });

  final AppLanguage language;
  final FoundationsProgress progress;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return AppSectionCard(
      padding: const EdgeInsets.all(18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: context.openFoundations,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: palette.success.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.grass_rounded,
                      color: palette.success,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${language.foundationsTitle} - Bảng chữ Hiragana / Katakana / Hán Việt',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 12),
              AppProgressStrip(
                value: progress.percentComplete,
                label:
                    '${progress.studiedCount}/$foundationsKanaTotal kana (${(progress.percentComplete * 100).round()}%)',
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: context.openFoundations,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(_foundationsCtaLabel(language)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _foundationsCtaLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start with kana',
  AppLanguage.vi => 'Bắt đầu với bảng chữ',
  AppLanguage.ja => 'かなから始める',
};

class _DojoHeroCard extends StatelessWidget {
  const _DojoHeroCard({
    required this.language,
    required this.level,
    required this.streak,
    required this.todayXp,
    required this.dueCount,
    required this.weakCount,
    required this.hasStartedToday,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    this.missionLabel,
  });

  final AppLanguage language;
  final StudyLevel level;
  final int streak;
  final int todayXp;
  final int dueCount;
  final int weakCount;
  final bool hasStartedToday;
  final String? missionLabel;
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
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
                              _title(
                                language,
                                dueCount: dueCount,
                                weakCount: weakCount,
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
                      AppStatusChip(
                        label: level.shortLabel,
                        tone: AppStatusTone.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _subtitle(
                      language,
                      dueCount: dueCount,
                      weakCount: weakCount,
                      hasStartedToday: hasStartedToday,
                    ),
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (missionLabel != null &&
                      missionLabel!.trim().isNotEmpty) ...[
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
                          const Icon(
                            Icons.flag_circle_rounded,
                            color: Color(0xFFFFE4BF),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              missionLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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
                      _DojoStatChip(
                        icon: Icons.local_fire_department_rounded,
                        label: _streakLabel(language),
                        value: '$streak',
                      ),
                      _DojoStatChip(
                        icon: Icons.star_rounded,
                        label: _xpLabel(language),
                        value: '$todayXp XP',
                      ),
                      _DojoStatChip(
                        icon: Icons.history_edu_rounded,
                        label: _reviewLabel(language),
                        value: '$dueCount',
                      ),
                      _DojoStatChip(
                        icon: Icons.auto_fix_high_rounded,
                        label: _repairLabel(language),
                        value: '$weakCount',
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
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _eyebrow(AppLanguage language) => switch (language) {
    AppLanguage.en => 'TODAY DOJO • 日本語 TRAINING',
    AppLanguage.vi => 'DOJO HÔM NAY • LUYỆN NHẬT NGỮ',
    AppLanguage.ja => '今日の道場 • 日本語トレーニング',
  };

  static String _title(
    AppLanguage language, {
    required int dueCount,
    required int weakCount,
  }) => language.learningHeroTitle(dueCount: dueCount, weakCount: weakCount);

  static String _subtitle(
    AppLanguage language, {
    required int dueCount,
    required int weakCount,
    required bool hasStartedToday,
  }) => language.learningHeroSubtitle(
    dueCount: dueCount,
    weakCount: weakCount,
    hasStartedToday: hasStartedToday,
  );

  static String _streakLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Streak',
    AppLanguage.vi => 'Chuỗi',
    AppLanguage.ja => '連続',
  };

  static String _xpLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Today XP',
    AppLanguage.vi => 'XP hôm nay',
    AppLanguage.ja => '今日のXP',
  };

  static String _reviewLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => language.learningHeroReviewLabel(),
    AppLanguage.vi => language.learningHeroReviewLabel(),
    AppLanguage.ja => language.learningHeroReviewLabel(),
  };

  static String _repairLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => language.learningHeroRepairLabel(),
    AppLanguage.vi => language.learningHeroRepairLabel(),
    AppLanguage.ja => language.learningHeroRepairLabel(),
  };

  static String _primaryLabel(AppLanguage language) =>
      language.learningHeroPrimaryLabel();

  static String _secondaryLabel(AppLanguage language) =>
      language.learningHeroSecondaryLabel();
}

class _DojoStatChip extends StatelessWidget {
  const _DojoStatChip({
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

class _LearningLanesPanel extends StatelessWidget {
  const _LearningLanesPanel({
    required this.language,
    required this.level,
    required this.dueCount,
    required this.weakCount,
  });

  final AppLanguage language;
  final StudyLevel level;
  final int dueCount;
  final int weakCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppSectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _title(language),
            caption: _subtitle(language),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final cards = [
                _LaneCard(
                  icon: Icons.hub_rounded,
                  title: _studyLaneTitle(language),
                  subtitle: _studyLaneSubtitle(language, dueCount),
                  ctaLabel: _openLaneLabel(language),
                  chipLabel: dueCount > 0
                      ? _dueChip(language, dueCount)
                      : _readyChip(language),
                  color: palette.primary,
                  onTap: () => context.openStudy(),
                ),
                _LaneCard(
                  icon: Icons.quiz_rounded,
                  title: _jlptLaneTitle(language),
                  subtitle: _jlptLaneSubtitle(language, level),
                  ctaLabel: _openLaneLabel(language),
                  chipLabel: level.shortLabel,
                  color: palette.accent,
                  onTap: () => context.openJlptCoach(),
                ),
                _LaneCard(
                  icon: Icons.auto_stories_rounded,
                  title: _immersionLaneTitle(language),
                  subtitle: _immersionLaneSubtitle(language, weakCount),
                  ctaLabel: _openLaneLabel(language),
                  chipLabel: _immersionChip(language),
                  color: palette.secondary,
                  onTap: () => context.openImmersion(),
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 10),
                    Expanded(child: cards[1]),
                    const SizedBox(width: 10),
                    Expanded(child: cards[2]),
                  ],
                );
              }

              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 10),
                  cards[1],
                  const SizedBox(height: 10),
                  cards[2],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _title(AppLanguage language) => switch (language) {
    AppLanguage.en => language.learningLanesTitle(),
    AppLanguage.vi => language.learningLanesTitle(),
    AppLanguage.ja => language.learningLanesTitle(),
  };

  static String _subtitle(AppLanguage language) => switch (language) {
    AppLanguage.en => language.learningLanesSubtitle(),
    AppLanguage.vi => language.learningLanesSubtitle(),
    AppLanguage.ja => language.learningLanesSubtitle(),
  };

  static String _studyLaneTitle(AppLanguage language) =>
      language.learningStudyLaneTitle();

  static String _studyLaneSubtitle(AppLanguage language, int dueCount) =>
      language.learningStudyLaneSubtitle(dueCount);

  static String _jlptLaneTitle(AppLanguage language) =>
      language.learningJlptLaneTitle();

  static String _jlptLaneSubtitle(AppLanguage language, StudyLevel level) =>
      language.learningJlptLaneSubtitle(level.shortLabel);

  static String _immersionLaneTitle(AppLanguage language) =>
      language.learningImmersionLaneTitle();

  static String _immersionLaneSubtitle(AppLanguage language, int weakCount) =>
      language.learningImmersionLaneSubtitle(weakCount);

  static String _dueChip(AppLanguage language, int dueCount) =>
      switch (language) {
        AppLanguage.en => '$dueCount due',
        AppLanguage.vi => '$dueCount đến hạn',
        AppLanguage.ja => '$dueCount件待機',
      };

  static String _readyChip(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Ready now',
    AppLanguage.vi => 'Sẵn sàng',
    AppLanguage.ja => '今すぐ開始',
  };

  static String _immersionChip(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Real Japanese',
    AppLanguage.vi => 'Nhật ngữ thật',
    AppLanguage.ja => '実際の日本語',
  };

  static String _openLaneLabel(AppLanguage language) =>
      language.learningOpenLaneLabel();
}

class _LaneCard extends StatelessWidget {
  const _LaneCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.chipLabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String chipLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
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
              colors: [
                color.withValues(alpha: 0.16),
                context.appPalette.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.28)),
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
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chipLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: palette.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.7),
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

class _FocusChip extends StatelessWidget {
  const _FocusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
