import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/community/community_screen.dart';

Widget buildScreen({AppLanguage language = AppLanguage.en}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
    ],
    child: const MaterialApp(home: CommunityScreen()),
  );
}

void main() {
  testWidgets('tapping Send feedback opens a feedback dialog (EN)', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Scroll to make the connect section visible.
    await tester.scrollUntilVisible(
      find.text('Send feedback'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Send feedback'), findsAtLeastNWidgets(1));
    expect(find.text('What would you like us to know?'), findsOneWidget);
  });

  testWidgets('tapping Cancel closes the feedback dialog', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Send feedback'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send feedback'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'tapping Invite a friend does NOT open a feedback dialog (snackbar instead)',
    (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Invite a friend'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Invite a friend'));
      await tester.pumpAndSettle();

      // No dialog should appear.
      expect(find.byType(AlertDialog), findsNothing);
      // Snackbar should appear instead.
      expect(
        find.text('Referral flow is on our roadmap — stay tuned!'),
        findsOneWidget,
      );
    },
  );
}
