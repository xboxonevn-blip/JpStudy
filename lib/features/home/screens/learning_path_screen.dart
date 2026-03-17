import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/daily_session_card.dart';
import 'package:jpstudy/features/home/widgets/discover_practice_panel.dart';
import 'package:jpstudy/features/home/widgets/mini_dashboard.dart';
import 'package:jpstudy/features/home/widgets/weakness_radar_card.dart';
import 'package:jpstudy/features/home/widgets/weekly_challenge_card.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
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

    return JapaneseBackground(
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 108, 0, AppSpacing.pageBottom),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DojoHeroCard(
                language: language,
                level: level,
                streak: streak,
                todayXp: todayXp,
                dueCount: dueCount,
                weakCount: weakCount,
                hasStartedToday: hasStartedToday,
                missionLabel: continueAction?.label,
                onPrimaryTap: () =>
                    _openContinueAction(context, continueAction),
                onSecondaryTap: () => context.push('/jlpt/coach'),
              ),
            ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08, end: 0),
            const SizedBox(height: 14),
            const DailySessionCard()
                .animate(delay: 80.ms)
                .fadeIn(duration: 340.ms)
                .slideY(begin: 0.06, end: 0),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const MiniDashboard(compact: true),
            ).animate(delay: 140.ms).fadeIn(duration: 320.ms),
            const SizedBox(height: 14),
            const WeeklyChallengeCard()
                .animate(delay: 180.ms)
                .fadeIn(duration: 320.ms),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _LearningLanesPanel(
                language: language,
                level: level,
                dueCount: dueCount,
                weakCount: weakCount,
              ),
            ).animate(delay: 220.ms).fadeIn(duration: 340.ms),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const WeaknessRadarCard(compact: true),
            ).animate(delay: 280.ms).fadeIn(duration: 320.ms),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const DiscoverPracticePanel(
                initiallyExpanded: true,
                dense: true,
              ),
            ).animate(delay: 340.ms).fadeIn(duration: 360.ms),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSectionHeader(
                      title: _studyPromptTitle(language),
                      caption: _studyPromptSubtitle(language),
                    ),
                    const SizedBox(height: 14),
                    AppProgressStrip(
                      value: hasStartedToday
                          ? (todayXp / 30).clamp(0.18, 1.0)
                          : 0.08,
                      label: _studyPromptProgressLabel(
                        language,
                        hasStartedToday: hasStartedToday,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
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
            ).animate(delay: 400.ms).fadeIn(duration: 320.ms),
          ],
        ),
      ),
    );
  }

  static void _openContinueAction(
    BuildContext context,
    ContinueAction? action,
  ) {
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

  static String _studyPromptTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Keep the Japanese rhythm',
    AppLanguage.vi => 'Giữ nhịp tiếng Nhật mỗi ngày',
    AppLanguage.ja => '毎日の日本語リズムを保つ',
  };

  static String _studyPromptSubtitle(
    AppLanguage language,
  ) => switch (language) {
    AppLanguage.en =>
      'This home screen now leads with sessions, drills, and clear next moves.',
    AppLanguage.vi =>
      'Màn hình này giờ ưu tiên session, drill và bước tiếp theo thật rõ ràng.',
    AppLanguage.ja => 'このホームは記事一覧ではなく、セッションとドリルを先頭に配置します。',
  };

  static String _studyPromptProgressLabel(
    AppLanguage language, {
    required bool hasStartedToday,
  }) => switch (language) {
    AppLanguage.en =>
      hasStartedToday
          ? 'Today already has momentum.'
          : 'One short session is enough to open today.',
    AppLanguage.vi =>
      hasStartedToday
          ? 'Hôm nay đã có đà học.'
          : 'Chỉ cần một session ngắn để mở nhịp hôm nay.',
    AppLanguage.ja =>
      hasStartedToday ? '今日はすでに学習の勢いがあります。' : '短い1セッションで今日の流れを作れます。',
  };

  static String _focusChipLabel(AppLanguage language, int dueCount) =>
      switch (language) {
        AppLanguage.en =>
          dueCount > 0 ? '$dueCount reviews waiting' : 'Review queue is clear',
        AppLanguage.vi =>
          dueCount > 0
              ? '$dueCount mục review đang chờ'
              : 'Hàng review đang sạch',
        AppLanguage.ja => dueCount > 0 ? '$dueCount件の復習が待機中' : '復習キューは空です',
      };

  static String _repairChipLabel(AppLanguage language, int weakCount) =>
      switch (language) {
        AppLanguage.en =>
          weakCount > 0
              ? '$weakCount weak points to repair'
              : 'Weak points are under control',
        AppLanguage.vi =>
          weakCount > 0
              ? '$weakCount điểm yếu cần sửa'
              : 'Điểm yếu đang trong tầm kiểm soát',
        AppLanguage.ja =>
          weakCount > 0 ? '$weakCount件の弱点を補強' : '弱点は今のところ安定しています',
      };

  static String _momentumChipLabel(AppLanguage language, StudyLevel level) =>
      switch (language) {
        AppLanguage.en => '${level.shortLabel} momentum lane',
        AppLanguage.vi => 'Lane tăng lực ${level.shortLabel}',
        AppLanguage.ja => '${level.shortLabel} の勢いレーン',
      };
}

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
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              top: -26,
              right: -18,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.11),
                ),
              ),
            ),
            Positioned(
              bottom: -34,
              left: -12,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _eyebrow(language),
                              style: const TextStyle(
                                color: Color(0xFFFFF7ED),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _title(
                                language,
                                dueCount: dueCount,
                                weakCount: weakCount,
                              ),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.08,
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
                  const SizedBox(height: 16),
                  Text(
                    _subtitle(
                      language,
                      dueCount: dueCount,
                      weakCount: weakCount,
                      hasStartedToday: hasStartedToday,
                    ),
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (missionLabel != null &&
                      missionLabel!.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_circle_rounded,
                            color: Color(0xFFFFE4BF),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              missionLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: onPrimaryTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF12324B),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(_primaryLabel(language)),
                      ),
                      OutlinedButton.icon(
                        onPressed: onSecondaryTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.32),
                          ),
                        ),
                        icon: const Icon(Icons.quiz_rounded),
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
  }) {
    if (dueCount > 0) {
      return switch (language) {
        AppLanguage.en => 'Clear the review queue first',
        AppLanguage.vi => 'Dọn hàng review trước',
        AppLanguage.ja => 'まず復習キューを片づける',
      };
    }
    if (weakCount > 0) {
      return switch (language) {
        AppLanguage.en => 'Lock in weak points today',
        AppLanguage.vi => 'Khóa lại điểm yếu hôm nay',
        AppLanguage.ja => '今日は弱点を締め直す',
      };
    }
    return switch (language) {
      AppLanguage.en => 'Open a clean Japanese session',
      AppLanguage.vi => 'Mở một session tiếng Nhật thật gọn',
      AppLanguage.ja => '気持ちよく日本語セッションを始める',
    };
  }

  static String _subtitle(
    AppLanguage language, {
    required int dueCount,
    required int weakCount,
    required bool hasStartedToday,
  }) {
    if (dueCount > 0) {
      return switch (language) {
        AppLanguage.en =>
          '$dueCount reviews are waiting. Finish them early, then drills and reading will feel lighter.',
        AppLanguage.vi =>
          'Có $dueCount lượt review đang chờ. Xong phần này sớm thì drill và đọc sẽ nhẹ hơn hẳn.',
        AppLanguage.ja => '$dueCount件の復習が待っています。先に終えると、そのあとのドリルと読解がずっと軽くなります。',
      };
    }
    if (weakCount > 0) {
      return switch (language) {
        AppLanguage.en =>
          '$weakCount weak spots are still warm. Repair them now while recall is close.',
        AppLanguage.vi =>
          'Còn $weakCount điểm yếu đang “nóng”. Vá ngay lúc này sẽ nhớ sâu hơn.',
        AppLanguage.ja => '$weakCount件の弱点がまだ新しいうちに補強すると、記憶が安定しやすくなります。',
      };
    }
    return switch (language) {
      AppLanguage.en =>
        hasStartedToday
            ? 'Your rhythm is already open. Pick one strong lane and keep the momentum moving.'
            : 'No urgent queue right now. Start one focused lane to keep Japanese active today.',
      AppLanguage.vi =>
        hasStartedToday
            ? 'Bạn đã mở nhịp rồi. Chọn một lane mạnh và giữ đà học tiếp tục.'
            : 'Hiện chưa có hàng chờ gấp. Mở một lane tập trung để giữ tiếng Nhật sống hôm nay.',
      AppLanguage.ja =>
        hasStartedToday
            ? '今日はもう流れができています。1つのレーンに集中して勢いを保ちましょう。'
            : '急ぎのキューはありません。1つの集中レーンで今日の日本語を動かしましょう。',
    };
  }

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
    AppLanguage.en => 'Review',
    AppLanguage.vi => 'Review',
    AppLanguage.ja => '復習',
  };

  static String _repairLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Repair',
    AppLanguage.vi => 'Sửa lỗi',
    AppLanguage.ja => '補修',
  };

  static String _primaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Start session',
    AppLanguage.vi => 'Bắt đầu session',
    AppLanguage.ja => 'セッション開始',
  };

  static String _secondaryLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT coach',
    AppLanguage.vi => 'JLPT coach',
    AppLanguage.ja => 'JLPTコーチ',
  };
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFE4BF)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _title(language),
            caption: _subtitle(language),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final cards = [
                Expanded(
                  child: _LaneCard(
                    icon: Icons.hub_rounded,
                    title: _studyLaneTitle(language),
                    subtitle: _studyLaneSubtitle(language, dueCount),
                    ctaLabel: _openLaneLabel(language),
                    chipLabel: dueCount > 0
                        ? _dueChip(language, dueCount)
                        : _readyChip(language),
                    color: palette.primary,
                    onTap: () => context.push('/study'),
                  ),
                ),
                Expanded(
                  child: _LaneCard(
                    icon: Icons.quiz_rounded,
                    title: _jlptLaneTitle(language),
                    subtitle: _jlptLaneSubtitle(language, level),
                    ctaLabel: _openLaneLabel(language),
                    chipLabel: level.shortLabel,
                    color: palette.accent,
                    onTap: () => context.push('/jlpt/coach'),
                  ),
                ),
                Expanded(
                  child: _LaneCard(
                    icon: Icons.auto_stories_rounded,
                    title: _immersionLaneTitle(language),
                    subtitle: _immersionLaneSubtitle(language, weakCount),
                    ctaLabel: _openLaneLabel(language),
                    chipLabel: _immersionChip(language),
                    color: palette.secondary,
                    onTap: () => context.push('/immersion'),
                  ),
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    cards[0],
                    const SizedBox(width: 12),
                    cards[1],
                    const SizedBox(width: 12),
                    cards[2],
                  ],
                );
              }

              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 12),
                  cards[1],
                  const SizedBox(height: 12),
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
    AppLanguage.en => 'Pick your training lane',
    AppLanguage.vi => 'Chọn lane luyện tập',
    AppLanguage.ja => '学習レーンを選ぶ',
  };

  static String _subtitle(AppLanguage language) => switch (language) {
    AppLanguage.en =>
      'Every lane is action-first: drill, exam, or real reading.',
    AppLanguage.vi =>
      'Mỗi lane đều hành động trước: drill, thi JLPT, hoặc đọc tiếng Nhật thật.',
    AppLanguage.ja => '記事一覧ではなく、ドリル・試験・実読の3レーンから始めます。',
  };

  static String _studyLaneTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Drill hub',
    AppLanguage.vi => 'Hub luyện tập',
    AppLanguage.ja => 'ドリルハブ',
  };

  static String _studyLaneSubtitle(
    AppLanguage language,
    int dueCount,
  ) => switch (language) {
    AppLanguage.en =>
      dueCount > 0
          ? 'Clear due items, fix ghosts, and hit the highest-priority drills.'
          : 'Jump into vocab, kanji, grammar, and focus drills right away.',
    AppLanguage.vi =>
      dueCount > 0
          ? 'Dọn bài đến hạn, sửa ghost và vào đúng drill ưu tiên ngay.'
          : 'Nhảy thẳng vào từ vựng, kanji, ngữ pháp và drill tập trung.',
    AppLanguage.ja =>
      dueCount > 0 ? '期限項目を処理し、ゴーストを直して、優先ドリルへ入ります。' : '語彙・漢字・文法・集中ドリルへすぐ入れます。',
  };

  static String _jlptLaneTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'JLPT studio',
    AppLanguage.vi => 'Studio JLPT',
    AppLanguage.ja => 'JLPTスタジオ',
  };

  static String _jlptLaneSubtitle(
    AppLanguage language,
    StudyLevel level,
  ) => switch (language) {
    AppLanguage.en =>
      'Stay exam-shaped for ${level.shortLabel} with reading sets, diagnosis, and mock flow.',
    AppLanguage.vi =>
      'Giữ form thi ${level.shortLabel} bằng đọc hiểu, chẩn đoán và luồng mock test.',
    AppLanguage.ja => '${level.shortLabel} 対策として、読解セット・診断・模試フローをまとめて練習できます。',
  };

  static String _immersionLaneTitle(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Reading lab',
    AppLanguage.vi => 'Phòng đọc luyện',
    AppLanguage.ja => '読解ラボ',
  };

  static String _immersionLaneSubtitle(
    AppLanguage language,
    int weakCount,
  ) => switch (language) {
    AppLanguage.en =>
      weakCount > 0
          ? 'Use level-based reading sets to repair recall in real sentences.'
          : 'Build real Japanese speed with level lanes, saved words, and repeat reads.',
    AppLanguage.vi =>
      weakCount > 0
          ? 'Dùng bài đọc theo level để vá trí nhớ ngay trong câu thật.'
          : 'Tăng tốc đọc tiếng Nhật thật với lane theo level, lưu từ và đọc lặp.',
    AppLanguage.ja =>
      weakCount > 0
          ? 'レベル別の読解セットで、実際の文の中から記憶を補強します。'
          : 'レベル別レーンと再読で、本物の日本語スピードを育てます。',
  };

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

  static String _openLaneLabel(AppLanguage language) => switch (language) {
    AppLanguage.en => 'Open lane',
    AppLanguage.vi => 'Mở lane',
    AppLanguage.ja => 'レーンを開く',
  };
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.16), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.28)),
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
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chipLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ctaLabel,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_outward_rounded, color: color, size: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
