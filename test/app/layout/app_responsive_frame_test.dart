import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/layout/app_responsive_frame.dart';

void main() {
  testWidgets('sizes to child inside vertically unbounded scrollables', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              AppResponsiveFrame(
                child: SizedBox(height: 120, child: Text('dashboard content')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('dashboard content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
