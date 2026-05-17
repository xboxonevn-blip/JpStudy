import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/features/exam/exam_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_coach_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_mock_pro_screen.dart';
import 'package:jpstudy/features/jlpt/screens/jlpt_reading_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:jpstudy/features/test/models/home_mock_exam_launch_args.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';
import 'package:jpstudy/features/test/screens/test_history_screen.dart';

StatefulShellBranch buildExamBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.examCenter,
        name: AppRouteName.examCenter,
        builder: (context, state) => const ExamCenterHubScreen(),
      ),
      GoRoute(
        path: AppRoutePath.practiceMockExam,
        name: AppRouteName.practiceMockExam,
        builder: (context, state) => HomeMockExamScreen(
          launchArgs: state.extra is HomeMockExamLaunchArgs
              ? state.extra as HomeMockExamLaunchArgs
              : null,
        ),
      ),
      GoRoute(
        path: AppRoutePath.jlptCoach,
        name: AppRouteName.jlptCoach,
        builder: (context, state) => const JlptCoachScreen(),
      ),
      GoRoute(
        path: AppRoutePath.jlptReading,
        name: AppRouteName.jlptReading,
        builder: (context, state) => const JlptReadingScreen(),
      ),
      GoRoute(
        path: AppRoutePath.jlptMockPro,
        name: AppRouteName.jlptMockPro,
        builder: (context, state) => const JlptMockProScreen(),
      ),
      GoRoute(
        path: AppRoutePath.exam,
        name: AppRouteName.exam,
        builder: (context, state) => const ExamScreen(),
      ),
      GoRoute(
        path: AppRoutePath.lessonTestEnhanced,
        name: AppRouteName.lessonTestEnhanced,
        redirect: (context, state) =>
            redirectToLessonPractice(state, LessonPracticeMode.test),
      ),
      GoRoute(
        path: AppRoutePath.lessonTestHistory,
        name: AppRouteName.lessonTestHistory,
        builder: (context, state) => TestHistoryScreen(
          lessonId: routeInt(state, 'id'),
          lessonTitle: routeLessonTitle(state),
        ),
      ),
    ],
  );
}
