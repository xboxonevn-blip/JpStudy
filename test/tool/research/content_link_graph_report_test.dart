import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prints content link graph coverage from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_links_');
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
                  'lemma': {
                    'term': '学校',
                    'kanji': ['学'],
                  },
                },
              ],
            }),
          ),
        );
    await File('${root.path}/kanji/n5/lesson_01.json')
        .create(recursive: true)
        .then(
          (file) => file.writeAsString(
            jsonEncode({
              'level': 'N5',
              'entries': [
                {'character': '学'},
              ],
            }),
          ),
        );

    final result = await Process.run(Platform.isWindows ? 'dart.bat' : 'dart', [
      'run',
      'tool/research/content_link_graph_report.dart',
      '--content-root',
      root.path,
    ]);

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('# Content Link Graph Report'));
    expect(result.stdout as String, contains('| N5 | 1 | 1 | 1 | 1 | 1 | 1 |'));
  });
}
