import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/utils/grammar_example_quality.dart';

void main() {
  group('GrammarExampleQualityAssessor', () {
    test(
      'prioritizes statement examples for transformation and replacement',
      () {
        final report = GrammarExampleQualityAssessor.assessBlock(
          grammarPoint: 'です',
          locale: GrammarExampleLocale.en,
          examples: const [
            GrammarExampleSeedData(
              sentence: 'わたしは学生です。',
              translation: 'Tôi là học sinh.',
              translationEn: 'I am a student.',
            ),
            GrammarExampleSeedData(
              sentence: 'あなたは学生ですか。',
              translation: 'Bạn là học sinh phải không?',
              translationEn: 'Are you a student?',
            ),
            GrammarExampleSeedData(
              sentence: 'お国はどちらですか。…日本です。',
              translation: 'Bạn đến từ đâu?... Nhật Bản.',
              translationEn: 'Where are you from? ... Japan.',
            ),
          ],
        );

        final transformExamples = report.prioritizedFor(
          GrammarExampleQuestionKind.transformation,
        );
        final replacementExamples = report.prioritizedFor(
          GrammarExampleQuestionKind.errorCorrection,
        );
        final contextExamples = report.prioritizedFor(
          GrammarExampleQuestionKind.contextChoice,
        );

        expect(transformExamples.map((item) => item.example.sentence), [
          'わたしは学生です。',
        ]);
        expect(replacementExamples.first.example.sentence, 'わたしは学生です。');
        expect(
          contextExamples.every((item) => !item.example.sentence.contains('…')),
          isTrue,
        );
      },
    );

    test('marks prompt fallback as not usable for context choice', () {
      final report = GrammarExampleQualityAssessor.assessBlock(
        grammarPoint: 'に',
        locale: GrammarExampleLocale.en,
        examples: const [
          GrammarExampleSeedData(
            sentence: '学校に行きます。',
            translation: '学校に行きます。',
            translationVi: 'Tôi đi đến trường.',
          ),
        ],
      );

      final assessment = report.examples.single;
      expect(assessment.hasUsablePrompt, isFalse);
      expect(
        assessment.supports(GrammarExampleQuestionKind.contextChoice),
        isFalse,
      );
      expect(assessment.notes, contains('prompt_falls_back_to_source'));
    });

    test('supports broader negative transformations for plain and te-iru endings', () {
      expect(
        GrammarExampleQualityAssessor.transformToNegative(
          '毎朝散歩することにしている。',
        ),
        '毎朝散歩することにしていない。',
      );
      expect(
        GrammarExampleQualityAssessor.transformToNegative('明日ビザを取りに行く。'),
        '明日ビザを取りに行かない。',
      );
      expect(
        GrammarExampleQualityAssessor.transformToNegative('部屋は静かだ。'),
        '部屋は静かではない。',
      );
      expect(
        GrammarExampleQualityAssessor.transformToNegative('この道は危ない。'),
        'この道は危なくない。',
      );
    });

    test('does not transform already-negative or request-like statements', () {
      expect(
        GrammarExampleQualityAssessor.transformToNegative(
          'あの人が約束を忘れるはずがない。',
        ),
        isNull,
      );
      expect(
        GrammarExampleQualityAssessor.transformToNegative(
          'ここに名前を書いてください。',
        ),
        isNull,
      );
    });
  });
}
