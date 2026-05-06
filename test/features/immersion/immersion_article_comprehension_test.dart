import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';

Map<String, dynamic> _articleJson({Object? comprehensionQuestions}) {
  return {
    'id': 'n2_lesson_01',
    'title': '地域の変化',
    'officialLevel': 'N2',
    'source': 'JpStudy Original',
    'publishedAt': '2026-03-19T00:00:00.000',
    'paragraphs': [
      [
        {'surface': '地域', 'reading': 'ちいき', 'meaningVi': 'khu vực'},
      ],
    ],
    'translation': 'Bản dịch mẫu.',
    'comprehensionQuestions': ?comprehensionQuestions,
  };
}

void main() {
  test('ImmersionArticle.fromJson parses comprehensionQuestions array', () {
    final article = ImmersionArticle.fromJson(
      _articleJson(
        comprehensionQuestions: [
          {
            'question': '筆者が述べていることは何ですか。',
            'options': ['A', 'B', 'C', 'D'],
            'correctIndex': 2,
          },
        ],
      ),
    );

    expect(article.comprehensionQuestions, hasLength(1));
    expect(article.comprehensionQuestions.single.question, '筆者が述べていることは何ですか。');
    expect(article.comprehensionQuestions.single.options, ['A', 'B', 'C', 'D']);
    expect(article.comprehensionQuestions.single.correctIndex, 2);
  });

  test('ImmersionArticle.fromJson returns empty list when key is absent', () {
    final article = ImmersionArticle.fromJson(_articleJson());

    expect(article.comprehensionQuestions, isEmpty);
  });

  test('ComprehensionQuestion.fromJson parses all optional fields', () {
    final question = ComprehensionQuestion.fromJson({
      'question': '筆者の主張は何ですか。',
      'questionVi': 'Luận điểm của tác giả là gì?',
      'options': ['A', 'B', 'C', 'D'],
      'optionsVi': ['Một', 'Hai', 'Ba', 'Bốn'],
      'correctIndex': 1,
      'explanationVi': 'Đáp án B phù hợp nhất với ý chính.',
    });

    expect(question.question, '筆者の主張は何ですか。');
    expect(question.questionVi, 'Luận điểm của tác giả là gì?');
    expect(question.options, ['A', 'B', 'C', 'D']);
    expect(question.optionsVi, ['Một', 'Hai', 'Ba', 'Bốn']);
    expect(question.correctIndex, 1);
    expect(question.explanationVi, 'Đáp án B phù hợp nhất với ý chính.');
  });

  test(
    'ImmersionArticle.fromJson skips malformed comprehensionQuestions entries',
    () {
      final article = ImmersionArticle.fromJson(
        _articleJson(
          comprehensionQuestions: [
            null,
            'bad',
            ['bad'],
            {
              'question': '内容に合うものはどれですか。',
              'options': ['A', 'B', 'C', 'D'],
              'correctIndex': 0,
            },
          ],
        ),
      );

      expect(article.comprehensionQuestions, hasLength(1));
      expect(article.comprehensionQuestions.single.correctIndex, 0);
    },
  );
}
