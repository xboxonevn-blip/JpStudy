import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final language = ref.watch(appLanguageProvider);
    final grammarCount = ref.watch(grammarGhostCountProvider).valueOrNull ?? 0;
    final vocabCount = ref.watch(vocabGhostCountProvider).valueOrNull ?? 0;
    final vocabGhosts = ref.watch(vocabGhostsProvider).valueOrNull ?? [];
    final totalCount = grammarCount + vocabCount;

    final cardMargin = embedded
        ? const EdgeInsets.only(bottom: 10)
        : const EdgeInsets.fromLTRB(16, 0, 16, 12);

    if (totalCount == 0) {
      return Container(
        margin: cardMargin,
        padding: EdgeInsets.all(embedded ? 10 : 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(embedded ? 14 : 18),
          border: Border.all(color: const Color(0xFFE5F5EB)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.08),
              blurRadius: embedded ? 10 : 16,
              offset: Offset(0, embedded ? 4 : 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF16A34A),
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
                      color: const Color(0xFF6B7390),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(embedded ? 16 : 20),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF87171).withValues(alpha: 0.2),
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
                color: Color(0xFFDC2626),
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
                        color: const Color(0xFF7F1D1D),
                      ),
                    ),
                    SizedBox(height: embedded ? 1 : 2),
                    Text(
                      language.ghostReviewBannerSubtitle,
                      style: TextStyle(
                        fontSize: embedded ? 11 : 12,
                        color: const Color(0xFF9F1239),
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
                      backgroundColor: const Color(0xFFDC2626),
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
                      backgroundColor: const Color(0xFFEA580C),
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
