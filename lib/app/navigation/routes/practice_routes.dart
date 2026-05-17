import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/features/custom_decks/custom_decks_screen.dart';
import 'package:jpstudy/features/games/match_game/match_game_screen.dart';
import 'package:jpstudy/features/immersion/immersion_home_screen.dart';
import 'package:jpstudy/features/practice/models/recall_sprint_strategy.dart';
import 'package:jpstudy/features/practice/practice_screen.dart';
import 'package:jpstudy/features/practice/screens/recall_sprint_screen.dart';

StatefulShellBranch buildPracticeBranch() {
  return StatefulShellBranch(routes: buildPracticeRoutes());
}

List<RouteBase> buildPracticeRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.review,
      name: AppRouteName.review,
      builder: (context, state) => const PracticeScreen(),
    ),
    GoRoute(
      path: AppRoutePath.active,
      name: AppRouteName.active,
      builder: (context, state) => const CustomDecksScreen(),
    ),
    GoRoute(
      path: AppRoutePath.study,
      name: AppRouteName.study,
      builder: (context, state) => const PracticeScreen(),
    ),
    GoRoute(
      path: AppRoutePath.practice,
      name: AppRouteName.practice,
      builder: (context, state) => const PracticeScreen(),
    ),
    GoRoute(
      path: AppRoutePath.match,
      name: AppRouteName.match,
      builder: (context, state) => const MatchGameScreen(),
    ),
    GoRoute(
      path: AppRoutePath.immersion,
      name: AppRouteName.immersion,
      builder: (context, state) => const ImmersionHomeScreen(),
    ),
    GoRoute(
      path: AppRoutePath.practiceRecallSprint,
      name: AppRouteName.practiceRecallSprint,
      builder: (context, state) => RecallSprintScreen(
        launchArgs: state.extra is RecallSprintArgs
            ? state.extra as RecallSprintArgs
            : null,
      ),
    ),
    GoRoute(
      path: AppRoutePath.learnSession,
      name: AppRouteName.learnSession,
      builder: buildLearnScreenFromArgs,
    ),
  ];
}
