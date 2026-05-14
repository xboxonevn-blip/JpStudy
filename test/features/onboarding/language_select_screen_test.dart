import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/onboarding/language_select_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<({Widget app, SharedPreferences prefs})> buildApp() async {
    SharedPreferences.setMockInitialValues({'app.locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: AppRoutePath.onboardingLanguage,
      routes: [
        GoRoute(
          path: AppRoutePath.onboardingLanguage,
          builder: (context, state) => const LanguageSelectScreen(),
        ),
        GoRoute(
          path: AppRoutePath.onboardingLevel,
          builder: (context, state) =>
              const Scaffold(body: Text('level-route')),
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

  testWidgets('renders three language options and locks Continue initially', (
    tester,
  ) async {
    final host = await buildApp();
    await tester.pumpWidget(host.app);
    await tester.pumpAndSettle();

    expect(find.text('Tiếng Việt'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);

    final continueButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('language_continue')),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('Vietnamese selection persists locale and routes to level step', (
    tester,
  ) async {
    final host = await buildApp();
    await tester.pumpWidget(host.app);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pump();

    final continueButton = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('language_continue')),
    );
    expect(continueButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('language_continue')));
    await tester.pumpAndSettle();

    expect(host.prefs.getString(prefAppLocale), AppLanguage.vi.name);
    expect(find.text('level-route'), findsOneWidget);
  });

  testWidgets('English selection persists locale and routes to level step', (
    tester,
  ) async {
    final host = await buildApp();
    await tester.pumpWidget(host.app);
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('language_continue')));
    await tester.pumpAndSettle();

    expect(host.prefs.getString(prefAppLocale), AppLanguage.en.name);
    expect(find.text('level-route'), findsOneWidget);
  });

  testWidgets('Japanese selection sets N3, completes onboarding, and skips level', (
    tester,
  ) async {
    final host = await buildApp();
    await tester.pumpWidget(host.app);
    await tester.pumpAndSettle();

    await tester.tap(find.text('日本語'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('language_continue')));
    await tester.pumpAndSettle();

    expect(host.prefs.getString(prefAppLocale), AppLanguage.ja.name);
    expect(host.prefs.getString(prefOnboardingLevel), StudyLevel.n3.name);
    expect(host.prefs.getBool(prefOnboardingCompleted), isTrue);
    expect(find.text('home-route'), findsOneWidget);
  });
}
