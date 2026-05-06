import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
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

    await pumpSmokeRoute(tester, AppRoutePath.studyHub);
    expect(find.byType(StudyHubScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.search);
    expect(find.byType(SearchScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.examCenter);
    expect(find.byType(HomeMockExamScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.progress);
    expect(find.byType(ProgressScreen), findsOneWidget);

    await pumpSmokeRoute(tester, AppRoutePath.meData);
    expect(find.byType(DataSettingsScreen), findsOneWidget);

    await disposeSmokeApp(tester);
  });
}
