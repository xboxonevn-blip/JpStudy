import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:jpstudy/features/study_hub/study_hub_screen.dart';
import 'package:jpstudy/features/test/screens/home_mock_exam_screen.dart';

import '../../support/release_smoke_harness.dart';

Future<void> _goToRoute(WidgetTester tester, String path) async {
  AppRouter.router.go(path);
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _disposeSmokeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.idle();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('core shell routes resolve to their primary screens', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await _goToRoute(tester, AppRoutePath.studyHub);
    expect(find.byType(StudyHubScreen), findsOneWidget);

    await _goToRoute(tester, AppRoutePath.search);
    expect(find.byType(SearchScreen), findsOneWidget);

    await _goToRoute(tester, AppRoutePath.examCenter);
    expect(find.byType(HomeMockExamScreen), findsOneWidget);

    await _goToRoute(tester, AppRoutePath.progress);
    expect(find.byType(ProgressScreen), findsOneWidget);

    await _goToRoute(tester, AppRoutePath.meData);
    expect(find.byType(DataSettingsScreen), findsOneWidget);

    await _disposeSmokeApp(tester);
  });
}
