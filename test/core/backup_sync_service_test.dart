import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/backup_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Map<String, dynamic> payload({DateTime? exportedAt}) {
    return {
      'version': 2,
      'exportedAt': (exportedAt ?? DateTime(2026, 2, 22, 10, 0)).toIso8601String(),
      'lessons': <Map<String, dynamic>>[],
      'terms': <Map<String, dynamic>>[],
    };
  }

  group('buildExportEnvelope', () {
    test('adds sync meta and checksum', () async {
      final envelope = await BackupSyncService.buildExportEnvelope(payload());
      expect(envelope.containsKey(BackupSyncService.backupSyncMetaKey), isTrue);
      expect(
        envelope.containsKey(BackupSyncService.backupSyncChecksumKey),
        isTrue,
      );
    });

    test('creates stable deviceId across multiple exports in same prefs store',
        () async {
      final first = await BackupSyncService.buildExportEnvelope(payload());
      final second = await BackupSyncService.buildExportEnvelope(payload());

      final firstMeta =
          first[BackupSyncService.backupSyncMetaKey] as Map<String, dynamic>;
      final secondMeta =
          second[BackupSyncService.backupSyncMetaKey] as Map<String, dynamic>;

      expect(firstMeta['deviceId'], isNotEmpty);
      expect(secondMeta['deviceId'], firstMeta['deviceId']);
    });

    test('removes pre-existing sync meta/checksum before rebuilding envelope',
        () async {
      final dirty = {
        ...payload(),
        BackupSyncService.backupSyncMetaKey: {'deviceId': 'stale-device'},
        BackupSyncService.backupSyncChecksumKey: 'stale-checksum',
      };

      final rebuilt = await BackupSyncService.buildExportEnvelope(dirty);
      final meta =
          rebuilt[BackupSyncService.backupSyncMetaKey] as Map<String, dynamic>;

      expect(meta['deviceId'], isNot('stale-device'));
      expect(rebuilt[BackupSyncService.backupSyncChecksumKey], isNot('stale-checksum'));
    });
  });

  group('prepareImport', () {
    test('accepts valid import payload', () async {
      final envelope = await BackupSyncService.buildExportEnvelope(payload());
      final plan = await BackupSyncService.prepareImport(envelope);
      expect(plan.decision, BackupImportDecision.apply);
    });

    test('rejects tampered checksum payload', () async {
      final envelope = await BackupSyncService.buildExportEnvelope(payload());
      envelope['version'] = 999;

      final plan = await BackupSyncService.prepareImport(envelope);
      expect(plan.decision, BackupImportDecision.invalidChecksum);
    });

    test('accepts legacy payload without checksum', () async {
      final legacy = payload();
      final plan = await BackupSyncService.prepareImport(legacy);
      expect(plan.decision, BackupImportDecision.apply);
    });

    test('accepts legacy payload with empty root exportedAt but valid meta exportedAt',
        () async {
      final envelope = await BackupSyncService.buildExportEnvelope(payload());
      envelope['exportedAt'] = '';
      envelope.remove(BackupSyncService.backupSyncChecksumKey);

      final plan = await BackupSyncService.prepareImport(envelope);
      expect(plan.decision, BackupImportDecision.apply);
      expect(plan.incomingExportedAt, isNotNull);
    });

    test('skips older backup when newer import was already applied', () async {
      await BackupSyncService.markImportApplied(DateTime(2026, 2, 22, 12, 0));

      final olderEnvelope =
          await BackupSyncService.buildExportEnvelope(payload(exportedAt: DateTime(2026, 2, 22, 8, 0)));
      final plan = await BackupSyncService.prepareImport(olderEnvelope);

      expect(plan.decision, BackupImportDecision.skipOlder);
    });

    test('skips equal-timestamp backup because it is not after lastAppliedAt',
        () async {
      final ts = DateTime(2026, 2, 22, 12, 0);
      await BackupSyncService.markImportApplied(ts);

      final equalEnvelope = await BackupSyncService.buildExportEnvelope(
        payload(exportedAt: ts),
      );
      final plan = await BackupSyncService.prepareImport(equalEnvelope);

      expect(plan.decision, BackupImportDecision.skipOlder);
    });

    test('applies newer backup after older import was already applied', () async {
      await BackupSyncService.markImportApplied(DateTime(2026, 2, 22, 8, 0));

      final newerEnvelope =
          await BackupSyncService.buildExportEnvelope(payload(exportedAt: DateTime(2026, 2, 22, 12, 0)));
      final plan = await BackupSyncService.prepareImport(newerEnvelope);

      expect(plan.decision, BackupImportDecision.apply);
    });
  });

  group('markImportApplied / getLastAppliedAt', () {
    test('stores explicit incoming timestamp', () async {
      final ts = DateTime(2026, 2, 22, 15, 30);
      await BackupSyncService.markImportApplied(ts);
      final stored = await BackupSyncService.getLastAppliedAt();
      expect(stored, ts);
    });

    test('stores current time when incomingExportedAt is null', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await BackupSyncService.markImportApplied(null);
      final stored = await BackupSyncService.getLastAppliedAt();
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(stored, isNotNull);
      expect(stored!.isAfter(before), isTrue);
      expect(stored.isBefore(after), isTrue);
    });

    test('returns null when no import has been applied yet', () async {
      final stored = await BackupSyncService.getLastAppliedAt();
      expect(stored, isNull);
    });
  });

  group('parseExportedAt', () {
    test('prefers root exportedAt when valid', () {
      final rootTs = DateTime(2026, 2, 22, 10, 0);
      final metaTs = DateTime(2026, 2, 22, 8, 0);
      final parsed = BackupSyncService.parseExportedAt({
        'exportedAt': rootTs.toIso8601String(),
        BackupSyncService.backupSyncMetaKey: {
          'exportedAt': metaTs.toIso8601String(),
        },
      });
      expect(parsed, rootTs);
    });

    test('falls back to meta exportedAt when root is absent', () {
      final metaTs = DateTime(2026, 2, 22, 8, 0);
      final parsed = BackupSyncService.parseExportedAt({
        BackupSyncService.backupSyncMetaKey: {
          'exportedAt': metaTs.toIso8601String(),
        },
      });
      expect(parsed, metaTs);
    });

    test('accepts plain Map meta payload, not only Map<String, dynamic>', () {
      final metaTs = DateTime(2026, 2, 22, 8, 0);
      final parsed = BackupSyncService.parseExportedAt({
        BackupSyncService.backupSyncMetaKey: <Object?, Object?>{
          'exportedAt': metaTs.toIso8601String(),
        },
      });
      expect(parsed, metaTs);
    });

    test('returns null when both root and meta timestamps are missing/invalid', () {
      final parsed = BackupSyncService.parseExportedAt({
        'exportedAt': 'not-a-date',
        BackupSyncService.backupSyncMetaKey: {'exportedAt': ''},
      });
      expect(parsed, isNull);
    });
  });
}
