import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/app_route_constants.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required SharedPreferences preferences,
  String initialLocation = AppRoutePath.home,
}) async {
  final router = AppRouter.createRouter(
    preferences: preferences,
    initialLocation: initialLocation,
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  testWidgets('clear prefs redirect root to language onboarding', (
    tester,
  ) async {
    await _pumpRouter(tester, preferences: await _prefs({}));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);
  });

  testWidgets('locale without completed onboarding redirects to level screen', (
    tester,
  ) async {
    await _pumpRouter(tester, preferences: await _prefs({prefAppLocale: 'vi'}));

    expect(find.text('Chọn cấp độ JLPT của bạn'), findsOneWidget);
  });

  testWidgets('completed onboarding with valid level allows deep link', (
    tester,
  ) async {
    await _pumpRouter(
      tester,
      initialLocation: AppRoutePath.privacy,
      preferences: await _prefs({
        prefAppLocale: 'en',
        prefOnboardingCompleted: true,
        prefOnboardingLevel: 'n3',
      }),
    );

    expect(find.text('Privacy Policy'), findsWidgets);
  });

  testWidgets('deep link keeps return target through onboarding', (
    tester,
  ) async {
    final preferences = await _prefs({});
    final router = await _pumpRouter(
      tester,
      initialLocation: AppRoutePath.grammar,
      preferences: preferences,
    );

    expect(find.text('Choose your language'), findsOneWidget);
    expect(
      router.routeInformationProvider.value.uri.queryParameters['from'],
      AppRoutePath.grammar,
    );

    router.go(AppRoutePath.privacy);
    await tester.pump();
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('Tiếng Việt'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('language_continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('level_start')), findsOneWidget);

    await tester.tap(find.text('N3'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('level_start')));
    await tester.pump();

    expect(preferences.getBool(prefOnboardingCompleted), isTrue);
    expect(preferences.getString(prefOnboardingLevel), 'n3');
  });
}
