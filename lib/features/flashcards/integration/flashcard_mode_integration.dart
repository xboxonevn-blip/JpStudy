import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../core/level_provider.dart';
import '../../../core/study_level.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../screens/enhanced_flashcard_screen.dart';

class FlashcardModeIntegration extends ConsumerWidget {
  final int lessonId;
  final String lessonTitle;

  const FlashcardModeIntegration({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final termsAsync = ref.watch(
      lessonTermsProvider(
        LessonTermsArgs(lessonId, level.shortLabel, lessonTitle),
      ),
    );

    return termsAsync.when(
      data: (terms) {
        if (terms.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('${language.flashcardsAction}: $lessonTitle'),
            ),
            body: Center(child: Text(language.noTermsAvailableLabel)),
          );
        }
        final vocabItems = _toVocabItems(terms, level.shortLabel);
        return EnhancedFlashcardScreen(
          items: vocabItems,
          lessonId: lessonId,
          lessonTitle: lessonTitle,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('${language.flashcardsAction}: $lessonTitle'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          title: Text('${language.flashcardsAction}: $lessonTitle'),
        ),
        body: Center(child: Text(language.loadErrorLabel)),
      ),
    );
  }

  List<VocabItem> _toVocabItems(
    List<UserLessonTermData> terms,
    String levelLabel,
  ) {
    return terms
        .map(
          (t) => VocabItem(
            id: t.id,
            term: t.term,
            reading: t.reading,
            meaning: t.definition,
            meaningEn: t.definitionEn,
            kanjiMeaning: t.kanjiMeaning,
            level: levelLabel,
          ),
        )
        .toList();
  }
}
