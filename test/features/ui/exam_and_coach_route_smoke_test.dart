import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_router.dart';

import '../../support/release_smoke_harness.dart';

void main() {
  testWidgets('exam-center route stays mountable', (tester) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    Future<void> pumpRoute(String route) async {
      AppRouter.router.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await pumpRoute('/exam-center');
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/exam-center');
    expect(find.textContaining('Mock Exam'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.idle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('jlpt coach route stays mountable', (tester) async {
    await pumpReleaseSmokeApp(tester, size: const Size(1440, 1600));

    Future<void> pumpRoute(String route) async {
      AppRouter.router.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await pumpRoute('/jlpt/coach');
    expect(AppRouter.router.routeInformationProvider.value.uri.path, '/jlpt/coach');
    expect(find.text('JLPT Prep'), findsWidgets);
    expect(find.text('JLPT N5 prep hub'), findsOneWidget);
    expect(find.textContaining('mock'), findsWidgets);
    expect(find.textContaining('Reading'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.idle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
