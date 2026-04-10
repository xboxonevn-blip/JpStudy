import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/features/vocab/models/vocab_match_session_args.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_detail_screen.dart';
import 'package:jpstudy/features/vocab/screens/minna_lesson_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:jpstudy/features/vocab/screens/vocab_detail_screen.dart';
import 'package:jpstudy/features/vocab/screens/vocab_match_session_screen.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';

StatefulShellBranch buildVocabBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.vocab,
        name: AppRouteName.vocab,
        builder: (context, state) => const VocabScreen(),
      ),
      GoRoute(
        path: AppRoutePath.vocabReview,
        name: AppRouteName.vocabReview,
        builder: (context, state) {
          final args = state.extra is VocabReviewArgs
              ? state.extra as VocabReviewArgs
              : VocabReviewArgs.fromLegacyQuery(state.uri.queryParameters);
          return TermReviewScreen(
            reviewArgs: args,
            sessionTitle: args.title,
            sessionSubtitle: args.subtitle,
            lessonStart: args.lessonStart,
            lessonEnd: args.lessonEnd,
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.vocabMinna,
        name: AppRouteName.vocabMinna,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return MinnaLessonCatalogScreen(
            levelCode: query['level'] ?? 'N5',
            title: query['title'] ?? 'Minna no Nihongo',
            subtitle: query['subtitle'],
            lessonStart: int.tryParse(query['lessonStart'] ?? '') ?? 1,
            lessonEnd: int.tryParse(query['lessonEnd'] ?? '') ?? 25,
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.vocabHajimete,
        name: AppRouteName.vocabHajimete,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return HajimeteChapterCatalogScreen(
            levelCode: query['level'] ?? 'N5',
            title: query['title'] ?? 'Hajimete no Nihongo Tango',
            subtitle: query['subtitle'],
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.vocabHajimeteChapter,
        name: AppRouteName.vocabHajimeteChapter,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return HajimeteChapterDetailScreen(
            levelCode: query['level'] ?? 'N5',
            chapterId: int.tryParse(query['chapterId'] ?? '') ?? 1,
            laneTitle: query['title'] ?? 'Hajimete no Nihongo Tango',
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.vocabMatchSession,
        name: AppRouteName.vocabMatchSession,
        builder: (context, state) {
          final args = state.extra;
          if (args is VocabMatchSessionArgs) {
            return VocabMatchSessionScreen(args: args);
          }
          return const VocabMatchSessionScreen(
            args: VocabMatchSessionArgs(items: [], title: 'Match'),
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.vocabDetail,
        name: AppRouteName.vocabDetail,
        builder: (context, state) =>
            VocabDetailScreen(vocabId: routeInt(state, 'id')),
      ),
    ],
  );
}
