import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prints FSRS correctness audit from the CLI', () async {
    final result = await Process.run(Platform.isWindows ? 'dart.bat' : 'dart', [
      'run',
      'tool/research/fsrs_correctness_report.dart',
    ]);

    expect(result.stderr, isEmpty);
    expect(result.exitCode, 0);
    expect(result.stdout as String, contains('# FSRS Correctness Audit'));
    expect(result.stdout as String, contains('Blockers:'));
    expect(result.stdout as String, contains('- none'));
  });
}
