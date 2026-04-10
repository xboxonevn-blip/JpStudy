import 'dart:ui';

import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import '../../support/release_smoke_harness.dart';

void main() {
  testWidgets('App shell routes stay mountable across core study screens', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    Future<void> pumpRoute(String route) async {
      AppRouter.router.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await pumpRoute(AppRoutePath.home);
    expect(find.text('Start session'), findsOneWidget);
    expect(find.text('JLPT prep'), findsAtLeastNWidgets(1));

    await pumpRoute(AppRoutePath.study);
    expect(find.text('Today plan'), findsOneWidget);
    expect(find.text('Run Recall Sprint first'), findsWidgets);

    await pumpRoute(AppRoutePath.library);
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);

    await pumpRoute(AppRoutePath.search);
    expect(find.text('Lookup'), findsAtLeastNWidgets(1));
    expect(find.text('Current search bank'), findsOneWidget);

    await pumpRoute(AppRoutePath.progress);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Review history'), findsOneWidget);

    await pumpRoute(AppRoutePath.me);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);

    await pumpRoute(AppRoutePath.meData);
    expect(find.text('Data controls'), findsAtLeastNWidgets(1));
    expect(find.text('Manual backup', skipOffstage: false), findsOneWidget);
  });
}
