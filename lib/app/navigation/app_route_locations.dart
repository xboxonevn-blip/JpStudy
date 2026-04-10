import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';

class AppRouteLocation {
  static String _withQuery(String path, Map<String, String> queryParameters) {
    return Uri(path: path, queryParameters: queryParameters).toString();
  }

  static Map<String, String> _titleQuery(String? title) => {
    if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
  };

  static String _lessonPath(Object? id, String suffix, {String? title}) =>
      _withQuery('/lesson/$id/$suffix', _titleQuery(title));

  static String kanji({int? kanjiId}) => kanjiId == null
      ? AppRoutePath.kanji
      : _withQuery(AppRoutePath.kanji, {'kanjiId': '$kanjiId'});

  static String vocabReview({required VocabReviewArgs args}) =>
      _withQuery(AppRoutePath.vocabReview, args.toQueryParameters());

  static String minnaCatalog({
    required String levelCode,
    required String title,
    String? subtitle,
    required int lessonStart,
    required int lessonEnd,
  }) => _withQuery(AppRoutePath.vocabMinna, {
    'level': levelCode,
    'title': title,
    if (subtitle != null && subtitle.trim().isNotEmpty) 'subtitle': subtitle,
    'lessonStart': '$lessonStart',
    'lessonEnd': '$lessonEnd',
  });

  static String hajimeteCatalog({
    required String levelCode,
    required String title,
    String? subtitle,
  }) => _withQuery(AppRoutePath.vocabHajimete, {
    'level': levelCode,
    'title': title,
    if (subtitle != null && subtitle.trim().isNotEmpty) 'subtitle': subtitle,
  });

  static String hajimeteChapter({
    required String levelCode,
    required int chapterId,
    required String title,
  }) => _withQuery(AppRoutePath.vocabHajimeteChapter, {
    'level': levelCode,
    'chapterId': '$chapterId',
    'title': title,
  });

  static String vocabDetail(Object? id) => '/vocab/$id';
  static String grammarDetail(Object? id) => '/grammar/$id';
  static String lessonDetail(Object? id) => '/lesson/$id';
  static String lessonEdit(Object? id) => '/lesson/$id/edit';
  static String minnaLesson(Object? lessonId) => '/lesson/$lessonId';

  static String lessonPractice(
    Object? lessonId,
    LessonPracticeMode mode, {
    String? title,
  }) =>
      _withQuery('/lesson/$lessonId/practice/${mode.name}', _titleQuery(title));

  static String lessonLearnEnhanced(Object? lessonId, {String? title}) =>
      _lessonPath(lessonId, 'learn-enhanced', title: title);

  static String lessonWriteMode(Object? lessonId, {String? title}) =>
      _lessonPath(lessonId, 'write-mode', title: title);

  static String lessonMatchMode(Object? lessonId, {String? title}) =>
      _lessonPath(lessonId, 'match-mode', title: title);

  static String lessonFlashcardsEnhanced(Object? lessonId, {String? title}) =>
      _lessonPath(lessonId, 'flashcards-enhanced', title: title);

  static String lessonTestEnhanced(Object? lessonId, {String? title}) =>
      _lessonPath(lessonId, 'test-enhanced', title: title);

  static String lessonTestHistory(Object? lessonId, {String? title}) =>
      _lessonPath(lessonId, 'test-history', title: title);
}
