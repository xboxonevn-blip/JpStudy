import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';

import '../../support/release_smoke_harness.dart';

Future<void> _disposeSmokeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.idle();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('desktop shell shows top bar, sidebar, and roadmap by default', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    expect(find.text('JP Study'), findsOneWidget);
    expect(find.byTooltip('Choose language'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.text('Roadmap'), findsWidgets);
    expect(find.text('Kanji'), findsOneWidget);
    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Exams'), findsOneWidget);
    expect(find.text('Ranks'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);

    await _disposeSmokeApp(tester);
  });

  testWidgets('mobile shell shows top bar, bottom nav, and more sheet', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(390, 844));

    expect(find.text('JP Study'), findsOneWidget);
    expect(find.byTooltip('Choose language'), findsOneWidget);
    expect(find.text('Roadmap'), findsOneWidget);
    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Kanji'), findsOneWidget);
    expect(find.text('Exams'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Ranks'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.text('Community'), findsAtLeastNWidgets(1));

    await _disposeSmokeApp(tester);
  });

  testWidgets('language picker opens and Japanese option is selectable', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    await tester.tap(find.byTooltip('Choose language'));
    await tester.pumpAndSettle();

    final jaOption = find.text(AppLanguage.ja.label).last;
    expect(jaOption, findsOneWidget);
    await tester.ensureVisible(jaOption);
    await tester.tap(jaOption, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('JP Study'), findsOneWidget);
    expect(find.byTooltip('Choose language'), findsOneWidget);

    await _disposeSmokeApp(tester);
  });
}
