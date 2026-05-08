import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/auth/auth_user.dart';

void main() {
  group('AuthUser.initialsForAvatar', () {
    test('uses two leading initials of the display name when available', () {
      const user = AuthUser(uid: '1', displayName: 'Hoai Chung');
      expect(user.initialsForAvatar, 'HC');
    });

    test('falls back to email when display name is empty', () {
      const user = AuthUser(uid: '1', displayName: '', email: 'foo@bar.com');
      expect(user.initialsForAvatar, 'F');
    });

    test('returns ? when both display name and email are missing', () {
      const user = AuthUser(uid: '1');
      expect(user.initialsForAvatar, '?');
    });

    test('uppercases the result', () {
      const user = AuthUser(uid: '1', displayName: 'lowercase user');
      expect(user.initialsForAvatar, 'LU');
    });

    test('handles single-word names', () {
      const user = AuthUser(uid: '1', displayName: 'Solo');
      expect(user.initialsForAvatar, 'S');
    });
  });

  test('copyWith preserves unchanged fields', () {
    const user = AuthUser(
      uid: '1',
      email: 'a@b.c',
      displayName: 'A',
      photoUrl: 'http://x',
    );
    final copy = user.copyWith(displayName: 'B');
    expect(copy.uid, '1');
    expect(copy.email, 'a@b.c');
    expect(copy.displayName, 'B');
    expect(copy.photoUrl, 'http://x');
  });
}
