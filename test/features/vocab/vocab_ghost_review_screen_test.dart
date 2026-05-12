import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/vocab/screens/vocab_ghost_review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

VocabItem _vocab(int id, String term, String meaning) => VocabItem(
  id: id,
  term: term,
  reading: 'reading',
  meaning: meaning,
  meaningEn: meaning,
  level: 'N5',
);

Widget buildScreen(List<VocabItem> items) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
  ],
  child: MaterialApp(home: VocabGhostReviewScreen(items: items)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Words Review app bar title', (tester) async {
    await tester.pumpWidget(buildScreen([_vocab(1, '火', 'fire')]));
    await tester.pump();
    expect(find.text(AppLanguage.en.reviewVocabLabel), findsOneWidget);
  });

  testWidgets('shows progress counter and indicator', (tester) async {
    await tester.pumpWidget(
      buildScreen([_vocab(1, '火', 'fire'), _vocab(2, '水', 'water')]),
    );
    await tester.pump();
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows tap-to-reveal button before flip', (tester) async {
    await tester.pumpWidget(buildScreen([_vocab(1, '火', 'fire')]));
    await tester.pump();
    expect(find.text(AppLanguage.en.tapCardToRevealLabel), findsWidgets);
  });
}
