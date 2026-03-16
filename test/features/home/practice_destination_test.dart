import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';

void main() {
  test(
    'applyPracticeDestinationOrder reorders known ids and keeps remaining',
    () {
      final ranked = buildPracticeDestinations(
        language: AppLanguage.en,
        ghostCount: 2,
        mistakeCount: 1,
        dueReviewCount: 3,
      );

      final ordered = applyPracticeDestinationOrder(
        rankedDestinations: ranked,
        preferredOrder: const ['immersion', 'handwriting'],
      );

      expect(ordered.first.id, 'immersion');
      expect(ordered[1].id, 'handwriting');
      expect(ordered.length, ranked.length);
    },
  );

  test('selectFocusPracticeDestinations returns top 3 items', () {
    final ranked = buildPracticeDestinations(
      language: AppLanguage.en,
      ghostCount: 4,
      mistakeCount: 2,
      dueReviewCount: 0,
      preferImmersion: true,
    );

    final focus = selectFocusPracticeDestinations(
      rankedDestinations: ranked,
      limit: 3,
    );

    expect(focus.length, 3);
    expect(focus.any((item) => item.route == '/grammar-practice'), isTrue);
    expect(focus.any((item) => item.route == '/mistakes'), isTrue);
  });

  test('buildPracticeDestinations includes recall sprint and prioritizes it when review is due', () {
    final ranked = buildPracticeDestinations(
      language: AppLanguage.en,
      dueReviewCount: 6,
      vocabDue: 3,
      grammarDue: 2,
      kanjiDue: 1,
      mistakeCount: 0,
    );

    expect(ranked.any((item) => item.id == 'recall_sprint'), isTrue);
    expect(ranked.first.id, 'recall_sprint');
    expect(ranked.first.route, '/practice/recall-sprint');
  });
}
