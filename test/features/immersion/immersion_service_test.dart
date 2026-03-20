import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ImmersionArticle normalizes JLPT level and local source metadata', () {
    final article = ImmersionArticle.fromJson({
      'id': 'sample',
      'title': 'Sample',
      'level': 'n4',
      'source': 'Local',
      'publishedAt': '2026-02-01',
      'paragraphs': [
        [
          {'surface': '旅行', 'reading': 'りょこう', 'meaningEn': 'trip'},
        ],
      ],
    }, expectedLevel: 'n5');

    expect(article.officialLevel, 'N5');
    expect(article.source, ImmersionArticle.localSourceLabel);
  });

  test('ImmersionService loads a canonical local reading bank', () async {
    final articles = await ImmersionService().loadLocalSamples();

    expect(articles, isNotEmpty);
    expect(
      articles.every(
        (article) => article.source == ImmersionArticle.localSourceLabel,
      ),
      isTrue,
    );
    expect(
      articles.every(
        (article) => const {'N5', 'N4', 'N3'}.contains(article.officialLevel),
      ),
      isTrue,
    );
    expect(
      articles.any(
        (article) =>
            article.id == 'n5-lesson-01' && article.officialLevel == 'N5',
      ),
      isTrue,
    );
    expect(
      articles.any(
        (article) =>
            article.id == 'n4-lesson-26' && article.officialLevel == 'N4',
      ),
      isTrue,
    );
    expect(
      articles.any(
        (article) =>
            article.id == 'n3-lesson-51' && article.officialLevel == 'N3',
      ),
      isTrue,
    );
  });

  test('ImmersionService keeps read status and quiz history intact', () async {
    final service = ImmersionService();

    await service.markArticleAsRead('article_1', true);
    expect(await service.getReadArticleIds(), contains('article_1'));

    await service.saveQuizAttempt(articleId: 'article_1', correct: 2, total: 3);
    final history = await service.getQuizHistory('article_1');

    expect(history, hasLength(1));
    expect(history.first.correct, 2);
    expect(history.first.total, 3);
  });
}
