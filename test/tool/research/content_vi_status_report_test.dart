import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prints Vietnamese content status from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_content_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final contentDir = Directory('${tempDir.path}/content');
    await File('${contentDir.path}/vocab/n1/sample.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'dataset': 'vocab',
              'level': 'N1',
              'entries': [
                {
                  'tags': ['machine-translated-vi', 'needs-vi-editorial'],
                  'sense': {'meaningViDraft': 'draft'},
                },
              ],
            }),
          ),
        );

    final result = await Process.run(Platform.isWindows ? 'dart.bat' : 'dart', [
      'run',
      'tool/research/content_vi_status_report.dart',
      '--content-root',
      contentDir.path,
    ]);

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('# Vietnamese Content Status'));
    expect(result.stdout as String, contains('Files scanned: `1`'));
    expect(result.stdout as String, contains('| N1 | 1 | 1 | 1 | 0 |'));
    expect(result.stdout as String, contains('| vocab | 1 | 1 | 1 | 0 |'));
  });
}
