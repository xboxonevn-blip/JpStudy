import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
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
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/home/widgets/header_bar.dart';
import 'package:jpstudy/core/models/streak_milestone.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as model;
import 'package:jpstudy/features/learn/services/learn_session_service.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:jpstudy/features/onboarding/onboarding_screen.dart';
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
          onSettingsTap: () => context.go('/me'),
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
    final service = LearnSessionService(
      LearnDao(ref.read(databaseProvider)),
      AchievementDao(ref.read(databaseProvider)),
    );
    _lastKnownLevel = service.calculateLevel(progress.totalXp);
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
      final service = LearnSessionService(LearnDao(db), AchievementDao(db));
      final newLevel = service.calculateLevel(progress.totalXp);
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
      ref.read(appLanguageProvider.notifier).state = AppLanguage.en;
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
    if (!mounted) {
      return;
    }
    ref.read(studyGoalProvider.notifier).state = goal;
    _setLevel(level);
    ref.read(onboardingDoneProvider.notifier).state = true;
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
            ref.read(appLanguageProvider.notifier).state = language;
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _AchievementDialog extends StatelessWidget {
  const _AchievementDialog({required this.achievement, required this.language});

  final model.Achievement achievement;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final isStreak = achievement.type == model.AchievementType.streak;
    final milestone = isStreak
        ? StreakMilestone.forStreak(achievement.value)
        : null;
    final bgColor = milestone?.color ?? const Color(0xFFD1493F);
    final borderColor = isStreak
        ? bgColor.withValues(alpha: 0.7)
        : const Color(0xFFB03A32);

    final bonusLabel = isStreak && milestone != null
        ? '+${milestone.bonusXp} XP'
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStreak && milestone != null)
            Text(
              milestone.emoji,
              style: const TextStyle(fontSize: 56),
            ),
          if (isStreak && milestone != null)
            const SizedBox(height: 8),
          Transform.rotate(
            angle: -0.09,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(color: borderColor, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
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
              style: const TextStyle(
                color: Color(0xFFFDE68A),
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
                color: Theme.of(context).colorScheme.primary,
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
