import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'dart_cli_test_helper.dart';

void main() {
  test('serializes dart run processes until the child process exits', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_cli_lock_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final activeFile = File('${tempDir.path}/active.lock');
    final probe = File('${tempDir.path}/lock_probe.dart');
    await probe.writeAsString('''
import 'dart:io';

Future<void> main(List<String> args) async {
  final activeFile = File(args.single);
  try {
    await activeFile.create(exclusive: true);
  } on FileSystemException {
    stderr.writeln('overlap detected');
    exitCode = 7;
    return;
  }

  await Future<void>.delayed(const Duration(milliseconds: 800));
  await activeFile.delete();
  stdout.writeln('done');
}
''');

    final results = await Future.wait([
      runDartTool([probe.path, activeFile.path]),
      runDartTool([probe.path, activeFile.path]),
    ]);

    for (final result in results) {
      expect(result.stderr, isEmpty);
      expect(result.exitCode, 0);
      expect(result.stdout as String, contains('done'));
    }
  }, timeout: dartCliTestTimeout);

}
