import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';
import 'package:jpstudy/features/legal/legal_document_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final void Function(StudyLevel level, StudyGoal goal) onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  StudyLevel? _selectedLevel;
  StudyGoal? _selectedGoal;

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    if (reducedMotionEnabled(context)) {
      _controller.jumpToPage(page);
      return;
    }
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      body: JapaneseBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              _ProgressDots(current: _currentPage, total: 3),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _LevelPage(
                      language: language,
                      onSelected: (level) {
                        setState(() => _selectedLevel = level);
                        _goToPage(1);
                      },
                    ),
                    _GoalPage(
                      language: language,
                      selected: _selectedGoal,
                      onSelected: (goal) =>
                          setState(() => _selectedGoal = goal),
                      onNext: () => _goToPage(2),
                      onBack: () => _goToPage(0),
                    ),
                    _FirstWinPage(
                      language: language,
                      level: _selectedLevel,
                      goal: _selectedGoal,
                      onStart: () =>
                          widget.onComplete(_selectedLevel!, _selectedGoal!),
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

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: reducedMotionDuration(
            context,
            const Duration(milliseconds: 200),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? context.appPalette.primary
                : context.appPalette.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _LevelPage extends StatelessWidget {
  const _LevelPage({required this.language, required this.onSelected});

  final AppLanguage language;
  final ValueChanged<StudyLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          language.onboardingWelcomeTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.appPalette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          language.onboardingWelcomeSubtitle,
          style: TextStyle(
            fontSize: 15,
            color: context.appPalette.ink.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        LegalDocumentLinks(language: language, compact: true),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          language.onboardingLevelTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.appPalette.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...StudyLevel.values.map(
          (level) => _OnboardingLevelCard(
            level: level,
            language: language,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}

class _OnboardingLevelCard extends StatelessWidget {
  const _OnboardingLevelCard({
    required this.level,
    required this.language,
    required this.onSelected,
  });

  final StudyLevel level;
  final AppLanguage language;
  final ValueChanged<StudyLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appPalette.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appPalette.outline),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: context.appPalette.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.folder_open, color: context.appPalette.primary),
        ),
        title: Text(
          level.shortLabel,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          level.description(language),
          style: TextStyle(
            color: context.appPalette.ink.withValues(alpha: 0.55),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelected(level),
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  const _GoalPage({
    required this.language,
    required this.selected,
    required this.onSelected,
    required this.onNext,
    required this.onBack,
  });

  final AppLanguage language;
  final StudyGoal? selected;
  final ValueChanged<StudyGoal> onSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: context.appPalette.ink.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                language.onboardingGoalTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.appPalette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ...StudyGoal.values.map(
            (goal) => _GoalCard(
              goal: goal,
              language: language,
              isSelected: selected == goal,
              onTap: () => onSelected(goal),
            ),
          ),
          const Spacer(),
          ClayButton(
            key: const ValueKey('onboarding_goal_next'),
            label: language.onboardingNextButton,
            style: ClayButtonStyle.primary,
            isExpanded: true,
            onPressed: selected != null ? onNext : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final StudyGoal goal;
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: reducedMotionDuration(
          context,
          const Duration(milliseconds: 150),
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appPalette.primary.withValues(alpha: 0.08)
              : context.appPalette.elevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.appPalette.primary
                : context.appPalette.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.appPalette.primary.withValues(alpha: 0.15)
                    : context.appPalette.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(goal.icon, color: context.appPalette.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.label(language),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? context.appPalette.primary
                          : context.appPalette.ink,
                    ),
                  ),
                  Text(
                    goal.description(language),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appPalette.ink.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: context.appPalette.primary),
          ],
        ),
      ),
    );
  }
}

class _FirstWinPage extends ConsumerStatefulWidget {
  const _FirstWinPage({
    required this.language,
    required this.level,
    required this.goal,
    required this.onStart,
  });

  final AppLanguage language;
  final StudyLevel? level;
  final StudyGoal? goal;
  final VoidCallback onStart;

  @override
  ConsumerState<_FirstWinPage> createState() => _FirstWinPageState();
}

class _FirstWinPageState extends ConsumerState<_FirstWinPage> {
  int? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;
  late Future<List<VocabItem>> _previewFuture;

  @override
  void initState() {
    super.initState();
    _previewFuture = _loadPreviewItems();
  }

  @override
  void didUpdateWidget(covariant _FirstWinPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level != widget.level || oldWidget.goal != widget.goal) {
      _selectedOption = null;
      _answered = false;
      _isCorrect = false;
      _previewFuture = _loadPreviewItems();
    }
  }

  Future<List<VocabItem>> _loadPreviewItems() async {
    final level = widget.level;
    if (level == null) {
      return const [];
    }
    return ref.read(lessonRepositoryProvider).getVocabByLevel(level.shortLabel);
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final goal = widget.goal;

    if (level == null || goal == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) => FutureBuilder<List<VocabItem>>(
          future: _previewFuture,
          builder: (context, snapshot) {
            final preview = _buildPreviewItems(snapshot.data, widget.language);
            final showLoadingHint =
                snapshot.connectionState != ConnectionState.done &&
                !(snapshot.hasData && (snapshot.data?.isNotEmpty ?? false));

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.language.onboardingFirstWinTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.appPalette.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.language.onboardingFirstWinSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.appPalette.ink.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.appPalette.primary.withValues(
                          alpha: 0.06,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${level.shortLabel} | ${goal.label(widget.language)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.appPalette.primary,
                        ),
                      ),
                    ),
                    if (showLoadingHint) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.language.onboardingFirstWinLoadingHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appPalette.ink.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _PreviewQuestionCard(
                      language: widget.language,
                      target: preview.target,
                      options: preview.options,
                      selectedOption: _selectedOption,
                      answered: _answered,
                      isCorrect: _isCorrect,
                      onSelect: (index) {
                        if (_answered) {
                          return;
                        }
                        setState(() {
                          _selectedOption = index;
                          _answered = true;
                          _isCorrect = index == 0;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SessionPreview(language: widget.language),
                    const SizedBox(height: AppSpacing.lg),
                    if (!_answered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          widget.language.onboardingFirstWinUnlockHint,
                          key: const ValueKey('onboarding_first_win_hint'),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appPalette.ink.withValues(
                              alpha: 0.55,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ClayButton(
                      key: const ValueKey('onboarding_first_win_start'),
                      label: widget.language.onboardingStartButton,
                      style: ClayButtonStyle.primary,
                      isExpanded: true,
                      icon: Icons.play_arrow_rounded,
                      onPressed: _answered ? widget.onStart : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  ({VocabItem target, List<String> options}) _buildPreviewItems(
    List<VocabItem>? items,
    AppLanguage language,
  ) {
    const fallbackItems = <VocabItem>[
      VocabItem(
        id: -1,
        term: '\u65e5\u672c',
        reading: '\u306b\u307b\u3093',
        meaning: 'Nhật Bản',
        meaningEn: 'Japan',
        level: 'N5',
      ),
      VocabItem(
        id: -2,
        term: '\u5b66\u751f',
        reading: '\u304c\u304f\u305b\u3044',
        meaning: 'Học sinh',
        meaningEn: 'Student',
        level: 'N5',
      ),
      VocabItem(
        id: -3,
        term: '\u6c34',
        reading: '\u307f\u305a',
        meaning: 'Nước',
        meaningEn: 'Water',
        level: 'N5',
      ),
    ];

    final source = items == null || items.length < 3
        ? fallbackItems
        : items.take(3).toList(growable: false);
    final target = source.first;
    final options = <String>[
      target.displayMeaning(language),
      ...source.skip(1).map((item) => item.displayMeaning(language)),
    ];
    return (target: target, options: options);
  }
}

class _PreviewQuestionCard extends StatelessWidget {
  const _PreviewQuestionCard({
    required this.language,
    required this.target,
    required this.options,
    required this.selectedOption,
    required this.answered,
    required this.isCorrect,
    required this.onSelect,
  });

  final AppLanguage language;
  final VocabItem target;
  final List<String> options;
  final int? selectedOption;
  final bool answered;
  final bool isCorrect;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appPalette.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appPalette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.onboardingFirstWinQuestionLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.appPalette.ink.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            target.term,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: context.appPalette.ink,
            ),
          ),
          if (target.hasDisplayReading) ...[
            const SizedBox(height: 4),
            Text(
              target.reading ?? '',
              style: TextStyle(
                color: context.appPalette.ink.withValues(alpha: 0.55),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PreviewOptionTile(
                key: ValueKey('onboarding_preview_option_$i'),
                label: options[i],
                selected: selectedOption == i,
                correct: answered && i == 0,
                wrong: answered && selectedOption == i && !isCorrect,
                onTap: () => onSelect(i),
              ),
            ),
          if (answered) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              isCorrect
                  ? language.onboardingFirstWinSuccessLabel
                  : language.onboardingFirstWinAnswerLabel(options.first),
              style: TextStyle(
                color: isCorrect
                    ? context.appPalette.success
                    : context.appPalette.ink.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewOptionTile extends StatelessWidget {
  const _PreviewOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final borderColor = correct
        ? palette.success
        : wrong
        ? palette.error
        : selected
        ? palette.primary
        : palette.outline;
    final background = correct
        ? palette.success.withValues(alpha: 0.08)
        : wrong
        ? palette.error.withValues(alpha: 0.06)
        : selected
        ? palette.primary.withValues(alpha: 0.06)
        : palette.elevated;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: reducedMotionDuration(
          context,
          const Duration(milliseconds: 150),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.appPalette.ink,
          ),
        ),
      ),
    );
  }
}

class _SessionPreview extends StatelessWidget {
  const _SessionPreview({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appPalette.base,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appPalette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.onboardingSessionPreviewTitle,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.appPalette.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PreviewChip(label: language.onboardingSessionPreviewStep1),
          const SizedBox(height: AppSpacing.xs),
          _PreviewChip(label: language.onboardingSessionPreviewStep2),
          const SizedBox(height: AppSpacing.xs),
          _PreviewChip(label: language.onboardingSessionPreviewStep3),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.appPalette.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appPalette.outlineSoft),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.appPalette.ink,
        ),
      ),
    );
  }
}
