import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/auth/auth_service.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/features/auth/widgets/login_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SharedPreferences.setMockInitialValues({'app.locale': language.name});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
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

      expect(find.text(AppLanguage.vi.loginDialogTitle), findsWidgets);
      expect(
        find.text(AppLanguage.vi.loginDialogSubtitle),
        findsOneWidget,
      );
      expect(find.text(AppLanguage.vi.signInWithGoogleLabel), findsOneWidget);
      expect(find.text(AppLanguage.vi.orDividerLabel), findsOneWidget);
      expect(
        find.text(AppLanguage.vi.loginManualAccountFooterLabel),
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
    expect(find.text(AppLanguage.vi.loginPasswordLabel), findsOneWidget);
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

    await tester.tap(find.text(AppLanguage.vi.signInWithGoogleLabel));
    await tester.pumpAndSettle();

    expect(fake.googleCalls, 1);
    expect(find.byType(LoginDialog), findsNothing);
  });

  testWidgets('Google button surfaces inline error on failure', (tester) async {
    // googleResult: null â†’ service throws AuthException(unknown)
    final fake = FakeAuthService();
    await _pumpHost(tester, authService: fake);
    await _openDialog(tester);

    await tester.tap(find.text(AppLanguage.vi.signInWithGoogleLabel));
    await tester.pumpAndSettle();

    expect(fake.googleCalls, 1);
    expect(find.text(AppLanguage.vi.authUnknownErrorLabel), findsOneWidget);
    expect(find.byType(LoginDialog), findsOneWidget);
  });

  testWidgets(
    'submit with empty fields surfaces inline validation without calling service',
    (tester) async {
      final fake = FakeAuthService();
      await _pumpHost(tester, authService: fake);
      await _openDialog(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, AppLanguage.vi.loginSubmitLabel));
      await tester.pumpAndSettle();
      expect(find.text(AppLanguage.vi.loginEmptyFieldLabel), findsWidgets);
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
      await tester.tap(find.widgetWithText(ElevatedButton, AppLanguage.vi.loginSubmitLabel));
      await tester.pumpAndSettle();

      expect(fake.emailCalls, 1);
      expect(fake.lastEmail, 'user@example.com');
      expect(fake.lastPassword, 'hunter2');
      expect(find.byType(LoginDialog), findsNothing);
    },
  );

  testWidgets('submit with wrong password shows specific inline error', (
    tester,
  ) async {
    final fake = FakeAuthService(
      emailResult: ({required email, required password}) =>
          AuthException(AuthErrorKind.wrongPassword),
    );
    await _pumpHost(tester, authService: fake);
    await _openDialog(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, AppLanguage.vi.loginSubmitLabel));
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.vi.authWrongPasswordLabel), findsWidgets);
    expect(find.byType(LoginDialog), findsOneWidget);
  });

  testWidgets('submit with missing email shows specific inline error', (
    tester,
  ) async {
    final fake = FakeAuthService(
      emailResult: ({required email, required password}) =>
          AuthException(AuthErrorKind.userNotFound),
    );
    await _pumpHost(tester, authService: fake);
    await _openDialog(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'missing@example.com');
    await tester.enterText(fields.at(1), 'hunter2');
    await tester.tap(find.widgetWithText(ElevatedButton, AppLanguage.vi.loginSubmitLabel));
    await tester.pumpAndSettle();

    expect(find.text(AppLanguage.vi.authUserNotFoundLabel), findsWidgets);
    expect(find.byType(LoginDialog), findsOneWidget);
  });

  testWidgets(
    'submit surfaces unknown inline error for AuthException unknown',
    (tester) async {
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
    },
  );

  testWidgets(
    'submit surfaces unknown inline error for non-AuthException failures',
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
