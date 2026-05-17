import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/features/leaderboard/leaderboard_screen.dart';
import 'package:jpstudy/features/legal/legal_document_screen.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:jpstudy/features/premium/premium_screen.dart';
import 'package:jpstudy/features/progress/screens/mastery_dashboard_screen.dart';
import 'package:jpstudy/features/progress/screens/review_forecast_screen.dart';

StatefulShellBranch buildLeaderboardBranch() {
  return StatefulShellBranch(routes: buildLeaderboardRoutes());
}

List<RouteBase> buildLeaderboardRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.leaderboard,
      name: AppRouteName.leaderboard,
      builder: (context, state) => const LeaderboardScreen(),
    ),
  ];
}

StatefulShellBranch buildPremiumBranch() {
  return StatefulShellBranch(routes: buildPremiumRoutes());
}

List<RouteBase> buildPremiumRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.premium,
      name: AppRouteName.premium,
      builder: (context, state) => const PremiumScreen(),
    ),
  ];
}

StatefulShellBranch buildProfileBranch() {
  return StatefulShellBranch(
    routes: [
      ...buildProfileRoutes(),
      ...buildLeaderboardRoutes(),
      ...buildPremiumRoutes(),
    ],
  );
}

List<RouteBase> buildProfileRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.me,
      name: AppRouteName.me,
      builder: (context, state) => const MeScreen(),
    ),
    GoRoute(
      path: AppRoutePath.community,
      name: AppRouteName.community,
      redirect: (context, state) => AppRoutePath.me,
    ),
    GoRoute(
      path: AppRoutePath.mastery,
      name: AppRouteName.mastery,
      builder: (context, state) => const MasteryDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutePath.meData,
      name: AppRouteName.meData,
      builder: (context, state) => const DataSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutePath.forecast,
      name: AppRouteName.forecast,
      builder: (context, state) => const ReviewForecastScreen(),
    ),
    GoRoute(
      path: AppRoutePath.privacy,
      name: AppRouteName.privacy,
      builder: (context, state) =>
          const LegalDocumentScreen(kind: LegalDocumentKind.privacy),
    ),
    GoRoute(
      path: AppRoutePath.terms,
      name: AppRouteName.terms,
      builder: (context, state) =>
          const LegalDocumentScreen(kind: LegalDocumentKind.terms),
    ),
  ];
}
