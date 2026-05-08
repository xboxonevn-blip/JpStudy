import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:jpstudy/features/me/screens/data_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDataSettingsController extends DataSettingsController {
  _FakeDataSettingsController(this._state);

  final DataSettingsState _state;

  @override
  DataSettingsState build() => _state;

  @override
  Future<void> initialize({BuildContext? hostContext}) async {}
}

const _unlinkedStatus = CloudSyncStatus(
  target: null,
  lastSyncedAt: null,
  lastRemoteExportedAt: null,
  lastDirection: null,
);

const _linkedStatus = CloudSyncStatus(
  target: CloudSyncTarget(
    path: '/tmp/jpstudy_linked_sync.json',
    displayName: 'jpstudy_linked_sync.json',
  ),
  lastSyncedAt: null,
  lastRemoteExportedAt: null,
  lastDirection: null,
);

final _downloadedStatus = CloudSyncStatus(
  target: CloudSyncTarget(
    path: '/tmp/jpstudy_linked_sync.json',
    displayName: 'jpstudy_linked_sync.json',
  ),
  lastSyncedAt: DateTime(2026, 3, 10, 8),
  lastRemoteExportedAt: DateTime(2026, 3, 10, 8),
  lastDirection: CloudSyncDirection.download,
);

Widget buildScreen({
  DataSettingsState state = const DataSettingsState(
    isReady: true,
    autoBackupEnabled: true,
  ),
  CloudSyncStatus status = _unlinkedStatus,
  AuthUser? signedInUser,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      authStateProvider.overrideWith((ref) => Stream.value(signedInUser)),
      cloudSyncStatusProvider.overrideWith((ref) async => status),
      dataSettingsControllerProvider.overrideWith(
        () => _FakeDataSettingsController(state),
      ),
    ],
    child: const MaterialApp(home: DataSettingsScreen()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'backup.auto.enabled': true});
  });

  testWidgets('shows backup and linked file sync controls', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Data controls'), findsAtLeastNWidgets(1));
    expect(find.text('Linked file sync'), findsAtLeastNWidgets(1));
    expect(find.byKey(const ValueKey('linked_sync_headline')), findsOneWidget);
    expect(find.text('How linked file sync works'), findsOneWidget);
    expect(find.text('Manual backup', skipOffstage: false), findsOneWidget);
  });

  testWidgets('shows loading indicator when settings are not ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        state: const DataSettingsState(
          isReady: false,
          autoBackupEnabled: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows auto-backup on status when enabled', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        state: const DataSettingsState(isReady: true, autoBackupEnabled: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Auto backup on'), findsOneWidget);
  });

  testWidgets('shows manual-only status when auto backup disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        state: const DataSettingsState(isReady: true, autoBackupEnabled: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manual only'), findsOneWidget);
  });

  testWidgets('shows unlink button only when linked file exists', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(status: _linkedStatus));
    await tester.pumpAndSettle();

    expect(find.text('Remove link'), findsOneWidget);
  });

  testWidgets('does not show unlink button when linked file is not set', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(status: _unlinkedStatus));
    await tester.pumpAndSettle();

    expect(find.text('Remove link'), findsNothing);
  });

  testWidgets('shows choose/create/upload/download linked actions', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(status: _linkedStatus));
    await tester.pumpAndSettle();

    expect(find.text('Choose file'), findsOneWidget);
    expect(find.text('Create file'), findsOneWidget);
    expect(find.text('Upload snapshot'), findsOneWidget);
    expect(find.text('Download snapshot'), findsOneWidget);
  });

  testWidgets('shows setup recommendation when no file is linked', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(status: _unlinkedStatus));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('linked_sync_headline')), findsOneWidget);
    expect(
      find.text('Create or choose one shared JSON file first.'),
      findsOneWidget,
    );
    expect(find.text('Create shared file'), findsOneWidget);
    expect(find.text('Not linked yet'), findsOneWidget);
  });

  testWidgets('shows upload recommendation after device already downloaded', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(status: _downloadedStatus));
    await tester.pumpAndSettle();

    expect(
      find.text('This device has already pulled from the shared file.'),
      findsOneWidget,
    );
    expect(find.text('Upload latest snapshot'), findsOneWidget);
    expect(find.text('jpstudy_linked_sync.json'), findsWidgets);
  });

  testWidgets('shows auto backup time row with formatted time', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        state: const DataSettingsState(
          isReady: true,
          autoBackupEnabled: true,
          autoBackupTime: TimeOfDay(hour: 2, minute: 30),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backup time'), findsOneWidget);
    expect(find.textContaining('2'), findsWidgets);
  });

  testWidgets('shows last auto backup label when timestamp exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        state: DataSettingsState(
          isReady: true,
          autoBackupEnabled: true,
          lastAutoBackup: DateTime(2026, 3, 10),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Last:'), findsOneWidget);
  });

  testWidgets('keeps account sync discoverable when signed out', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Account sync'), findsOneWidget);
    expect(find.text('Please sign in to use cloud sync.'), findsOneWidget);
    expect(find.text('Upload to cloud'), findsNothing);
    expect(find.text('Pull from cloud'), findsNothing);
  });
}
