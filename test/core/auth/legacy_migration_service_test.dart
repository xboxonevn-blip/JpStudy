import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/auth/legacy_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeLegacyMigrationUploader implements LegacyMigrationUploader {
  final uploads = <({String uid, Map<String, Object?> payload})>[];
  Object? error;

  @override
  Future<String> upload({
    required String uid,
    required Map<String, Object?> payload,
  }) async {
    final thrown = error;
    if (thrown != null) throw thrown;
    uploads.add((uid: uid, payload: payload));
    return 'users/$uid/legacy_migration.json';
  }
}

void main() {
  test('uploads progress-like SharedPreferences once', () async {
    SharedPreferences.setMockInitialValues({
      'learn_session_1': 'cached',
      'onboarding.level': 'N3',
      'analytics.consent': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final uploader = _FakeLegacyMigrationUploader();
    final service = LegacyMigrationService(uploader: uploader);

    final result = await service.migrateIfNeeded(
      preferences: prefs,
      user: const AuthUser(uid: 'anon-1', isAnonymous: true),
    );

    expect(result.decision, LegacyMigrationDecision.uploaded);
    expect(result.keyCount, 2);
    expect(uploader.uploads.single.uid, 'anon-1');
    expect(uploader.uploads.single.payload['learn_session_1'], 'cached');
    expect(uploader.uploads.single.payload['onboarding.level'], 'N3');
    expect(
      uploader.uploads.single.payload.containsKey('analytics.consent'),
      isFalse,
    );
    expect(prefs.getBool(LegacyMigrationService.migratedPreferenceKey), isTrue);
  });

  test('skips when already migrated', () async {
    SharedPreferences.setMockInitialValues({
      LegacyMigrationService.migratedPreferenceKey: true,
      'learn_session_1': 'cached',
    });
    final prefs = await SharedPreferences.getInstance();
    final uploader = _FakeLegacyMigrationUploader();
    final service = LegacyMigrationService(uploader: uploader);

    final result = await service.migrateIfNeeded(
      preferences: prefs,
      user: const AuthUser(uid: 'anon-1', isAnonymous: true),
    );

    expect(result.decision, LegacyMigrationDecision.alreadyMigrated);
    expect(uploader.uploads, isEmpty);
  });

  test('does not mark migrated if upload fails', () async {
    SharedPreferences.setMockInitialValues({'learn_session_1': 'cached'});
    final prefs = await SharedPreferences.getInstance();
    final uploader = _FakeLegacyMigrationUploader()..error = StateError('nope');
    final service = LegacyMigrationService(uploader: uploader);

    final result = await service.migrateIfNeeded(
      preferences: prefs,
      user: const AuthUser(uid: 'anon-1', isAnonymous: true),
    );

    expect(result.decision, LegacyMigrationDecision.uploadFailed);
    expect(prefs.getBool(LegacyMigrationService.migratedPreferenceKey), isNull);
  });
}
