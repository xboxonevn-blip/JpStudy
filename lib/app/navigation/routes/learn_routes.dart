import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/routes/foundations_routes.dart';
import 'package:jpstudy/app/navigation/routes/grammar_routes.dart';
import 'package:jpstudy/app/navigation/routes/kanji_routes.dart';
import 'package:jpstudy/app/navigation/routes/vocab_routes.dart';
import 'package:jpstudy/features/learn/learn_hub_screen.dart';

StatefulShellBranch buildLearnBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.learn,
        name: AppRouteName.learn,
        builder: (context, state) => const LearnHubScreen(),
      ),
      ...buildKanjiRoutes(),
      ...buildFoundationsRoutes(),
      ...buildVocabRoutes(),
      ...buildGrammarRoutes(),
    ],
  );
}
