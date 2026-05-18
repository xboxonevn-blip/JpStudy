import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test('prints kanji coverage audit from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_kanji_coverage_cli_',
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
<reading_meaning><rmgroup><meaning>water</meaning></rmgroup></reading_meaning>
</character>
</kanjidic2>
''');

    final result = await runDartTool(
      [
        'tool/research/kanji_coverage_audit_report.dart',
        '--content-root',
        contentRoot.path,
        '--kanjidic2',
        kanjidic2.path,
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(
      result.stdout as String,
      contains('# Kanji Expansion Coverage Audit'),
    );
    expect(result.stdout as String, contains('| N5 | 1 | 2 | 1 |'));
    expect(result.stdout as String, contains('水'));
  }, timeout: dartCliTestTimeout);
}
