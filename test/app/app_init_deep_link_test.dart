import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/app.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() {
    AppRouter.router.go(AppRoutePath.home);
  });

  testWidgets('app bootstrap loads persisted level on direct grammar link', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      prefOnboardingCompleted: true,
      prefOnboardingLevel: 'n3',
      prefOnboardingGoal: 'jlpt',
      'app.locale': 'en',
      'analytics.consent': false,
      'foundations.softSuggest.grammar.shown': true,
    });
    final prefs = await SharedPreferences.getInstance();

    AppRouter.router.go(AppRoutePath.grammar);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        grammarPointsProvider('N3').overrideWith((_) async => const []),
        grammarPointsProvider('N5').overrideWith((_) async => const []),
        grammarDueCountProvider.overrideWith((_) async => 0),
        grammarGhostCountProvider.overrideWith((_) => Stream.value(0)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TickerMode(enabled: false, child: App()),
      ),
    );

    await tester.pump();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Grammar (N3)').evaluate().isNotEmpty) {
        break;
      }
    }

    expect(
      AppRouter.router.routeInformationProvider.value.uri.path,
      AppRoutePath.grammar,
    );
    expect(container.read(studyLevelProvider), StudyLevel.n3);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
