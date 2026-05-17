import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/features/games/match_game/lesson_match_screen.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/home/screens/daily_session_summary_screen.dart';
import 'package:jpstudy/features/learn/integration/learn_mode_integration.dart';
import 'package:jpstudy/features/learn/integration/write_mode_integration.dart';
import 'package:jpstudy/features/library/library_screen.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:jpstudy/features/lesson/lesson_edit_screen.dart';
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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutePath.today,
        name: AppRouteName.today,
        builder: (context, state) => const HomeScreen(),
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
        builder: (context, state) =>
            LessonEditScreen(lessonId: routeInt(state, 'id')),
      ),
      GoRoute(
        path: AppRoutePath.lessonPractice,
        name: AppRouteName.lessonPractice,
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
        builder: (context, state) => LearnModeIntegration(
          lessonId: routeInt(state, 'id'),
          lessonTitle: routeLessonTitle(state),
        ),
      ),
      GoRoute(
        path: AppRoutePath.lessonWriteMode,
        name: AppRouteName.lessonWriteMode,
        builder: (context, state) => WriteModeIntegration(
          lessonId: routeInt(state, 'id'),
          lessonTitle: routeLessonTitle(state),
        ),
      ),
      GoRoute(
        path: AppRoutePath.lessonMatchMode,
        name: AppRouteName.lessonMatchMode,
        builder: (context, state) => LessonMatchScreen(
          lessonId: routeInt(state, 'id'),
          lessonTitle: routeLessonTitle(state),
        ),
      ),
    ],
  );
}
