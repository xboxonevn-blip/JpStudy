import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/global_top_bar.dart';

Widget _wrap(AppLanguage language) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => language),
      ],
      child: const MaterialApp(
        home: Scaffold(body: GlobalTopBar()),
      ),
    );

void main() {
  testWidgets('GlobalTopBar shows English tooltips and menu labels', (
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
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('GlobalTopBar shows Japanese language tooltip', (tester) async {
    await tester.pumpWidget(_wrap(AppLanguage.ja));
    await tester.pumpAndSettle();

    expect(find.byTooltip('言語を選択'), findsOneWidget);
    expect(find.byTooltip('通知'), findsOneWidget);
  });
}
