import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_router.dart';

Future<void> pumpSmokeRoute(
  WidgetTester tester,
  String route, {
  Object? extra,
}) async {
  AppRouter.router.go(route, extra: extra);
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> disposeSmokeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.idle();
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}
