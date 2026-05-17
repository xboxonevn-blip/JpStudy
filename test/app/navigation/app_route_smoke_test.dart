import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/features/learn/learn_hub_screen.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:jpstudy/features/practice/practice_screen.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';

import '../../support/release_smoke_harness.dart';
import '../../support/route_smoke_helpers.dart';

void main() {
  testWidgets('core shell routes resolve to their primary screens', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.learn);
    expect(find.byType(LearnHubScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.review);
    expect(find.byType(PracticeScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.memory);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/review');
    expect(find.byType(PracticeScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.active);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/review');
    expect(find.byType(PracticeScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.study);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/review');
    expect(find.byType(PracticeScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.community);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/me');
    expect(find.byType(MeScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.studyHub);
    expect(find.byType(StudyHubScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.search);
    expect(find.byType(SearchScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.examCenter);
    expect(find.byType(ExamCenterHubScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.progress);
    expect(find.byType(ProgressScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.meData);
    expect(find.byType(DataSettingsScreen), findsOneWidget);

    await pumpSmokeRoute(tester, '/privacy');
    expect(find.text('Privacy Policy'), findsWidgets);
    expect(find.textContaining('review-needed draft'), findsWidgets);

    await pumpSmokeRoute(tester, '/terms');
    expect(find.text('Terms of Service'), findsWidgets);
    expect(find.textContaining('review-needed draft'), findsWidgets);

    await disposeSmokeApp(tester);
  });

  testWidgets('legacy home aliases redirect to canonical home route', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.roadmap);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/');

    await pumpSmokeRoute(tester, AppRoutePath.today);
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/');

    await disposeSmokeApp(tester);
  });

  testWidgets(
    'legacy lesson mode aliases redirect to canonical practice route',
    (tester) async {
      await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

      await pumpSmokeRoute(tester, '/lesson/1/learn-enhanced?title=Lesson%201');
      var uri = AppRouter.router.routeInformationProvider.value.uri;
      expect(uri.path, '/lesson/1/practice/learn');
      expect(uri.queryParameters['title'], 'Lesson 1');

      await pumpSmokeRoute(tester, '/lesson/1/flashcards-enhanced');
      uri = AppRouter.router.routeInformationProvider.value.uri;
      expect(uri.path, '/lesson/1/practice/learn');

      await pumpSmokeRoute(tester, '/lesson/1/test-enhanced');
      uri = AppRouter.router.routeInformationProvider.value.uri;
      expect(uri.path, '/lesson/1/practice/test');

      await pumpSmokeRoute(tester, '/lesson/1/write-mode');
      uri = AppRouter.router.routeInformationProvider.value.uri;
      expect(uri.path, '/lesson/1/practice/write');

      await pumpSmokeRoute(tester, '/lesson/1/match-mode');
      uri = AppRouter.router.routeInformationProvider.value.uri;
      expect(uri.path, '/lesson/1/practice/test');

      await pumpSmokeRoute(tester, '/lesson/1/practice/match');
      uri = AppRouter.router.routeInformationProvider.value.uri;
      expect(uri.path, '/lesson/1/practice/test');

      await disposeSmokeApp(tester);
    },
  );

  testWidgets('curriculum lesson edit route redirects to lesson detail', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, '/lesson/1/edit');
    final uri = AppRouter.router.routeInformationProvider.value.uri;
    expect(uri.path, '/lesson/1');

    await disposeSmokeApp(tester);
  });
}
