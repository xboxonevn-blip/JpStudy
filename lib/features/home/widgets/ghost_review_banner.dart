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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5F5EB)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.ghostReviewAllClearTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    language.ghostReviewAllClearSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7390),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF87171).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.ghostReviewBannerTitle(totalCount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language.ghostReviewBannerSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
