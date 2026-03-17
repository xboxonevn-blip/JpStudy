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

  test('buildPracticeDestinations renders JLPT Coach labels correctly in Vietnamese', () {
    final ranked = buildPracticeDestinations(
      language: AppLanguage.vi,
      dueReviewCount: 0,
      mistakeCount: 1,
      ghostCount: 1,
    );

    final jlptCoach = ranked.firstWhere((item) => item.id == 'jlpt_coach');
    expect(jlptCoach.title, '\u0054r\u1ee3 l\u00fd JLPT');
    expect(
      jlptCoach.subtitle,
      '\u0110\u1ecdc hi\u1ec3u, mock exam, ch\u1ea9n \u0111o\u00e1n, k\u1ebf ho\u1ea1ch 7 ng\u00e0y.',
    );
  });
}
