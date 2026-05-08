import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_user.dart';

/// Domain errors that the auth flow can surface to the UI. Translating
/// platform errors here keeps the dialog free of Firebase-specific imports
/// and makes the flow testable with fakes.
enum AuthErrorKind {
  invalidCredentials,
  userNotFound,
  wrongPassword,
  networkError,
  userDisabled,
  tooManyAttempts,
  cancelledByUser,
  notSupportedOnPlatform,
  unknown,
}

class AuthException implements Exception {
  AuthException(this.kind, [this.cause]);

  final AuthErrorKind kind;
  final Object? cause;

  @override
  String toString() => 'AuthException($kind)';
}

class AuthService {
  AuthService({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb_auth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  bool _googleSignInInitialized = false;

  /// Stream of authenticated user identity (or null when signed out).
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  AuthUser? get currentUser => _mapUser(_auth.currentUser);

  /// Whether Google sign-in is supported on the current platform.
  /// Windows desktop has no `google_sign_in` plugin and Firebase Web popup
  /// requires a browser context, so we gate the UI accordingly. Instance
  /// method (not static) so tests can override via [AuthService] subclass.
  bool get isGoogleSignInSupported {
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) return true;
    return false;
  }

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapUser(credential.user);
      if (user == null) {
        throw AuthException(AuthErrorKind.unknown);
      }
      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e);
    } catch (e) {
      throw AuthException(AuthErrorKind.unknown, e);
    }
  }

  Future<AuthUser> signInWithGoogle() async {
    if (!isGoogleSignInSupported) {
      throw AuthException(AuthErrorKind.notSupportedOnPlatform);
    }
    try {
      if (kIsWeb) {
        // Firebase Auth handles the entire popup flow on web; google_sign_in
        // is unnecessary here and conflicts with the popup credential path.
        final provider = fb_auth.GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(provider);
        final user = _mapUser(credential.user);
        if (user == null) {
          throw AuthException(AuthErrorKind.unknown);
        }
        return user;
      }

      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }
      final account = await _googleSignIn.authenticate(scopeHint: const [
        'email',
      ]);
      final auth = account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw AuthException(AuthErrorKind.unknown);
      }
      final credential = fb_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = _mapUser(result.user);
      if (user == null) {
        throw AuthException(AuthErrorKind.unknown);
      }
      return user;
    } on GoogleSignInException catch (e) {
      // The new google_sign_in API surfaces UserCancelled via this type.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException(AuthErrorKind.cancelledByUser, e);
      }
      throw AuthException(AuthErrorKind.unknown, e);
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e), e);
    } catch (e) {
      throw AuthException(AuthErrorKind.unknown, e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // signOut on a never-initialised plugin throws; ignore.
      }
    }
  }

  AuthUser? _mapUser(fb_auth.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  AuthErrorKind _mapFirebaseError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'invalid-email':
      case 'invalid-login-credentials':
        return AuthErrorKind.invalidCredentials;
      case 'user-not-found':
        return AuthErrorKind.userNotFound;
      case 'wrong-password':
        return AuthErrorKind.wrongPassword;
      case 'user-disabled':
        return AuthErrorKind.userDisabled;
      case 'too-many-requests':
        return AuthErrorKind.tooManyAttempts;
      case 'network-request-failed':
        return AuthErrorKind.networkError;
      default:
        return AuthErrorKind.unknown;
    }
  }
}
