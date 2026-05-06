import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_router.dart';

import '../../support/route_smoke_helpers.dart';
import '../../support/release_smoke_harness.dart';

void main() {
  testWidgets('exam-center route stays mountable', (tester) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.examCenter);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.examCenter,
    );
    expect(find.textContaining('Mock Exam'), findsWidgets);

    await disposeSmokeApp(tester);
  });

  testWidgets('practice mock exam route stays mountable', (tester) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.practiceMockExam);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.practiceMockExam,
    );
    expect(find.textContaining('Mock Exam'), findsWidgets);

    await disposeSmokeApp(tester);
  });

  testWidgets('jlpt coach route stays mountable', (tester) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.jlptCoach);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.jlptCoach,
    );
    expect(find.text('JLPT Prep'), findsWidgets);
    expect(find.text('JLPT N5 prep hub'), findsOneWidget);
    expect(find.textContaining('mock'), findsWidgets);
    expect(find.textContaining('Reading'), findsWidgets);

    await disposeSmokeApp(tester);
  });

  testWidgets('study route targets stay mountable', (tester) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.learnSession);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.learnSession,
    );
    await pumpSmokeRoute(tester, AppRoutePath.grammarPractice);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.grammarPractice,
    );
    await pumpSmokeRoute(tester, AppRoutePath.kanjiPractice);
    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.kanjiPractice,
    );
    await disposeSmokeApp(tester);
  });
}
