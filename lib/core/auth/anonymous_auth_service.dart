import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jpstudy/core/analytics/analytics_service.dart';

import 'auth_user.dart';
import 'legacy_migration_service.dart';

enum AnonymousAuthDecision {
  existingUser,
  signedInAnonymously,
  offlineFallback,
}

class AnonymousAuthResult {
  const AnonymousAuthResult({
    required this.decision,
    this.user,
    this.migrationResult,
    this.error,
  });

  final AnonymousAuthDecision decision;
  final AuthUser? user;
  final LegacyMigrationResult? migrationResult;
  final Object? error;
}

abstract interface class AnonymousAuthGateway {
  AuthUser? get currentUser;

  Future<AuthUser> signInAnonymously();
}

class FirebaseAnonymousAuthGateway implements AnonymousAuthGateway {
  FirebaseAnonymousAuthGateway({fb_auth.FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? fb_auth.FirebaseAuth.instance;

  final fb_auth.FirebaseAuth _auth;

  @override
  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<AuthUser> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final user = _mapUser(credential.user);
    if (user == null) {
      throw StateError('Anonymous sign-in returned no user');
    }
    return user;
  }

  AuthUser? _mapUser(fb_auth.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }
}

class AnonymousAuthService {
  AnonymousAuthService({
    AnonymousAuthGateway? gateway,
    AnalyticsService? analyticsService,
    LegacyMigrationService? legacyMigrationService,
    this.timeout = const Duration(seconds: 5),
  }) : _gateway = gateway ?? FirebaseAnonymousAuthGateway(),
       _analyticsService = analyticsService,
       _legacyMigrationService =
           legacyMigrationService ?? LegacyMigrationService();

  final AnonymousAuthGateway _gateway;
  final AnalyticsService? _analyticsService;
  final LegacyMigrationService _legacyMigrationService;
  final Duration timeout;

  Future<AnonymousAuthResult> ensureAuthenticated({
    required SharedPreferences preferences,
  }) async {
    final existing = _gateway.currentUser;
    if (existing != null) {
      await _identify(existing);
      return AnonymousAuthResult(
        decision: AnonymousAuthDecision.existingUser,
        user: existing,
      );
    }

    try {
      final user = await _gateway.signInAnonymously().timeout(timeout);
      await _identify(user);
      final migration = await _legacyMigrationService.migrateIfNeeded(
        preferences: preferences,
        user: user,
      );
      return AnonymousAuthResult(
        decision: AnonymousAuthDecision.signedInAnonymously,
        user: user,
        migrationResult: migration,
      );
    } catch (error) {
      return AnonymousAuthResult(
        decision: AnonymousAuthDecision.offlineFallback,
        error: error,
      );
    }
  }

  Future<void> _identify(AuthUser user) {
    return _analyticsService?.identifyUser(
          userId: user.uid,
          authType: user.isAnonymous ? 'anonymous' : 'registered',
        ) ??
        Future<void>.value();
  }
}
