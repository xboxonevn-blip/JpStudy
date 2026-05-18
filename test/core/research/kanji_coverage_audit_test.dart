import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/kanji_coverage_audit.dart';

void main() {
  test(
    'compares current kanji assets against KANJIDIC2 old JLPT tiers',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'jpstudy_kanji_coverage_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final contentRoot = Directory('${tempDir.path}/content');
      await File('${contentRoot.path}/kanji/n5/lesson_01.json')
          .create(recursive: true)
          .then(
            (file) => file.writeAsString(
              jsonEncode({
                'entries': [
                  {
                    'character': '日',
                    'labels': {
                      'hanViet': 'Nhật',
                      'meaningVi': 'ngày',
                      'meaningEn': 'day',
                    },
                    'readings': {
                      'onyomi': ['ニチ'],
                      'kunyomi': ['ひ'],
                    },
                    'strokeCount': 4,
                    'decomposition': {
                      'relatedKanji': ['月'],
                    },
                    'examples': [
                      {'word': '日本'},
                    ],
                  },
                ],
              }),
            ),
          );

      final kanjidic2 = File('${tempDir.path}/kanjidic2.xml');
      await kanjidic2.writeAsString('''
<kanjidic2>
<character>
<literal>日</literal>
<misc><stroke_count>4</stroke_count><jlpt>4</jlpt></misc>
<reading_meaning><rmgroup>
<reading r_type="vietnam">Nhật</reading>
<reading r_type="ja_on">ニチ</reading>
<reading r_type="ja_kun">ひ</reading>
<meaning>day</meaning>
</rmgroup></reading_meaning>
</character>
<character>
<literal>水</literal>
<misc><stroke_count>4</stroke_count><jlpt>4</jlpt></misc>
<reading_meaning><rmgroup>
<reading r_type="vietnam">Thủy</reading>
<reading r_type="ja_on">スイ</reading>
<reading r_type="ja_kun">みず</reading>
<meaning>water</meaning>
</rmgroup></reading_meaning>
</character>
</kanjidic2>
''');

      final report = await KanjiCoverageAuditRunner.run(
        contentRoot: contentRoot,
        kanjidic2Xml: kanjidic2,
      );

      expect(report.currentUniqueTotal, 1);
      expect(report.sourceUniqueTotal, 2);
      expect(report.levels['N5']!.currentUnique, 1);
      expect(report.levels['N5']!.sourceUnique, 2);
      expect(report.levels['N5']!.missingCharacters, ['水']);
      expect(report.levels['N5']!.missingCompleteness, isEmpty);
    },
  );

  test(
    'reports incomplete current entries separately from source gaps',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'jpstudy_kanji_coverage_incomplete_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final contentRoot = Directory('${tempDir.path}/content');
      await File('${contentRoot.path}/kanji/n4/lesson_01.json')
          .create(recursive: true)
          .then(
            (file) => file.writeAsString(
              jsonEncode({
                'entries': [
                  {
                    'character': '海',
                    'labels': {'meaningVi': ''},
                    'readings': {'onyomi': [], 'kunyomi': []},
                    'strokeCount': 0,
                    'examples': [],
                  },
                ],
              }),
            ),
          );

      final kanjidic2 = File('${tempDir.path}/kanjidic2.xml');
      await kanjidic2.writeAsString('''
<kanjidic2>
<character>
<literal>海</literal>
<misc><stroke_count>9</stroke_count><jlpt>3</jlpt></misc>
<reading_meaning><rmgroup>
<reading r_type="vietnam">Hải</reading>
<reading r_type="ja_on">カイ</reading>
<reading r_type="ja_kun">うみ</reading>
<meaning>sea</meaning>
</rmgroup></reading_meaning>
</character>
</kanjidic2>
''');

      final report = await KanjiCoverageAuditRunner.run(
        contentRoot: contentRoot,
        kanjidic2Xml: kanjidic2,
      );

      expect(report.levels['N4']!.missingCharacters, isEmpty);
      expect(report.levels['N4']!.missingCompleteness, hasLength(1));
      expect(report.levels['N4']!.missingCompleteness.single.character, '海');
      expect(
        report.levels['N4']!.missingCompleteness.single.missingFields,
        containsAll([
          'hanViet',
          'meaningVi',
          'onyomi/kunyomi',
          'strokeCount',
          'examples',
        ]),
      );
    },
  );
}
