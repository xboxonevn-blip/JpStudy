import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/features/achievements/achievements_screen.dart';
import 'package:jpstudy/features/flashcards/integration/flashcard_mode_integration.dart';
import 'package:jpstudy/features/learn/screens/recovery_pack_screen.dart';
import 'package:jpstudy/features/mistakes/screens/mistake_screen.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';

StatefulShellBranch buildMemoryBranch() {
  return StatefulShellBranch(routes: buildMemoryRoutes());
}

List<RouteBase> buildMemoryRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.memory,
      name: AppRouteName.memory,
      builder: (context, state) => const StudyHubScreen(),
    ),
    GoRoute(
      path: AppRoutePath.studyHub,
      name: AppRouteName.studyHub,
      builder: (context, state) => const StudyHubScreen(),
    ),
    GoRoute(
      path: AppRoutePath.mistakes,
      name: AppRouteName.mistakes,
      builder: (context, state) => const MistakeScreen(),
    ),
    GoRoute(
      path: AppRoutePath.lessonFlashcardsEnhanced,
      name: AppRouteName.lessonFlashcardsEnhanced,
      builder: (context, state) => FlashcardModeIntegration(
        lessonId: routeInt(state, 'id'),
        lessonTitle: routeLessonTitle(state),
      ),
    ),
    GoRoute(
      path: AppRoutePath.learnRecoveryPack,
      name: AppRouteName.learnRecoveryPack,
      builder: (context, state) => const RecoveryPackScreen(),
    ),
    GoRoute(
      path: AppRoutePath.achievements,
      name: AppRouteName.achievements,
      builder: (context, state) => const AchievementsScreen(),
    ),
  ];
}
