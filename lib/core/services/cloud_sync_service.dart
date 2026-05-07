import 'dart:convert';

import 'package:jpstudy/core/platform_io.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_encryption.dart';
import 'backup_sync_service.dart';

enum CloudSyncDirection { upload, download }

enum CloudSyncUploadDecision { uploaded, missingTarget, writeFailed }

enum CloudSyncDownloadDecision {
  apply,
  skipOlder,
  invalidChecksum,
  missingTarget,
  missingRemoteFile,
  invalidFormat,
  readFailed,
  requiresPassphrase,
  decryptionFailed,
}

class CloudSyncTarget {
  const CloudSyncTarget({required this.path, required this.displayName});

  final String path;
  final String displayName;
}

class CloudSyncStatus {
  const CloudSyncStatus({
    required this.target,
    required this.lastSyncedAt,
    required this.lastRemoteExportedAt,
    required this.lastDirection,
  });

  final CloudSyncTarget? target;
  final DateTime? lastSyncedAt;
  final DateTime? lastRemoteExportedAt;
  final CloudSyncDirection? lastDirection;

  bool get isLinked => target != null;
}

class CloudSyncUploadResult {
  const CloudSyncUploadResult({
    required this.decision,
    this.target,
    this.syncedAt,
    this.remoteExportedAt,
  });

  final CloudSyncUploadDecision decision;
  final CloudSyncTarget? target;
  final DateTime? syncedAt;
  final DateTime? remoteExportedAt;
}

class CloudSyncDownloadResult {
  const CloudSyncDownloadResult({
    required this.decision,
    this.target,
    this.payload,
    this.remoteExportedAt,
  });

  final CloudSyncDownloadDecision decision;
  final CloudSyncTarget? target;
  final Map<String, dynamic>? payload;
  final DateTime? remoteExportedAt;
}

class CloudSyncService {
  const CloudSyncService._();

  static const _prefLinkedPath = 'backup.cloud.linkedPath';
  static const _prefLinkedName = 'backup.cloud.linkedName';
  static const _prefLastSyncedAt = 'backup.cloud.lastSyncedAt';
  static const _prefLastDirection = 'backup.cloud.lastDirection';
  static const _prefLastRemoteExportedAt = 'backup.cloud.lastRemoteExportedAt';

  static Future<void> linkTarget({
    required String path,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLinkedPath, path);
    await prefs.setString(
      _prefLinkedName,
      displayName?.trim().isNotEmpty == true
          ? displayName!.trim()
          : p.basename(path),
    );
    await prefs.remove(_prefLastSyncedAt);
    await prefs.remove(_prefLastDirection);
    await prefs.remove(_prefLastRemoteExportedAt);
  }

  static Future<void> unlinkTarget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefLinkedPath);
    await prefs.remove(_prefLinkedName);
    await prefs.remove(_prefLastSyncedAt);
    await prefs.remove(_prefLastDirection);
    await prefs.remove(_prefLastRemoteExportedAt);
  }

  static Future<CloudSyncTarget?> getLinkedTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefLinkedPath);
    if (path == null || path.isEmpty) {
      return null;
    }
    final displayName = prefs.getString(_prefLinkedName);
    return CloudSyncTarget(
      path: path,
      displayName:
          displayName != null && displayName.isNotEmpty
              ? displayName
              : p.basename(path),
    );
  }

  static Future<CloudSyncStatus> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final target = await getLinkedTarget();
    return CloudSyncStatus(
      target: target,
      lastSyncedAt: _parseTime(prefs.getString(_prefLastSyncedAt)),
      lastRemoteExportedAt: _parseTime(
        prefs.getString(_prefLastRemoteExportedAt),
      ),
      lastDirection: _parseDirection(prefs.getString(_prefLastDirection)),
    );
  }

  static Future<CloudSyncUploadResult> uploadEnvelope(
    Map<String, dynamic> envelope,
  ) async {
    final target = await getLinkedTarget();
    if (target == null) {
      return const CloudSyncUploadResult(
        decision: CloudSyncUploadDecision.missingTarget,
      );
    }

    final file = File(target.path);
    try {
      await file.parent.create(recursive: true);
      final jsonText = const JsonEncoder.withIndent('  ').convert(envelope);
      await file.writeAsString(jsonText, flush: true);
      final remoteExportedAt = BackupSyncService.parseExportedAt(envelope);
      final syncedAt = DateTime.now();
      await _markSuccess(
        direction: CloudSyncDirection.upload,
        syncedAt: syncedAt,
        remoteExportedAt: remoteExportedAt,
      );
      return CloudSyncUploadResult(
        decision: CloudSyncUploadDecision.uploaded,
        target: target,
        syncedAt: syncedAt,
        remoteExportedAt: remoteExportedAt,
      );
    } catch (_) {
      return CloudSyncUploadResult(
        decision: CloudSyncUploadDecision.writeFailed,
        target: target,
      );
    }
  }

  static Future<CloudSyncDownloadResult> prepareDownload({
    String? passphrase,
  }) async {
    final target = await getLinkedTarget();
    if (target == null) {
      return const CloudSyncDownloadResult(
        decision: CloudSyncDownloadDecision.missingTarget,
      );
    }

    final file = File(target.path);
    if (!file.existsSync()) {
      return CloudSyncDownloadResult(
        decision: CloudSyncDownloadDecision.missingRemoteFile,
        target: target,
      );
    }

    try {
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return CloudSyncDownloadResult(
          decision: CloudSyncDownloadDecision.invalidFormat,
          target: target,
        );
      }

      final rawPayload = Map<String, dynamic>.from(decoded);
      final Map<String, dynamic> payload;
      if (BackupSyncService.isEnvelopeEncrypted(rawPayload)) {
        if (passphrase == null || passphrase.isEmpty) {
          return CloudSyncDownloadResult(
            decision: CloudSyncDownloadDecision.requiresPassphrase,
            target: target,
            remoteExportedAt: BackupSyncService.parseExportedAt(rawPayload),
          );
        }
        try {
          payload = await BackupSyncService.tryDecryptEnvelope(
            rawPayload,
            passphrase,
          );
        } on BackupDecryptionException {
          return CloudSyncDownloadResult(
            decision: CloudSyncDownloadDecision.decryptionFailed,
            target: target,
          );
        }
      } else {
        payload = rawPayload;
      }
      final plan = await BackupSyncService.prepareImport(payload);
      var mappedDecision = switch (plan.decision) {
        BackupImportDecision.apply => CloudSyncDownloadDecision.apply,
        BackupImportDecision.skipOlder => CloudSyncDownloadDecision.skipOlder,
        BackupImportDecision.invalidChecksum =>
          CloudSyncDownloadDecision.invalidChecksum,
      };
      if (mappedDecision == CloudSyncDownloadDecision.apply) {
        final status = await loadStatus();
        final lastRemoteExportedAt = status.lastRemoteExportedAt;
        final incomingExportedAt = plan.incomingExportedAt;
        if (lastRemoteExportedAt != null &&
            incomingExportedAt != null &&
            !incomingExportedAt.isAfter(lastRemoteExportedAt)) {
          mappedDecision = CloudSyncDownloadDecision.skipOlder;
        }
      }
      return CloudSyncDownloadResult(
        decision: mappedDecision,
        target: target,
        payload: plan.payload,
        remoteExportedAt: plan.incomingExportedAt,
      );
    } catch (_) {
      return CloudSyncDownloadResult(
        decision: CloudSyncDownloadDecision.readFailed,
        target: target,
      );
    }
  }

  static Future<void> markDownloadApplied(DateTime? remoteExportedAt) async {
    await BackupSyncService.markImportApplied(remoteExportedAt);
    await _markSuccess(
      direction: CloudSyncDirection.download,
      syncedAt: DateTime.now(),
      remoteExportedAt: remoteExportedAt,
    );
  }

  static Future<void> _markSuccess({
    required CloudSyncDirection direction,
    required DateTime syncedAt,
    required DateTime? remoteExportedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastSyncedAt, syncedAt.toIso8601String());
    await prefs.setString(_prefLastDirection, direction.name);
    if (remoteExportedAt != null) {
      await prefs.setString(
        _prefLastRemoteExportedAt,
        remoteExportedAt.toIso8601String(),
      );
    } else {
      await prefs.remove(_prefLastRemoteExportedAt);
    }
  }

  static DateTime? _parseTime(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static CloudSyncDirection? _parseDirection(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    for (final value in CloudSyncDirection.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return null;
  }
}
