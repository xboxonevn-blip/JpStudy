import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_route_builders.dart';
import 'package:jpstudy/features/grammar/grammar_screen.dart';
import 'package:jpstudy/features/grammar/screens/grammar_detail_screen.dart';

StatefulShellBranch buildGrammarBranch() {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: AppRoutePath.grammar,
        name: AppRouteName.grammar,
        builder: (context, state) => const GrammarScreen(),
      ),
      GoRoute(
        path: AppRoutePath.grammarDetail,
        name: AppRouteName.grammarDetail,
        builder: (context, state) =>
            GrammarDetailScreen(grammarId: routeInt(state, 'id')),
      ),
      GoRoute(
        path: AppRoutePath.grammarPractice,
        name: AppRouteName.grammarPractice,
        builder: buildGrammarPracticeScreen,
      ),
    ],
  );
}
