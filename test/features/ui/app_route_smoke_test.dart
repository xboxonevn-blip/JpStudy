import 'dart:ui';

import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/release_smoke_harness.dart';
import '../../support/route_smoke_helpers.dart';

void main() {
  testWidgets('App shell routes stay mountable across core study screens', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await pumpSmokeRoute(tester, AppRoutePath.home);
    expect(find.text('Start session'), findsOneWidget);
    expect(find.text('JLPT prep'), findsAtLeastNWidgets(1));

    await pumpSmokeRoute(tester, AppRoutePath.study);
    expect(find.text('Today plan'), findsOneWidget);
    expect(find.text('Run Recall Sprint first'), findsWidgets);

    await pumpSmokeRoute(tester, AppRoutePath.library);
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.search);
    expect(find.text('Lookup'), findsAtLeastNWidgets(1));
    expect(find.text('Current search set'), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.progress);
    expect(find.text('Progress (N5)'), findsWidgets);

    await pumpSmokeRoute(tester, AppRoutePath.me);
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.meData);
    expect(find.text('Data controls'), findsAtLeastNWidgets(1));
    expect(find.text('Manual backup', skipOffstage: false), findsOneWidget);
  });
}
