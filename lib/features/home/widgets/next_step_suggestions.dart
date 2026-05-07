import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_navigation_extensions.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../core/study_level.dart';
import '../../grammar/grammar_providers.dart';
import '../../grammar/screens/grammar_practice_screen.dart';
import '../../kanji_hub/models/kanji_practice_args.dart';
import '../../vocab/vocab_ghost_providers.dart';
import '../../vocab/models/vocab_review_args.dart';
import '../../vocab/vocab_copy.dart';
import '../../vocab/screens/vocab_ghost_review_screen.dart';
import '../providers/continue_provider.dart';
import '../providers/dashboard_provider.dart';

/// A reusable widget that shows 2-3 smart "What's next?" suggestions
/// based on the current state of ghosts, due reviews, and immersion.
///
/// Drop this into any session result/summary screen to give users a
/// clear path forward without navigating back to Home first.
class NextStepSuggestions extends ConsumerWidget {
  const NextStepSuggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final (vocabDue, grammarDue, kanjiDue) = ref.watch(
      dashboardProvider.select((v) {
        final d = v.value;
        return (d?.vocabDue ?? 0, d?.grammarDue ?? 0, d?.kanjiDue ?? 0);
      }),
    );
    final grammarGhostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (c) => c, orElse: () => 0);
    final vocabGhostCount = ref
        .watch(vocabGhostCountProvider)
        .maybeWhen(data: (c) => c, orElse: () => 0);
    final vocabGhosts = ref.watch(vocabGhostsProvider).value ?? [];
    final continueAction = ref.watch(continueActionProvider).value;

    final totalGhosts = grammarGhostCount + vocabGhostCount;
    final totalDue = vocabDue + grammarDue + kanjiDue;

    final steps = <_Step>[];

    final palette = context.appPalette;

    // Priority 1: Ghosts need fixing first
    if (totalGhosts > 0) {
      steps.add(
        _Step(
          icon: Icons.warning_amber_rounded,
          label: language.fixMistakesLabel,
          count: totalGhosts,
          color: palette.error,
          onTap: () {
            if (grammarGhostCount > 0) {
              context.push(
                '/grammar-practice',
                extra: GrammarPracticeMode.ghost,
              );
            } else if (vocabGhosts.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VocabGhostReviewScreen(items: vocabGhosts),
                ),
              );
            }
          },
        ),
      );
    }

    // Priority 2: Due reviews
    if (totalDue > 0) {
      steps.add(
        _Step(
          icon: Icons.schedule_rounded,
          label: language.reviewsLabel,
          count: totalDue,
          color: palette.primary,
          onTap: () => _navigateToDue(
            context,
            ref,
            continueAction,
            grammarDue: grammarDue,
            vocabDue: vocabDue,
            kanjiDue: kanjiDue,
          ),
        ),
      );
    }

    // Always fill up to 3 with Immersion
    if (steps.length < 3) {
      steps.add(
        _Step(
          icon: Icons.article_rounded,
          label: language.practiceImmersionLabel,
          count: 0,
          color: palette.success,
          onTap: () => context.openImmersion(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language.nextStepLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...steps.take(3).map((s) => _StepTile(step: s)),
      ],
    );
  }

  void _navigateToDue(
    BuildContext context,
    WidgetRef ref,
    ContinueAction? action, {
    required int grammarDue,
    required int vocabDue,
    required int kanjiDue,
  }) {
    final language = ref.read(appLanguageProvider);
    final level = ref.read(studyLevelProvider) ?? StudyLevel.n5;

    switch (action?.type) {
      case ContinueActionType.grammarReview:
        final ids = action?.data;
        if (ids is List && ids.isNotEmpty) {
          context.openGrammarPractice(extra: List<int>.from(ids));
        } else {
          context.openGrammar();
        }
        return;
      case ContinueActionType.vocabReview:
        context.push(
          '/vocab/review',
          extra: VocabReviewArgs(
            source: 'daily_queue',
            levelCode: level.shortLabel,
            title: language.vocabReviewTitle(level.shortLabel),
            subtitle: switch (language) {
              AppLanguage.en => 'Due queue for today',
              AppLanguage.vi => 'Hàng đợi đến hạn hôm nay',
              AppLanguage.ja => '今日の期限レビュー',
            },
          ),
        );
        return;
      case ContinueActionType.kanjiReview:
        context.push(
          '/kanji/practice',
          extra: KanjiPracticeArgs(
            mode: KanjiPracticeMode.both,
            levelCode: level.shortLabel,
            source: 'due',
          ),
        );
        return;
      default:
        break;
    }

    if (grammarDue > 0) {
      context.openGrammar();
    } else if (vocabDue > 0) {
      context.push(
        '/vocab/review',
        extra: VocabReviewArgs(
          source: 'daily_queue',
          levelCode: level.shortLabel,
          title: language.vocabReviewTitle(level.shortLabel),
          subtitle: switch (language) {
            AppLanguage.en => 'Due queue for today',
            AppLanguage.vi => 'Hàng đợi đến hạn hôm nay',
            AppLanguage.ja => '今日の期限レビュー',
          },
        ),
      );
    } else {
      context.push(
        '/kanji/practice',
        extra: KanjiPracticeArgs(
          mode: KanjiPracticeMode.both,
          levelCode: level.shortLabel,
          source: 'due',
        ),
      );
    }
  }
}

class _Step {
  const _Step({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step});

  final _Step step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: step.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: step.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: step.color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: step.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon, color: step.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (step.count > 0)
                        Text(
                          '${step.count} ${step.count == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appPalette.ink.withValues(alpha: 0.55),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: step.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


