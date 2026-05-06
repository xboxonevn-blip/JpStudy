import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme_palette.dart';
import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../grammar/grammar_providers.dart';
import '../../grammar/screens/grammar_practice_screen.dart';
import '../../vocab/vocab_ghost_providers.dart';
import '../../vocab/screens/vocab_ghost_review_screen.dart';

class GhostReviewBanner extends ConsumerWidget {
  const GhostReviewBanner({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final language = ref.watch(appLanguageProvider);
    final grammarCount = ref.watch(grammarGhostCountProvider).value ?? 0;
    final vocabCount = ref.watch(vocabGhostCountProvider).value ?? 0;
    final vocabGhosts = ref.watch(vocabGhostsProvider).value ?? [];
    final totalCount = grammarCount + vocabCount;

    final cardMargin = embedded
        ? const EdgeInsets.only(bottom: 10)
        : const EdgeInsets.fromLTRB(16, 0, 16, 12);

    if (totalCount == 0) {
      return Container(
        margin: cardMargin,
        padding: EdgeInsets.all(embedded ? 10 : 14),
        decoration: BoxDecoration(
          color: palette.elevated,
          borderRadius: BorderRadius.circular(embedded ? 14 : 18),
          border: Border.all(color: palette.success.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: palette.success.withValues(alpha: 0.08),
              blurRadius: embedded ? 10 : 16,
              offset: Offset(0, embedded ? 4 : 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: palette.success,
              size: embedded ? 18 : 24,
            ),
            SizedBox(width: embedded ? 8 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.ghostReviewAllClearTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: embedded ? 13 : 14,
                    ),
                  ),
                  Text(
                    language.ghostReviewAllClearSubtitle,
                    style: TextStyle(
                      fontSize: embedded ? 11 : 12,
                      color: palette.ink.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: cardMargin,
      padding: EdgeInsets.all(embedded ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.error.withValues(alpha: 0.05),
            palette.error.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(embedded ? 16 : 20),
        border: Border.all(color: palette.error.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: palette.error.withValues(alpha: 0.2),
            blurRadius: embedded ? 10 : 16,
            offset: Offset(0, embedded ? 5 : 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: palette.error,
                size: embedded ? 18 : 24,
              ),
              SizedBox(width: embedded ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.ghostReviewBannerTitle(totalCount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: embedded ? 13.5 : 15,
                        color: palette.error,
                      ),
                    ),
                    SizedBox(height: embedded ? 1 : 2),
                    Text(
                      language.ghostReviewBannerSubtitle,
                      style: TextStyle(
                        fontSize: embedded ? 11 : 12,
                        color: palette.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: embedded ? 8 : 12),
          Row(
            children: [
              if (grammarCount > 0)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/grammar-practice',
                      extra: GrammarPracticeMode.ghost,
                    ),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: Text(
                      'Grammar ($grammarCount)',
                      style: TextStyle(fontSize: embedded ? 12 : 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.error,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: embedded ? 8 : 10,
                      ),
                      visualDensity: embedded
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                    ),
                  ),
                ),
              if (grammarCount > 0 && vocabCount > 0)
                const SizedBox(width: 8),
              if (vocabCount > 0)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: vocabGhosts.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VocabGhostReviewScreen(
                                  items: vocabGhosts,
                                ),
                              ),
                            ),
                    icon: const Icon(Icons.translate_rounded, size: 18),
                    label: Text(
                      'Vocab ($vocabCount)',
                      style: TextStyle(fontSize: embedded ? 12 : 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: embedded ? 8 : 10,
                      ),
                      visualDensity: embedded
                          ? VisualDensity.compact
                          : VisualDensity.standard,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


