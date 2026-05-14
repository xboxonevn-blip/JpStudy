import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';
import 'package:jpstudy/core/auth/anonymous_auth_service.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/auth/legacy_migration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAnonymousAuthGateway implements AnonymousAuthGateway {
  _FakeAnonymousAuthGateway({this.current, this.signInDelay});

  AuthUser? current;
  Duration? signInDelay;
  Object? error;
  int signInCalls = 0;

  @override
  AuthUser? get currentUser => current;

  @override
  Future<AuthUser> signInAnonymously() async {
    signInCalls++;
    final delay = signInDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    final thrown = error;
    if (thrown != null) throw thrown;
    return current = const AuthUser(uid: 'anon-1', isAnonymous: true);
  }
}

class _FakeLegacyMigrationService extends Fake
    implements LegacyMigrationService {
  int calls = 0;

  @override
  Future<LegacyMigrationResult> migrateIfNeeded({
    required SharedPreferences preferences,
    required AuthUser user,
  }) async {
    calls++;
    return const LegacyMigrationResult(
      decision: LegacyMigrationDecision.uploaded,
      keyCount: 2,
      path: 'users/anon-1/legacy_migration.json',
    );
  }
}

class _FakeAnalyticsService extends Fake implements AnalyticsService {
  final identified = <({String userId, String authType})>[];

  @override
  Future<void> identifyUser({
    required String userId,
    required String authType,
  }) async {
    identified.add((userId: userId, authType: authType));
  }
}

void main() {
  test('returns existing signed-in user without anonymous sign-in', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final gateway = _FakeAnonymousAuthGateway(
      current: const AuthUser(uid: 'real-1', email: 'a@b.test'),
    );
    final analytics = _FakeAnalyticsService();
    final migration = _FakeLegacyMigrationService();
    final service = AnonymousAuthService(
      gateway: gateway,
      analyticsService: analytics,
      legacyMigrationService: migration,
    );

    final result = await service.ensureAuthenticated(preferences: prefs);

    expect(result.decision, AnonymousAuthDecision.existingUser);
    expect(result.user?.uid, 'real-1');
    expect(gateway.signInCalls, 0);
    expect(migration.calls, 0);
    expect(analytics.identified.single.authType, 'registered');
  });

  test('signs in anonymously and uploads legacy prefs once', () async {
    SharedPreferences.setMockInitialValues({'learn_session_1': 'cached'});
    final prefs = await SharedPreferences.getInstance();
    final gateway = _FakeAnonymousAuthGateway();
    final analytics = _FakeAnalyticsService();
    final migration = _FakeLegacyMigrationService();
    final service = AnonymousAuthService(
      gateway: gateway,
      analyticsService: analytics,
      legacyMigrationService: migration,
    );

    final result = await service.ensureAuthenticated(preferences: prefs);

    expect(result.decision, AnonymousAuthDecision.signedInAnonymously);
    expect(result.user?.isAnonymous, isTrue);
    expect(gateway.signInCalls, 1);
    expect(migration.calls, 1);
    expect(analytics.identified.single, (
      userId: 'anon-1',
      authType: 'anonymous',
    ));
  });

  test('times out and keeps app booting offline', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = AnonymousAuthService(
      gateway: _FakeAnonymousAuthGateway(
        signInDelay: const Duration(milliseconds: 50),
      ),
      analyticsService: _FakeAnalyticsService(),
      legacyMigrationService: _FakeLegacyMigrationService(),
      timeout: const Duration(milliseconds: 1),
    );

    final result = await service.ensureAuthenticated(preferences: prefs);

    expect(result.decision, AnonymousAuthDecision.offlineFallback);
    expect(result.user, isNull);
  });
}
