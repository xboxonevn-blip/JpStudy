import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../data/db/database_provider.dart';
import '../models/kanji_reading_question.dart';
import '../providers/kanji_reading_providers.dart';
import 'kanji_reading_quiz_screen.dart';

class HomeKanjiReadingScreen extends ConsumerWidget {
  const HomeKanjiReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(ref.watch(appLanguageProvider).kanjiReadingQuizTitle)),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    final repo = ref.read(lessonRepositoryProvider);
    return FutureBuilder(
      future: repo.fetchKanjiByLevel(level.shortLabel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('${ref.watch(appLanguageProvider).kanjiReadingQuizTitle} ${level.shortLabel}')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data ?? const [];
        if (items.isEmpty || items.length < 4) {
          return Scaffold(
            appBar: AppBar(title: Text('${ref.watch(appLanguageProvider).kanjiReadingQuizTitle} ${level.shortLabel}')),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('${ref.watch(appLanguageProvider).kanjiReadingQuizTitle} ${level.shortLabel}')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded,
                      size: 64, color: Color(0xFF1E3A5F)),
                  const SizedBox(height: 24),
                  Text(
                    language.kanjiReadingQuizTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    language.kanjiAvailableLabel(items.length),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  Consumer(
                    builder: (context, ref, _) {
                      final dueCountAsync =
                          ref.watch(kanjiReadingDueCountProvider);
                      return dueCountAsync.when(
                        data: (count) {
                          if (count == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'All caught up! No reviews due.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.green),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SizedBox(
                              width: 200,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final db = ref.read(databaseProvider);
                                  final dueStates =
                                      await db.kanjiSrsDao.getDueReviews();
                                  final dueIds = dueStates
                                      .map((s) => s.kanjiId)
                                      .toSet();
                                  final dueItems = items
                                      .where((k) => dueIds.contains(k.id))
                                      .toList();
                                  if (dueItems.length >= 4) {
                                    final questions =
                                        KanjiReadingQuestion.generate(
                                      dueItems,
                                      count: dueItems.length.clamp(0, 10),
                                    );
                                    if (questions.isNotEmpty &&
                                        context.mounted) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              KanjiReadingQuizScreen(
                                            questions: questions,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.rate_review_rounded),
                                label: Text(language.dueForReviewLabel(count)),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  SizedBox(
                    width: 200,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        final questions =
                            KanjiReadingQuestion.generate(items, count: 10);
                        if (questions.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                KanjiReadingQuizScreen(questions: questions),
                          ),
                        );
                      },
                      child: Text(language.startQuizLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
