import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';

Map<String, dynamic> _minimalJson({
  String id = 'a1',
  String title = 'Test Article',
  String officialLevel = 'N3',
  String source = 'NHK',
  String publishedAt = '2024-01-15T00:00:00.000Z',
}) {
  return {
    'id': id,
    'title': title,
    'officialLevel': officialLevel,
    'source': source,
    'publishedAt': publishedAt,
    'paragraphs': <dynamic>[],
  };
}

void main() {
  group('ImmersionToken', () {
    test('fromJson maps all fields', () {
      final token = ImmersionToken.fromJson({
        'surface': '食べる',
        'reading': 'たべる',
        'meaningVi': 'ăn',
        'meaningEn': 'to eat',
      });
      expect(token.surface, '食べる');
      expect(token.reading, 'たべる');
      expect(token.meaningVi, 'ăn');
      expect(token.meaningEn, 'to eat');
    });

    test('fromJson missing optional fields → null', () {
      final token = ImmersionToken.fromJson({'surface': 'hello'});
      expect(token.reading, isNull);
      expect(token.meaningVi, isNull);
      expect(token.meaningEn, isNull);
    });

    test('fromJson missing surface → empty string', () {
      final token = ImmersionToken.fromJson({});
      expect(token.surface, '');
    });

    test('hasMeaning true when meaningEn is present', () {
      final token = ImmersionToken(surface: 'x', meaningEn: 'word');
      expect(token.hasMeaning, isTrue);
    });

    test('hasMeaning true when meaningVi is present', () {
      final token = ImmersionToken(surface: 'x', meaningVi: 'từ');
      expect(token.hasMeaning, isTrue);
    });

    test('hasMeaning false when both meanings are null', () {
      final token = ImmersionToken(surface: 'x');
      expect(token.hasMeaning, isFalse);
    });

    test('hasMeaning false when meanings are blank strings', () {
      final token =
          ImmersionToken(surface: 'x', meaningEn: '  ', meaningVi: '');
      expect(token.hasMeaning, isFalse);
    });

    test('toJson round-trips correctly', () {
      const token = ImmersionToken(
        surface: '食べ',
        reading: 'たべ',
        meaningVi: 'ăn',
        meaningEn: 'eat',
      );
      final json = token.toJson();
      final restored = ImmersionToken.fromJson(json);
      expect(restored.surface, token.surface);
      expect(restored.reading, token.reading);
      expect(restored.meaningVi, token.meaningVi);
      expect(restored.meaningEn, token.meaningEn);
    });
  });

  group('ImmersionArticle.normalizeOfficialLevel', () {
    test('exact match N1-N5 is preserved', () {
      for (final level in ['N1', 'N2', 'N3', 'N4', 'N5']) {
        expect(ImmersionArticle.normalizeOfficialLevel(level), level);
      }
    });

    test('lowercase is uppercased', () {
      expect(ImmersionArticle.normalizeOfficialLevel('n3'), 'N3');
    });

    test('JLPT prefix stripped via compact regex', () {
      expect(ImmersionArticle.normalizeOfficialLevel('JLPT N2'), 'N2');
      expect(ImmersionArticle.normalizeOfficialLevel('jlpt n4'), 'N4');
    });

    test('digit-only input normalized', () {
      expect(ImmersionArticle.normalizeOfficialLevel('3'), 'N3');
      expect(ImmersionArticle.normalizeOfficialLevel('5'), 'N5');
    });

    test('null returns fallback N5', () {
      expect(ImmersionArticle.normalizeOfficialLevel(null), 'N5');
    });

    test('empty string returns fallback N5', () {
      expect(ImmersionArticle.normalizeOfficialLevel(''), 'N5');
    });

    test('whitespace-only returns fallback N5', () {
      expect(ImmersionArticle.normalizeOfficialLevel('   '), 'N5');
    });

    test('unrecognized string returns fallback N5', () {
      expect(ImmersionArticle.normalizeOfficialLevel('beginner'), 'N5');
    });

    test('custom fallback is used when provided', () {
      expect(
        ImmersionArticle.normalizeOfficialLevel('???', fallback: 'N3'),
        'N3',
      );
    });
  });

  group('ImmersionArticle.normalizeDifficultyLabel', () {
    test('null returns null', () {
      expect(ImmersionArticle.normalizeDifficultyLabel(null), isNull);
    });

    test('empty string returns null', () {
      expect(ImmersionArticle.normalizeDifficultyLabel(''), isNull);
    });

    test('valid JLPT level normalized', () {
      expect(ImmersionArticle.normalizeDifficultyLabel('n2'), 'N2');
    });

    test('non-JLPT string preserved as-is (fallback = input)', () {
      // normalizeDifficultyLabel passes _cleanOptionalText(raw) as the fallback
      // to normalizeOfficialLevel. "hard" fails all JLPT branches, so the
      // original lowercase 'hard' is returned (not uppercased).
      expect(ImmersionArticle.normalizeDifficultyLabel('hard'), 'hard');
    });
  });

  group('ImmersionArticle.normalizeSourceLabel', () {
    test('null returns JpStudy Original', () {
      expect(
        ImmersionArticle.normalizeSourceLabel(null),
        ImmersionArticle.localSourceLabel,
      );
    });

    test('"sample" maps to JpStudy Original', () {
      expect(
        ImmersionArticle.normalizeSourceLabel('sample'),
        ImmersionArticle.localSourceLabel,
      );
    });

    test('"jpstudy" maps to JpStudy Original', () {
      expect(
        ImmersionArticle.normalizeSourceLabel('jpstudy'),
        ImmersionArticle.localSourceLabel,
      );
    });

    test('"local sample" maps to JpStudy Original', () {
      expect(
        ImmersionArticle.normalizeSourceLabel('local sample'),
        ImmersionArticle.localSourceLabel,
      );
    });

    test('real source label preserved', () {
      expect(ImmersionArticle.normalizeSourceLabel('NHK'), 'NHK');
    });

    test('custom fallback used when null', () {
      expect(
        ImmersionArticle.normalizeSourceLabel(null, fallback: 'Custom'),
        'Custom',
      );
    });
  });

  group('ImmersionArticle.fromJson', () {
    test('parses minimal json correctly', () {
      final article = ImmersionArticle.fromJson(_minimalJson());
      expect(article.id, 'a1');
      expect(article.title, 'Test Article');
      expect(article.officialLevel, 'N3');
      expect(article.source, 'NHK');
      expect(article.paragraphs, isEmpty);
      expect(article.translation, isNull);
      expect(article.titleFurigana, isNull);
      expect(article.estimatedDifficulty, isNull);
    });

    test('expectedLevel overrides json officialLevel', () {
      final json = _minimalJson(officialLevel: 'N5');
      final article = ImmersionArticle.fromJson(json, expectedLevel: 'N2');
      expect(article.officialLevel, 'N2');
    });

    test('fallbackSource used when source is null', () {
      final json = _minimalJson()..remove('source');
      final article = ImmersionArticle.fromJson(
        json,
        fallbackSource: 'Custom Source',
      );
      expect(article.source, 'Custom Source');
    });

    test('publishedAt parsed from ISO string', () {
      final article = ImmersionArticle.fromJson(
        _minimalJson(publishedAt: '2024-06-01T12:00:00.000Z'),
      );
      expect(article.publishedAt.year, 2024);
      expect(article.publishedAt.month, 6);
      expect(article.publishedAt.day, 1);
    });

    test('invalid publishedAt falls back to now (within 5s)', () {
      final before = DateTime.now();
      final article = ImmersionArticle.fromJson(
        _minimalJson(publishedAt: 'not-a-date'),
      );
      final after = DateTime.now();
      expect(
        article.publishedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(article.publishedAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('paragraphs with tokens parsed correctly', () {
      final json = _minimalJson();
      json['paragraphs'] = [
        [
          {'surface': '食べる', 'reading': 'たべる'},
          {'surface': 'は'},
        ],
        [
          {'surface': 'うまい'},
        ],
      ];
      final article = ImmersionArticle.fromJson(json);
      expect(article.paragraphs.length, 2);
      expect(article.paragraphs[0].length, 2);
      expect(article.paragraphs[0][0].surface, '食べる');
      expect(article.paragraphs[1][0].surface, 'うまい');
    });

    test('whitespace-only titleFurigana becomes null', () {
      final json = _minimalJson()..['titleFurigana'] = '   ';
      final article = ImmersionArticle.fromJson(json);
      expect(article.titleFurigana, isNull);
    });

    test('estimatedDifficulty normalized from json', () {
      final json = _minimalJson()..['estimatedDifficulty'] = 'n1';
      final article = ImmersionArticle.fromJson(json);
      expect(article.estimatedDifficulty, 'N1');
    });
  });

  group('ImmersionArticle.effectiveDifficulty', () {
    test('returns estimatedDifficulty when present', () {
      final json = _minimalJson(officialLevel: 'N5');
      json['estimatedDifficulty'] = 'N2';
      final article = ImmersionArticle.fromJson(json);
      expect(article.effectiveDifficulty, 'N2');
    });

    test('falls back to officialLevel when estimatedDifficulty is null', () {
      final article = ImmersionArticle.fromJson(_minimalJson(officialLevel: 'N4'));
      expect(article.effectiveDifficulty, 'N4');
    });
  });

  group('ImmersionArticle.copyWith', () {
    test('copies with title override', () {
      final original = ImmersionArticle.fromJson(_minimalJson());
      final copy = original.copyWith(title: 'New Title');
      expect(copy.title, 'New Title');
      expect(copy.id, original.id);
      expect(copy.officialLevel, original.officialLevel);
    });

    test('normalizes officialLevel in copyWith', () {
      final original = ImmersionArticle.fromJson(_minimalJson());
      final copy = original.copyWith(officialLevel: 'n1');
      expect(copy.officialLevel, 'N1');
    });
  });
}
