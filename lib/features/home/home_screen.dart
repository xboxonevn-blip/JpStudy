import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/core/analytics/analytics_provider.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/gamification/level_calculator.dart';
import 'package:jpstudy/core/goal_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/home/widgets/header_bar.dart';
import 'package:jpstudy/features/home/widgets/goal_selection_banner.dart';
import 'package:jpstudy/core/models/streak_milestone.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as model;
import 'package:jpstudy/features/learn/services/learn_session_service.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:jpstudy/features/onboarding/onboarding_screen.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int? _lastKnownLevel;
  late final AppSettingsController _appSettingsController;
  late final DataSettingsController _dataSettingsController;

  @override
  void initState() {
    super.initState();
    _appSettingsController = ref.read(appSettingsControllerProvider.notifier);
    _dataSettingsController = ref.read(dataSettingsControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _appSettingsController.initialize(hostContext: context);
      _dataSettingsController.initialize(hostContext: context);
      _showPendingAchievements();
      _initLevelTracking();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appSettingsController.bindHostContext(context);
    _dataSettingsController.bindHostContext(context);
  }

  @override
  void dispose() {
    _appSettingsController.unbindHostContext(context);
    _dataSettingsController.unbindHostContext(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appInitProvider);
    ref.listen<AsyncValue<DashboardState>>(dashboardProvider, (_, next) {
      next.whenData((state) => _checkMilestones(state));
    });

    final onboardingDone = ref.watch(onboardingDoneProvider);
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    if (onboardingDone == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!onboardingDone) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }

    final isMobile = MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
    if (isMobile) {
      return _MobileHomeFallback(
        language: language,
        level: level ?? StudyLevel.n5,
        onLanguageTap: () => _showLanguageSheet(context),
        onLevelChanged: _setLevel,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: HeaderBar(
          level: level,
          language: language,
          onLanguageTap: () => _showLanguageSheet(context),
          onLevelChanged: _setLevel,
          onSettingsTap: () => context.openMe(),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: const LearningPathScreen(),
    );
  }

  Future<void> _initLevelTracking() async {
    if (!mounted) {
      return;
    }
    final repo = ref.read(lessonRepositoryProvider);
    final progress = await repo.fetchProgressSummary();
    if (!mounted) {
      return;
    }
    _lastKnownLevel = LevelCalculator.calculate(progress.totalXp).level;
  }

  Future<void> _checkMilestones(DashboardState state) async {
    if (!mounted) {
      return;
    }
    final db = ref.read(databaseProvider);
    final achievementDao = AchievementDao(db);

    const milestones = [7, 14, 30, 60, 100];
    if (milestones.contains(state.streak)) {
      final already = await achievementDao.hasAchievement(
        model.AchievementType.streak.name,
        state.streak,
      );
      if (!already) {
        await achievementDao.addAchievement(
          AchievementsCompanion(
            type: Value(model.AchievementType.streak.name),
            value: Value(state.streak),
            earnedAt: Value(DateTime.now()),
            isNotified: const Value(false),
          ),
        );
      }
    }

    if (_lastKnownLevel != null) {
      final repo = ref.read(lessonRepositoryProvider);
      final progress = await repo.fetchProgressSummary();
      final newLevel = LevelCalculator.calculate(progress.totalXp).level;
      if (newLevel > _lastKnownLevel!) {
        final already = await achievementDao.hasAchievement(
          model.AchievementType.levelUp.name,
          newLevel,
        );
        if (!already) {
          await achievementDao.addAchievement(
            AchievementsCompanion(
              type: Value(model.AchievementType.levelUp.name),
              value: Value(newLevel),
              earnedAt: Value(DateTime.now()),
              isNotified: const Value(false),
            ),
          );
        }
        _lastKnownLevel = newLevel;
      }
    }

    if (!mounted) {
      return;
    }
    await _showPendingAchievements();
  }

  Future<void> _showPendingAchievements() async {
    if (!mounted) {
      return;
    }
    final db = ref.read(databaseProvider);
    final service = LearnSessionService(LearnDao(db), AchievementDao(db));
    final achievements = await service.getPendingAchievements();
    if (!mounted || achievements.isEmpty) {
      return;
    }

    final language = ref.read(appLanguageProvider);
    for (final achievement in achievements) {
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            _AchievementDialog(achievement: achievement, language: language),
      );
    }
  }

  void _setLevel(StudyLevel selected) {
    ref.read(studyLevelProvider.notifier).state = selected;
    if (selected != StudyLevel.n3 &&
        ref.read(appLanguageProvider) == AppLanguage.ja) {
      unawaited(
        ref.read(appLanguageProvider.notifier).setLanguage(AppLanguage.en),
      );
    }
  }

  Future<void> _handleOnboardingComplete(
    StudyLevel level,
    StudyGoal goal,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOnboardingCompleted, true);
    await prefs.setString(prefOnboardingLevel, level.name);
    await prefs.setString(prefOnboardingGoal, goal.name);
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logOnboardingCompleted(level: level.shortLabel, goal: goal.name),
    );
    if (!mounted) {
      return;
    }
    ref.read(studyGoalProvider.notifier).state = goal;
    _setLevel(level);
    ref.read(onboardingDoneProvider.notifier).state = true;
    if (goal == StudyGoal.writing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.openFoundationsKana(KanaScript.hiragana);
        }
      });
    }
  }

  void _showLanguageSheet(BuildContext context) {
    final level = ref.read(studyLevelProvider);
    final allowJapanese = level == StudyLevel.n3;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _LanguagePicker(
          allowJapanese: allowJapanese,
          uiLanguage: ref.read(appLanguageProvider),
          onSelected: (language) {
            unawaited(
              ref.read(appLanguageProvider.notifier).setLanguage(language),
            );
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _MobileHomeFallback extends StatelessWidget {
  const _MobileHomeFallback({
    required this.language,
    required this.level,
    required this.onLanguageTap,
    required this.onLevelChanged,
  });

  final AppLanguage language;
  final StudyLevel level;
  final VoidCallback onLanguageTap;
  final ValueChanged<StudyLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        toolbarHeight: 72,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: HeaderBar(
          level: level,
          language: language,
          onLanguageTap: onLanguageTap,
          onLevelChanged: onLevelChanged,
          onSettingsTap: () => context.openMe(),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AppPageShell(
        child: Column(
          children: [
            const GoalSelectionBanner(),
            AppFluidGrid(
              maxColumns: 2,
              children: [
                _MobileHomeCard(
                  icon: Icons.spa_rounded,
                  title: _mobileFoundationsTitle(language),
                  subtitle: _mobileFoundationsSubtitle(language),
                  cta: _mobileStartLabel(language),
                  onTap: context.openFoundations,
                ),
                _MobileHomeCard(
                  icon: Icons.auto_awesome_rounded,
                  title: _mobilePlanTitle(language),
                  subtitle: _mobilePlanSubtitle(language),
                  cta: _mobileStudyLabel(language),
                  onTap: context.openStudy,
                ),
                _MobileHomeCard(
                  icon: Icons.translate_rounded,
                  title: _mobileVocabTitle(language),
                  subtitle: _mobileVocabSubtitle(language),
                  cta: _mobileOpenLabel(language),
                  onTap: context.openVocab,
                ),
                _MobileHomeCard(
                  icon: Icons.account_tree_rounded,
                  title: _mobileGrammarTitle(language),
                  subtitle: _mobileGrammarSubtitle(language),
                  cta: _mobileOpenLabel(language),
                  onTap: context.openGrammar,
                ),
                _MobileHomeCard(
                  icon: Icons.grid_view_rounded,
                  title: _mobileKanjiTitle(language),
                  subtitle: _mobileKanjiSubtitle(language),
                  cta: _mobileOpenLabel(language),
                  onTap: context.openKanji,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileHomeCard extends StatelessWidget {
  const _MobileHomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: palette.primary, size: 30),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(subtitle),
              const SizedBox(height: 12),
              Text(
                cta,
                style: TextStyle(
                  color: palette.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _mobileFoundationsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Foundations',
  AppLanguage.vi => 'Nền tảng',
  AppLanguage.ja => '基礎',
};

String _mobileFoundationsSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Kana, basic sounds, and Han-Viet essentials.',
  AppLanguage.vi => 'Bảng chữ Kana, âm cơ bản và Hán Việt cốt lõi.',
  AppLanguage.ja => 'かな、基本音、漢越の基礎。',
};

String _mobilePlanTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => "Today's plan",
  AppLanguage.vi => 'Bảng kế hoạch hôm nay',
  AppLanguage.ja => '今日の学習計画',
};

String _mobilePlanSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start with a short focused session.',
  AppLanguage.vi => 'Bắt đầu bằng một phiên học ngắn, tập trung.',
  AppLanguage.ja => '短い集中セッションから始めましょう。',
};

String _mobileVocabTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Learn vocab',
  AppLanguage.vi => 'Học từ vựng',
  AppLanguage.ja => '語彙を学ぶ',
};

String _mobileVocabSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Review due words and learn new terms.',
  AppLanguage.vi => 'Ôn từ đến hạn và học từ mới.',
  AppLanguage.ja => '復習語彙と新しい語彙。',
};

String _mobileGrammarTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Learn grammar',
  AppLanguage.vi => 'Học ngữ pháp',
  AppLanguage.ja => '文法を学ぶ',
};

String _mobileGrammarSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Practice JLPT patterns with examples.',
  AppLanguage.vi => 'Luyện mẫu câu JLPT với ví dụ.',
  AppLanguage.ja => 'JLPT文型を例文で練習。',
};

String _mobileKanjiTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Learn Kanji',
  AppLanguage.vi => 'Học Kanji',
  AppLanguage.ja => '漢字を学ぶ',
};

String _mobileKanjiSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Explore readings, meanings, and writing.',
  AppLanguage.vi => 'Khám phá âm đọc, nghĩa và luyện viết.',
  AppLanguage.ja => '読み、意味、書き方を確認。',
};

String _mobileStartLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start',
  AppLanguage.vi => 'Bắt đầu',
  AppLanguage.ja => '開始',
};

String _mobileStudyLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Study now',
  AppLanguage.vi => 'Học ngay',
  AppLanguage.ja => '今すぐ学習',
};

String _mobileOpenLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open',
  AppLanguage.vi => 'Mở',
  AppLanguage.ja => '開く',
};

class _AchievementDialog extends StatelessWidget {
  const _AchievementDialog({required this.achievement, required this.language});

  final model.Achievement achievement;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isStreak = achievement.type == model.AchievementType.streak;
    final milestone = isStreak
        ? StreakMilestone.forStreak(achievement.value)
        : null;
    final bgColor = milestone?.color ?? palette.error;
    final borderColor = isStreak
        ? bgColor.withValues(alpha: 0.7)
        : palette.error.withValues(alpha: 0.7);

    final bonusLabel = isStreak && milestone != null
        ? '+${milestone.bonusXp} XP'
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStreak && milestone != null)
            Text(milestone.emoji, style: const TextStyle(fontSize: 56)),
          if (isStreak && milestone != null) const SizedBox(height: 8),
          Transform.rotate(
            angle: -0.09,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(color: borderColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: palette.ink.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            achievement.type.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (bonusLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              bonusLabel,
              style: TextStyle(
                color: palette.warning,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: context.appPalette.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.allowJapanese,
    required this.uiLanguage,
    required this.onSelected,
  });

  final bool allowJapanese;
  final AppLanguage uiLanguage;
  final ValueChanged<AppLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          Text(
            uiLanguage.languageMenuLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _LanguageCard(language: AppLanguage.en, onSelected: onSelected),
          _LanguageCard(language: AppLanguage.vi, onSelected: onSelected),
          _LanguageCard(
            language: AppLanguage.ja,
            onSelected: onSelected,
            enabled: allowJapanese,
            disabledLabel: uiLanguage.n3OnlyLabel,
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.onSelected,
    this.enabled = true,
    this.disabledLabel,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onSelected;
  final bool enabled;
  final String? disabledLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(language.label),
        subtitle: !enabled && disabledLabel != null
            ? Text(disabledLabel!)
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? () => onSelected(language) : null,
      ),
    );
  }
}
