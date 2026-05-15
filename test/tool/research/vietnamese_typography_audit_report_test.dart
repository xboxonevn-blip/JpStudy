import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test('prints Vietnamese typography audit markdown', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_vi_typography_cli_',
    );
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
        return 'Học từ vựng';
      case AppLanguage.ja:
        return '学ぶ';
    }
  }
}
''');

    final result = await runDartTool(
      [
        'tool/research/vietnamese_typography_audit_report.dart',
        '--app-language',
        appLanguage.path,
        '--lib-root',
        '${tempDir.path}/lib',
        '--sample-size',
        '5',
        '--seed',
        '1',
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(result.stdout as String, contains('# Vietnamese Typography Audit'));
    expect(result.stdout as String, contains('| Sample size | 1 |'));
    expect(result.stdout as String, contains('| Average score | 5.00 |'));
  }, timeout: dartCliTestTimeout);
}
