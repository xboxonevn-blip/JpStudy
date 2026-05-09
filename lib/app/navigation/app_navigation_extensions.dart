import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/features/learn/models/learn_session_args.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';

extension AppNavigationContext on BuildContext {
  void openHome() => goNamed(AppRouteName.home);
  void openToday() => goNamed(AppRouteName.today);
  void openTodaySessionSummary() => pushNamed(AppRouteName.todaySessionSummary);
  void openVocab() => goNamed(AppRouteName.vocab);
  void openGrammar() => goNamed(AppRouteName.grammar);
  void openGrammarPractice({Object? extra}) =>
      pushNamed(AppRouteName.grammarPractice, extra: extra);
  void openSearch({Object? extra}) =>
      pushNamed(AppRouteName.search, extra: extra);
  void openFoundations() => pushNamed(AppRouteName.foundations);
  void openFoundationsKana(KanaScript script) => pushNamed(
    AppRouteName.foundationsKana,
    pathParameters: {'script': script.name},
  );
  void openFoundationsCompounds() =>
      pushNamed(AppRouteName.foundationsCompounds);
  void openFoundationsHanViet() => pushNamed(AppRouteName.foundationsHanViet);
  void openFoundationsQuiz({
    KanaScript? script,
    KanaView? view,
    bool fromDue = false,
  }) => pushNamed(
    AppRouteName.foundationsQuiz,
    queryParameters: {
      if (script != null) 'script': script.name,
      if (view != null) 'view': view.name,
      if (fromDue) 'source': 'due',
    },
  );
  void popFoundations() => pop();
  void openLibrary() => pushNamed(AppRouteName.library);
  void openStudy() => pushNamed(AppRouteName.study);
  void openStudyHub() => pushNamed(AppRouteName.studyHub);
  void openMistakes() => pushNamed(AppRouteName.mistakes);
  void openImmersion() => pushNamed(AppRouteName.immersion);
  void openJlptCoach() => pushNamed(AppRouteName.jlptCoach);
  void openJlptReading() => pushNamed(AppRouteName.jlptReading);
  void openJlptMockPro() => pushNamed(AppRouteName.jlptMockPro);
  void openExamCenter({HomeMockExamLaunchArgs? extra}) =>
      pushNamed(AppRouteName.examCenter, extra: extra);
  void openPracticeMockExam({HomeMockExamLaunchArgs? extra}) =>
      pushNamed(AppRouteName.practiceMockExam, extra: extra);
  void openPremium() => pushNamed(AppRouteName.premium);
  void openMe() => goNamed(AppRouteName.me);
  void openMeData() => pushNamed(AppRouteName.meData);
  void openProgressHome() => pushNamed(AppRouteName.progressHome);
  void openProgress() => pushNamed(AppRouteName.progressProfile);
  void openMastery() => pushNamed(AppRouteName.mastery);
  void openForecast() => pushNamed(AppRouteName.forecast);
  void openAchievements() => pushNamed(AppRouteName.achievements);
  void openDesignLab() => pushNamed(AppRouteName.designLab);
  void openLearnRecoveryPack() => pushNamed(AppRouteName.learnRecoveryPack);
  void openKanjiPractice({Object? extra}) =>
      pushNamed(AppRouteName.kanjiPractice, extra: extra);
  void openLeaderboard() => goNamed(AppRouteName.leaderboard);
  void openHandwritingPractice() => goNamed(AppRouteName.practice);
  void openLearnSession(LearnSessionArgs args) =>
      pushNamed(AppRouteName.learnSession, extra: args);

  void openVocabReview({
    VocabReviewArgs? args,
    String? source,
    String? levelCode,
    String? series,
    int? lessonStart,
    int? lessonEnd,
    String? title,
    String? subtitle,
  }) {
    final resolvedArgs =
        args ??
        VocabReviewArgs(
          source: source ?? 'manual',
          levelCode: levelCode,
          series: series,
          lessonStart: lessonStart,
          lessonEnd: lessonEnd,
          title: title,
          subtitle: subtitle,
        );
    push(AppRouteLocation.vocabReview(args: resolvedArgs));
  }

  void openMinnaCatalog({
    required String levelCode,
    required String title,
    String? subtitle,
    required int lessonStart,
    required int lessonEnd,
  }) => push(
    AppRouteLocation.minnaCatalog(
      levelCode: levelCode,
      title: title,
      subtitle: subtitle,
      lessonStart: lessonStart,
      lessonEnd: lessonEnd,
    ),
  );

  void openHajimeteCatalog({
    required String levelCode,
    required String title,
    String? subtitle,
  }) => push(
    AppRouteLocation.hajimeteCatalog(
      levelCode: levelCode,
      title: title,
      subtitle: subtitle,
    ),
  );

  void openHajimeteChapter({
    required String levelCode,
    required int chapterId,
    required String title,
  }) => push(
    AppRouteLocation.hajimeteChapter(
      levelCode: levelCode,
      chapterId: chapterId,
      title: title,
    ),
  );

  void openLesson(Object? lessonId) =>
      push(AppRouteLocation.lessonDetail(lessonId));
  void openLessonEdit(Object? lessonId) =>
      push(AppRouteLocation.lessonEdit(lessonId));
  void openLessonPractice(
    Object? lessonId,
    LessonPracticeMode mode, {
    String? title,
  }) => push(AppRouteLocation.lessonPractice(lessonId, mode, title: title));
  void openLessonLearn(Object? lessonId, {String? title}) =>
      push(AppRouteLocation.lessonLearnEnhanced(lessonId, title: title));
  void openLessonWrite(Object? lessonId, {String? title}) =>
      push(AppRouteLocation.lessonWriteMode(lessonId, title: title));
  void openLessonMatch(Object? lessonId, {String? title}) =>
      push(AppRouteLocation.lessonMatchMode(lessonId, title: title));
  void openLessonFlashcards(Object? lessonId, {String? title}) =>
      push(AppRouteLocation.lessonFlashcardsEnhanced(lessonId, title: title));
  void openLessonTest(Object? lessonId, {String? title}) =>
      push(AppRouteLocation.lessonTestEnhanced(lessonId, title: title));
  void openLessonTestHistory(Object? lessonId, {String? title}) =>
      push(AppRouteLocation.lessonTestHistory(lessonId, title: title));
  void openGrammarDetail(Object? grammarId) =>
      push(AppRouteLocation.grammarDetail(grammarId));
  void openVocabDetail(Object? vocabId) =>
      push(AppRouteLocation.vocabDetail(vocabId));
  void openKanji({int? kanjiId}) =>
      push(AppRouteLocation.kanji(kanjiId: kanjiId));
}
