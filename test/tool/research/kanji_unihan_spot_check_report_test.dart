import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test('prints kanji Unihan spot check from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_kanji_unihan_cli_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final contentRoot = Directory('${tempDir.path}/content');

    await File('${contentRoot.path}/kanji/n1/lesson_01.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N1',
              'entries': [
                {
                  'kanjiId': 'n1_k001',
                  'level': 'N1',
                  'character': '作',
                  'labels': {'hanViet': 'Tác'},
                },
              ],
            }),
          ),
        );
    final unihanReadings = File('${tempDir.path}/Unihan_Readings.txt');
    await unihanReadings.writeAsString('U+4F5C\tkVietnamese\ttác\n');

    final result = await runDartTool(
      [
        'tool/research/kanji_unihan_spot_check_report.dart',
        '--content-root',
        contentRoot.path,
        '--unihan-readings',
        unihanReadings.path,
        '--sample-size',
        '1',
        '--seed',
        'unit-seed',
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('# Kanji Unihan Spot Check'));
    expect(result.stdout as String, contains('| Exact matches | 1 |'));
    expect(
      result.stdout as String,
      contains('| N1 | n1_k001 | 作 | Tác | tác | match |'),
    );
  }, timeout: dartCliTestTimeout);
}
