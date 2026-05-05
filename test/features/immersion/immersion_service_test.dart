import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ImmersionArticle / reading bank', () {
    test(
      'ImmersionArticle normalizes JLPT level and local source metadata',
      () {
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
      },
    );

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
          (article) => const {
            'N5',
            'N4',
            'N3',
            'N2',
            'N1',
          }.contains(article.officialLevel),
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
              article.id == 'n3-lesson-01' && article.officialLevel == 'N3',
        ),
        isTrue,
      );
      expect(
        articles.any(
          (article) =>
              article.id == 'n2-lesson-01' && article.officialLevel == 'N2',
        ),
        isTrue,
      );
      expect(
        articles.any(
          (article) =>
              article.id == 'n1-lesson-01' && article.officialLevel == 'N1',
        ),
        isTrue,
      );
    });
  });

  group('read status', () {
    test('markArticleAsRead adds id to read set', () async {
      final service = ImmersionService();

      await service.markArticleAsRead('article_1', true);
      expect(await service.getReadArticleIds(), contains('article_1'));
    });

    test('markArticleAsRead(false) removes id from read set', () async {
      final service = ImmersionService();

      await service.markArticleAsRead('article_1', true);
      await service.markArticleAsRead('article_1', false);

      expect(await service.getReadArticleIds(), isNot(contains('article_1')));
    });

    test(
      'read ids are deduplicated because service stores them as a Set',
      () async {
        final service = ImmersionService();

        await service.markArticleAsRead('article_1', true);
        await service.markArticleAsRead('article_1', true);
        final ids = await service.getReadArticleIds();

        expect(ids.where((id) => id == 'article_1').length, 1);
      },
    );

    test('getReadArticleIds returns empty set by default', () async {
      final service = ImmersionService();
      expect(await service.getReadArticleIds(), isEmpty);
    });
  });

  group('quiz history', () {
    test('keeps quiz history intact for saved attempts', () async {
      final service = ImmersionService();

      await service.saveQuizAttempt(
        articleId: 'article_1',
        correct: 2,
        total: 3,
      );
      final history = await service.getQuizHistory('article_1');

      expect(history, hasLength(1));
      expect(history.first.correct, 2);
      expect(history.first.total, 3);
    });

    test('saveQuizAttempt is a no-op when total <= 0', () async {
      final service = ImmersionService();

      await service.saveQuizAttempt(
        articleId: 'article_1',
        correct: 2,
        total: 0,
      );
      expect(await service.getQuizHistory('article_1'), isEmpty);
    });

    test('newest attempts are inserted first', () async {
      final service = ImmersionService();

      await service.saveQuizAttempt(
        articleId: 'article_1',
        correct: 1,
        total: 3,
      );
      await service.saveQuizAttempt(
        articleId: 'article_1',
        correct: 2,
        total: 3,
      );
      final history = await service.getQuizHistory('article_1');

      expect(history, hasLength(2));
      expect(history.first.correct, 2);
      expect(history.last.correct, 1);
    });

    test('history is truncated to keep limit on save', () async {
      final service = ImmersionService();

      for (var i = 0; i < 5; i++) {
        await service.saveQuizAttempt(
          articleId: 'article_1',
          correct: i,
          total: 5,
          keep: 3,
        );
      }
      final history = await service.getQuizHistory('article_1', limit: 10);

      expect(history, hasLength(3));
      expect(history.first.correct, 4);
      expect(history.last.correct, 2);
    });

    test('getQuizHistory respects read limit argument', () async {
      final service = ImmersionService();

      for (var i = 0; i < 4; i++) {
        await service.saveQuizAttempt(
          articleId: 'article_1',
          correct: i,
          total: 4,
        );
      }
      final history = await service.getQuizHistory('article_1', limit: 2);

      expect(history, hasLength(2));
      expect(history.first.correct, 3);
      expect(history.last.correct, 2);
    });

    test(
      'getQuizHistory filters out corrupted entries with total <= 0',
      () async {
        SharedPreferences.setMockInitialValues({
          'immersion_quiz_history_v1': jsonEncode({
            'article_1': [
              {
                'correct': 2,
                'total': 0,
                'attemptedAt': '2026-02-01T10:00:00.000',
              },
              {
                'correct': 1,
                'total': 3,
                'attemptedAt': '2026-02-01T11:00:00.000',
              },
            ],
          }),
        });
        final service = ImmersionService();

        final history = await service.getQuizHistory('article_1');
        expect(history, hasLength(1));
        expect(history.first.total, 3);
      },
    );

    test('getQuizHistory returns empty on invalid JSON payload', () async {
      SharedPreferences.setMockInitialValues({
        'immersion_quiz_history_v1': 'not-json',
      });
      final service = ImmersionService();
      expect(await service.getQuizHistory('article_1'), isEmpty);
    });

    test(
      'getQuizHistory returns empty when decoded payload is not a map',
      () async {
        SharedPreferences.setMockInitialValues({
          'immersion_quiz_history_v1': jsonEncode(['bad', 'shape']),
        });
        final service = ImmersionService();
        expect(await service.getQuizHistory('article_1'), isEmpty);
      },
    );

    test(
      'saveQuizAttempt recovers from invalid existing JSON by rebuilding payload',
      () async {
        SharedPreferences.setMockInitialValues({
          'immersion_quiz_history_v1': 'not-json',
        });
        final service = ImmersionService();

        await service.saveQuizAttempt(
          articleId: 'article_1',
          correct: 2,
          total: 3,
        );
        final history = await service.getQuizHistory('article_1');

        expect(history, hasLength(1));
        expect(history.first.correct, 2);
        expect(history.first.total, 3);
      },
    );

    test('histories for different articles are isolated', () async {
      final service = ImmersionService();

      await service.saveQuizAttempt(
        articleId: 'article_1',
        correct: 2,
        total: 3,
      );
      await service.saveQuizAttempt(
        articleId: 'article_2',
        correct: 1,
        total: 2,
      );

      final history1 = await service.getQuizHistory('article_1');
      final history2 = await service.getQuizHistory('article_2');

      expect(history1, hasLength(1));
      expect(history1.first.correct, 2);
      expect(history2, hasLength(1));
      expect(history2.first.correct, 1);
    });
  });

  group('ImmersionQuizAttempt.fromJson', () {
    test('parses ints from string-like values', () {
      final attempt = ImmersionQuizAttempt.fromJson({
        'correct': '2',
        'total': '5',
        'attemptedAt': '2026-02-01T10:00:00.000',
      });
      expect(attempt.correct, 2);
      expect(attempt.total, 5);
    });

    test('falls back safely for invalid values', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final attempt = ImmersionQuizAttempt.fromJson({
        'correct': 'bad',
        'total': 'bad',
        'attemptedAt': 'not-a-date',
      });
      final after = DateTime.now().add(const Duration(seconds: 1));

      expect(attempt.correct, 0);
      expect(attempt.total, 0);
      expect(attempt.attemptedAt.isAfter(before), isTrue);
      expect(attempt.attemptedAt.isBefore(after), isTrue);
    });
  });
}
