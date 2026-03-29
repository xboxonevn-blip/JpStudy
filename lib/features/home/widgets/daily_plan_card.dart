import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';
import 'package:jpstudy/features/home/providers/daily_plan_provider.dart';

class DailyPlanCard extends ConsumerWidget {
  const DailyPlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(dailyPlanProvider);
    final language = ref.watch(appLanguageProvider);
    final palette = context.appPalette;

    return planAsync.when(
      data: (plan) {
        if (plan.steps.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: AppSectionCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  language: language,
                  palette: palette,
                  plan: plan,
                ),
                const SizedBox(height: 12),
                _PlanProgress(plan: plan, palette: palette),
                const SizedBox(height: 14),
                ...List.generate(plan.steps.length, (i) {
                  final step = plan.steps[i];
                  final done = plan.completedSteps.contains(i);
                  return _StepRow(
                    step: step,
                    index: i,
                    done: done,
                    language: language,
                    palette: palette,
                    onTap: () => context.push(step.route),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.language,
    required this.palette,
    required this.plan,
  });

  final AppLanguage language;
  final AppThemePalette palette;
  final DailyPlan plan;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 18, color: palette.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _title(language),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: palette.ink,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '~${plan.totalMinutes} min',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: palette.accent,
            ),
          ),
        ),
      ],
    );
  }

  String _title(AppLanguage l) {
    switch (l) {
      case AppLanguage.en:
        return "Today's Plan";
      case AppLanguage.vi:
        return 'Kế hoạch hôm nay';
      case AppLanguage.ja:
        return '今日のプラン';
    }
  }
}

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------

class _PlanProgress extends StatelessWidget {
  const _PlanProgress({required this.plan, required this.palette});

  final DailyPlan plan;
  final AppThemePalette palette;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: plan.progress,
          backgroundColor: palette.outline.withValues(alpha: 0.5),
          valueColor: AlwaysStoppedAnimation(palette.success),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step row
// ---------------------------------------------------------------------------

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.index,
    required this.done,
    required this.language,
    required this.palette,
    required this.onTap,
  });

  final PlanStep step;
  final int index;
  final bool done;
  final AppLanguage language;
  final AppThemePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final urgent = step.urgency >= 2;
    final iconColor = done
        ? palette.success
        : urgent
            ? palette.error
            : palette.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: done ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: done
                  ? palette.success.withValues(alpha: 0.06)
                  : urgent
                      ? palette.error.withValues(alpha: 0.05)
                      : palette.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: done
                    ? palette.success.withValues(alpha: 0.15)
                    : palette.outline.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : _iconForType(step.type),
                  size: 20,
                  color: iconColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stepLabel(step, language),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: done
                              ? palette.ink.withValues(alpha: 0.45)
                              : palette.ink,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${step.count} ${_itemLabel(step.type, language)} · ${step.estimatedMinutes} min',
                        style: TextStyle(
                          fontSize: 11,
                          color: palette.ink.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!done)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: palette.ink.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForType(PlanStepType type) {
    switch (type) {
      case PlanStepType.vocabReview:
        return Icons.menu_book_rounded;
      case PlanStepType.grammarReview:
        return Icons.rule_rounded;
      case PlanStepType.kanjiReview:
        return Icons.translate_rounded;
      case PlanStepType.mistakeFix:
        return Icons.auto_fix_high_rounded;
      case PlanStepType.newVocab:
        return Icons.add_circle_outline_rounded;
      case PlanStepType.newGrammar:
        return Icons.library_add_outlined;
      case PlanStepType.newKanji:
        return Icons.draw_rounded;
    }
  }

  String _stepLabel(PlanStep step, AppLanguage l) {
    switch (l) {
      case AppLanguage.en:
        return _stepLabelEn(step);
      case AppLanguage.vi:
        return _stepLabelVi(step);
      case AppLanguage.ja:
        return _stepLabelJa(step);
    }
  }

  String _stepLabelEn(PlanStep step) {
    switch (step.type) {
      case PlanStepType.mistakeFix:
        return 'Fix Mistakes';
      case PlanStepType.vocabReview:
        return step.urgency >= 2 ? 'Urgent Vocab Review' : 'Vocab Review';
      case PlanStepType.grammarReview:
        return step.urgency >= 2
            ? 'Urgent Grammar Review'
            : 'Grammar Review';
      case PlanStepType.kanjiReview:
        return step.urgency >= 2 ? 'Urgent Kanji Review' : 'Kanji Review';
      case PlanStepType.newVocab:
        return 'Learn New Words';
      case PlanStepType.newGrammar:
        return 'Learn New Grammar';
      case PlanStepType.newKanji:
        return 'Learn New Kanji';
    }
  }

  String _stepLabelVi(PlanStep step) {
    switch (step.type) {
      case PlanStepType.mistakeFix:
        return 'Sửa lỗi';
      case PlanStepType.vocabReview:
        return step.urgency >= 2 ? 'Ôn từ vựng gấp' : 'Ôn từ vựng';
      case PlanStepType.grammarReview:
        return step.urgency >= 2 ? 'Ôn ngữ pháp gấp' : 'Ôn ngữ pháp';
      case PlanStepType.kanjiReview:
        return step.urgency >= 2 ? 'Ôn Kanji gấp' : 'Ôn Kanji';
      case PlanStepType.newVocab:
        return 'Học từ mới';
      case PlanStepType.newGrammar:
        return 'Học ngữ pháp mới';
      case PlanStepType.newKanji:
        return 'Học Kanji mới';
    }
  }

  String _stepLabelJa(PlanStep step) {
    switch (step.type) {
      case PlanStepType.mistakeFix:
        return '間違い修正';
      case PlanStepType.vocabReview:
        return step.urgency >= 2 ? '緊急：語彙復習' : '語彙復習';
      case PlanStepType.grammarReview:
        return step.urgency >= 2 ? '緊急：文法復習' : '文法復習';
      case PlanStepType.kanjiReview:
        return step.urgency >= 2 ? '緊急：漢字復習' : '漢字復習';
      case PlanStepType.newVocab:
        return '新しい語彙';
      case PlanStepType.newGrammar:
        return '新しい文法';
      case PlanStepType.newKanji:
        return '新しい漢字';
    }
  }

  String _itemLabel(PlanStepType type, AppLanguage l) {
    switch (l) {
      case AppLanguage.en:
        switch (type) {
          case PlanStepType.vocabReview:
          case PlanStepType.newVocab:
            return 'words';
          case PlanStepType.grammarReview:
          case PlanStepType.newGrammar:
            return 'points';
          case PlanStepType.kanjiReview:
          case PlanStepType.newKanji:
            return 'kanji';
          case PlanStepType.mistakeFix:
            return 'items';
        }
      case AppLanguage.vi:
        switch (type) {
          case PlanStepType.vocabReview:
          case PlanStepType.newVocab:
            return 'từ';
          case PlanStepType.grammarReview:
          case PlanStepType.newGrammar:
            return 'điểm';
          case PlanStepType.kanjiReview:
          case PlanStepType.newKanji:
            return 'chữ';
          case PlanStepType.mistakeFix:
            return 'mục';
        }
      case AppLanguage.ja:
        switch (type) {
          case PlanStepType.vocabReview:
          case PlanStepType.newVocab:
            return '語';
          case PlanStepType.grammarReview:
          case PlanStepType.newGrammar:
            return '項目';
          case PlanStepType.kanjiReview:
          case PlanStepType.newKanji:
            return '字';
          case PlanStepType.mistakeFix:
            return '件';
        }
    }
  }
}
