import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupRepository extends LessonRepository {
  _FakeBackupRepository(super.db, super.contentDb);

  int importCalls = 0;
  Map<String, dynamic>? importedPayload;

  @override
  Future<Map<String, dynamic>> exportBackup() async {
    return {
      'version': 2,
      'exportedAt': DateTime(2026, 4, 12, 9).toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
    };
  }

  @override
  Future<void> importBackup(Map<String, dynamic> data) async {
    importCalls += 1;
    importedPayload = Map<String, dynamic>.from(data);
  }
}

void main() {
  late Directory tempDir;
  AppDatabase? appDb;
  ContentDatabase? contentDb;
  _FakeBackupRepository? repo;
  BuildContext? hostContext;
  DataSettingsController? controller;
  Future<void>? pendingDownload;

  final incomingAt = DateTime(2026, 4, 10, 8, 30);
  final lastAppliedAt = DateTime(2026, 4, 11, 16, 45);

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'backup.sync.lastAppliedAt': lastAppliedAt.toIso8601String(),
    });
    tempDir = Directory.systemTemp.createTempSync('jpstudy-conflict-surface-');
  });

  tearDown(() async {
    await contentDb?.close();
    await appDb?.close();
    if (tempDir.existsSync()) {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  Future<String> writeOlderBackup() async {
    final payload = {
      'version': 2,
      'exportedAt': incomingAt.toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
      'marker': 'incoming-older-payload',
    };
    final envelope = await BackupSyncService.buildExportEnvelope(payload);
    final jsonText = jsonEncode(envelope);
    final file = File('${tempDir.path}${Platform.pathSeparator}older.json');
    file.writeAsStringSync(jsonText, flush: true);
    return file.path;
  }

  void mockPlatformChannels() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );

    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    addTearDown(() {
      messenger.setMockMethodCallHandler(pathProviderChannel, null);
    });
  }

  Widget buildHarness() {
    final fakeRepo = repo!;
    return ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        lessonRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) {
              hostContext = context;
              controller = ref.read(dataSettingsControllerProvider.notifier);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void createRepository() {
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
    repo = _FakeBackupRepository(appDb!, contentDb!);
  }

  Future<void> openOlderImportDialog(WidgetTester tester) async {
    await tester.runAsync(() {
      pendingDownload = controller!.downloadFromCloudFile(
        hostContext!,
        AppLanguage.en,
      );
      return Future<void>.value();
    });
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Older backup detected').evaluate().isNotEmpty) {
        break;
      }
    }
  }

  testWidgets(
    'force applying older linked-file import imports payload and reports it',
    (tester) async {
      final backupPath = await writeOlderBackup();
      createRepository();
      await CloudSyncService.linkTarget(
        path: backupPath,
        displayName: 'older.json',
      );
      mockPlatformChannels();

      await tester.pumpWidget(buildHarness());
      await openOlderImportDialog(tester);

      expect(find.text('Older backup detected'), findsOneWidget);

      await tester.tap(find.text('Apply anyway'));
      await tester.pump();
      await tester.runAsync(
        () => pendingDownload!.timeout(const Duration(seconds: 5)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo!.importCalls, 1);
      expect(repo!.importedPayload?['marker'], 'incoming-older-payload');
      expect(find.text('Older backup applied'), findsOneWidget);
    },
  );

  testWidgets(
    'canceling older linked-file import leaves repository untouched',
    (tester) async {
      final backupPath = await writeOlderBackup();
      createRepository();
      await CloudSyncService.linkTarget(
        path: backupPath,
        displayName: 'older.json',
      );
      mockPlatformChannels();

      await tester.pumpWidget(buildHarness());
      await openOlderImportDialog(tester);

      expect(find.text('Older backup detected'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.runAsync(
        () => pendingDownload!.timeout(const Duration(seconds: 5)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo!.importCalls, 0);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Older backup applied'), findsNothing);
      expect(
        find.text(
          'Skipped because the incoming file is older than local data.',
        ),
        findsNothing,
      );
    },
  );
}
