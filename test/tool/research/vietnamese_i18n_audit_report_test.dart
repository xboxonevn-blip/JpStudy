import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test('prints Vietnamese i18n audit from the CLI', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_i18n_cli_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final appLanguage = File('${tempDir.path}/lib/core/app_language.dart');
    await appLanguage.create(recursive: true);
    await appLanguage.writeAsString('''
enum AppLanguage { en, vi, ja }
extension Copy on AppLanguage {
  String get title {
    switch (this) {
      case AppLanguage.en:
        return 'Learn';
      case AppLanguage.vi:
        return 'Học';
      case AppLanguage.ja:
        return '学ぶ';
    }
  }
}
''');
    await File('${tempDir.path}/lib/features/foo.dart')
        .create(recursive: true)
        .then((file) => file.writeAsString("final label = 'Đề thi';"));
    await File('${tempDir.path}/assets/data/content/bad.json')
        .create(recursive: true)
        .then((file) => file.writeAsString('{"text":"Ã¡"}'));
    await Directory('${tempDir.path}/docs').create(recursive: true);

    final result = await runDartTool(
      [
        'tool/research/vietnamese_i18n_audit_report.dart',
        '--app-language',
        appLanguage.path,
        '--lib-root',
        '${tempDir.path}/lib',
        '--content-root',
        '${tempDir.path}/assets/data/content',
        '--docs-root',
        '${tempDir.path}/docs',
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('# Vietnamese I18n Audit'));
    expect(result.stdout as String, contains('| vi | 1 |'));
    expect(
      result.stdout as String,
      contains('| Hardcoded Vietnamese lines | 1 |'),
    );
    expect(result.stdout as String, contains('| Mojibake hits | 1 |'));
  });
}
