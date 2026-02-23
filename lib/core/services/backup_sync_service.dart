import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BackupImportDecision { apply, skipOlder, invalidChecksum }

class BackupImportPlan {
  const BackupImportPlan({
    required this.decision,
    required this.payload,
    required this.incomingExportedAt,
  });

  final BackupImportDecision decision;
  final Map<String, dynamic> payload;
  final DateTime? incomingExportedAt;
}

class BackupSyncService {
  const BackupSyncService._();

  static const backupSyncMetaKey = 'syncMeta';
  static const backupSyncChecksumKey = 'checksum';

  static const _prefDeviceId = 'backup.sync.deviceId';
  static const _prefLastAppliedAt = 'backup.sync.lastAppliedAt';
  static const _envelopeVersion = 1;

  static Future<Map<String, dynamic>> buildExportEnvelope(
    Map<String, dynamic> payload,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = _getOrCreateDeviceId(prefs);
    final working = Map<String, dynamic>.from(payload)
      ..remove(backupSyncMetaKey)
      ..remove(backupSyncChecksumKey);

    final exportedAt = _parseTime(working['exportedAt']) ?? DateTime.now();
    final meta = {
      'envelopeVersion': _envelopeVersion,
      'deviceId': deviceId,
      'exportedAt': exportedAt.toIso8601String(),
    };
    final forChecksum = {...working, backupSyncMetaKey: meta};
    final checksum = _checksum(forChecksum);
    return {
      ...working,
      backupSyncMetaKey: meta,
      backupSyncChecksumKey: checksum,
    };
  }

  static Future<BackupImportPlan> prepareImport(
    Map<String, dynamic> input,
  ) async {
    final payload = Map<String, dynamic>.from(input);
    final incomingExportedAt = parseExportedAt(payload);
    final hasValidChecksum = _verifyChecksum(payload);
    if (!hasValidChecksum) {
      return BackupImportPlan(
        decision: BackupImportDecision.invalidChecksum,
        payload: payload,
        incomingExportedAt: incomingExportedAt,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final lastAppliedAt = _parseTime(prefs.getString(_prefLastAppliedAt));
    final shouldSkip =
        incomingExportedAt != null &&
        lastAppliedAt != null &&
        !incomingExportedAt.isAfter(lastAppliedAt);

    return BackupImportPlan(
      decision: shouldSkip
          ? BackupImportDecision.skipOlder
          : BackupImportDecision.apply,
      payload: payload,
      incomingExportedAt: incomingExportedAt,
    );
  }

  static Future<void> markImportApplied(DateTime? incomingExportedAt) async {
    final prefs = await SharedPreferences.getInstance();
    final toStore = incomingExportedAt ?? DateTime.now();
    await prefs.setString(_prefLastAppliedAt, toStore.toIso8601String());
  }

  static Future<DateTime?> getLastAppliedAt() async {
    final prefs = await SharedPreferences.getInstance();
    return _parseTime(prefs.getString(_prefLastAppliedAt));
  }

  static DateTime? parseExportedAt(Map<String, dynamic> payload) {
    final rawRoot = payload['exportedAt'];
    final rootTime = _parseTime(rawRoot);
    if (rootTime != null) {
      return rootTime;
    }

    final meta = payload[backupSyncMetaKey];
    if (meta is Map<String, dynamic>) {
      return _parseTime(meta['exportedAt']);
    }
    if (meta is Map) {
      return _parseTime(meta['exportedAt']);
    }
    return null;
  }

  static String _checksum(Map<String, dynamic> payload) {
    final normalized = _normalize(payload);
    final canonical = jsonEncode(normalized);
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static bool _verifyChecksum(Map<String, dynamic> payload) {
    final checksum = payload[backupSyncChecksumKey];
    if (checksum is! String || checksum.isEmpty) {
      // Backward compatible: legacy backups may not have checksum.
      return true;
    }
    final working = Map<String, dynamic>.from(payload)
      ..remove(backupSyncChecksumKey);
    final expected = _checksum(working);
    return expected == checksum;
  }

  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((key) => '$key').toList()..sort();
      return {for (final key in sortedKeys) key: _normalize(value[key])};
    }
    if (value is List) {
      return value.map(_normalize).toList(growable: false);
    }
    return value;
  }

  static DateTime? _parseTime(Object? raw) {
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static String _getOrCreateDeviceId(SharedPreferences prefs) {
    final existing = prefs.getString(_prefDeviceId);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(1 << 31);
    final deviceId = 'device_${now}_$random';
    prefs.setString(_prefDeviceId, deviceId);
    return deviceId;
  }
}
