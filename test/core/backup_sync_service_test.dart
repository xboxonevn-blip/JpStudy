import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('builds envelope and accepts valid import payload', () async {
    final payload = {
      'version': 2,
      'exportedAt': DateTime(2026, 2, 22, 10, 0).toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
    };

    final envelope = await BackupSyncService.buildExportEnvelope(payload);
    expect(envelope.containsKey(BackupSyncService.backupSyncMetaKey), isTrue);
    expect(
      envelope.containsKey(BackupSyncService.backupSyncChecksumKey),
      isTrue,
    );

    final plan = await BackupSyncService.prepareImport(envelope);
    expect(plan.decision, BackupImportDecision.apply);
  });

  test('rejects tampered checksum payload', () async {
    final payload = {
      'version': 2,
      'exportedAt': DateTime(2026, 2, 22, 10, 0).toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
    };
    final envelope = await BackupSyncService.buildExportEnvelope(payload);
    envelope['version'] = 999;

    final plan = await BackupSyncService.prepareImport(envelope);
    expect(plan.decision, BackupImportDecision.invalidChecksum);
  });

  test('skips older backup when a newer import was already applied', () async {
    await BackupSyncService.markImportApplied(DateTime(2026, 2, 22, 12, 0));

    final payload = {
      'version': 2,
      'exportedAt': DateTime(2026, 2, 22, 8, 0).toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
    };
    final envelope = await BackupSyncService.buildExportEnvelope(payload);
    final plan = await BackupSyncService.prepareImport(envelope);

    expect(plan.decision, BackupImportDecision.skipOlder);
  });
}
