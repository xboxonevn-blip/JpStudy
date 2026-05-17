import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/gamification/level_calculator.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/home/widgets/header_bar.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as model;
import 'package:jpstudy/features/learn/services/learn_session_service.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';

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

    if (onboardingDone != true) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '${language.achievementUnlockedTitle}: ${achievement.type.title}',
          ),
        ),
      );
    }
  }

  Future<void> _setLevel(StudyLevel selected) async {
    await setPersistedStudyLevel(ref, selected);
    if (!mounted) {
      return;
    }
    if (selected != StudyLevel.n3 &&
        ref.read(appLanguageProvider) == AppLanguage.ja) {
      unawaited(
        ref.read(appLanguageProvider.notifier).setLanguage(AppLanguage.en),
      );
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
