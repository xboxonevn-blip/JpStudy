import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jpstudy/core/analytics/analytics_provider.dart';

import 'auth_service.dart';
import 'auth_user.dart';

/// The single source of truth for the auth service. Tests override this with
/// a fake; production code never instantiates AuthService directly.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(analyticsService: ref.watch(analyticsServiceProvider));
});

/// Streams the currently signed-in user, or null when signed out. Listeners
/// rebuild when Firebase reports an auth state change.
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges();
});

/// Convenient sync read for screens that just want "is the user logged in?"
/// without dealing with AsyncValue.
final isSignedInProvider = Provider<bool>((ref) {
  final state = ref.watch(authStateProvider);
  return state.maybeWhen(data: (user) => user != null, orElse: () => false);
});
