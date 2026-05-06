import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_language.dart';
import '../../../core/language_provider.dart';
import '../../../data/models/vocab_item.dart';
import '../../../data/models/kanji_item.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/lesson_repository.dart';
import '../../../core/level_provider.dart';
import '../../../core/study_level.dart';
import '../../write/screens/write_mode_screen.dart';

/// Write mode - choose typing or handwriting practice
class WriteModeIntegration extends ConsumerWidget {
  final int lessonId;
  final String lessonTitle;

  const WriteModeIntegration({
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
    final kanjiAsync = ref.watch(lessonKanjiProvider(lessonId));
    final dueTermsAsync = ref.watch(lessonDueTermsProvider(lessonId));
    final dueKanjiAsync = ref.watch(lessonDueKanjiProvider(lessonId));

    return termsAsync.when(
      data: (terms) => kanjiAsync.when(
        data: (kanji) {
          final dueTerms =
              dueTermsAsync.value ?? const <UserLessonTermData>[];
          final dueKanji = dueKanjiAsync.value ?? const <KanjiItem>[];
          final vocabItems = _convertToVocabItems(terms, level.shortLabel);
          final dueVocabItems = _convertToVocabItems(dueTerms, level.shortLabel);
          return WriteModeScreen(
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            vocabItems: vocabItems,
            dueVocabItems: dueVocabItems,
            kanjiItems: kanji,
            dueKanjiItems: dueKanji,
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(
            title: Text('${language.writeModeLabel}: $lessonTitle'),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            title: Text('${language.writeModeLabel}: $lessonTitle'),
          ),
          body: Center(child: Text(language.loadErrorLabel)),
        ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: Text('${language.writeModeLabel}: $lessonTitle')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text('${language.writeModeLabel}: $lessonTitle')),
        body: Center(child: Text(language.loadErrorLabel)),
      ),
    );
  }

  List<VocabItem> _convertToVocabItems(List<UserLessonTermData> terms, String level) {
    return terms
        .map(
          (term) => VocabItem(
            id: term.id,
            term: term.term,
            reading: term.reading,
            meaning: term.definition,
            meaningEn: term.definitionEn,
            level: level,
          ),
        )
        .toList();
  }
}


