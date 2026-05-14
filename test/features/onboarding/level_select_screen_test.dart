import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/onboarding/level_select_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<({Widget app, SharedPreferences prefs})> buildApp() async {
    SharedPreferences.setMockInitialValues({'app.locale': 'vi'});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: AppRoutePath.onboardingLevel,
      routes: [
        GoRoute(
          path: AppRoutePath.onboardingLevel,
          builder: (context, state) => const LevelSelectScreen(),
        ),
        GoRoute(
          path: AppRoutePath.home,
          builder: (context, state) => const Scaffold(body: Text('home-route')),
        ),
      ],
    );

    return (
      app: ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
      prefs: prefs,
    );
  }

  testWidgets('renders five JLPT choices with localized taglines', (
    tester,
  ) async {
    final host = await buildApp();
    await tester.pumpWidget(host.app);
    await tester.pumpAndSettle();

    expect(find.text('N5'), findsOneWidget);
    expect(find.text('N4'), findsOneWidget);
    expect(find.text('N3'), findsOneWidget);
    expect(find.text('N2'), findsOneWidget);
    expect(find.text('N1'), findsOneWidget);
    expect(find.text(AppLanguage.vi.levelN5Tagline), findsOneWidget);
    expect(find.text(AppLanguage.vi.levelN1Tagline), findsOneWidget);

    final startButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('level_start')),
    );
    expect(startButton.onPressed, isNull);
  });

  testWidgets('selecting a level enables start and completes onboarding', (
    tester,
  ) async {
    final host = await buildApp();
    await tester.pumpWidget(host.app);
    await tester.pumpAndSettle();

    await tester.tap(find.text('N3'));
    await tester.pump();

    final startButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('level_start')),
    );
    expect(startButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('level_start')));
    await tester.pumpAndSettle();

    expect(host.prefs.getString(prefOnboardingLevel), StudyLevel.n3.name);
    expect(host.prefs.getBool(prefOnboardingCompleted), isTrue);
    expect(find.text('home-route'), findsOneWidget);
  });
}
