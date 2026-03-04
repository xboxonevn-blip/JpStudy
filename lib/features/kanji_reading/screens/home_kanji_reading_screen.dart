import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../models/kanji_reading_question.dart';
import 'kanji_reading_quiz_screen.dart';

class HomeKanjiReadingScreen extends ConsumerWidget {
  const HomeKanjiReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);
    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kanji Reading Quiz')),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    final repo = ref.read(lessonRepositoryProvider);
    return FutureBuilder(
      future: repo.fetchKanjiByLevel(level.shortLabel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Kanji Reading ${level.shortLabel}')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data ?? const [];
        if (items.isEmpty || items.length < 4) {
          return Scaffold(
            appBar: AppBar(title: Text('Kanji Reading ${level.shortLabel}')),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Kanji Reading ${level.shortLabel}')),
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
                    'Kanji Reading Quiz',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${items.length} kanji available',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
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
                      child: const Text('Start Quiz'),
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
