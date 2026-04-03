import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/home_surface.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

import '../data/jlpt_mock_bank.dart';
import '../data/jlpt_reading_bank.dart';
import '../models/jlpt_coach_models.dart';
import '../models/jlpt_plan_playbook.dart';
import '../services/jlpt_coach_service.dart';

final jlptPrepOverviewProvider =
    FutureProvider.family<JlptPrepOverview, StudyLevel>((ref, level) async {
      final repo = ref.watch(lessonRepositoryProvider);
      final contentDb = ref.watch(contentDatabaseProvider);
      final language = ref.watch(appLanguageProvider);
      // Fire all three IO-bound fetches concurrently — fully independent.
      final quickMockBankFuture = repo.getVocabByLevel(level.shortLabel);
      final passagesFuture = loadJlptReadingBank();
      final fullMockSectionsFuture = buildJlptMockSections(
        level: level,
        language: language,
        contentDb: contentDb,
        lessonRepo: repo,
      );

      final quickMockBank = await quickMockBankFuture;
      final passages = await passagesFuture;
      final levelPassages = passages
          .where((entry) => entry.level == level.shortLabel)
          .toList(growable: false);
      final fullMockSections = await fullMockSectionsFuture;

      return JlptPrepOverview(
        quickMockQuestionCount: quickMockBank.length,
        readingPassageCount: levelPassages.length,
        readingQuestionCount: levelPassages.fold<int>(
          0,
          (sum, passage) => sum + passage.questions.length,
        ),
        fullMockQuestionCount: fullMockSections.fold<int>(
          0,
          (sum, section) => sum + section.questions.length,
        ),
        fullMockMinutes: fullMockSections.fold<int>(
          0,
          (sum, section) => sum + section.minutes,
        ),
        fullMockSectionCount: fullMockSections.length,
      );
    });

class JlptCoachScreen extends ConsumerWidget {
  const JlptCoachScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final snapshot = ref.watch(jlptCoachSnapshotProvider).valueOrNull;
    final overviewAsync = ref.watch(jlptPrepOverviewProvider(level));
    final overview =
        overviewAsync.valueOrNull ?? JlptPrepOverview.placeholder();
    final dashboard =
        ref.watch(dashboardProvider).valueOrNull ?? _emptyDashboardState;
    final mistakeRepo = ref.watch(mistakeRepositoryProvider);
    final dueCount =
        dashboard.vocabDue + dashboard.grammarDue + dashboard.kanjiDue;

    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle(language))),
      body: AppPageShell(
        topPadding: AppSpacing.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PrepHero(
              language: language,
              level: level,
              subtitle: _heroSubtitle(language),
              readinessLabel: _heroReadinessLabel(language, snapshot),
              readinessTone: snapshot == null
                  ? AppStatusTone.warning
                  : _isReadyForExam(snapshot)
                  ? AppStatusTone.success
                  : AppStatusTone.primary,
              metrics: [
                _HeroMetricData(
                  label: _heroMetricReadiness(language),
                  value: _heroReadinessValue(language, snapshot),
                ),
                _HeroMetricData(
                  label: _heroMetricFullMock(language),
                  value: overviewAsync.isLoading
                      ? _loadingLabel(language)
                      : '${overview.fullMockQuestionCount}Q • ${overview.fullMockMinutes}m',
                ),
                _HeroMetricData(
                  label: _heroMetricLevelBank(language),
                  value: overviewAsync.isLoading
                      ? _loadingLabel(language)
                      : '${overview.quickMockQuestionCount}Q • ${overview.readingPassageCount} bài',
                ),
              ],
              primaryLabel: _startFullMockLabel(language),
              onPrimaryTap: () => context.push('/jlpt/mock-pro'),
              secondaryLabel: _startReadingLabel(language),
              onSecondaryTap: () => context.push('/jlpt/reading'),
            ),
            const SizedBox(height: AppSpacing.md),
            _PrepPanel(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: _modesTitle(language),
                    caption: _modesCaption(language, level),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SectionAccent(accent: context.appPalette.accent),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cards = [
                        _PrepModeCardData(
                          icon: Icons.fact_check_rounded,
                          title: _fullMockTitle(language),
                          subtitle: _fullMockSubtitle(language),
                          meta:
                              '${overview.fullMockSectionCount} phần • ${overview.fullMockQuestionCount} câu • ${overview.fullMockMinutes} phút',
                          statusLabel: _heroReadinessValue(language, snapshot),
                          statusTone: snapshot == null
                              ? AppStatusTone.warning
                              : _isReadyForExam(snapshot)
                              ? AppStatusTone.success
                              : AppStatusTone.primary,
                          accent: context.appPalette.accent,
                          onTap: () => context.push('/jlpt/mock-pro'),
                        ),
                        _PrepModeCardData(
                          icon: Icons.timer_rounded,
                          title: _quickMockTitle(language),
                          subtitle: _quickMockSubtitle(language, level),
                          meta: overviewAsync.isLoading
                              ? _loadingLabel(language)
                              : _quickMockMeta(
                                  language,
                                  overview.quickMockQuestionCount,
                                ),
                          statusLabel: overview.quickMockQuestionCount > 0
                              ? level.shortLabel
                              : _comingSoonLabel(language),
                          statusTone: overview.quickMockQuestionCount > 0
                              ? AppStatusTone.neutral
                              : AppStatusTone.warning,
                          accent: context.appPalette.primary,
                          onTap: overview.quickMockQuestionCount > 0
                              ? () => context.push('/practice/mock-exam')
                              : null,
                        ),
                        _PrepModeCardData(
                          icon: Icons.menu_book_rounded,
                          title: _readingDrillTitle(language),
                          subtitle: _readingDrillSubtitle(language, level),
                          meta: overviewAsync.isLoading
                              ? _loadingLabel(language)
                              : _readingDrillMeta(
                                  language,
                                  passages: overview.readingPassageCount,
                                  questions: overview.readingQuestionCount,
                                ),
                          statusLabel: level.shortLabel,
                          statusTone: AppStatusTone.primary,
                          accent: context.appPalette.secondary,
                          onTap: () => context.push('/jlpt/reading'),
                        ),
                      ];
                      final columns = constraints.maxWidth >= 980
                          ? 3
                          : constraints.maxWidth >= 620
                          ? 2
                          : 1;
                      final width = columns == 1
                          ? constraints.maxWidth
                          : (constraints.maxWidth -
                                    ((columns - 1) * AppSpacing.md)) /
                                columns;

                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          for (final card in cards)
                            SizedBox(
                              width: width,
                              child: _PrepModeCard(data: card),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 920;
                final readinessPanel = _ReadinessPanel(
                  language: language,
                  snapshot: snapshot,
                );
                final supportPanel = _SupportPanel(
                  language: language,
                  level: level,
                  dueCount: dueCount,
                  dashboard: dashboard,
                  mistakeStream: mistakeRepo.watchAllMistakes(),
                );

                if (!wide) {
                  return Column(
                    children: [
                      readinessPanel,
                      const SizedBox(height: AppSpacing.md),
                      supportPanel,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: readinessPanel),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(flex: 5, child: supportPanel),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _PlanPanel(language: language, snapshot: snapshot),
          ],
        ),
      ),
    );
  }
}

class JlptPrepOverview {
  const JlptPrepOverview({
    required this.quickMockQuestionCount,
    required this.readingPassageCount,
    required this.readingQuestionCount,
    required this.fullMockQuestionCount,
    required this.fullMockMinutes,
    required this.fullMockSectionCount,
  });

  const JlptPrepOverview.placeholder()
    : quickMockQuestionCount = 0,
      readingPassageCount = 0,
      readingQuestionCount = 0,
      fullMockQuestionCount = 0,
      fullMockMinutes = 0,
      fullMockSectionCount = 0;

  final int quickMockQuestionCount;
  final int readingPassageCount;
  final int readingQuestionCount;
  final int fullMockQuestionCount;
  final int fullMockMinutes;
  final int fullMockSectionCount;
}

class _PrepPanel extends StatelessWidget {
  const _PrepPanel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: HomeSurface.softPanel(
        radius: AppSpacing.radiusXxl,
        colors: const [Color(0xFFFFFEFC), Color(0xFFF8FBFF)],
      ),
      child: child,
    );
  }
}

class _PrepHero extends StatelessWidget {
  const _PrepHero({
    required this.language,
    required this.level,
    required this.subtitle,
    required this.readinessLabel,
    required this.readinessTone,
    required this.metrics,
    required this.primaryLabel,
    required this.onPrimaryTap,
    required this.secondaryLabel,
    required this.onSecondaryTap,
  });

  final AppLanguage language;
  final StudyLevel level;
  final String subtitle;
  final String readinessLabel;
  final AppStatusTone readinessTone;
  final List<_HeroMetricData> metrics;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String secondaryLabel;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final highlight =
        Color.lerp(palette.heroGradient.last, palette.accent, 0.32) ??
        palette.accent;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.heroGradient.first, highlight],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -12,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.16),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -26,
            left: -16,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF8D7AE).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 820;
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _heroEyebrow(language),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _heroTitle(language, level),
                          style: TextStyle(
                            fontSize: wide ? 30 : 24,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        AppStatusChip(
                          label: readinessLabel,
                          tone: readinessTone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: wide ? 560 : constraints.maxWidth,
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          height: 1.52,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.icon(
                          onPressed: onPrimaryTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: palette.primary,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(primaryLabel),
                        ),
                        OutlinedButton.icon(
                          onPressed: onSecondaryTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: Text(secondaryLabel),
                        ),
                      ],
                    ),
                  ],
                );

                final stats = Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [_HeroMetricBoard(metrics: metrics, wide: wide)],
                );

                final iconBlock = Container(
                  width: wide ? 88 : 72,
                  height: wide ? 88 : 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.09),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: wide ? 40 : 32,
                  ),
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      iconBlock,
                      const SizedBox(height: AppSpacing.lg),
                      copy,
                      const SizedBox(height: AppSpacing.lg),
                      stats,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: copy),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: iconBlock,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          stats,
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricData {
  const _HeroMetricData({required this.label, required this.value});

  final String label;
  final String value;
}

class _SectionAccent extends StatelessWidget {
  const _SectionAccent({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 3,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _HeroMetricBoard extends StatelessWidget {
  const _HeroMetricBoard({required this.metrics, required this.wide});

  final List<_HeroMetricData> metrics;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: wide ? 240 : double.infinity),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _heroBoardLabel(
              ProviderScope.containerOf(
                context,
                listen: false,
              ).read(appLanguageProvider),
            ),
            style: const TextStyle(
              color: Color(0xFFFFE4BF),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < metrics.length; index++) ...[
            _HeroMetricRow(metric: metrics[index]),
            if (index != metrics.length - 1) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _HeroMetricRow extends StatelessWidget {
  const _HeroMetricRow({required this.metric});

  final _HeroMetricData metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            metric.label,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          metric.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _PrepModeCardData {
  const _PrepModeCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.statusLabel,
    required this.statusTone,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String meta;
  final String statusLabel;
  final AppStatusTone statusTone;
  final Color accent;
  final VoidCallback? onTap;
}

class _PrepModeCard extends StatelessWidget {
  const _PrepModeCard({required this.data});

  final _PrepModeCardData data;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final language = ProviderScope.containerOf(
      context,
      listen: false,
    ).read(appLanguageProvider);
    final enabled = data.onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration:
              HomeSurface.softPanel(
                radius: 24,
                colors: [
                  Colors.white,
                  Color.lerp(
                        palette.base,
                        data.accent.withValues(alpha: 0.04),
                        0.45,
                      ) ??
                      palette.base,
                ],
              ).copyWith(
                boxShadow: [
                  BoxShadow(
                    color: data.accent.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
          child: Opacity(
            opacity: enabled ? 1 : 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 3,
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            data.accent.withValues(alpha: 0.16),
                            data.accent.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(data.icon, color: data.accent),
                    ),
                    const Spacer(),
                    AppStatusChip(
                      label: data.statusLabel,
                      tone: data.statusTone,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  data.title,
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  data.subtitle,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w600,
                    height: 1.40,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: data.accent.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    data.meta,
                    style: TextStyle(
                      color: data.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        enabled
                            ? _openLaneLabel(language)
                            : _preparingDataLabel(language),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.ink.withValues(alpha: 0.56),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: palette.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        enabled
                            ? Icons.arrow_outward_rounded
                            : Icons.schedule_rounded,
                        size: 18,
                        color: palette.ink.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel({required this.language, required this.snapshot});

  final AppLanguage language;
  final JlptCoachSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return _PrepPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _readinessTitle(language),
            caption: _readinessCaption(language),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionAccent(accent: context.appPalette.primary),
          const SizedBox(height: AppSpacing.md),
          if (snapshot == null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: HomeSurface.softPanel(
                radius: 22,
                colors: const [Color(0xFFFFFDFA), Color(0xFFF9FBFF)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _readinessEmptyTitle(language),
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _readinessEmptyBody(language),
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.72),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppStatusChip(
                        label: _baselineChip(language),
                        tone: AppStatusTone.warning,
                      ),
                      AppStatusChip(
                        label: _passRuleLabel(language),
                        tone: AppStatusTone.neutral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            AppProgressStrip(
              value: snapshot!.profile.overallAccuracy.clamp(0.06, 1.0),
              label: _readinessSummary(language, snapshot!),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppStatusChip(
                  label: _snapshotSourceLabel(
                    language,
                    snapshot!.profile.source,
                  ),
                  tone: AppStatusTone.neutral,
                ),
                AppStatusChip(
                  label: _lastUpdatedLabel(
                    language,
                    snapshot!.profile.generatedAt,
                  ),
                  tone: AppStatusTone.primary,
                ),
                AppStatusChip(
                  label: _isReadyForExam(snapshot!)
                      ? _passStatusLabel(language)
                      : _repairStatusLabel(language),
                  tone: _isReadyForExam(snapshot!)
                      ? AppStatusTone.success
                      : AppStatusTone.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final area in JlptSkillArea.values) ...[
              _ReadinessBar(
                label: _areaLabel(language, area),
                value: snapshot!.profile.statFor(area).accuracy,
                accent: _areaColor(context, area),
              ),
              if (area != JlptSkillArea.values.last)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        ],
      ),
    );
  }
}

class _ReadinessBar extends StatelessWidget {
  const _ReadinessBar({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final double value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final normalized = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: palette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${(normalized * 100).round()}%',
              style: TextStyle(color: accent, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: palette.outlineSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: normalized,
              child: Container(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({
    required this.language,
    required this.level,
    required this.dueCount,
    required this.dashboard,
    required this.mistakeStream,
  });

  final AppLanguage language;
  final StudyLevel level;
  final int dueCount;
  final DashboardState dashboard;
  final Stream<List<UserMistake>> mistakeStream;

  @override
  Widget build(BuildContext context) {
    return _PrepPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _supportTitle(language),
            caption: _supportCaption(language),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionAccent(accent: context.appPalette.secondary),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<UserMistake>>(
            stream: mistakeStream,
            builder: (context, snapshot) {
              final mistakes = snapshot.data ?? const <UserMistake>[];
              final buckets = computeMistakeDueBuckets(
                mistakes,
                DateTime.now(),
              );

              return Column(
                children: [
                  AppCompactRow(
                    icon: Icons.auto_fix_high_rounded,
                    title: _weakPointsTitle(language),
                    subtitle: _weakPointsSubtitle(language, buckets),
                    status: AppStatusChip(
                      label: mistakes.isEmpty
                          ? _readyShortLabel(language)
                          : '${mistakes.length}',
                      tone: mistakes.isEmpty
                          ? AppStatusTone.success
                          : AppStatusTone.warning,
                    ),
                    onTap: () => context.push('/mistakes'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCompactRow(
                    icon: Icons.hub_rounded,
                    title: _studyLaneTitle(language),
                    subtitle: _studyLaneSubtitle(language, dashboard, dueCount),
                    status: AppStatusChip(
                      label: dueCount > 0
                          ? '$dueCount'
                          : _readyShortLabel(language),
                      tone: dueCount > 0
                          ? AppStatusTone.warning
                          : AppStatusTone.success,
                    ),
                    onTap: () => context.push('/study'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCompactRow(
                    icon: Icons.local_florist_rounded,
                    title: _immersionTitle(language),
                    subtitle: _immersionSubtitle(language, level),
                    status: AppStatusChip(
                      label: level.shortLabel,
                      tone: AppStatusTone.primary,
                    ),
                    onTap: () => context.push('/immersion'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PlanPanel extends StatelessWidget {
  const _PlanPanel({required this.language, required this.snapshot});

  final AppLanguage language;
  final JlptCoachSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return _PrepPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _planTitle(language),
            caption: _planCaption(language),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SectionAccent(accent: context.appPalette.accent),
          const SizedBox(height: AppSpacing.md),
          if (snapshot == null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: HomeSurface.softPanel(
                radius: 22,
                colors: const [Color(0xFFFFFDFA), Color(0xFFF9FBFF)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _planEmptyTitle(language),
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _planEmptyBody(language),
                    style: TextStyle(
                      color: palette.ink.withValues(alpha: 0.72),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final items = snapshot!.plan.items
                    .take(4)
                    .toList(growable: false);
                final columns = constraints.maxWidth >= 620 ? 2 : 1;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - AppSpacing.md) / columns;

                return Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: _PlanCard(language: language, item: item),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.language, required this.item});

  final AppLanguage language;
  final JlptPlanItem item;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final accent = _areaColor(context, item.area);
    final presentation = buildJlptPlanPresentation(
      language: language,
      item: item,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: HomeSurface.softPanel(
        radius: 24,
        colors: [
          Colors.white,
          Color.lerp(palette.base, accent.withValues(alpha: 0.04), 0.5) ??
              palette.base,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 3,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _planDayLabel(language, item.dayOffset),
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: palette.elevated,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.18)),
                ),
                child: Text(
                  presentation.phaseLabel,
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${item.minutes}m',
                style: TextStyle(
                  color: palette.ink.withValues(alpha: 0.52),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            presentation.title,
            style: TextStyle(
              color: palette.ink,
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            presentation.body,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.72),
              height: 1.48,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.push(
              presentation.launchTarget.route,
              extra: presentation.launchTarget.extra,
            ),
            icon: Icon(_iconForArea(item.area), color: accent),
            label: Text(presentation.actionLabel),
          ),
        ],
      ),
    );
  }
}

String _screenTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'JLPT Prep',
  AppLanguage.vi => 'Ôn thi JLPT',
  AppLanguage.ja => 'JLPT試験対策',
};

String _heroEyebrow(AppLanguage language) => switch (language) {
  AppLanguage.en => 'EXAM PREP • JLPT TRACK',
  AppLanguage.vi => 'ÔN THI • JLPT TRACK',
  AppLanguage.ja => '試験対策 • JLPTトラック',
};

String _heroTitle(AppLanguage language, StudyLevel level) => switch (language) {
  AppLanguage.en => 'JLPT ${level.shortLabel} prep hub',
  AppLanguage.vi => 'Hub ôn thi ${level.shortLabel}',
  AppLanguage.ja => '${level.shortLabel} JLPT対策ハブ',
};

String _heroSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'One focused hub for full mock, quick checks, reading drills, diagnosis, and a 7-day repair plan.',
  AppLanguage.vi =>
    'Một hub thống nhất cho thi thử đầy đủ, kiểm tra nhanh, đọc hiểu, chẩn đoán và kế hoạch vá lỗ hổng 7 ngày.',
  AppLanguage.ja => 'フル模試、クイックチェック、読解、診断、7日補強プランをひとつにまとめた入口です。',
};

String _heroReadinessLabel(AppLanguage language, JlptCoachSnapshot? snapshot) {
  if (snapshot == null) {
    return switch (language) {
      AppLanguage.en => 'Need baseline',
      AppLanguage.vi => 'Cần baseline',
      AppLanguage.ja => '基準作成が必要',
    };
  }

  return _isReadyForExam(snapshot)
      ? switch (language) {
          AppLanguage.en => 'Ready to push',
          AppLanguage.vi => 'Sẵn sàng tăng nhịp',
          AppLanguage.ja => '仕上げ段階',
        }
      : switch (language) {
          AppLanguage.en => 'Repair in progress',
          AppLanguage.vi => 'Đang vá lỗ hổng',
          AppLanguage.ja => '補強中',
        };
}

String _heroMetricReadiness(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Readiness',
  AppLanguage.vi => 'Độ sẵn sàng',
  AppLanguage.ja => '準備度',
};

String _heroReadinessValue(AppLanguage language, JlptCoachSnapshot? snapshot) {
  if (snapshot == null) {
    return switch (language) {
      AppLanguage.en => 'First run',
      AppLanguage.vi => 'Lần đầu',
      AppLanguage.ja => '初回',
    };
  }
  final percent = (snapshot.profile.overallAccuracy * 100).round();
  return '$percent%';
}

String _heroMetricFullMock(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Full mock',
  AppLanguage.vi => 'Full mock',
  AppLanguage.ja => 'フル模試',
};

String _heroMetricLevelBank(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Current level bank',
  AppLanguage.vi => 'Bank level hiện tại',
  AppLanguage.ja => '現在レベルのバンク',
};

String _heroBoardLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'EXAM SNAPSHOT',
  AppLanguage.vi => 'TÓM TẮT NHANH',
  AppLanguage.ja => '試験スナップショット',
};

String _loadingLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Loading',
  AppLanguage.vi => 'Đang tải',
  AppLanguage.ja => '読み込み中',
};

String _startFullMockLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start full mock',
  AppLanguage.vi => 'Bắt đầu full mock',
  AppLanguage.ja => 'フル模試を開始',
};

String _startReadingLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Start reading drill',
  AppLanguage.vi => 'Mở reading drill',
  AppLanguage.ja => '読解ドリルへ',
};

String _modesTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Exam modes',
  AppLanguage.vi => 'Chế độ ôn thi',
  AppLanguage.ja => '試験モード',
};

String _modesCaption(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'Everything below stays locked to ${level.shortLabel}, so mock, reading, and diagnosis all speak the same level.',
  AppLanguage.vi =>
    'Tất cả chế độ bên dưới đều bám đúng ${level.shortLabel}, để thi thử, đọc hiểu và chẩn đoán nói cùng một mức độ.',
  AppLanguage.ja =>
    '下のモードはすべて ${level.shortLabel} にそろえてあり、模試・読解・診断が同じ難度でつながります。',
};

String _fullMockTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Full mock',
  AppLanguage.vi => 'Thi thử đầy đủ',
  AppLanguage.ja => 'フル模試',
};

String _fullMockSubtitle(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Run the full exam flow with section timing, scoring, and instant diagnosis.',
  AppLanguage.vi =>
    'Chạy đủ luồng thi với timer theo từng phần, chấm điểm và chẩn đoán ngay.',
  AppLanguage.ja => 'セクション時間、採点、診断つきで本番に近い流れを回します。',
};

String _quickMockTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Quick mock',
  AppLanguage.vi => 'Kiểm tra nhanh',
  AppLanguage.ja => 'クイック模試',
};

String _quickMockSubtitle(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'A shorter timed check built from the ${level.shortLabel} vocabulary bank already in the app.',
  AppLanguage.vi =>
    'Bài kiểm tra ngắn có bấm giờ, dùng từ vựng ${level.shortLabel} đã có sẵn trong app.',
  AppLanguage.ja => 'アプリ内の ${level.shortLabel} 語彙バンクから作る短い時間制チェックです。',
};

String _quickMockMeta(AppLanguage language, int questionCount) =>
    switch (language) {
      AppLanguage.en => '$questionCount questions ready from your level bank',
      AppLanguage.vi => '$questionCount câu hỏi sẵn sàng từ bank hiện tại',
      AppLanguage.ja => '$questionCount 問を現在レベルから使用',
    };

String _comingSoonLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No bank yet',
  AppLanguage.vi => 'Chưa có bank',
  AppLanguage.ja => '未準備',
};

String _readingDrillTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Reading drill',
  AppLanguage.vi => 'Đọc hiểu mục tiêu',
  AppLanguage.ja => '読解ドリル',
};

String _readingDrillSubtitle(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'Practice timed passages that stay on the ${level.shortLabel} track only.',
  AppLanguage.vi =>
    'Luyện bài đọc có bấm giờ, chỉ giữ đúng track ${level.shortLabel}.',
  AppLanguage.ja => '${level.shortLabel} だけに絞った時間つき読解を回します。',
};

String _readingDrillMeta(
  AppLanguage language, {
  required int passages,
  required int questions,
}) => switch (language) {
  AppLanguage.en => '$passages passages • $questions questions',
  AppLanguage.vi => '$passages bài đọc • $questions câu hỏi',
  AppLanguage.ja => '$passages 本 • $questions 問',
};

String _readinessTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Readiness and diagnosis',
  AppLanguage.vi => 'Độ sẵn sàng và chẩn đoán',
  AppLanguage.ja => '準備度と診断',
};

String _readinessCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Your latest exam baseline is translated into skill-by-skill weak points.',
  AppLanguage.vi =>
    'Baseline gần nhất được đổi thành các điểm yếu rõ ràng theo từng kỹ năng.',
  AppLanguage.ja => '直近の結果を技能ごとの弱点として見やすく整理します。',
};

String _readinessEmptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'No personal baseline yet',
  AppLanguage.vi => 'Chưa có baseline cá nhân',
  AppLanguage.ja => '個人ベースラインはまだありません',
};

String _readinessEmptyBody(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Finish one reading drill or one full mock and this area will turn into a personalized readiness map with a repair plan.',
  AppLanguage.vi =>
    'Hoàn thành 1 bài reading drill hoặc 1 full mock, khu vực này sẽ đổi thành readiness map và kế hoạch sửa lỗ hổng cho riêng bạn.',
  AppLanguage.ja => '読解ドリルかフル模試を1回終えると、ここが個別の準備度マップと補強プランに変わります。',
};

String _baselineChip(AppLanguage language) => switch (language) {
  AppLanguage.en => 'First run creates the baseline',
  AppLanguage.vi => 'Lần đầu sẽ tạo baseline',
  AppLanguage.ja => '初回で基準を作成',
};

String _passRuleLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Pass rule: 60% overall, no area below 40%',
  AppLanguage.vi => 'Mốc đạt: tổng 60%, không kỹ năng nào dưới 40%',
  AppLanguage.ja => '合格目安: 総合60%、各技能40%以上',
};

String _readinessSummary(AppLanguage language, JlptCoachSnapshot snapshot) {
  final percent = (snapshot.profile.overallAccuracy * 100).round();
  return _isReadyForExam(snapshot)
      ? switch (language) {
          AppLanguage.en => '$percent% readiness • projected pass zone',
          AppLanguage.vi => '$percent% độ sẵn sàng • đang ở ngưỡng đậu',
          AppLanguage.ja => '準備度 $percent% • 合格圏',
        }
      : switch (language) {
          AppLanguage.en => '$percent% readiness • still needs repair',
          AppLanguage.vi => '$percent% độ sẵn sàng • vẫn cần vá thêm',
          AppLanguage.ja => '準備度 $percent% • まだ補強が必要',
        };
}

String _snapshotSourceLabel(AppLanguage language, String source) {
  switch (source) {
    case 'jlpt_mock_pro':
      return switch (language) {
        AppLanguage.en => 'Source: full mock',
        AppLanguage.vi => 'Nguồn: full mock',
        AppLanguage.ja => '元データ: フル模試',
      };
    case 'jlpt_reading':
      return switch (language) {
        AppLanguage.en => 'Source: reading drill',
        AppLanguage.vi => 'Nguồn: reading drill',
        AppLanguage.ja => '元データ: 読解ドリル',
      };
    default:
      return switch (language) {
        AppLanguage.en => 'Source: JLPT prep',
        AppLanguage.vi => 'Nguồn: JLPT prep',
        AppLanguage.ja => '元データ: JLPT対策',
      };
  }
}

String _lastUpdatedLabel(AppLanguage language, DateTime date) {
  final text =
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  return switch (language) {
    AppLanguage.en => 'Updated $text',
    AppLanguage.vi => 'Cập nhật $text',
    AppLanguage.ja => '$text 更新',
  };
}

String _passStatusLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Projected pass',
  AppLanguage.vi => 'Dự đoán đạt',
  AppLanguage.ja => '合格予測',
};

String _repairStatusLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Repair first',
  AppLanguage.vi => 'Cần sửa trước',
  AppLanguage.ja => '先に補強',
};

String _supportTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Support lanes',
  AppLanguage.vi => 'Lane hỗ trợ',
  AppLanguage.ja => '補助レーン',
};

String _supportCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'These lanes help you repair what the mock and reading flow expose.',
  AppLanguage.vi =>
    'Đây là các lane để vá lại những chỗ mock và reading đang làm lộ ra.',
  AppLanguage.ja => '模試や読解で出た弱点を、ここから埋め直します。',
};

String _weakPointsTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Weak points notebook',
  AppLanguage.vi => 'Sổ tay điểm yếu',
  AppLanguage.ja => '弱点ノート',
};

String _weakPointsSubtitle(
  AppLanguage language,
  MistakeDueBuckets buckets,
) => switch (language) {
  AppLanguage.en =>
    buckets.totalDue > 0
        ? 'D1 ${buckets.due1d} • D3 ${buckets.due3d} • D7 ${buckets.due7d} are ready for repair.'
        : 'No urgent weak points right now. Keep this lane for post-mock repair.',
  AppLanguage.vi =>
    buckets.totalDue > 0
        ? 'D1 ${buckets.due1d} • D3 ${buckets.due3d} • D7 ${buckets.due7d} đang chờ xử lý.'
        : 'Chưa có điểm yếu gấp. Giữ lane này để sửa sau mỗi lần mock.',
  AppLanguage.ja =>
    buckets.totalDue > 0
        ? 'D1 ${buckets.due1d} • D3 ${buckets.due3d} • D7 ${buckets.due7d} を補強できます。'
        : '今すぐ直す弱点はありません。模試後の補強用に残しておけます。',
};

String _readyShortLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Ready',
  AppLanguage.vi => 'Sẵn sàng',
  AppLanguage.ja => '準備OK',
};

String _studyLaneTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Focused drill hub',
  AppLanguage.vi => 'Hub drill tập trung',
  AppLanguage.ja => '集中ドリルハブ',
};

String _studyLaneSubtitle(
  AppLanguage language,
  DashboardState dashboard,
  int dueCount,
) => switch (language) {
  AppLanguage.en =>
    dueCount > 0
        ? 'Due now: vocab ${dashboard.vocabDue} • grammar ${dashboard.grammarDue} • kanji ${dashboard.kanjiDue}.'
        : 'Queue is calm, so this is a clean place to tighten weak skills between mock runs.',
  AppLanguage.vi =>
    dueCount > 0
        ? 'Đến hạn: từ vựng ${dashboard.vocabDue} • ngữ pháp ${dashboard.grammarDue} • kanji ${dashboard.kanjiDue}.'
        : 'Hàng đợi đang nhẹ, hợp để siết các kỹ năng yếu giữa hai lần thi thử.',
  AppLanguage.ja =>
    dueCount > 0
        ? '期限あり: 語彙 ${dashboard.vocabDue} • 文法 ${dashboard.grammarDue} • 漢字 ${dashboard.kanjiDue}'
        : 'キューが落ち着いているので、模試の合間の補強に向いています。',
};

String _immersionTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Reading speed lab',
  AppLanguage.vi => 'Phòng tăng tốc đọc',
  AppLanguage.ja => '読解スピードラボ',
};

String _immersionSubtitle(
  AppLanguage language,
  StudyLevel level,
) => switch (language) {
  AppLanguage.en =>
    'Read real Japanese on the ${level.shortLabel} lane, save words, and keep exam stamina natural.',
  AppLanguage.vi =>
    'Đọc tiếng Nhật thật trên lane ${level.shortLabel}, lưu từ và giữ sức bền khi vào đề.',
  AppLanguage.ja => '${level.shortLabel} レーンで実際の日本語を読み、語彙を保存しながら本番の持久力を整えます。',
};

String _planTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => '7-day repair plan',
  AppLanguage.vi => 'Kế hoạch vá lỗ hổng 7 ngày',
  AppLanguage.ja => '7日補強プラン',
};

String _planCaption(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Use the latest diagnosis to decide what to sharpen before the next mock.',
  AppLanguage.vi =>
    'Dùng chẩn đoán gần nhất để chốt xem cần sharpen điều gì trước lần mock tiếp theo.',
  AppLanguage.ja => '直近の診断をもとに、次の模試までに何を磨くかを決めます。',
};

String _planEmptyTitle(AppLanguage language) => switch (language) {
  AppLanguage.en => 'The plan unlocks after your first serious run',
  AppLanguage.vi => 'Kế hoạch sẽ mở sau lần chạy nghiêm túc đầu tiên',
  AppLanguage.ja => '最初の本格ランのあとにプランが開きます',
};

String _planEmptyBody(AppLanguage language) => switch (language) {
  AppLanguage.en =>
    'Once you finish a reading drill or full mock, this area becomes a compact plan that tells you what to repair day by day.',
  AppLanguage.vi =>
    'Sau khi bạn xong reading drill hoặc full mock, khu vực này sẽ thành một plan gọn, chỉ rõ mỗi ngày nên sửa cái gì.',
  AppLanguage.ja => '読解ドリルかフル模試を終えると、ここが日ごとの補強プランに変わります。',
};

String _planDayLabel(AppLanguage language, int dayOffset) => switch (language) {
  AppLanguage.en => 'Day ${dayOffset + 1}',
  AppLanguage.vi => 'Ngày ${dayOffset + 1}',
  AppLanguage.ja => '${dayOffset + 1}日目',
};

String _openLaneLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Open lane',
  AppLanguage.vi => 'Mở lane',
  AppLanguage.ja => '開く',
};

String _preparingDataLabel(AppLanguage language) => switch (language) {
  AppLanguage.en => 'Preparing data',
  AppLanguage.vi => 'Đang chuẩn bị dữ liệu',
  AppLanguage.ja => 'データ準備中',
};

String _areaLabel(AppLanguage language, JlptSkillArea area) => switch (area) {
  JlptSkillArea.vocabulary => switch (language) {
    AppLanguage.en => 'Vocabulary',
    AppLanguage.vi => 'Từ vựng',
    AppLanguage.ja => '語彙',
  },
  JlptSkillArea.grammar => switch (language) {
    AppLanguage.en => 'Grammar',
    AppLanguage.vi => 'Ngữ pháp',
    AppLanguage.ja => '文法',
  },
  JlptSkillArea.kanji => switch (language) {
    AppLanguage.en => 'Kanji',
    AppLanguage.vi => 'Kanji',
    AppLanguage.ja => '漢字',
  },
  JlptSkillArea.reading => switch (language) {
    AppLanguage.en => 'Reading',
    AppLanguage.vi => 'Đọc hiểu',
    AppLanguage.ja => '読解',
  },
};

IconData _iconForArea(JlptSkillArea area) {
  switch (area) {
    case JlptSkillArea.vocabulary:
      return Icons.translate_rounded;
    case JlptSkillArea.grammar:
      return Icons.auto_fix_high_rounded;
    case JlptSkillArea.kanji:
      return Icons.draw_rounded;
    case JlptSkillArea.reading:
      return Icons.menu_book_rounded;
  }
}

Color _areaColor(BuildContext context, JlptSkillArea area) {
  final palette = context.appPalette;
  switch (area) {
    case JlptSkillArea.vocabulary:
      return palette.info;
    case JlptSkillArea.grammar:
      return palette.accent;
    case JlptSkillArea.kanji:
      return palette.warning;
    case JlptSkillArea.reading:
      return palette.secondary;
  }
}

bool _isReadyForExam(JlptCoachSnapshot snapshot) {
  if (snapshot.profile.overallAccuracy < 0.60) {
    return false;
  }
  for (final area in JlptSkillArea.values) {
    if (snapshot.profile.statFor(area).accuracy < 0.40) {
      return false;
    }
  }
  return true;
}

const _emptyDashboardState = DashboardState(
  streak: 0,
  todayXp: 0,
  vocabDue: 0,
  grammarDue: 0,
  kanjiDue: 0,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);
