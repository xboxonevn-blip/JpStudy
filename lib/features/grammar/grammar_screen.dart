import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';

class GrammarScreen extends ConsumerWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    final levelSuffix = level == null ? '' : ' (${level.shortLabel})';

    final levelStr = level?.shortLabel ?? 'N5';
    final pointsAsync = ref.watch(grammarPointsProvider(levelStr));
    final ghostCountAsync = ref.watch(
      grammarGhostCountProvider,
    ); // New provider

    return Scaffold(
      appBar: AppBar(title: Text('${_title(language)}$levelSuffix')),
      body: pointsAsync.when(
        data: (points) {
          if (points.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_stories, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _tr(
                      language,
                      en: 'No grammar for $levelStr yet.',
                      vi: 'Ch\u01b0a c\u00f3 ng\u1eef ph\u00e1p cho $levelStr.',
                      ja: '$levelStr \u306e\u6587\u6cd5\u306f\u307e\u3060\u3042\u308a\u307e\u305b\u3093\u3002',
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Ghost Review Alert
              ghostCountAsync.when(
                data: (ghostCount) {
                  if (ghostCount == 0) {
                    // Empty State - "All caught up"
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  language.ghostReviewAllClearTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900],
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  language.ghostReviewAllClearSubtitle,
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Active State - "Fix Mistakes"
                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                language.ghostReviewBannerTitle(ghostCount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                              Text(
                                language.ghostReviewBannerSubtitle,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            // We need to pass the enum, but it's in grammar_practice.dart
                            // To avoid circular dep if it was weird, we could use int or string.
                            // But here we can import it.
                            // Assuming we add import 'package:jpstudy/features/grammar/screens/grammar_practice_screen.dart';
                            context.push(
                              '/grammar-practice',
                              extra: GrammarPracticeMode.ghost,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(language.ghostReviewBannerActionLabel),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: points.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final point = points[index];
                    final headline = switch (language) {
                      AppLanguage.en => resolveEnglishGrammarConnection(
                        connectionEn: point.connectionEn,
                        connection: point.connection,
                        grammarPoint: point.grammarPoint,
                        titleEn: point.titleEn,
                        meaningEn: point.meaningEn,
                      ),
                      AppLanguage.vi => point.grammarPoint,
                      AppLanguage.ja => point.grammarPoint,
                    };
                    final subtitle = switch (language) {
                      AppLanguage.en => resolveEnglishGrammarMeaning(
                        meaningEn: point.meaningEn,
                        titleEn: point.titleEn,
                        connectionEn: point.connectionEn,
                        connection: point.connection,
                        grammarPoint: point.grammarPoint,
                      ),
                      AppLanguage.vi => point.meaningVi ?? point.meaning,
                      AppLanguage.ja => point.meaning,
                    };
                    return ListTile(
                      title: Text(
                        headline,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(subtitle),
                      trailing: point.isLearned
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () => context.push('/grammar/${point.id}'),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${language.loadErrorLabel}: $err')),
      ),
      floatingActionButton: ref
          .watch(grammarDueCountProvider)
          .when(
            data: (count) => count > 0
                ? FloatingActionButton.extended(
                    onPressed: () => context.push('/grammar-practice'),
                    icon: const Icon(Icons.psychology),
                    label: Text(language.reviewCountLabel(count)),
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                  )
                : null,
            loading: () => null,
            error: (_, _) => null,
          ),
    );
  }

  String _title(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return 'Grammar';
      case AppLanguage.vi:
        return 'Ng\u1eef ph\u00e1p';
      case AppLanguage.ja:
        return '\u6587\u6cd5';
    }
  }

  String _tr(
    AppLanguage language, {
    required String en,
    required String vi,
    required String ja,
  }) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}
