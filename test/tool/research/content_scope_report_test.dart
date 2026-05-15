import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test('prints content scope from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_scope_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    final root = Directory('${tempDir.path}/content');

    await File('${root.path}/vocab/n5/minna/lesson_01.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N5',
              'entries': [
                {
                  'lemma': {'term': '学校'},
                },
              ],
            }),
          ),
        );

    final result = await runDartTool([
      'tool/research/content_scope_report.dart',
      '--content-root',
      root.path,
    ]);

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('# Content Scope Report'));
    expect(result.stdout as String, contains('| N5 | 1 | 0 | 0 | 0 |'));
  });
}
