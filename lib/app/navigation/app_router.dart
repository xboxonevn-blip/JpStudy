import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_shell_scaffold.dart';
import 'package:jpstudy/app/navigation/routes/exam_routes.dart';
import 'package:jpstudy/app/navigation/routes/home_routes.dart';
import 'package:jpstudy/app/navigation/routes/learn_routes.dart';
import 'package:jpstudy/app/navigation/routes/meta_routes.dart';
import 'package:jpstudy/app/navigation/routes/review_routes.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/onboarding/language_select_screen.dart';
import 'package:jpstudy/features/onboarding/level_select_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static SharedPreferences? _preferences;

  static final GoRouter router = createRouter();

  static void configurePreferences(SharedPreferences preferences) {
    _preferences = preferences;
  }

  static GoRouter createRouter({
    SharedPreferences? preferences,
    String initialLocation = AppRoutePath.home,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) =>
          _onboardingRedirect(state.uri, preferences ?? _preferences),
      routes: [
        GoRoute(
          path: AppRoutePath.onboardingLanguage,
          name: AppRouteName.onboardingLanguage,
          builder: (context, state) => const LanguageSelectScreen(),
        ),
        GoRoute(
          path: AppRoutePath.onboardingLevel,
          name: AppRouteName.onboardingLevel,
          builder: (context, state) => const LevelSelectScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShellScaffold(navigationShell: navigationShell),
          branches: [
            buildHomeBranch(),
            buildLearnBranch(),
            buildReviewBranch(),
            buildExamBranch(),
            buildProfileBranch(),
          ],
        ),
      ],
    );
  }

  static String? _onboardingRedirect(
    Uri currentUri,
    SharedPreferences? preferences,
  ) {
    if (preferences == null) {
      return null;
    }

    final path = currentUri.path;
    final isLanguageRoute = path == AppRoutePath.onboardingLanguage;
    final isLevelRoute = path == AppRoutePath.onboardingLevel;
    final isOnboardingRoute = isLanguageRoute || isLevelRoute;
    final from = _encodedReturnTarget(currentUri);

    final hasLocale = preferences.getString(prefAppLocale) != null;
    if (!hasLocale) {
      return isLanguageRoute
          ? null
          : '${AppRoutePath.onboardingLanguage}?from=$from';
    }

    final completed = preferences.getBool(prefOnboardingCompleted) ?? false;
    final levelName = preferences.getString(prefOnboardingLevel);
    final hasValidLevel =
        levelName != null &&
        StudyLevel.values.any((level) => level.name == levelName);
    if (!completed || !hasValidLevel) {
      return isLevelRoute ? null : '${AppRoutePath.onboardingLevel}?from=$from';
    }

    if (isOnboardingRoute) {
      return AppRoutePath.home;
    }
    return null;
  }

  static String _encodedReturnTarget(Uri uri) {
    final target = uri.toString().isEmpty ? AppRoutePath.home : uri.toString();
    return Uri.encodeComponent(target);
  }
}
