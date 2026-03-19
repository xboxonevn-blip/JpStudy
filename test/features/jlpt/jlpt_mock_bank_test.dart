import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/data/db/content_database.dart' as content;
import 'package:jpstudy/features/jlpt/data/jlpt_mock_bank.dart';

void main() {
  const grammarPoint = content.GrammarPointData(
    id: 7,
    lessonId: 2,
    title: '何（なん）',
    titleEn: 'What? (nan/nani)',
    structure: 'これ / それ / あれ は 何（なん） です か',
    structureEn: 'kore / sore / are wa nan desu ka',
    explanation:
        'Câu hỏi với từ để hỏi 何 dùng để hỏi tên gọi hoặc nội dung của vật.',
    explanationEn:
        'Question with 何 (what). Used to ask for the name or content of an object.',
    level: 'N5',
    tags: null,
  );
  const staleBeforePoint = content.GrammarPointData(
    id: 18,
    lessonId: 18,
    title: '前に',
    titleEn: 'Before ... (mae ni)',
    structure: 'Vる / N の / 時間 + 前に、V2',
    structureEn: 'V-る / N の / Time + mae に, V2',
    explanation: 'Trước khi làm gì đó.',
    explanationEn: 'Before doing something.',
    level: 'N5',
    tags: null,
  );
  const staleHonorificPoint = content.GrammarPointData(
    id: 41,
    lessonId: 41,
    title: 'くださる / くださいました',
    titleEn: 'kudasaru / kudasaimashita',
    structure: 'N が N を くださいました',
    structureEn: 'N (superior) が N (thing) を くださいました',
    explanation: 'Kính ngữ của くれます.',
    explanationEn: 'Honorific form of くれます.',
    level: 'N4',
    tags: null,
  );
  const staleTeTitlePoint = content.GrammarPointData(
    id: 16,
    lessonId: 16,
    title: 'Nối câu (Vて、Vて)',
    titleEn: 'Connecting verbs (V-te, V-te)',
    structure: 'V1て、[V2て、] ～ ます',
    structureEn: 'V1-て, [V2-て,] ...',
    explanation: 'Nối các hành động liên tiếp.',
    explanationEn: 'Connects consecutive actions.',
    level: 'N5',
    tags: null,
  );

  test(
    'jlptMockGrammarPatternLabel normalizes stale romaji labels in English mode',
    () {
      expect(
        jlptMockGrammarPatternLabel(grammarPoint, AppLanguage.en),
        'What? (何 / なん / なに)',
      );
    },
  );

  test(
    'jlptMockGrammarStructureLabel normalizes stale romaji structures in English mode',
    () {
      expect(
        jlptMockGrammarStructureLabel(grammarPoint, AppLanguage.en),
        'これ / それ / あれ は 何ですか',
      );
    },
  );

  test(
    'grammar labels keep Vietnamese source text when app language is Vietnamese',
    () {
      expect(
        jlptMockGrammarPatternLabel(grammarPoint, AppLanguage.vi),
        '何（なん）',
      );
      expect(
        jlptMockGrammarStructureLabel(grammarPoint, AppLanguage.vi),
        'これ / それ / あれ は 何（なん） です か',
      );
    },
  );

  test('normalizes remaining mae romaji in English structures', () {
    expect(
      jlptMockGrammarStructureLabel(staleBeforePoint, AppLanguage.en),
      'V-る / N の / Time + 前に, V2',
    );
  });

  test('normalizes remaining honorific romaji labels in English mode', () {
    expect(
      jlptMockGrammarPatternLabel(staleHonorificPoint, AppLanguage.en),
      'くださる / くださいました',
    );
  });

  test('normalizes V-te labels in English grammar titles', () {
    expect(
      jlptMockGrammarPatternLabel(staleTeTitlePoint, AppLanguage.en),
      'Connecting verbs (V-て, V-て)',
    );
  });
}
