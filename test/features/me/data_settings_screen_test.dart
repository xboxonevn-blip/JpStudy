import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'backup.auto.enabled': true});
  });

  testWidgets('Data settings screen shows backup and linked file controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          cloudSyncStatusProvider.overrideWith(
            (ref) async => const CloudSyncStatus(
              target: null,
              lastSyncedAt: null,
              lastRemoteExportedAt: null,
              lastDirection: null,
            ),
          ),
        ],
        child: const MaterialApp(home: DataSettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Data controls'), findsAtLeastNWidgets(1));
    expect(find.text('Linked sync file'), findsAtLeastNWidgets(1));
    expect(find.text('Manual backup', skipOffstage: false), findsOneWidget);
  });
}
