import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_provider.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/global_top_bar.dart';

Widget _wrap(AppLanguage language, {AuthUser? signedInUser}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(language),
    ),
    authStateProvider.overrideWith((ref) => Stream.value(signedInUser)),
  ],
  child: const MaterialApp(home: Scaffold(body: GlobalTopBar())),
);

void main() {
  testWidgets('GlobalTopBar shows Sign in entry when signed out', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(AppLanguage.en));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Choose language'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(find.text('Invite friends'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    // Signed-out users see Sign in instead of Log out.
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Log out'), findsNothing);
  });

  testWidgets(
    'GlobalTopBar shows Log out + signed-in identity when authenticated',
    (tester) async {
      const user = AuthUser(
        uid: 'uid-1',
        email: 'student@example.com',
        displayName: 'Test Student',
      );
      await tester.pumpWidget(_wrap(AppLanguage.en, signedInUser: user));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Test Student'), findsOneWidget);
      expect(find.text('student@example.com'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
    },
  );

  testWidgets('GlobalTopBar shows Japanese language tooltip', (tester) async {
    await tester.pumpWidget(_wrap(AppLanguage.ja));
    await tester.pumpAndSettle();

    expect(find.byTooltip('言語を選択'), findsOneWidget);
    expect(find.byTooltip('通知'), findsOneWidget);
  });

  testWidgets('notifications control keeps a 44px touch target', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(AppLanguage.en));
    await tester.pumpAndSettle();

    final size = tester.getSize(
      find.byKey(const ValueKey('global_notifications_touch_target')),
    );
    expect(size.width, greaterThanOrEqualTo(AppTouchTargets.min));
    expect(size.height, greaterThanOrEqualTo(AppTouchTargets.min));
  });
}
