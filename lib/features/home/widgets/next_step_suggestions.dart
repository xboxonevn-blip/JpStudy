import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../grammar/grammar_providers.dart';
import '../../grammar/screens/grammar_practice_screen.dart';
import '../../vocab/vocab_ghost_providers.dart';
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
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final grammarGhostCount = ref
        .watch(grammarGhostCountProvider)
        .maybeWhen(data: (c) => c, orElse: () => 0);
    final vocabGhostCount = ref
        .watch(vocabGhostCountProvider)
        .maybeWhen(data: (c) => c, orElse: () => 0);
    final vocabGhosts = ref.watch(vocabGhostsProvider).valueOrNull ?? [];
    final continueAction = ref.watch(continueActionProvider).valueOrNull;

    final totalGhosts = grammarGhostCount + vocabGhostCount;
    final totalDue =
        (dashboard?.vocabDue ?? 0) +
        (dashboard?.grammarDue ?? 0) +
        (dashboard?.kanjiDue ?? 0);

    final steps = <_Step>[];

    // Priority 1: Ghosts need fixing first
    if (totalGhosts > 0) {
      steps.add(
        _Step(
          icon: Icons.warning_amber_rounded,
          label: language.fixMistakesLabel,
          count: totalGhosts,
          color: const Color(0xFFDC2626),
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
          color: const Color(0xFF1D4ED8),
          onTap: () => _navigateToDue(context, continueAction, dashboard),
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
          color: const Color(0xFF059669),
          onTap: () => context.push('/immersion'),
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
    ContinueAction? action,
    DashboardState? dashboard,
  ) {
    switch (action?.type) {
      case ContinueActionType.grammarReview:
        final ids = action?.data;
        if (ids is List && ids.isNotEmpty) {
          context.push('/grammar-practice', extra: List<int>.from(ids));
        } else {
          context.push('/grammar');
        }
        return;
      case ContinueActionType.vocabReview:
        context.push('/vocab/review');
        return;
      case ContinueActionType.kanjiReview:
        final lessonId = action?.data;
        if (lessonId is int) {
          context.push('/lesson/$lessonId');
        } else {
          context.push('/kanji-dash');
        }
        return;
      default:
        break;
    }

    if ((dashboard?.grammarDue ?? 0) > 0) {
      context.push('/grammar');
    } else if ((dashboard?.vocabDue ?? 0) > 0) {
      context.push('/vocab/review');
    } else {
      context.push('/kanji-dash');
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
              border: Border.all(
                color: step.color.withValues(alpha: 0.25),
              ),
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
                            color: Colors.grey[600],
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
