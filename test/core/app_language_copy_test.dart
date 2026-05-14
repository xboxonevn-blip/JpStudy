import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';

void main() {
  test('Vietnamese copy follows D3 terminology glossary seed', () {
    expect(AppLanguage.vi.practiceKanjiMistakesLabel(3), 'Luyện kanji (3)');
    expect(AppLanguage.vi.kanjiMeaningLabel, 'Nghĩa kanji');
    expect(AppLanguage.vi.immersionEmptyLabel, 'Chưa có bộ thẻ bài đọc.');
  });

  test('English count labels use singular nouns when count is one', () {
    expect(AppLanguage.en.termsCountLabel(1), '1 term');
    expect(AppLanguage.en.termsCountLabel(2), '2 terms');
    expect(AppLanguage.en.itemsCountLabel(1), '1 item');
    expect(AppLanguage.en.itemsCountLabel(2), '2 items');
    expect(AppLanguage.en.handwritingStrokeShortLabel(1), '1 stroke');
    expect(AppLanguage.en.handwritingStrokeShortLabel(2), '2 strokes');
    expect(AppLanguage.en.handwritingStrokeCountLabel(1), 'Expected: 1 stroke');
    expect(
      AppLanguage.en.handwritingStrokeCountLabel(2),
      'Expected: 2 strokes',
    );
    expect(
      AppLanguage.en.itemsReviewedViaSrsLabel(1),
      '1 item reviewed via SRS',
    );
    expect(
      AppLanguage.en.itemsReviewedViaSrsLabel(2),
      '2 items reviewed via SRS',
    );
    expect(AppLanguage.en.lessonCountLabel(1), '1 lesson');
    expect(AppLanguage.en.lessonCountLabel(2), '2 lessons');
    expect(AppLanguage.en.learnTermsAvailableLabel(1), '1 term available');
    expect(AppLanguage.en.learnTermsAvailableLabel(2), '2 terms available');
    expect(
      AppLanguage.en.testQuestionsAvailableLabel(1),
      '1 question available',
    );
    expect(
      AppLanguage.en.testQuestionsAvailableLabel(2),
      '2 questions available',
    );
    expect(
      AppLanguage.en.unansweredSubmitLabel(1),
      'You have 1 unanswered question. Submit anyway?',
    );
    expect(
      AppLanguage.en.unansweredSubmitLabel(2),
      'You have 2 unanswered questions. Submit anyway?',
    );
    expect(AppLanguage.en.termsNeedPracticeLabel(1), '1 term needs practice');
    expect(AppLanguage.en.termsNeedPracticeLabel(2), '2 terms need practice');
    expect(AppLanguage.en.reviewTermsDueLabel(1), '1 term due');
    expect(AppLanguage.en.reviewTermsDueLabel(2), '2 terms due');
  });
}
