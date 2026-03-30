part of 'vocab_screen.dart';

class _VocabCatalogBody extends ConsumerWidget {
  const _VocabCatalogBody({
    required this.language,
    required this.sections,
    required this.home,
  });

  final AppLanguage language;
  final List<_VocabCatalogSection> sections;
  final VocabHomeSection home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(studyLevelProvider);
    final totalPrograms = sections.fold<int>(
      0,
      (sum, section) => sum + section.programs.length,
    );
    final livePrograms = sections
        .expand((section) => section.programs)
        .where((program) => program.isInteractive)
        .length;
    final totalTerms = sections
        .expand((section) => section.programs)
        .where((program) => program.termCount > 0)
        .fold<int>(0, (sum, program) => sum + program.termCount);
    final liveSections = sections
        .where((section) => section.levelCode == 'N5' || section.levelCode == 'N4')
        .toList(growable: false);
    final previewSections = sections
        .where((section) => section.levelCode != 'N5' && section.levelCode != 'N4')
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VocabTodaySection(
          key: const ValueKey('vocab_today_section'),
          language: language,
          home: home,
        ),
        const SizedBox(height: AppSpacing.xl),
        _VocabHero(
          key: const ValueKey('vocab_catalog_hero'),
          language: language,
          selectedLevel: selectedLevel,
          totalPrograms: totalPrograms,
          livePrograms: livePrograms,
          totalTerms: totalTerms,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppSectionHeader(
          title: _liveCatalogTitle(language),
          caption: _liveCatalogCaption(language),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final section in liveSections) ...[
          _VocabSection(
            key: ValueKey('section_${section.key}'),
            section: section,
            language: language,
            onProgramTap: (program) =>
                _openProgram(context, ref, section, program),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        AppSectionHeader(
          title: _previewCatalogTitle(language),
          caption: _previewCatalogCaption(language),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final section in previewSections) ...[
          _VocabSection(
            key: ValueKey('section_${section.key}'),
            section: section,
            language: language,
            onProgramTap: (program) =>
                _openProgram(context, ref, section, program),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
    );
  }

  void _openProgram(
    BuildContext context,
    WidgetRef ref,
    _VocabCatalogSection section,
    _VocabCatalogProgram program,
  ) {
    final language = ref.read(appLanguageProvider);
    if (!program.isInteractive) {
      if (!program.isPreviewOnly) return;
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_previewDialogTitle(language)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${program.titleTop} ? ${program.titleMain}',
                style: Theme.of(
                  dialogContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(_programCountLabel(program, language)),
              if (program.chapterCount != null) ...[
                const SizedBox(height: 6),
                Text(_chapterSummaryLabel(program.chapterCount!, language)),
              ],
              const SizedBox(height: 12),
              Text(_previewDialogBody(language, program)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_previewDialogClose(language)),
            ),
          ],
        ),
      );
      return;
    }
    final level = StudyLevel.fromCode(section.levelCode);
    if (level == null) return;
    ref.read(studyLevelProvider.notifier).state = level;

    final minnaRange = _minnaLessonRange(section.levelCode, program.type);
    if (minnaRange != null) {
      final uri = Uri(
        path: '/vocab/minna',
        queryParameters: {
          'level': section.levelCode,
          'title': program.titleTop,
          'subtitle': _localizedProgramSubtitle(program, language),
          'lessonStart': '${minnaRange.$1}',
          'lessonEnd': '${minnaRange.$2}',
        },
      );
      context.push(uri.toString());
      return;
    }

    if (program.type == _VocabProgramType.core) {
      final uri = Uri(
        path: '/vocab/hajimete',
        queryParameters: {
          'level': section.levelCode,
          'title': '${program.titleTop} ${program.titleMain}'.trim(),
          'subtitle': _localizedProgramSubtitle(program, language),
        },
      );
      context.push(uri.toString());
      return;
    }

    context.push(
      '/vocab/review',
      extra: VocabReviewArgs(
        source: 'catalog',
        levelCode: section.levelCode,
        title: '${program.titleTop} ${program.titleMain}'.trim(),
        subtitle: _localizedProgramSubtitle(program, language),
      ),
    );
  }
}

class _VocabHero extends StatelessWidget {
  const _VocabHero({
    super.key,
    required this.language,
    required this.selectedLevel,
    required this.totalPrograms,
    required this.livePrograms,
    required this.totalTerms,
  });

  final AppLanguage language;
  final StudyLevel? selectedLevel;
  final int totalPrograms;
  final int livePrograms;
  final int totalTerms;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 980;
    final palette = context.appPalette;

    return AppSectionCard(
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _HeroCopy(
                    language: language,
                    selectedLevel: selectedLevel,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  flex: 4,
                  child: _HeroMetricsPanel(
                    language: language,
                    totalPrograms: totalPrograms,
                    livePrograms: livePrograms,
                    totalTerms: totalTerms,
                    palette: palette,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(language: language, selectedLevel: selectedLevel),
                const SizedBox(height: AppSpacing.lg),
                _HeroMetricsPanel(
                  language: language,
                  totalPrograms: totalPrograms,
                  livePrograms: livePrograms,
                  totalTerms: totalTerms,
                  palette: palette,
                ),
              ],
            ),
    );
  }
}

class _VocabTodaySection extends ConsumerWidget {
  const _VocabTodaySection({
    super.key,
    required this.language,
    required this.home,
  });

  final AppLanguage language;
  final VocabHomeSection home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = home.recommendedTrack;
    final reviewArgs = VocabReviewArgs(
      source: 'today',
      levelCode: home.selectedLevelCode,
      title: _todayReviewTitle(language, home.selectedLevelCode),
      subtitle: _todayReviewSubtitle(language, home.dueCount, home.nextReview),
    );

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: _todayTitle(language),
            caption: _todayCaption(language),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _TodayMetric(
                key: const ValueKey('vocab_today_due'),
                label: _dueNowLabel(language),
                value: '${home.dueCount}',
              ),
              _TodayMetric(
                key: const ValueKey('vocab_today_lane'),
                label: _activeLaneLabel(language),
                value: home.selectedLevelCode,
              ),
              _TodayMetric(
                key: const ValueKey('vocab_today_next'),
                label: _nextWindowLabel(language),
                value: _formatReviewTiming(home.nextReview),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              FilledButton.icon(
                key: const ValueKey('vocab_today_review_cta'),
                onPressed: () => context.push('/vocab/review', extra: reviewArgs),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(_reviewNowLabel(language)),
              ),
              if (recommended != null && recommended.isCompanion)
                OutlinedButton.icon(
                  key: const ValueKey('vocab_today_companion_cta'),
                  onPressed: () => _openCompanion(context, recommended),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(recommended.title),
                )
              else if (home.liveTracks.any((track) => track.isCompanion))
                OutlinedButton.icon(
                  key: const ValueKey('vocab_today_companion_cta'),
                  onPressed: () => _openCompanion(
                    context,
                    home.liveTracks.firstWhere((track) =>
                        track.levelCode == home.selectedLevelCode &&
                        track.isCompanion),
                  ),
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(_companionShortcutLabel(language)),
                ),
            ],
          ),
          if (recommended != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              _currentTrackLine(language, recommended),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  void _openCompanion(BuildContext context, VocabTrackSummary track) {
    final range = track.levelCode == 'N5' ? (1, 25) : (26, 50);
    final uri = Uri(
      path: '/vocab/minna',
      queryParameters: {
        'level': track.levelCode,
        'title': track.title,
        'subtitle': track.subtitle,
        'lessonStart': '${range.$1}',
        'lessonEnd': '${range.$2}',
      },
    );
    context.push(uri.toString());
  }
}

class _TodayMetric extends StatelessWidget {
  const _TodayMetric({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appPalette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.language, required this.selectedLevel});

  final AppLanguage language;
  final StudyLevel? selectedLevel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
              height: 1.12,
            ),
            children: [
              TextSpan(
                text: _heroHighlight(language),
                style: TextStyle(
                  color: palette.primary,
                  backgroundColor: palette.primary.withValues(alpha: 0.15),
                ),
              ),
              TextSpan(text: _heroTitle(language)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _heroSubtitle(language),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: palette.ink.withValues(alpha: 0.82),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _heroDescription(language),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: palette.ink.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
            height: 1.55,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusChip(
              label: selectedLevel == null
                  ? _heroScopeAllLabel(language)
                  : _heroScopeLevelLabel(language, selectedLevel!.shortLabel),
              tone: AppStatusTone.primary,
            ),
            AppStatusChip(
              label: _heroMemoryLabel(language),
              tone: AppStatusTone.success,
            ),
            AppStatusChip(
              label: _heroUsageLabel(language),
              tone: AppStatusTone.neutral,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroMetricsPanel extends StatelessWidget {
  const _HeroMetricsPanel({
    required this.language,
    required this.totalPrograms,
    required this.livePrograms,
    required this.totalTerms,
    required this.palette,
  });

  final AppLanguage language;
  final int totalPrograms;
  final int livePrograms;
  final int totalTerms;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            palette.primary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.outline.withValues(alpha: 0.95)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _heroPanelTitle(language),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: palette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _heroPanelSubtitle(language),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.ink.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _HeroMetricTile(
                  label: _heroMetricPrograms(language),
                  value: '$totalPrograms',
                  accent: palette.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HeroMetricTile(
                  label: _heroMetricLive(language),
                  value: '$livePrograms',
                  accent: palette.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _HeroMetricStrip(
            label: _heroMetricTerms(language),
            value: _formatNumber(totalTerms),
            accent: palette.warning,
          ),
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HeroMetricStrip extends StatelessWidget {
  const _HeroMetricStrip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabSection extends StatelessWidget {
  const _VocabSection({
    super.key,
    required this.section,
    required this.language,
    required this.onProgramTap,
  });

  final _VocabCatalogSection section;
  final AppLanguage language;
  final ValueChanged<_VocabCatalogProgram> onProgramTap;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1040;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(section: section, language: language),
        const SizedBox(height: AppSpacing.md),
        if (isWide)
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: [
              for (final program in section.programs)
                SizedBox(
                  width: _cardWidth(section.programs.length),
                  child: _ProgramCard(
                    section: section,
                    program: program,
                    language: language,
                    onTap: () => onProgramTap(program),
                  ),
                ),
            ],
          )
        else
          Column(
            children: [
              for (final program in section.programs) ...[
                _ProgramCard(
                  section: section,
                  program: program,
                  language: language,
                  onTap: () => onProgramTap(program),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
      ],
    );
  }
}

double _cardWidth(int count) {
  if (count == 1) return 460;
  if (count == 2) return 432;
  return 286;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section, required this.language});

  final _VocabCatalogSection section;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final liveCount = section.programs
        .where((program) => program.isInteractive)
        .length;
    final palette = context.appPalette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 44,
          decoration: BoxDecoration(
            color: section.accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    section.levelCode,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppStatusChip(
                    label: liveCount > 0
                        ? _availableNowLabel(language)
                        : _comingSoonLabel(language),
                    tone: liveCount > 0
                        ? AppStatusTone.success
                        : AppStatusTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _localizedSectionSubtitle(section, language),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.ink.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return switch (program.type) {
      _VocabProgramType.core => _CoreProgramCard(
        section: section,
        program: program,
        language: language,
        onTap: onTap,
      ),
      _VocabProgramType.minna ||
      _VocabProgramType.shinkanzen ||
      _VocabProgramType.listening => _CompanionProgramCard(
        section: section,
        program: program,
        language: language,
        onTap: onTap,
      ),
      _VocabProgramType.advanced ||
      _VocabProgramType.specialized => _GlassProgramCard(
        section: section,
        program: program,
        language: language,
        onTap: onTap,
      ),
    };
  }
}

class _CoreProgramCard extends StatelessWidget {
  const _CoreProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = program.isInteractive || program.isPreviewOnly;

    return InkWell(
      key: ValueKey('program_${section.key}_${program.key}'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(26),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.9,
        duration: const Duration(milliseconds: 180),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [section.accent, section.accent.withValues(alpha: 0.82)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: section.accent.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ProgramTypeBadge(
                      label: _trackLabel(language),
                      accent: section.accent,
                    ),
                    const Spacer(),
                    AppStatusChip(
                      label: _badgeLabel(program, language),
                      tone: enabled
                          ? AppStatusTone.primary
                          : AppStatusTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  program.titleTop,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.ink.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      program.titleMain,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            color: palette.primary,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _programCountLabel(program, language),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: palette.ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _localizedProgramSubtitle(program, language),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: palette.ink.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaPill(
                      icon: Icons.auto_awesome_rounded,
                      label: _meaningFirstLabel(language),
                    ),
                    _MetaPill(
                      icon: Icons.route_rounded,
                      label: _usageFlowLabel(language),
                    ),
                    _MetaPill(
                      icon: Icons.memory_rounded,
                      label: _programAvailabilityPill(program, language),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: enabled ? onTap : null,
                        icon: Icon(
                          program.isInteractive
                              ? Icons.play_arrow_rounded
                              : program.isPreviewOnly
                              ? Icons.visibility_rounded
                              : Icons.lock_clock_rounded,
                        ),
                        label: Text(
                          program.isInteractive
                              ? _openLaneLabel(language)
                              : _previewLabel(language),
                        ),
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

class _CompanionProgramCard extends StatelessWidget {
  const _CompanionProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = program.isInteractive || program.isPreviewOnly;
    final footerColor = program.type == _VocabProgramType.listening
        ? const Color(0xFF2F9A8F)
        : const Color(0xFF67C778);

    return InkWell(
      key: ValueKey('program_${section.key}_${program.key}'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.9,
        duration: const Duration(milliseconds: 180),
        child: Container(
          decoration: BoxDecoration(
            color: palette.elevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: palette.outline.withValues(alpha: 0.95),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: palette.ink.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ProgramTypeBadge(
                          label: _programTypeLabel(program.type, language),
                          accent: section.accent,
                        ),
                        const Spacer(),
                        AppStatusChip(
                          label: _badgeLabel(program, language),
                          tone: program.isComingSoon
                              ? AppStatusTone.neutral
                              : program.isPreviewOnly
                              ? AppStatusTone.primary
                              : AppStatusTone.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: footerColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            program.type == _VocabProgramType.listening
                                ? Icons.headphones_rounded
                                : Icons.menu_book_rounded,
                            color: footerColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                program.titleTop,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: palette.ink,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _localizedProgramSubtitle(program, language),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: palette.ink.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                      height: 1.45,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: footerColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _programCountLabel(program, language),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Text(
                          program.titleMain,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _programFooterHint(program.type, language),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.94),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: enabled ? onTap : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      icon: Icon(
                        program.isInteractive
                            ? Icons.north_east_rounded
                            : program.isPreviewOnly
                            ? Icons.visibility_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      label: Text(
                        program.isInteractive
                            ? _joinTrackLabel(language)
                            : _previewLabel(language),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassProgramCard extends StatelessWidget {
  const _GlassProgramCard({
    required this.section,
    required this.program,
    required this.language,
    required this.onTap,
  });

  final _VocabCatalogSection section;
  final _VocabCatalogProgram program;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final enabled = program.isInteractive || program.isPreviewOnly;

    return InkWell(
      key: ValueKey('program_${section.key}_${program.key}'),
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.74),
              section.accent.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: palette.outline.withValues(alpha: 0.9),
            width: 1.4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProgramTypeBadge(
                    label: _programTypeLabel(program.type, language),
                    accent: section.accent,
                  ),
                  const Spacer(),
                  AppStatusChip(
                    label: _badgeLabel(program, language),
                    tone: program.isComingSoon
                        ? AppStatusTone.neutral
                        : program.isPreviewOnly
                        ? AppStatusTone.primary
                        : AppStatusTone.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                program.titleTop,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.ink.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                program.titleMain,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: section.accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _programCountLabel(program, language),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _localizedProgramSubtitle(program, language),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: palette.ink.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                  height: 1.48,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(color: palette.outline.withValues(alpha: 0.8), height: 1),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: section.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _programFooterHint(program.type, language),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.ink.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _ProgramTypeBadge extends StatelessWidget {
  const _ProgramTypeBadge({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.outlineSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.ink.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabCatalogSection {
  const _VocabCatalogSection({
    required this.key,
    required this.levelCode,
    required this.subtitle,
    required this.accent,
    required this.programs,
  });

  final String key;
  final String levelCode;
  final String subtitle;
  final Color accent;
  final List<_VocabCatalogProgram> programs;
}

enum _VocabProgramType {
  core,
  minna,
  shinkanzen,
  listening,
  advanced,
  specialized,
}

class _VocabCatalogProgram {
  const _VocabCatalogProgram({
    required this.key,
    required this.titleTop,
    required this.titleMain,
    required this.termCount,
    required this.subtitle,
    required this.type,
    required this.isInteractive,
    this.chapterCount,
    this.previewBody,
    this.isComingSoon = false,
    this.badgeText,
  });

  final String key;
  final String titleTop;
  final String titleMain;
  final int termCount;
  final int? chapterCount;
  final String subtitle;
  final String? previewBody;
  final _VocabProgramType type;
  final bool isInteractive;
  final bool isComingSoon;
  final String? badgeText;

  bool get hasData => termCount > 0;
  bool get isPreviewOnly => hasData && !isInteractive;
}

_VocabCatalogSection _buildJlptSection({
  required String levelCode,
  required List<VocabItem> items,
  required int dueCount,
  required DateTime? nextReview,
  required Color accent,
  required String companionTitle,
  required String companionSubtitle,
  required _VocabProgramType companionType,
  int? companionCountOverride,
  int? companionStructureCount,
  String? companionPreviewBody,
  required bool isInteractive,
  List<_VocabCatalogProgram> extraPrograms = const [],
}) {
  final liveCount = items.length;
  final chapterCount = _chapterCountForLevel(levelCode);
  final coreInteractive =
      isInteractive && StudyLevel.fromCode(levelCode) != null && liveCount > 0;
  final coreBadge = dueCount > 0
      ? '$dueCount due ? ${_formatReviewTiming(nextReview)}'
      : _formatReviewTiming(nextReview);
  final companionTermCount = companionCountOverride ?? 0;
  final companionInteractive =
      isInteractive &&
      companionTermCount > 0 &&
      (companionType == _VocabProgramType.shinkanzen ||
          _minnaLessonRange(levelCode, companionType) != null);

  return _VocabCatalogSection(
    key: levelCode.toLowerCase(),
    levelCode: levelCode,
    subtitle: 'JLPT $levelCode vocabulary lane',
    accent: accent,
    programs: [
      _VocabCatalogProgram(
        key: '${levelCode.toLowerCase()}_core',
        titleTop: 'Hajimete no Nihongo Tango',
        titleMain: levelCode,
        termCount: liveCount,
        chapterCount: chapterCount,
        subtitle:
            'Chapter-based Hajimete track for $levelCode with seeded catalog data.',
        type: _VocabProgramType.core,
        isInteractive: coreInteractive,
        isComingSoon: liveCount == 0,
        badgeText: coreInteractive ? coreBadge : null,
      ),
      _VocabCatalogProgram(
        key: '${levelCode.toLowerCase()}_companion',
        titleTop: companionTitle,
        titleMain: levelCode,
        termCount: companionTermCount,
        chapterCount: companionStructureCount,
        subtitle: companionSubtitle,
        previewBody: companionPreviewBody,
        type: companionType,
        isInteractive: companionInteractive,
        isComingSoon: companionTermCount == 0,
        badgeText: companionTermCount > 0 ? _programBadge(companionType) : null,
      ),
      ...extraPrograms,
    ],
  );
}

