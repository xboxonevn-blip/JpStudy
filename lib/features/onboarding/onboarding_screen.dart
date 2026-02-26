import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/theme/app_theme_v2.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

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
                    _ReadyPage(
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

// ─── Progress Dots ────────────────────────────────────────────────────────────

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
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppThemeV2.primary : AppThemeV2.neutral,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Page 1: Level Selection ──────────────────────────────────────────────────

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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppThemeV2.textMain,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          language.onboardingWelcomeSubtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppThemeV2.textSub,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          language.onboardingLevelTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppThemeV2.textMain,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.folder_open, color: AppThemeV2.primary),
        ),
        title: Text(
          level.shortLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          level.description(language),
          style: const TextStyle(color: AppThemeV2.textSub),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelected(level),
      ),
    );
  }
}

// ─── Page 2: Goal Selection ───────────────────────────────────────────────────

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
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppThemeV2.textSub,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                language.onboardingGoalTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppThemeV2.textMain,
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
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeV2.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppThemeV2.primary : const Color(0xFFE8ECF5),
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
                    ? AppThemeV2.primary.withValues(alpha: 0.15)
                    : const Color(0xFFEFF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                goal.icon,
                color: isSelected
                    ? AppThemeV2.primary
                    : const Color(0xFF4255FF),
              ),
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
                          ? AppThemeV2.primary
                          : AppThemeV2.textMain,
                    ),
                  ),
                  Text(
                    goal.description(language),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeV2.textSub,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppThemeV2.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Page 3: Ready ────────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎌', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            language.onboardingReadyTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppThemeV2.textMain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (level != null && goal != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppThemeV2.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${level!.shortLabel}  •  ${goal!.label(language)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppThemeV2.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          ClayButton(
            label: language.onboardingStartButton,
            style: ClayButtonStyle.primary,
            isExpanded: true,
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
