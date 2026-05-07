import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_encryption.dart';

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
  static const backupSyncEncryptionKey = 'encryption';

  static const _prefDeviceId = 'backup.sync.deviceId';
  static const _prefLastAppliedAt = 'backup.sync.lastAppliedAt';
  static const _envelopeVersion = 1;

  /// Builds the export envelope with sync metadata and integrity checksum.
  ///
  /// When [passphrase] is supplied (non-null and non-empty), the working
  /// payload is encrypted with [BackupEncryption] and embedded under
  /// [backupSyncEncryptionKey]. The top-level [backupSyncMetaKey] and
  /// [backupSyncChecksumKey] always describe the original plaintext so
  /// conflict detection (`exportedAt`) and integrity (`sha256`) keep
  /// working without requiring the passphrase.
  static Future<Map<String, dynamic>> buildExportEnvelope(
    Map<String, dynamic> payload, {
    String? passphrase,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = _getOrCreateDeviceId(prefs);
    final working = Map<String, dynamic>.from(payload)
      ..remove(backupSyncMetaKey)
      ..remove(backupSyncChecksumKey)
      ..remove(backupSyncEncryptionKey);

    final exportedAt = _parseTime(working['exportedAt']) ?? DateTime.now();
    final meta = {
      'envelopeVersion': _envelopeVersion,
      'deviceId': deviceId,
      'exportedAt': exportedAt.toIso8601String(),
    };
    final forChecksum = {...working, backupSyncMetaKey: meta};
    final checksum = _checksum(forChecksum);

    if (passphrase == null || passphrase.isEmpty) {
      return {
        ...working,
        backupSyncMetaKey: meta,
        backupSyncChecksumKey: checksum,
      };
    }

    final encryptionBlock = await BackupEncryption.encrypt(
      jsonEncode(working),
      passphrase,
    );
    return {
      backupSyncMetaKey: meta,
      backupSyncChecksumKey: checksum,
      backupSyncEncryptionKey: encryptionBlock,
    };
  }

  /// Returns true when [envelope] carries an encrypted payload.
  static bool isEnvelopeEncrypted(Map<String, dynamic> envelope) {
    return envelope[backupSyncEncryptionKey] is Map;
  }

  /// Returns the plaintext envelope. If [envelope] is encrypted, the
  /// payload is decrypted with [passphrase] and merged back with the
  /// existing meta/checksum so callers can pass the result straight to
  /// [prepareImport]. Throws [BackupDecryptionException] if decryption
  /// fails or [passphrase] is missing for an encrypted envelope.
  static Future<Map<String, dynamic>> tryDecryptEnvelope(
    Map<String, dynamic> envelope,
    String? passphrase,
  ) async {
    final block = envelope[backupSyncEncryptionKey];
    if (block is! Map) {
      return envelope;
    }
    if (passphrase == null || passphrase.isEmpty) {
      throw BackupDecryptionException('passphrase-required');
    }
    final decryptedJson = await BackupEncryption.decrypt(
      Map<String, dynamic>.from(block),
      passphrase,
    );
    final decoded = jsonDecode(decryptedJson) as Map<String, dynamic>;
    return {
      ...decoded,
      backupSyncMetaKey: envelope[backupSyncMetaKey],
      backupSyncChecksumKey: envelope[backupSyncChecksumKey],
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
