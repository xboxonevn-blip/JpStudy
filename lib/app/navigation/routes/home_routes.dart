import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/app/navigation/app_route_locations.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/home/screens/daily_session_summary_screen.dart';
import 'package:jpstudy/features/library/library_screen.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:jpstudy/features/search/search_screen.dart';

StatefulShellBranch buildHomeBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.home,
        name: AppRouteName.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutePath.roadmap,
        name: AppRouteName.roadmap,
        redirect: (context, state) => AppRoutePath.home,
      ),
      GoRoute(
        path: AppRoutePath.today,
        name: AppRouteName.today,
        redirect: (context, state) => AppRoutePath.home,
      ),
      GoRoute(
        path: AppRoutePath.todaySessionSummary,
        name: AppRouteName.todaySessionSummary,
        builder: (context, state) => const DailySessionSummaryScreen(),
      ),
      GoRoute(
        path: AppRoutePath.progress,
        name: AppRouteName.progressHome,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutePath.library,
        name: AppRouteName.library,
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: AppRoutePath.search,
        name: AppRouteName.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutePath.lessonDetail,
        name: AppRouteName.lessonDetail,
        builder: (context, state) => LessonDetailScreen(
          lessonId: routeInt(state, 'id'),
          levelCode: state.uri.queryParameters['level'],
        ),
      ),
      GoRoute(
        path: AppRoutePath.lessonEdit,
        name: AppRouteName.lessonEdit,
        redirect: (context, state) =>
            AppRouteLocation.lessonDetail(state.pathParameters['id']),
      ),
      GoRoute(
        path: AppRoutePath.lessonPractice,
        name: AppRouteName.lessonPractice,
        redirect: (context, state) {
          final modeValue = state.pathParameters['mode'] ?? 'learn';
          if (modeValue == 'match') {
            return AppRouteLocation.lessonPractice(
              state.pathParameters['id'],
              LessonPracticeMode.test,
              title: state.uri.queryParameters['title'],
            );
          }
          return null;
        },
        builder: (context, state) {
          final modeValue = state.pathParameters['mode'] ?? 'learn';
          final mode =
              lessonPracticeModeFromPath(modeValue) ?? LessonPracticeMode.learn;
          return LessonPracticeScreen(
            lessonId: routeInt(state, 'id'),
            mode: mode,
          );
        },
      ),
      GoRoute(
        path: AppRoutePath.lessonLearnEnhanced,
        name: AppRouteName.lessonLearnEnhanced,
        redirect: (context, state) =>
            redirectToLessonPractice(state, LessonPracticeMode.learn),
      ),
      GoRoute(
        path: AppRoutePath.lessonWriteMode,
        name: AppRouteName.lessonWriteMode,
        redirect: (context, state) =>
            redirectToLessonPractice(state, LessonPracticeMode.write),
      ),
      GoRoute(
        path: AppRoutePath.lessonMatchMode,
        name: AppRouteName.lessonMatchMode,
        redirect: (context, state) =>
            redirectToLessonPractice(state, LessonPracticeMode.test),
      ),
    ],
  );
}
