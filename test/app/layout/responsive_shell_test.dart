import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/home/widgets/daily_session_card.dart';

import '../../support/release_smoke_harness.dart';

Future<void> _disposeSmokeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.idle();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('mobile shell keeps home content visible at 414x896', (
    tester,
  ) async {
    await pumpReleaseSmokeApp(tester, size: const Size(414, 896));

    final contentFinder = find.byType(DailySessionCard);
    expect(contentFinder, findsWidgets);

    final contentTopLeft = tester.getTopLeft(contentFinder.first);
    final contentSize = tester.getSize(contentFinder.first);
    expect(contentSize.width, greaterThan(0));
    expect(contentSize.height, greaterThan(0));
    expect(contentTopLeft.dy, greaterThan(0));
    expect(find.text('Start session'), findsOneWidget);

    await _disposeSmokeApp(tester);
  });
}
