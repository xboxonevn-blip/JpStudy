import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    final scaffoldFinder = find.byType(Scaffold);
    expect(scaffoldFinder, findsWidgets);

    final scaffoldTopLeft = tester.getTopLeft(scaffoldFinder.first);
    final scaffoldSize = tester.getSize(scaffoldFinder.first);
    expect(scaffoldSize.width, greaterThan(0));
    expect(scaffoldSize.height, greaterThan(0));
    expect(scaffoldTopLeft.dy, greaterThanOrEqualTo(0));

    await _disposeSmokeApp(tester);
  });
}
