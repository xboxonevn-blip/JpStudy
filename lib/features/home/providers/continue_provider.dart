import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import '../../../../core/level_provider.dart';
import '../../../data/repositories/grammar_repository.dart';
import '../../../data/repositories/lesson_repository.dart';
import 'dashboard_provider.dart';

final continueActionProvider = StreamProvider<ContinueAction>((ref) async* {
  final level = ref.watch(studyLevelProvider);
  final lessonRepo = ref.watch(lessonRepositoryProvider);
  final dashboardAsync = ref.watch(dashboardProvider);
  final language = ref.watch(appLanguageProvider);

  if (!dashboardAsync.hasValue) {
    yield ContinueAction(
      type: ContinueActionType.practiceMixed,
      label: language.practiceLabel,
      count: null,
    );
    return;
  }

  final dashboard = dashboardAsync.value!;

  // Priority 1: Grammar Due
  if (dashboard.grammarDue > 0) {
    final grammarRepo = ref.watch(grammarRepositoryProvider);
    final duePoints = await grammarRepo.fetchDuePoints();
    final dueIds = duePoints.map((p) => p.id).toList();
    yield ContinueAction(
      type: ContinueActionType.grammarReview,
      label: language.reviewGrammarLabel,
      count: dashboard.grammarDue,
      data: dueIds,
    );
    return;
  }

  // Priority 2: Vocab Due
  if (dashboard.vocabDue > 0) {
    yield ContinueAction(
      type: ContinueActionType.vocabReview,
      label: language.reviewVocabLabel,
      count: dashboard.vocabDue,
    );
    return;
  }

  // Priority 3: Kanji Due
  if (dashboard.kanjiDue > 0) {
    int? dueLessonId;
    if (level != null) {
      dueLessonId = await lessonRepo.findFirstLessonWithDueKanji(
        level.shortLabel,
      );
    }
    yield ContinueAction(
      type: ContinueActionType.kanjiReview,
      label: language.reviewKanjiLabel,
      count: dashboard.kanjiDue,
      data: dueLessonId,
    );
    return;
  }

  // Priority 4: Fix Mistakes
  if (dashboard.totalMistakeCount > 0) {
    yield ContinueAction(
      type: ContinueActionType.fixMistakes,
      label: language.fixMistakesLabel,
      count: dashboard.totalMistakeCount,
    );
    return;
  }

  // Priority 5: Next Lesson (Find the first not-fully-completed lesson)
  if (level != null) {
    final nextLessonId = await lessonRepo.findNextToStudyLesson(
      level.shortLabel,
    );
    if (nextLessonId != null) {
      yield ContinueAction(
        type: ContinueActionType.nextLesson,
        label: language.lessonTitle(nextLessonId),
        data: nextLessonId,
      );
      return;
    }
  }

  // Fallback: Practice Mixed if nothing else
  yield ContinueAction(
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
