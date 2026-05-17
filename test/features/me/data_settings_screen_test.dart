import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/analytics/analytics_provider.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';
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

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  int resetCount = 0;

  @override
  Future<void> resetAnalyticsData() async {
    resetCount += 1;
  }
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
  AnalyticsService? analyticsService,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      authStateProvider.overrideWith((ref) => Stream.value(signedInUser)),
      cloudSyncStatusProvider.overrideWith((ref) async => status),
      dataSettingsControllerProvider.overrideWith(
        () => _FakeDataSettingsController(state),
      ),
      if (analyticsService != null)
        analyticsServiceProvider.overrideWithValue(analyticsService),
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
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);
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

    expect(find.text('Backup when you choose'), findsOneWidget);
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

  testWidgets('shows account cloud backup as beta-disabled', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Account sync'), findsOneWidget);
    expect(
      find.text('Cloud backup is planned for a future release.'),
      findsOneWidget,
    );
    expect(find.text('Auto-upload to cloud'), findsNothing);
    expect(find.text('Upload to cloud'), findsNothing);
    expect(find.text('Pull from cloud'), findsNothing);
  });

  testWidgets(
    'keeps local backup/export visible while account cloud is disabled',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          signedInUser: const AuthUser(uid: 'uid-1', email: 'user@example.com'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manual backup', skipOffstage: false), findsOneWidget);
      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Import backup'), findsOneWidget);
      expect(
        find.text('Cloud backup is planned for a future release.'),
        findsOneWidget,
      );
      expect(find.text('Auto-upload to cloud'), findsNothing);
    },
  );

  testWidgets('copies support ID for deletion support requests', (
    tester,
  ) async {
    final clipboardCalls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboardCalls.add(call);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      buildScreen(
        signedInUser: const AuthUser(uid: 'uid-1', email: 'user@example.com'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Support ID'), findsOneWidget);
    expect(
      find.text('Use this ID for support or data deletion requests: uid-1'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Support ID'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Support ID'));
    await tester.pumpAndSettle();

    expect(clipboardCalls, hasLength(1));
    expect(clipboardCalls.single.arguments, {'text': 'uid-1'});
    expect(find.text('Support ID copied.'), findsOneWidget);
  });

  testWidgets('resets analytics data on this device after confirmation', (
    tester,
  ) async {
    final fakeAnalytics = _FakeFirebaseAnalytics();
    await tester.pumpWidget(
      buildScreen(analyticsService: AnalyticsService(instance: fakeAnalytics)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Usage data'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset usage data on this device'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset usage data'));
    await tester.pumpAndSettle();

    expect(fakeAnalytics.resetCount, 1);
    expect(find.text('Usage data reset on this device.'), findsOneWidget);
  });
}
