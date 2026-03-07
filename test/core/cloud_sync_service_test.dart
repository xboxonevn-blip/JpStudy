import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tempDir = Directory.systemTemp.createTempSync('jpstudy-cloud-sync-');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Map<String, dynamic> buildPayload(DateTime exportedAt) {
    return {
      'version': 2,
      'exportedAt': exportedAt.toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
    };
  }

  Future<String> linkPath([String fileName = 'jpstudy_cloud_sync.json']) async {
    final path = '${tempDir.path}${Platform.pathSeparator}$fileName';
    await CloudSyncService.linkTarget(path: path, displayName: fileName);
    return path;
  }

  test('loadStatus reports linked target after linkTarget', () async {
    final path = await linkPath();

    final status = await CloudSyncService.loadStatus();

    expect(status.isLinked, isTrue);
    expect(status.target?.path, path);
    expect(status.target?.displayName, 'jpstudy_cloud_sync.json');
    expect(status.lastSyncedAt, isNull);
  });

  test('uploadEnvelope writes linked file and updates status', () async {
    final path = await linkPath();
    final envelope = await BackupSyncService.buildExportEnvelope(
      buildPayload(DateTime(2026, 3, 7, 10, 0)),
    );

    final result = await CloudSyncService.uploadEnvelope(envelope);
    final status = await CloudSyncService.loadStatus();

    expect(result.decision, CloudSyncUploadDecision.uploaded);
    expect(File(path).existsSync(), isTrue);
    expect(status.lastDirection, CloudSyncDirection.upload);
    expect(status.lastSyncedAt, isNotNull);
    expect(status.lastRemoteExportedAt, isNotNull);
  });

  test('prepareDownload returns apply for valid linked file', () async {
    final path = await linkPath();
    final envelope = await BackupSyncService.buildExportEnvelope(
      buildPayload(DateTime(2026, 3, 7, 11, 0)),
    );
    await File(path).writeAsString(
      const JsonEncoder.withIndent('  ').convert(envelope),
      flush: true,
    );

    final result = await CloudSyncService.prepareDownload();

    expect(result.decision, CloudSyncDownloadDecision.apply);
    expect(result.payload, isNotNull);
    expect(result.remoteExportedAt, isNotNull);
  });

  test('prepareDownload returns invalidChecksum for tampered file', () async {
    final path = await linkPath();
    final envelope = await BackupSyncService.buildExportEnvelope(
      buildPayload(DateTime(2026, 3, 7, 12, 0)),
    )..['version'] = 999;
    await File(path).writeAsString(
      const JsonEncoder.withIndent('  ').convert(envelope),
      flush: true,
    );

    final result = await CloudSyncService.prepareDownload();

    expect(result.decision, CloudSyncDownloadDecision.invalidChecksum);
  });

  test('prepareDownload skips remote snapshot already synced before', () async {
    final path = await linkPath();
    final envelope = await BackupSyncService.buildExportEnvelope(
      buildPayload(DateTime(2026, 3, 7, 12, 30)),
    );
    await CloudSyncService.uploadEnvelope(envelope);
    await File(path).writeAsString(
      const JsonEncoder.withIndent('  ').convert(envelope),
      flush: true,
    );

    final result = await CloudSyncService.prepareDownload();

    expect(result.decision, CloudSyncDownloadDecision.skipOlder);
  });

  test('prepareDownload returns missingRemoteFile when linked file is absent', () async {
    await linkPath('missing_cloud.json');

    final result = await CloudSyncService.prepareDownload();

    expect(result.decision, CloudSyncDownloadDecision.missingRemoteFile);
  });

  test('markDownloadApplied stores download sync metadata', () async {
    await linkPath();

    await CloudSyncService.markDownloadApplied(DateTime(2026, 3, 7, 13, 0));

    final status = await CloudSyncService.loadStatus();
    final lastAppliedAt = await BackupSyncService.getLastAppliedAt();
    expect(status.lastDirection, CloudSyncDirection.download);
    expect(status.lastSyncedAt, isNotNull);
    expect(status.lastRemoteExportedAt, DateTime(2026, 3, 7, 13, 0));
    expect(lastAppliedAt, DateTime(2026, 3, 7, 13, 0));
  });
}
