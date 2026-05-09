import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/foundations/providers/kana_review_provider.dart';
import 'package:jpstudy/features/foundations/widgets/kana_review_due_card.dart';

void main() {
  testWidgets('due card shows due kana count', (tester) async {
    KanaReviewDueCard.showInWidgetTests = true;
    addTearDown(() => KanaReviewDueCard.showInWidgetTests = false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          dueKanaCountProvider.overrideWith((ref) => Stream.value(1)),
        ],
        child: const MaterialApp(home: Scaffold(body: KanaReviewDueCard())),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('1 kana due today'), findsOneWidget);
  });
}
