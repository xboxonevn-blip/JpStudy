import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import '../../../../core/level_provider.dart';
import '../../../data/repositories/grammar_repository.dart';
import '../../../data/repositories/lesson_repository.dart';
import 'dashboard_provider.dart';

final continueActionProvider = FutureProvider<ContinueAction>((ref) async {
  final level = ref.watch(studyLevelProvider);
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final language = ref.watch(appLanguageProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);

  // Subscribe only to the fields that drive the decision; streak/XP won't retrigger.
  final due = ref.watch(
    dashboardProvider.select((v) {
      if (!v.hasValue) return null;
      final d = v.value!;
      return (
        grammarDue: d.grammarDue,
        vocabDue: d.vocabDue,
        kanjiDue: d.kanjiDue,
        totalMistakeCount: d.totalMistakeCount,
      );
    }),
  );

  if (due == null) {
    return ContinueAction(
      type: ContinueActionType.practiceMixed,
      label: language.practiceLabel,
      count: null,
    );
  }

  // Priority 1: Grammar Due — fetch IDs only (no full GrammarPoint rows needed)
  if (due.grammarDue > 0) {
    final dueIds = await grammarRepo.fetchDueGrammarIds();
    return ContinueAction(
      type: ContinueActionType.grammarReview,
      label: language.reviewGrammarLabel,
      count: due.grammarDue,
      data: dueIds,
    );
  }

  // Priority 2: Vocab Due
  if (due.vocabDue > 0) {
    return ContinueAction(
      type: ContinueActionType.vocabReview,
      label: language.reviewVocabLabel,
      count: due.vocabDue,
    );
  }

  // Priority 3: Kanji Due
  if (due.kanjiDue > 0) {
    int? dueLessonId;
    if (level != null) {
      dueLessonId = await lessonRepo.findFirstLessonWithDueKanji(
        level.shortLabel,
      );
    }
    return ContinueAction(
      type: ContinueActionType.kanjiReview,
      label: language.reviewKanjiLabel,
      count: due.kanjiDue,
      data: dueLessonId,
    );
  }

  // Priority 4: Fix Mistakes
  if (due.totalMistakeCount > 0) {
    return ContinueAction(
      type: ContinueActionType.fixMistakes,
      label: language.fixMistakesLabel,
      count: due.totalMistakeCount,
    );
  }

  // Priority 5: Next Lesson (Find the first not-fully-completed lesson)
  if (level != null) {
    final nextLessonId = await lessonRepo.findNextToStudyLesson(
      level.shortLabel,
    );
    if (nextLessonId != null) {
      return ContinueAction(
        type: ContinueActionType.nextLesson,
        label: language.lessonTitle(nextLessonId),
        data: nextLessonId,
      );
    }
  }

  // Fallback: Practice Mixed if nothing else
  return ContinueAction(
    type: ContinueActionType.practiceMixed,
    label: language.practiceLabel,
    count: null,
  );
});

enum ContinueActionType {
  grammarReview,
  vocabReview,
  kanjiReview,
  fixMistakes,
  practiceMixed,
  nextLesson,
}

class ContinueAction {
  final ContinueActionType type;
  final String label;
  final int? count;
  final dynamic data;

  const ContinueAction({
    required this.type,
    required this.label,
    this.count,
    this.data,
  });
}
