import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_consent_banner.dart';
import 'package:jpstudy/core/analytics/analytics_consent_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  testWidgets('shows consent banner until user chooses', (tester) async {
    final preferences = await _prefs({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const MaterialApp(
          home: AnalyticsConsentBanner(child: SizedBox.shrink()),
        ),
      ),
    );

    expect(find.text('Help improve JpStudy'), findsOneWidget);

    await tester.tap(find.text('No thanks'));
    await tester.pump();

    expect(preferences.getBool(prefAnalyticsConsent), isFalse);
    expect(find.text('Help improve JpStudy'), findsNothing);
  });
}
