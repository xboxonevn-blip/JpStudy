import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/models/radical_item.dart';
import 'package:jpstudy/features/kanji_hub/models/radical_detail_support.dart';

void main() {
  test(
    'buildRelatedKanjiForRadical finds kanji containing radical component',
    () {
      const radical = RadicalItem(
        id: 85,
        kanji: '\u6c34',
        strokes: 4,
        viMeaning: 'Thuy',
      );

      final items = [
        const KanjiItem(
          id: 1,
          lessonId: 1,
          character: '\u6d77',
          strokeCount: 9,
          meaning: 'sea',
          examples: [],
          jlptLevel: 'N5',
          decomposition: KanjiDecomposition(
            components: ['\u6c35', '\u6bce'],
            relatedKanji: ['\u6c34'],
          ),
        ),
        const KanjiItem(
          id: 2,
          lessonId: 1,
          character: '\u4f11',
          strokeCount: 6,
          meaning: 'rest',
          examples: [],
          jlptLevel: 'N5',
          decomposition: KanjiDecomposition(components: ['\u4ebb', '\u6728']),
        ),
        const KanjiItem(
          id: 3,
          lessonId: 1,
          character: '\u6cf3',
          strokeCount: 8,
          meaning: 'swim',
          examples: [],
          jlptLevel: 'N5',
          decomposition: KanjiDecomposition(components: ['\u6c34', '\u6c38']),
        ),
      ];

      final related = buildRelatedKanjiForRadical(radical, items);
      expect(related, ['\u6d77', '\u6cf3']);
    },
  );

  test('buildRelatedKanjiSummary groups related kanji by level order', () {
    const radical = RadicalItem(
      id: 72,
      kanji: '\u65e5',
      strokes: 4,
      viMeaning: 'Nhat',
    );

    final items = [
      const KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u660e',
        strokeCount: 8,
        meaning: 'bright',
        examples: [],
        jlptLevel: 'N5',
        decomposition: KanjiDecomposition(components: ['\u65e5', '\u6708']),
      ),
      const KanjiItem(
        id: 2,
        lessonId: 1,
        character: '\u6642',
        strokeCount: 10,
        meaning: 'time',
        examples: [],
        jlptLevel: 'N4',
        decomposition: KanjiDecomposition(components: ['\u65e5', '\u5bfa']),
      ),
      const KanjiItem(
        id: 3,
        lessonId: 1,
        character: '\u65e7',
        strokeCount: 5,
        meaning: 'old',
        examples: [],
        jlptLevel: 'N3',
        decomposition: KanjiDecomposition(relatedKanji: ['\u65e5']),
      ),
    ];

    final summary = buildRelatedKanjiSummary(radical, items);

    expect(summary.totalCount, 3);
    expect(summary.allCharacters, ['\u660e', '\u6642', '\u65e7']);
    expect(summary.byLevel.keys.toList(), ['N5', 'N4', 'N3']);
    expect(summary.byLevel['N4'], ['\u6642']);
  });

  test(
    'buildRelatedKanjiSummaryForKanji groups shared components by level',
    () {
      const source = KanjiItem(
        id: 1,
        lessonId: 1,
        character: '\u660e',
        strokeCount: 8,
        meaning: 'bright',
        examples: [],
        jlptLevel: 'N5',
        decomposition: KanjiDecomposition(components: ['\u65e5', '\u6708']),
      );

      final items = [
        source,
        const KanjiItem(
          id: 2,
          lessonId: 1,
          character: '\u6642',
          strokeCount: 10,
          meaning: 'time',
          examples: [],
          jlptLevel: 'N4',
          decomposition: KanjiDecomposition(components: ['\u65e5', '\u5bfa']),
        ),
        const KanjiItem(
          id: 3,
          lessonId: 1,
          character: '\u6708',
          strokeCount: 4,
          meaning: 'moon',
          examples: [],
          jlptLevel: 'N5',
          decomposition: KanjiDecomposition(relatedKanji: ['\u660e']),
        ),
        const KanjiItem(
          id: 4,
          lessonId: 1,
          character: '\u4f11',
          strokeCount: 6,
          meaning: 'rest',
          examples: [],
          jlptLevel: 'N5',
          decomposition: KanjiDecomposition(components: ['\u4ebb', '\u6728']),
        ),
      ];

      final summary = buildRelatedKanjiSummaryForKanji(source, items);

      expect(summary.allCharacters, ['\u6708', '\u6642']);
      expect(summary.byLevel.keys.toList(), ['N5', 'N4']);
      expect(summary.byLevel['N5'], ['\u6708']);
      expect(summary.byLevel['N4'], ['\u6642']);
    },
  );
}
