import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/features/games/kanji_dash/kanji_dash_screen.dart';
import 'package:jpstudy/features/foundations/screens/han_viet_reference_screen.dart';
import 'package:jpstudy/features/kanji_hub/kanji_hub_screen.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/kanji_hub/screens/kanji_practice_hub_screen.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';

StatefulShellBranch buildKanjiBranch() {
  return StatefulShellBranch(routes: buildKanjiRoutes());
}

List<RouteBase> buildKanjiRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.kanji,
      name: AppRouteName.kanji,
      builder: (context, state) => KanjiHubScreen(
        initialKanjiId: int.tryParse(
          state.uri.queryParameters['kanjiId'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: AppRoutePath.kanjiHanViet,
      name: AppRouteName.kanjiHanViet,
      builder: (context, state) =>
          const HanVietReferenceGate(fallbackPath: AppRoutePath.kanji),
    ),
    GoRoute(
      path: AppRoutePath.kanjiPractice,
      name: AppRouteName.kanjiPractice,
      builder: (context, state) => KanjiPracticeHubScreen(
        launchArgs: state.extra is KanjiPracticeArgs
            ? state.extra as KanjiPracticeArgs
            : null,
      ),
    ),
    GoRoute(
      path: AppRoutePath.handwritingPractice,
      name: AppRouteName.handwritingPractice,
      builder: (context, state) => HomeHandwritingPracticeScreen(
        launchArgs: state.extra is KanjiPracticeArgs
            ? state.extra as KanjiPracticeArgs
            : null,
      ),
    ),
    GoRoute(
      path: AppRoutePath.kanjiReadingPractice,
      name: AppRouteName.kanjiReadingPractice,
      builder: (context, state) => HomeKanjiReadingScreen(
        launchArgs: state.extra is KanjiPracticeArgs
            ? state.extra as KanjiPracticeArgs
            : null,
      ),
    ),
    GoRoute(
      path: AppRoutePath.kanjiDash,
      name: AppRouteName.kanjiDash,
      builder: (context, state) => const KanjiDashScreen(),
    ),
  ];
}
