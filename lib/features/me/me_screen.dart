import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jpstudy/app/theme/app_breakpoints.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/theme_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:jpstudy/features/me/widgets/challenge_history_card.dart';
import 'package:jpstudy/features/me/widgets/personal_bests_card.dart';

class MeScreen extends ConsumerStatefulWidget {
  const MeScreen({super.key});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appSettingsControllerProvider.notifier).initialize();
      ref.read(dataSettingsControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final themeMode = ref.watch(themeModeProvider);
    final progressAsync = ref.watch(progressSummaryProvider);
    final appSettings = ref.watch(appSettingsControllerProvider);
    final appSettingsController = ref.read(
      appSettingsControllerProvider.notifier,
    );
    final dataSettings = ref.watch(dataSettingsControllerProvider);
    final dataSettingsController = ref.read(
      dataSettingsControllerProvider.notifier,
    );
    final cloudStatusAsync = ref.watch(cloudSyncStatusProvider);
    final profileHero = progressAsync.when(
      data: (summary) => AppFeatureCard(
        icon: Icons.person_rounded,
        title: _title(language),
        subtitle: _summaryCaption(language, summary),
        primaryLabel: _manageDataLabel(language),
        onPrimaryTap: () => context.push('/me/data'),
        secondaryLabel: switch (language) {
          AppLanguage.en => 'Progress',
          AppLanguage.vi => 'Tiến độ',
          AppLanguage.ja => '進捗',
        },
        onSecondaryTap: () => context.push('/progress'),
        status: AppStatusChip(
          label: level.shortLabel,
          tone: AppStatusTone.primary,
        ),
      ),
      loading: () => AppFeatureCard(
        icon: Icons.person_rounded,
        title: _title(language),
        subtitle: _toolsLabel(language),
        status: AppStatusChip(
          label: level.shortLabel,
          tone: AppStatusTone.primary,
        ),
      ),
      error: (error, stackTrace) => AppFeatureCard(
        icon: Icons.person_rounded,
        title: _title(language),
        subtitle: _toolsLabel(language),
        status: AppStatusChip(
          label: level.shortLabel,
          tone: AppStatusTone.primary,
        ),
      ),
    );
    final learningSection = _SectionCard(
      title: language.settingsLearningSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final candidate in StudyLevel.values)
                ChoiceChip(
                  label: Text(candidate.shortLabel),
                  selected: candidate == level,
                  onSelected: (_) {
                    ref.read(studyLevelProvider.notifier).state = candidate;
                    if (candidate != StudyLevel.n3 &&
                        ref.read(appLanguageProvider) == AppLanguage.ja) {
                      ref.read(appLanguageProvider.notifier).state =
                          AppLanguage.en;
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final appLanguage in AppLanguage.values)
                ChoiceChip(
                  label: Text(appLanguage.shortCode),
                  selected: appLanguage == language,
                  onSelected:
                      appLanguage == AppLanguage.ja && level != StudyLevel.n3
                      ? null
                      : (_) {
                          ref.read(appLanguageProvider.notifier).state =
                              appLanguage;
                        },
                ),
            ],
          ),
          const SizedBox(height: 12),
          _InlineActionTile(
            icon: Icons.school_outlined,
            title: language.levelMenuTitle,
            subtitle: language.changeLevelLabel,
            onTap: () => _resetOnboarding(context),
          ),
        ],
      ),
    );
    final appearanceSection = _SectionCard(
      title: language.settingsAppearanceSection,
      child: Column(
        children: [
          SwitchListTile(
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            contentPadding: EdgeInsets.zero,
            title: Text(language.darkModeLabel),
            subtitle: Text(language.darkModeHint),
          ),
          SwitchListTile(
            value: appSettings.strokeGuideDefaultExpanded,
            onChanged: appSettings.isReady
                ? (value) =>
                      appSettingsController.setStrokeGuideDefaultExpanded(value)
                : null,
            contentPadding: EdgeInsets.zero,
            title: Text(language.handwritingStrokeGuideDefaultLabel),
            subtitle: Text(language.handwritingStrokeGuideDefaultHint),
          ),
        ],
      ),
    );
    final reminderSection = _SectionCard(
      title: language.settingsReminderSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: appSettings.reminderEnabled,
            onChanged: appSettings.isReady
                ? (value) async {
                    await appSettingsController.setDailyReminder(
                      value,
                      language,
                    );
                    if (!appSettingsController.supportsNotifications &&
                        value &&
                        context.mounted) {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: appSettings.reminderTime,
                      );
                      if (picked != null) {
                        await appSettingsController.setReminderTime(picked);
                      }
                    }
                  }
                : null,
            contentPadding: EdgeInsets.zero,
            title: Text(language.reminderDailyLabel),
            subtitle: Text(language.reminderDailyHint),
          ),
          if (!appSettingsController.supportsNotifications) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                language.reminderUnsupportedLabel,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            _InlineActionTile(
              icon: Icons.schedule_outlined,
              title: language.reminderTimeLabel,
              subtitle: _formatTime(appSettings.reminderTime),
              onTap: !appSettings.reminderEnabled || !appSettings.isReady
                  ? null
                  : () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: appSettings.reminderTime,
                      );
                      if (picked != null) {
                        await appSettingsController.setReminderTime(picked);
                      }
                    },
            ),
          ],
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: appSettings.isReady
                ? () => appSettingsController.testReminder(
                    language,
                    context: context,
                  )
                : null,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(language.reminderTestLabel),
          ),
        ],
      ),
    );
    final dataSection = _SectionCard(
      title: language.settingsDataSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InlineActionTile(
            icon: Icons.schedule_outlined,
            title: language.autoBackupLabel,
            subtitle: _autoBackupSubtitle(language, dataSettings),
            onTap: () => context.push('/me/data'),
          ),
          const SizedBox(height: 10),
          cloudStatusAsync.when(
            data: (status) => _InlineActionTile(
              icon: Icons.cloud_sync_outlined,
              title: dataSettingsController.cloudSyncLabel(language),
              subtitle: dataSettingsController.cloudSyncStatusSubtitle(
                context,
                language,
                status,
              ),
              onTap: () => context.push('/me/data'),
            ),
            loading: () => _InlineActionTile(
              icon: Icons.cloud_sync_outlined,
              title: dataSettingsController.cloudSyncLabel(language),
              subtitle: dataSettingsController.cloudSyncLoadingLabel(language),
              onTap: () => context.push('/me/data'),
            ),
            error: (error, stackTrace) => _InlineActionTile(
              icon: Icons.cloud_sync_outlined,
              title: dataSettingsController.cloudSyncLabel(language),
              subtitle: dataSettingsController.cloudSyncLoadingLabel(language),
              onTap: () => context.push('/me/data'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.push('/me/data'),
            icon: const Icon(Icons.storage_rounded),
            label: Text(_manageDataLabel(language)),
          ),
        ],
      ),
    );
    final toolsSection = _SectionCard(
      title: _toolsLabel(language),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.insights_outlined,
            title: language.progressTitle,
            subtitle: _progressHint(language),
            onTap: () => context.push('/progress'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.military_tech_outlined,
            title: _masteryTitle(language),
            subtitle: _masteryHint(language),
            onTap: () => context.push('/mastery'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.calendar_month_outlined,
            title: _forecastTitle(language),
            subtitle: _forecastHint(language),
            onTap: () => context.push('/forecast'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.emoji_events_outlined,
            title: language.achievementsTitle,
            subtitle: _achievementsHint(language),
            onTap: () => context.push('/achievements'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.design_services_outlined,
            title: language.designLabLabel,
            subtitle: language.designLabSubtitle,
            onTap: () => context.push('/design-lab'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(_title(language))),
      body: AppPageShell(
        topPadding: AppSpacing.lg,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useDesktopGrid =
                constraints.maxWidth >= AppBreakpoints.desktop;
            final leftColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                learningSection,
                const SizedBox(height: AppSpacing.lg),
                appearanceSection,
                const SizedBox(height: AppSpacing.lg),
                reminderSection,
              ],
            );
            final rightColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dataSection,
                const SizedBox(height: AppSpacing.lg),
                const PersonalBestsCard(),
                const SizedBox(height: AppSpacing.lg),
                const ChallengeHistoryCard(),
                const SizedBox(height: AppSpacing.lg),
                toolsSection,
              ],
            );

            if (!useDesktopGrid) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileHero,
                  if (!appSettings.isReady || !dataSettings.isReady) ...[
                    const SizedBox(height: AppSpacing.lg),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  leftColumn,
                  const SizedBox(height: AppSpacing.lg),
                  rightColumn,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileHero,
                if (!appSettings.isReady || !dataSettings.isReady) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const LinearProgressIndicator(minHeight: 3),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: leftColumn),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 5, child: rightColumn),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOnboardingCompleted, false);
    if (!mounted || !context.mounted) {
      return;
    }
    ref.read(onboardingDoneProvider.notifier).state = false;
    context.go('/today');
  }

  String _formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Me';
      case AppLanguage.vi:
        return 'Cá nhân';
      case AppLanguage.ja:
        return 'マイページ';
    }
  }

  String _manageDataLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Manage data';
      case AppLanguage.vi:
        return 'Quản lý dữ liệu';
      case AppLanguage.ja:
        return 'データ管理';
    }
  }

  String _autoBackupSubtitle(AppLanguage language, DataSettingsState settings) {
    if (!settings.autoBackupEnabled) {
      return language.autoBackupHint;
    }
    if (settings.lastAutoBackup == null) {
      return '${language.autoBackupLabel} - ${_formatTime(settings.autoBackupTime)}';
    }
    final date = MaterialLocalizations.of(
      context,
    ).formatMediumDate(settings.lastAutoBackup!);
    return '$date - ${_formatTime(settings.autoBackupTime)}';
  }

  String _toolsLabel(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Progress and tools';
      case AppLanguage.vi:
        return 'Tiến độ và công cụ';
      case AppLanguage.ja:
        return '進捗とツール';
    }
  }

  String _progressHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Review streaks, XP, retention, and history.';
      case AppLanguage.vi:
        return 'Xem streak, XP, retention và lịch sử.';
      case AppLanguage.ja:
        return '連続学習、XP、定着率、履歴をまとめて確認します。';
    }
  }

<<<<<<< HEAD
=======
  String _masteryTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'JLPT Mastery';
      case AppLanguage.vi:
        return 'Tiến độ JLPT';
      case AppLanguage.ja:
        return 'JLPT 習熟度';
    }
  }

  String _masteryHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Track mastery across vocab, grammar, and kanji per level.';
      case AppLanguage.vi:
        return 'Theo dõi tiến trình từ vựng, ngữ pháp, hán tự theo cấp.';
      case AppLanguage.ja:
        return 'レベル別に語彙・文法・漢字の習熟度を追跡します。';
    }
  }

  String _forecastTitle(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Review Forecast';
      case AppLanguage.vi:
        return 'Dự báo ôn tập';
      case AppLanguage.ja:
        return '復習予報';
    }
  }

  String _forecastHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'See upcoming reviews, memory strength, and SRS analytics.';
      case AppLanguage.vi:
        return 'Xem lịch ôn tập, sức mạnh trí nhớ và phân tích SRS.';
      case AppLanguage.ja:
        return '今後の復習予定、記憶の強さ、SRS分析を確認します。';
    }
  }

>>>>>>> 6de2290 (feat(progress): add 14-day review forecast with stability analytics)
  String _achievementsHint(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'See unlocked milestones and pending goals.';
      case AppLanguage.vi:
        return 'Xem cột mốc đã mở và mục tiêu sắp đạt.';
      case AppLanguage.ja:
        return '解除済みのマイルストーンと次の目標を確認する。';
    }
  }

  String _summaryCaption(AppLanguage language, ProgressSummary summary) {
    switch (language) {
      case AppLanguage.en:
        return '${summary.todayXp} XP today / ${summary.streak} day streak';
      case AppLanguage.vi:
        return '${summary.todayXp} XP hôm nay / chuỗi ${summary.streak} ngày';
      case AppLanguage.ja:
        return '今日 ${summary.todayXp} XP / ${summary.streak}日連続';
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InlineActionTile extends StatelessWidget {
  const _InlineActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FBFF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF0369A1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
