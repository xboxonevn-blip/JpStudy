import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_user.dart';

enum LegacyMigrationDecision {
  uploaded,
  noProgress,
  alreadyMigrated,
  uploadFailed,
}

class LegacyMigrationResult {
  const LegacyMigrationResult({
    required this.decision,
    required this.keyCount,
    this.path,
  });

  final LegacyMigrationDecision decision;
  final int keyCount;
  final String? path;
}

abstract interface class LegacyMigrationUploader {
  Future<String> upload({
    required String uid,
    required Map<String, Object?> payload,
  });
}

class FirebaseLegacyMigrationUploader implements LegacyMigrationUploader {
  FirebaseLegacyMigrationUploader({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> upload({
    required String uid,
    required Map<String, Object?> payload,
  }) async {
    final path = 'users/$uid/legacy_migration.json';
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: 'application/json'));
    return path;
  }
}

class LegacyMigrationService {
  LegacyMigrationService({LegacyMigrationUploader? uploader})
    : _uploader = uploader ?? FirebaseLegacyMigrationUploader();

  // SharedPreferences Web stores this as localStorage key
  // `flutter.auth.migrated`.
  static const migratedPreferenceKey = 'auth.migrated';

  final LegacyMigrationUploader _uploader;

  Future<LegacyMigrationResult> migrateIfNeeded({
    required SharedPreferences preferences,
    required AuthUser user,
  }) async {
    if (preferences.getBool(migratedPreferenceKey) ?? false) {
      return const LegacyMigrationResult(
        decision: LegacyMigrationDecision.alreadyMigrated,
        keyCount: 0,
      );
    }

    final payload = _legacyProgressPayload(preferences);
    if (payload.isEmpty) {
      await preferences.setBool(migratedPreferenceKey, true);
      return const LegacyMigrationResult(
        decision: LegacyMigrationDecision.noProgress,
        keyCount: 0,
      );
    }

    try {
      final path = await _uploader.upload(uid: user.uid, payload: payload);
      await preferences.setBool(migratedPreferenceKey, true);
      return LegacyMigrationResult(
        decision: LegacyMigrationDecision.uploaded,
        keyCount: payload.length,
        path: path,
      );
    } catch (_) {
      return LegacyMigrationResult(
        decision: LegacyMigrationDecision.uploadFailed,
        keyCount: payload.length,
      );
    }
  }

  Map<String, Object?> _legacyProgressPayload(SharedPreferences preferences) {
    final payload = <String, Object?>{};
    for (final key in preferences.getKeys()) {
      if (!_isProgressKey(key)) continue;
      payload[key] = preferences.get(key);
    }
    return payload;
  }

  bool _isProgressKey(String key) {
    if (key == migratedPreferenceKey || key == 'analytics.consent') {
      return false;
    }
    return key.startsWith('learn_session_') ||
        key.startsWith('test_session_') ||
        key.startsWith('kana.') ||
        key.startsWith('onboarding.') ||
        key.startsWith('daily.') ||
        key.startsWith('challenge.') ||
        key.startsWith('backup.') ||
        key.startsWith('cloud_sync.');
  }
}
