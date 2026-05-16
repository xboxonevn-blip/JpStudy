import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/services/auto_cloud_upload_coordinator.dart';
import 'package:jpstudy/core/services/cloud_storage_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _user = AuthUser(uid: 'uid-1', email: 'student@example.com');

class _FakeCloudStorageSyncService implements CloudStorageSyncService {
  _FakeCloudStorageSyncService(this.decision);

  CloudStorageUploadDecision decision;
  int uploadCalls = 0;
  final uploadedEnvelopes = <Map<String, dynamic>>[];
  Completer<void>? gate;

  @override
  Future<CloudStorageUploadResult> uploadEnvelope(
    Map<String, dynamic> envelope,
  ) async {
    uploadCalls += 1;
    uploadedEnvelopes.add(envelope);
    await gate?.future;
    return CloudStorageUploadResult(decision: decision);
  }

  @override
  Future<CloudStorageDownloadResult> prepareDownload({
    String? passphrase,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<CloudStorageDeleteResult> deleteRemoteBackup() async {
    throw UnimplementedError();
  }
}

Future<AutoCloudUploadCoordinator> _coordinator({
  AuthUser? user = _user,
  CloudStorageUploadDecision decision = CloudStorageUploadDecision.uploaded,
  DateTime? now,
  Map<String, Object> initialPrefs = const {},
  Duration minimumInterval = const Duration(minutes: 5),
  _FakeCloudStorageSyncService? storage,
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  return AutoCloudUploadCoordinator(
    cloudStorageSync: storage ?? _FakeCloudStorageSyncService(decision),
    envelopeBuilder: () async => {'version': 2, 'exportedAt': 'now'},
    authState: () => user,
    preferences: prefs,
    minimumInterval: minimumInterval,
    clock: () => now ?? DateTime(2026, 5, 8, 12),
    cloudBackupEnabled: true,
  );
}

void main() {
  test('returns disabled when account cloud backup feature is off', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = _FakeCloudStorageSyncService(
      CloudStorageUploadDecision.uploaded,
    );
    final coordinator = AutoCloudUploadCoordinator(
      cloudStorageSync: storage,
      envelopeBuilder: () async => {'version': 2, 'exportedAt': 'now'},
      authState: () => _user,
      preferences: prefs,
      cloudBackupEnabled: false,
    );

    expect(await coordinator.maybeUpload(), 'disabled');
    expect(storage.uploadCalls, 0);
  });

  test('returns notSignedIn when AuthUser is null', () async {
    final coordinator = await _coordinator(user: null);
    expect(await coordinator.maybeUpload(), 'notSignedIn');
  });

  test('returns disabled when preference flag is false', () async {
    final coordinator = await _coordinator(
      initialPrefs: {AutoCloudUploadCoordinator.enabledPreferenceKey: false},
    );
    expect(await coordinator.maybeUpload(), 'disabled');
  });

  test('returns tooSoon when last upload is within minimumInterval', () async {
    final coordinator = await _coordinator(
      now: DateTime(2026, 5, 8, 12, 4),
      initialPrefs: {
        AutoCloudUploadCoordinator.lastUploadPreferenceKey: DateTime(
          2026,
          5,
          8,
          12,
        ).toIso8601String(),
      },
    );
    expect(await coordinator.maybeUpload(), 'tooSoon');
  });

  test('returns uploaded on happy path and records timestamp', () async {
    final now = DateTime(2026, 5, 8, 12, 10);
    final coordinator = await _coordinator(now: now);
    expect(await coordinator.maybeUpload(), 'uploaded');
    expect(
      coordinator.preferences.getString(
        AutoCloudUploadCoordinator.lastUploadPreferenceKey,
      ),
      now.toIso8601String(),
    );
  });

  test('returns failed when storage write fails', () async {
    final coordinator = await _coordinator(
      decision: CloudStorageUploadDecision.writeFailed,
    );
    expect(await coordinator.maybeUpload(), 'failed');
  });

  test('concurrent calls do not double-upload', () async {
    final storage = _FakeCloudStorageSyncService(
      CloudStorageUploadDecision.uploaded,
    )..gate = Completer<void>();
    final coordinator = await _coordinator(storage: storage);

    final first = coordinator.maybeUpload();
    final second = coordinator.maybeUpload();
    storage.gate!.complete();

    expect(await Future.wait([first, second]), ['uploaded', 'uploaded']);
    expect(storage.uploadCalls, 1);
  });
}
