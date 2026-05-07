import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/auth/widgets/login_dialog.dart';

Future<void> _pumpHost(
  WidgetTester tester, {
  AppLanguage language = AppLanguage.vi,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appLanguageProvider.overrideWith((ref) => language)],
      child: MaterialApp(
        theme: AppTheme.light(language),
        home: const Scaffold(
          body: _LoginLauncher(),
        ),
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
  testWidgets('renders title, subtitle, Google button, and footer in Vietnamese',
      (tester) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Đăng nhập để đồng bộ tiến trình học của bạn.'),
        findsOneWidget);
    expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
    expect(find.text('HOẶC'), findsOneWidget);
    expect(
      find.text('Nếu không tiện dùng Gmail hãy nhắn mình cấp tài khoản.'),
      findsOneWidget,
    );
  });

  testWidgets('renders email and password fields in Vietnamese',
      (tester) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('password visibility toggle flips the obscure-text icon',
      (tester) async {
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

  testWidgets('Google button taps show coming-soon snackbar', (tester) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    await tester.tap(find.text('Đăng nhập bằng Google'));
    await tester.pump();
    expect(find.text('Sắp ra mắt'), findsOneWidget);
  });

  testWidgets('submit with empty fields surfaces a validation snackbar',
      (tester) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    // The submit button is the only ElevatedButton with the localized text.
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Đăng nhập'),
    );
    await tester.pump();
    expect(find.text('Vui lòng điền đầy đủ cả hai ô.'), findsOneWidget);
  });

  testWidgets('submit with both fields filled shows coming-soon snackbar',
      (tester) async {
    await _pumpHost(tester);
    await _openDialog(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'hunter2');
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Đăng nhập'),
    );
    await tester.pump();
    expect(find.text('Sắp ra mắt'), findsOneWidget);
  });

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
