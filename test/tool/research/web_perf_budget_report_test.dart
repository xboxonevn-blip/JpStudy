import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/dart_cli_test_helper.dart';

void main() {
  test(
    'reports web build budget violations from build artifacts',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'jpstudy_web_perf_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final buildRoot = Directory('${tempDir.path}/build/web');
      await File(
        '${buildRoot.path}/main.dart.js',
      ).create(recursive: true).then((file) => file.writeAsString('x' * 128));
      await File(
        '${buildRoot.path}/canvaskit/canvaskit.wasm',
      ).create(recursive: true).then((file) => file.writeAsString('w' * 64));
      await File(
        '${buildRoot.path}/sqlite3.wasm',
      ).create(recursive: true).then((file) => file.writeAsString('s' * 32));
      await File('${buildRoot.path}/assets/data/grammar/n5/lesson_1.json')
          .create(recursive: true)
          .then(
            (file) => file.writeAsString(
              '{"items":${jsonEncode(List.filled(20, "grammar"))}}',
            ),
          );

      final budget = File('${tempDir.path}/budget.json');
      await budget.writeAsString(
        jsonEncode({
          'mainDartJsRawBytes': 64,
          'totalJsonRawBytes': 32,
          'totalBuildRawBytes': 128,
        }),
      );

      final result = await runDartTool([
        'tool/research/web_perf_budget_report.dart',
        '--build-root',
        buildRoot.path,
        '--budget',
        budget.path,
        '--fail-on-violation',
      ]);

      expect(result.exitCode, 1);
      expect(result.stderr, isEmpty);
      expect(
        result.stdout as String,
        contains('# Web Performance Budget Report'),
      );
      expect(result.stdout as String, contains('main.dart.js raw'));
      expect(result.stdout as String, contains('VIOLATION'));
    },
    timeout: dartCliTestTimeout,
  );
}
