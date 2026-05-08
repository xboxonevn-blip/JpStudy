import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/features/foundations/screens/foundations_hub_screen.dart';
import 'package:jpstudy/features/foundations/screens/han_viet_reference_screen.dart';
import 'package:jpstudy/features/foundations/screens/kana_table_screen.dart';

List<RouteBase> buildFoundationsRoutes() {
  return [
    GoRoute(
      path: AppRoutePath.foundations,
      name: AppRouteName.foundations,
      builder: (context, state) => const FoundationsHubScreen(),
    ),
    GoRoute(
      path: AppRoutePath.foundationsCompounds,
      name: AppRouteName.foundationsCompounds,
      builder: (context, state) => const KanaTableScreen(
        script: KanaScript.hiragana,
        initialView: KanaView.compound,
      ),
    ),
    GoRoute(
      path: AppRoutePath.foundationsKana,
      name: AppRouteName.foundationsKana,
      builder: (context, state) {
        final script = state.pathParameters['script'] == 'katakana'
            ? KanaScript.katakana
            : KanaScript.hiragana;
        return KanaTableScreen(script: script, initialView: KanaView.base);
      },
    ),
    GoRoute(
      path: AppRoutePath.foundationsHanViet,
      name: AppRouteName.foundationsHanViet,
      builder: (context, state) => const HanVietReferenceScreen(),
    ),
  ];
}
