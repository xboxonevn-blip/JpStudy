import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/shared/widgets/confidence_rating.dart';

void main() {
  testWidgets('shows four FSRS ratings including Hard', (tester) async {
    final selected = <ConfidenceLevel>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfidenceRatingWidget(
            language: AppLanguage.en,
            onSelect: selected.add,
          ),
        ),
      ),
    );

    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);

    await tester.tap(find.text('Hard'));
    expect(selected.single, ConfidenceLevel.hard);
    expect(selected.single.value, 2);
  });
}
