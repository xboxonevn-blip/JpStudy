import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/auth/auth_service.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/auth/widgets/login_dialog.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.googleResult, this.emailResult});

  AuthUser? Function()? googleResult;
  Object? Function({required String email, required String password})?
  emailResult;
  int googleCalls = 0;
  int emailCalls = 0;
  String? lastEmail;
  String? lastPassword;
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  void emit(AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser?> reloadCurrentUser() async => _currentUser;

  @override
  Future<void> sendEmailVerification() async {}

  @override
  bool get isGoogleSignInSupported => true;

  @override
  Future<AuthUser> signInWithGoogle() async {
    googleCalls += 1;
    final result = googleResult?.call();
    if (result == null) {
      throw AuthException(AuthErrorKind.unknown);
    }
    emit(result);
    return result;
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emailCalls += 1;
    lastEmail = email;
    lastPassword = password;
    final result = emailResult?.call(email: email, password: password);
    if (result == null) {
      throw AuthException(AuthErrorKind.invalidCredentials);
    }
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }
    final user = result as AuthUser;
    emit(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    emit(null);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _testUser = AuthUser(
  uid: 'uid-1',
  email: 'user@example.com',
  emailVerified: true,
  displayName: 'Test User',
);

Future<void> _pumpHost(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.vi,
  FakeAuthService? authService,
}) async {
  final fake = authService ?? FakeAuthService();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => language),
        authServiceProvider.overrideWithValue(fake),
      ],
      child: MaterialApp(
        theme: AppTheme.light(language),
        home: const Scaffold(body: _LoginLauncher()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'renders title, subtitle, Google button, and footer in Vietnamese',
    (tester) async {
      await _pumpHost(tester);
      await _openDialog(tester);

      expect(find.text('Đăng nhập'), findsWidgets);
      expect(
        find.text('Đăng nhập để đồng bộ tiến trình học của bạn.'),
        findsOneWidget,
      );
      expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
      expect(find.text('HOẶC'), findsOneWidget);
      expect(
        find.text('Nếu không tiện dùng Gmail hãy nhắn mình cấp tài khoản.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('renders email and password fields in Vietnamese', (
    tester,
  ) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('password visibility toggle flips the obscure-text icon', (
    tester,
  ) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);
  });

  testWidgets('close button dismisses the dialog', (tester) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    expect(find.byType(LoginDialog), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(LoginDialog), findsNothing);
  });

  testWidgets('Google button calls signInWithGoogle and dismisses on success', (
    tester,
  ) async {
    final fake = FakeAuthService(googleResult: () => _testUser);
    await _pumpHost(tester, authService: fake);
    await _openDialog(tester);

    await tester.tap(find.text('Đăng nhập bằng Google'));
    await tester.pumpAndSettle();

    expect(fake.googleCalls, 1);
    expect(find.byType(LoginDialog), findsNothing);
  });

  testWidgets(
    'Google button surfaces invalid-credentials snackbar on failure',
    (tester) async {
      // googleResult: null → service throws AuthException(unknown)
      final fake = FakeAuthService();
      await _pumpHost(tester, authService: fake);
      await _openDialog(tester);

      await tester.tap(find.text('Đăng nhập bằng Google'));
      await tester.pumpAndSettle();

      expect(fake.googleCalls, 1);
      expect(
        find.text('Đăng nhập thất bại. Vui lòng thử lại.'),
        findsOneWidget,
      );
      expect(find.byType(LoginDialog), findsOneWidget);
    },
  );

  testWidgets(
    'submit with empty fields surfaces a validation snackbar without calling service',
    (tester) async {
      final fake = FakeAuthService();
      await _pumpHost(tester, authService: fake);
      await _openDialog(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();
      expect(find.text('Vui lòng điền đầy đủ cả hai ô.'), findsWidgets);
      expect(fake.emailCalls, 0);
    },
  );

  testWidgets(
    'submit with both fields filled calls signInWithEmail and dismisses on success',
    (tester) async {
      final fake = FakeAuthService(
        emailResult: ({required email, required password}) => _testUser,
      );
      await _pumpHost(tester, authService: fake);
      await _openDialog(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'hunter2');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
      await tester.pumpAndSettle();

      expect(fake.emailCalls, 1);
      expect(fake.lastEmail, 'user@example.com');
      expect(fake.lastPassword, 'hunter2');
      expect(find.byType(LoginDialog), findsNothing);
    },
  );

  testWidgets('submit with wrong password shows invalid-credentials snackbar', (
    tester,
  ) async {
    // emailResult is null → fake throws invalidCredentials
    final fake = FakeAuthService();
    await _pumpHost(tester, authService: fake);
    await _openDialog(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Email hoặc mật khẩu không đúng.'), findsWidgets);
    expect(find.byType(LoginDialog), findsOneWidget);
  });

  testWidgets('submit surfaces unknown snackbar for AuthException unknown', (
    tester,
  ) async {
    final fake = FakeAuthService(
      emailResult: ({required email, required password}) =>
          AuthException(AuthErrorKind.unknown),
    );
    await _pumpHost(tester, authService: fake);
    await _openDialog(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'fake-test@example.com');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(
      find.widgetWithText(ElevatedButton, AppLanguage.vi.loginSubmitLabel),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.vi.authUnknownErrorLabel), findsWidgets);
    expect(find.byType(LoginDialog), findsOneWidget);
  });

  testWidgets(
    'submit surfaces unknown snackbar for non-AuthException failures',
    (tester) async {
      final fake = FakeAuthService(
        emailResult: ({required email, required password}) =>
            StateError('firebase web failed unexpectedly'),
      );
      await _pumpHost(tester, authService: fake);
      await _openDialog(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'fake-test@example.com');
      await tester.enterText(fields.at(1), 'wrongpass');
      await tester.tap(
        find.widgetWithText(ElevatedButton, AppLanguage.vi.loginSubmitLabel),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppLanguage.vi.authUnknownErrorLabel), findsWidgets);
      expect(find.byType(LoginDialog), findsOneWidget);
    },
  );

  testWidgets('English locale renders translated copy', (tester) async {
    await _pumpHost(tester, language: AppLanguage.en);
    await _openDialog(tester);

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
  });
}

class _LoginLauncher extends StatelessWidget {
  const _LoginLauncher();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => LoginDialog.show(context),
        child: const Text('open'),
      ),
    );
  }
}
