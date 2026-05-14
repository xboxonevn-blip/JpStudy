/// Identity-only view of the authenticated user. Keeps domain code free of
/// Firebase imports so screens / tests can use a simple value object.
class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.emailVerified = false,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;

  String get initialsForAvatar {
    final source = (displayName?.trim().isNotEmpty ?? false)
        ? displayName!
        : (email ?? '');
    final letters = source
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join();
    if (letters.isEmpty) return '?';
    return letters.toUpperCase();
  }

  AuthUser copyWith({
    String? uid,
    String? email,
    bool? emailVerified,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
