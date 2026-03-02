import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:jpstudy/core/notifications/notification_service.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/theme_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/home/widgets/header_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:jpstudy/core/goal_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/features/onboarding/onboarding_screen.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as model;
import 'package:jpstudy/features/learn/services/learn_session_service.dart';

const _prefDailyReminder = 'notifications.daily';
const _prefDailyReminderTime = 'notifications.daily.time';
const _prefDailyReminderLast = 'notifications.daily.last';
const _prefAutoBackup = 'backup.auto.enabled';
const _prefAutoBackupTime = 'backup.auto.time';
const _prefAutoBackupLast = 'backup.auto.last';
const _prefStrokeGuideDefaultExpanded =
    'write.handwriting.strokeGuide.defaultExpanded';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _inAppReminderTimer;
  Timer? _autoBackupTimer;
  SharedPreferences? _prefs;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _reminderEnabled = false;
  TimeOfDay _autoBackupTime = const TimeOfDay(hour: 2, minute: 0);
  bool _autoBackupEnabled = false;
  DateTime? _lastAutoBackup;
  int? _lastKnownLevel;

  @override
  void initState() {
    super.initState();
    _loadReminderPrefs();
    _loadBackupPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingAchievements();
      _initLevelTracking();
    });
  }

  @override
  void dispose() {
    _inAppReminderTimer?.cancel();
    _autoBackupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trigger init on first build; result tracked via onboardingDoneProvider.
    ref.watch(appInitProvider);
    ref.listen<AsyncValue<DashboardState>>(dashboardProvider, (_, next) {
      next.whenData((state) => _checkMilestones(state));
    });
    final onboardingDone = ref.watch(onboardingDoneProvider);
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    // Loading: still reading SharedPreferences
    if (onboardingDone == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // First install: show onboarding wizard
    if (!onboardingDone) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }

    // Normal: main app
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: HeaderBar(
          level: level,
          language: language,
          onLanguageTap: () => _showLanguageSheet(context),
          onLevelChanged: (selected) => _setLevel(selected),
          onSettingsTap: () => _showSettingsSheet(context),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: const LearningPathScreen(),
    );
  }

  Future<void> _initLevelTracking() async {
    if (!mounted) return;
    final repo = ref.read(lessonRepositoryProvider);
    final progress = await repo.fetchProgressSummary();
    if (!mounted) return;
    final service = LearnSessionService(
      LearnDao(ref.read(databaseProvider)),
      AchievementDao(ref.read(databaseProvider)),
    );
    _lastKnownLevel = service.calculateLevel(progress.totalXp);
  }

  Future<void> _checkMilestones(DashboardState state) async {
    if (!mounted) return;
    final db = ref.read(databaseProvider);
    final achievementDao = AchievementDao(db);

    // Streak milestones
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

    // Level-up milestone
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

    if (!mounted) return;
    await _showPendingAchievements();
  }

  Future<void> _showPendingAchievements() async {
    if (!mounted) return;
    final db = ref.read(databaseProvider);
    final service = LearnSessionService(LearnDao(db), AchievementDao(db));
    final achievements = await service.getPendingAchievements();
    if (!mounted || achievements.isEmpty) return;

    final language = ref.read(appLanguageProvider);
    for (final achievement in achievements) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _AchievementDialog(
          achievement: achievement,
          language: language,
        ),
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
    if (!mounted) return;
    ref.read(studyGoalProvider.notifier).state = goal;
    _setLevel(level); // also applies language guard (N3 → allow Japanese UI)
    ref.read(onboardingDoneProvider.notifier).state = true;
  }

  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOnboardingCompleted, false);
    if (!mounted) return;
    ref.read(onboardingDoneProvider.notifier).state = false;
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

  void _showSettingsSheet(BuildContext context) {
    final language = ref.read(appLanguageProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final prefs = snapshot.data!;
            final supportsNotifications =
                NotificationService.instance.isSupported;
            final themeMode = ref.watch(themeModeProvider);
            var reminderEnabled = prefs.getBool(_prefDailyReminder) ?? false;
            var strokeGuideDefaultExpanded =
                prefs.getBool(_prefStrokeGuideDefaultExpanded) ?? true;
            if (_prefs == null) {
              _prefs = prefs;
              _reminderEnabled = reminderEnabled;
              _reminderTime =
                  _reminderTimeFromPrefs(prefs) ??
                  const TimeOfDay(hour: 20, minute: 0);
            }
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    shrinkWrap: true,
                    children: [
                      Text(
                        language.settingsLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(language.languageMenuLabel),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showLanguageSheet(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.school_outlined),
                        title: Text(language.levelMenuTitle),
                        onTap: () {
                          Navigator.of(context).pop();
                          _resetOnboarding();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.insights_outlined),
                        title: Text(language.progressTitle),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/progress');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.emoji_events_outlined),
                        title: Text(language.achievementsTitle),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/achievements');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.design_services_outlined),
                        title: Text(language.designLabLabel),
                        subtitle: Text(language.designLabSubtitle),
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/design-lab');
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(language.darkModeLabel),
                        subtitle: Text(language.darkModeHint),
                        value: themeMode == ThemeMode.dark,
                        onChanged: (value) async {
                          await ref
                              .read(themeModeProvider.notifier)
                              .setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                          setModalState(() {});
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          language.handwritingStrokeGuideDefaultLabel,
                        ),
                        subtitle: Text(
                          language.handwritingStrokeGuideDefaultHint,
                        ),
                        value: strokeGuideDefaultExpanded,
                        onChanged: (value) async {
                          strokeGuideDefaultExpanded = value;
                          await prefs.setBool(
                            _prefStrokeGuideDefaultExpanded,
                            value,
                          );
                          setModalState(() {});
                        },
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(language.reminderDailyLabel),
                        subtitle: Text(language.reminderDailyHint),
                        value: reminderEnabled,
                        onChanged: (value) async {
                          reminderEnabled = value;
                          await _setDailyReminder(
                            value,
                            prefs: prefs,
                            language: language,
                          );
                          if (!supportsNotifications && value) {
                            if (!context.mounted) {
                              return;
                            }
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _reminderTime,
                            );
                            if (picked != null) {
                              _reminderTime = picked;
                              await _saveReminderTime(prefs, picked);
                              _scheduleInAppReminder();
                            }
                          }
                          setModalState(() {});
                        },
                      ),
                      if (!supportsNotifications) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            language.reminderUnsupportedLabel,
                            style: const TextStyle(color: Color(0xFF6B7390)),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.schedule_outlined),
                          title: Text(language.reminderTimeLabel),
                          subtitle: Text(_formatTime(_reminderTime, context)),
                          onTap: reminderEnabled
                              ? () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _reminderTime,
                                  );
                                  if (picked == null) {
                                    return;
                                  }
                                  _reminderTime = picked;
                                  await _saveReminderTime(prefs, picked);
                                  if (reminderEnabled) {
                                    _scheduleInAppReminder();
                                  }
                                  setModalState(() {});
                                }
                              : null,
                        ),
                      ],
                      TextButton.icon(
                        onPressed: supportsNotifications
                            ? () => NotificationService.instance
                                  .showTestNotification(
                                    title: language.reminderTitle,
                                    body: language.reminderTestBody,
                                  )
                            : () => _showInAppReminder(language),
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: Text(language.reminderTestLabel),
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(language.autoBackupLabel),
                        subtitle: Text(language.autoBackupHint),
                        value: _autoBackupEnabled,
                        onChanged: (value) async {
                          await _setAutoBackup(
                            value,
                            prefs: prefs,
                            language: language,
                          );
                          setModalState(() {});
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule_outlined),
                        title: Text(language.autoBackupTimeLabel),
                        subtitle: Text(_formatTime(_autoBackupTime, context)),
                        onTap: _autoBackupEnabled
                            ? () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: _autoBackupTime,
                                );
                                if (picked == null) {
                                  return;
                                }
                                _autoBackupTime = picked;
                                await _saveBackupTime(prefs, picked);
                                if (_autoBackupEnabled) {
                                  _scheduleAutoBackup();
                                }
                                setModalState(() {});
                              }
                            : null,
                      ),
                      if (_lastAutoBackup != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            language.autoBackupLastLabel(
                              MaterialLocalizations.of(
                                context,
                              ).formatMediumDate(_lastAutoBackup!),
                            ),
                            style: const TextStyle(color: Color(0xFF6B7390)),
                          ),
                        ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.save_alt_outlined),
                        title: Text(language.backupExportLabel),
                        onTap: () => _exportBackup(context, language),
                      ),
                      ListTile(
                        leading: const Icon(Icons.restore_outlined),
                        title: Text(language.backupImportLabel),
                        onTap: () => _importBackup(context, language),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _exportBackup(BuildContext context, AppLanguage language) async {
    final repo = ref.read(lessonRepositoryProvider);
    final data = await repo.exportBackup();
    final envelope = await BackupSyncService.buildExportEnvelope(data);
    final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
    final location = await getSaveLocation(
      suggestedName: 'jpstudy_backup.json',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (location == null) {
      return;
    }
    try {
      await File(location.path).writeAsString(jsonText, flush: true);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.backupExportSuccess)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.backupExportError)));
    }
  }

  Future<void> _importBackup(BuildContext context, AppLanguage language) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final shouldImport = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(language.backupImportTitle),
        content: Text(language.backupImportBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(language.backupImportConfirmLabel),
          ),
        ],
      ),
    );
    if (shouldImport != true) {
      return;
    }
    try {
      final content = await File(file.path).readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      final importPlan = await BackupSyncService.prepareImport(data);
      if (importPlan.decision == BackupImportDecision.invalidChecksum) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.backupImportError)));
        return;
      }
      if (importPlan.decision == BackupImportDecision.skipOlder) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language.autoBackupLastLabel('local is newer')),
          ),
        );
        return;
      }

      final repo = ref.read(lessonRepositoryProvider);
      await _savePreImportSafetySnapshot(repo);
      await repo.importBackup(importPlan.payload);
      await BackupSyncService.markImportApplied(importPlan.incomingExportedAt);
      refreshBackupStatus(ref);
      ref.invalidate(lessonMetaProvider);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.backupImportSuccess)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(language.backupImportError)));
    }
  }

  Future<void> _savePreImportSafetySnapshot(LessonRepository repo) async {
    final snapshot = await repo.exportBackup();
    final envelope = await BackupSyncService.buildExportEnvelope(snapshot);
    final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
    final backupDir = await _ensureBackupDir();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(
      p.join(backupDir.path, 'jpstudy_pre_import_$timestamp.json'),
    );
    await file.writeAsString(jsonText, flush: true);
    await _cleanupOldBackups(backupDir, keep: 10);
  }

  Future<void> _loadReminderPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    _prefs = prefs;
    _reminderEnabled = prefs.getBool(_prefDailyReminder) ?? false;
    _reminderTime =
        _reminderTimeFromPrefs(prefs) ?? const TimeOfDay(hour: 20, minute: 0);
    if (_reminderEnabled && !NotificationService.instance.isSupported) {
      _scheduleInAppReminder();
    }
  }

  Future<void> _loadBackupPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    _prefs ??= prefs;
    _autoBackupEnabled = prefs.getBool(_prefAutoBackup) ?? false;
    _autoBackupTime =
        _backupTimeFromPrefs(prefs) ?? const TimeOfDay(hour: 2, minute: 0);
    final lastRaw = prefs.getString(_prefAutoBackupLast);
    if (lastRaw != null) {
      _lastAutoBackup = DateTime.tryParse(lastRaw);
    }
    if (_autoBackupEnabled) {
      _scheduleAutoBackup();
    }
  }

  TimeOfDay? _reminderTimeFromPrefs(SharedPreferences prefs) {
    final stored = prefs.getString(_prefDailyReminderTime);
    if (stored == null || stored.isEmpty) {
      return null;
    }
    final parts = stored.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _saveReminderTime(
    SharedPreferences prefs,
    TimeOfDay time,
  ) async {
    final value =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_prefDailyReminderTime, value);
  }

  TimeOfDay? _backupTimeFromPrefs(SharedPreferences prefs) {
    final stored = prefs.getString(_prefAutoBackupTime);
    if (stored == null || stored.isEmpty) {
      return null;
    }
    final parts = stored.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _saveBackupTime(SharedPreferences prefs, TimeOfDay time) async {
    final value =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_prefAutoBackupTime, value);
  }

  Future<void> _setDailyReminder(
    bool enabled, {
    required SharedPreferences prefs,
    required AppLanguage language,
  }) async {
    _reminderEnabled = enabled;
    await prefs.setBool(_prefDailyReminder, enabled);
    if (NotificationService.instance.isSupported) {
      if (enabled) {
        await NotificationService.instance.enableDailyReminder(
          title: language.reminderTitle,
          body: language.reminderBody,
        );
      } else {
        await NotificationService.instance.disableDailyReminder();
      }
    } else {
      if (enabled) {
        _scheduleInAppReminder();
      } else {
        _inAppReminderTimer?.cancel();
      }
    }
  }

  Future<void> _setAutoBackup(
    bool enabled, {
    required SharedPreferences prefs,
    required AppLanguage language,
  }) async {
    _autoBackupEnabled = enabled;
    await prefs.setBool(_prefAutoBackup, enabled);
    if (enabled) {
      await _performAutoBackup(language);
      _scheduleAutoBackup();
    } else {
      _autoBackupTimer?.cancel();
    }
    refreshBackupStatus(ref);
  }

  void _scheduleInAppReminder() {
    _inAppReminderTimer?.cancel();
    if (!_reminderEnabled) {
      return;
    }
    final now = DateTime.now();
    final next = _nextReminderTime(now, _reminderTime);
    final delay = next.difference(now);
    _inAppReminderTimer = Timer(delay, _handleInAppReminder);
  }

  void _scheduleAutoBackup() {
    _autoBackupTimer?.cancel();
    if (!_autoBackupEnabled) {
      return;
    }
    final now = DateTime.now();
    final next = _nextReminderTime(now, _autoBackupTime);
    final delay = next.difference(now);
    _autoBackupTimer = Timer(delay, () async {
      await _performAutoBackup(ref.read(appLanguageProvider));
      _scheduleAutoBackup();
    });
  }

  DateTime _nextReminderTime(DateTime now, TimeOfDay time) {
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Future<void> _handleInAppReminder() async {
    if (!mounted) {
      return;
    }
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs ??= prefs;
    final todayKey = _dateKey(DateTime.now());
    final lastShown = prefs.getString(_prefDailyReminderLast);
    if (lastShown != todayKey) {
      await prefs.setString(_prefDailyReminderLast, todayKey);
      _showInAppReminder(ref.read(appLanguageProvider));
    }
    _scheduleInAppReminder();
  }

  Future<void> _performAutoBackup(AppLanguage language) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final lastRaw = prefs.getString(_prefAutoBackupLast);
    if (_dateKeyFromStored(lastRaw) == todayKey) {
      return;
    }
    try {
      final repo = ref.read(lessonRepositoryProvider);
      final data = await repo.exportBackup();
      final envelope = await BackupSyncService.buildExportEnvelope(data);
      final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
      final backupDir = await _ensureBackupDir();
      final timestamp = DateTime.now();
      final fileName =
          'jpstudy_auto_backup_${timestamp.toIso8601String().replaceAll(':', '-')}.json';
      final file = File(p.join(backupDir.path, fileName));
      await file.writeAsString(jsonText, flush: true);
      await prefs.setString(_prefAutoBackupLast, timestamp.toIso8601String());
      _lastAutoBackup = timestamp;
      refreshBackupStatus(ref);
      await _cleanupOldBackups(backupDir, keep: 7);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(language.autoBackupSuccessLabel)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(language.autoBackupErrorLabel)));
      }
    }
  }

  Future<Directory> _ensureBackupDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(directory.path, 'backups'));
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    return backupDir;
  }

  Future<void> _cleanupOldBackups(Directory backupDir, {int keep = 7}) async {
    final files =
        backupDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );
    if (files.length <= keep) return;
    for (final file in files.sublist(keep)) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  String _dateKey(DateTime time) {
    return '${time.year.toString().padLeft(4, '0')}-'
        '${time.month.toString().padLeft(2, '0')}-'
        '${time.day.toString().padLeft(2, '0')}';
  }

  String? _dateKeyFromStored(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return _dateKey(parsed);
    }
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }

  void _showInAppReminder(AppLanguage language) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(language.reminderBody)));
  }

  String _formatTime(TimeOfDay time, BuildContext context) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }
}

class _AchievementDialog extends StatelessWidget {
  const _AchievementDialog({
    required this.achievement,
    required this.language,
  });

  final model.Achievement achievement;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(language.achievementUnlockedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.type.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.type.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(achievement.description),
          const SizedBox(height: 8),
          Text(
            '+${achievement.bonusXP} XP',
            style: TextStyle(
              color: achievement.type.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Awesome!'),
        ),
      ],
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
