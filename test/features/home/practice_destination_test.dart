import 'package:jpstudy/app/navigation/app_route_constants.dart';
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
    expect(
      focus.any((item) => item.route == AppRoutePath.grammarPractice),
      isTrue,
    );
    expect(focus.any((item) => item.route == AppRoutePath.mistakes), isTrue);
  });

  test(
    'buildPracticeDestinations includes recall sprint and prioritizes it when review is due',
    () {
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
      expect(ranked.first.route, AppRoutePath.practiceRecallSprint);
    },
  );

  test(
    'buildPracticeDestinations renders JLPT Prep labels correctly in Vietnamese',
    () {
      final ranked = buildPracticeDestinations(
        language: AppLanguage.vi,
        dueReviewCount: 0,
        mistakeCount: 1,
        ghostCount: 1,
      );

      final jlptCoach = ranked.firstWhere((item) => item.id == 'jlpt_coach');
      expect(jlptCoach.title, 'Ôn thi JLPT');
      expect(
        jlptCoach.subtitle,
        'Thi thử đầy đủ, kiểm tra nhanh, đọc hiểu, chẩn đoán, kế hoạch 7 ngày.',
      );
    },
  );

  test(
    'buildPracticeDestinations no longer surfaces a separate JLPT Mock card',
    () {
      final ranked = buildPracticeDestinations(
        language: AppLanguage.en,
        dueReviewCount: 0,
        mistakeCount: 0,
        ghostCount: 0,
      );

      expect(ranked.any((item) => item.id == 'mock_exam'), isFalse);
      expect(
        ranked.any((item) => item.route == AppRoutePath.practiceMockExam),
        isFalse,
      );
    },
  );

  test(
    'buildPracticeDestinations keeps grammar repair and weak points distinct',
    () {
      final ranked = buildPracticeDestinations(
        language: AppLanguage.en,
        dueReviewCount: 0,
        ghostCount: 2,
        mistakeCount: 3,
      );

      final grammarRepair = ranked.firstWhere((item) => item.id == 'ghost');
      final weakPoints = ranked.firstWhere((item) => item.id == 'mistakes');

      expect(grammarRepair.title, 'Grammar repair');
      expect(weakPoints.title, 'Weak points');
      expect(grammarRepair.title, isNot(weakPoints.title));
    },
  );
}
