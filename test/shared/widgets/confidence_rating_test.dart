import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
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

  testWidgets('interactive star rating exposes 44px touch targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StarRating(rating: 0, onRatingChanged: (_) {})),
      ),
    );

    for (var index = 1; index <= 5; index++) {
      final size = tester.getSize(
        find.byKey(ValueKey('star_rating_target_$index')),
      );
      expect(size.width, greaterThanOrEqualTo(AppTouchTargets.min));
      expect(size.height, greaterThanOrEqualTo(AppTouchTargets.min));
    }
  });
}
