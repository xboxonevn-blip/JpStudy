import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_shell_scaffold.dart';
import 'package:jpstudy/app/navigation/routes/exam_routes.dart';
import 'package:jpstudy/app/navigation/routes/foundations_routes.dart';
import 'package:jpstudy/app/navigation/routes/grammar_routes.dart';
import 'package:jpstudy/app/navigation/routes/home_routes.dart';
import 'package:jpstudy/app/navigation/routes/kanji_routes.dart';
import 'package:jpstudy/app/navigation/routes/memory_routes.dart';
import 'package:jpstudy/app/navigation/routes/meta_routes.dart';
import 'package:jpstudy/app/navigation/routes/practice_routes.dart';
import 'package:jpstudy/app/navigation/routes/vocab_routes.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/onboarding/language_select_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: AppRoutePath.onboardingLanguage,
        name: AppRouteName.onboardingLanguage,
        builder: (context, state) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: AppRoutePath.onboardingLevel,
        name: AppRouteName.onboardingLevel,
        builder: (context, state) => const HomeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [
          buildKanjiBranch(),
          buildFoundationsBranch(),
          buildVocabBranch(),
          buildGrammarBranch(),
          buildHomeBranch(),
          buildMemoryBranch(),
          buildPracticeBranch(),
          buildExamBranch(),
          buildLeaderboardBranch(),
          buildPremiumBranch(),
          buildProfileBranch(),
        ],
      ),
    ],
  );
}
