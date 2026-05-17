import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/learn/integration/learn_mode_integration.dart';
import 'package:jpstudy/features/test/integration/test_mode_integration.dart';
import 'package:jpstudy/features/learn/integration/write_mode_integration.dart';

enum LessonPracticeMode { learn, test, write }

LessonPracticeMode? lessonPracticeModeFromPath(String value) {
  switch (value) {
    case 'learn':
      return LessonPracticeMode.learn;
    case 'test':
      return LessonPracticeMode.test;
    case 'match':
      return LessonPracticeMode.test;
    case 'write':
      return LessonPracticeMode.write;
  }
  return null;
}

class LessonPracticeScreen extends ConsumerWidget {
  const LessonPracticeScreen({
    super.key,
    required this.lessonId,
    required this.mode,
  });

  final int lessonId;
  final LessonPracticeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider) ?? StudyLevel.n5;
    final sourceLessonId = LessonRepository.curriculumSourceLessonId(
      level.shortLabel,
      lessonId,
    );
    final storageLessonId = LessonRepository.curriculumStorageLessonId(
      level.shortLabel,
      lessonId,
    );
    final fallbackTitle = language.curriculumLessonTitle(
      level.shortLabel,
      sourceLessonId,
    );
    final titleAsync = ref.watch(
      lessonTitleProvider(LessonTitleArgs(storageLessonId, fallbackTitle)),
    );
    final lessonTitle = titleAsync.maybeWhen(
      data: (value) => value,
      orElse: () => fallbackTitle,
    );

    switch (mode) {
      case LessonPracticeMode.learn:
        return LearnModeIntegration(
          lessonId: storageLessonId,
          lessonTitle: lessonTitle,
        );
      case LessonPracticeMode.test:
        return TestModeIntegration(
          lessonId: storageLessonId,
          lessonTitle: lessonTitle,
        );
      case LessonPracticeMode.write:
        return WriteModeIntegration(
          lessonId: storageLessonId,
          lessonTitle: lessonTitle,
        );
    }
  }
}
