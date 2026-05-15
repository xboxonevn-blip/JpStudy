import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const dartCliTestTimeout = Timeout(Duration(minutes: 3));

Future<ProcessResult> runDartTool(
  List<String> arguments, {
  String? workingDirectory,
  Encoding? stdoutEncoding,
  Encoding? stderrEncoding,
}) async {
  final repoRoot = workingDirectory ?? _repoRoot();
  final lockDir = Directory('$repoRoot/.dart_tool/jpstudy_test_locks');
  await lockDir.create(recursive: true);
  final lockFile = File('${lockDir.path}/dart_run_native_assets_v2.lock');
  await _acquireLock(lockFile);

  try {
    return await Process.run(
      Platform.isWindows ? 'dart.bat' : 'dart',
      ['run', ...arguments],
      workingDirectory: repoRoot,
      stdoutEncoding: stdoutEncoding ?? systemEncoding,
      stderrEncoding: stderrEncoding ?? systemEncoding,
    );
  } finally {
    if (await lockFile.exists()) {
      await lockFile.delete();
    }
  }
}

Future<void> _acquireLock(File lockFile) async {
  while (true) {
    try {
      await lockFile.create(exclusive: true);
      return;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}

String _repoRoot() {
  final githubWorkspace = Platform.environment['GITHUB_WORKSPACE'];
  if (githubWorkspace != null &&
      File('$githubWorkspace/pubspec.yaml').existsSync()) {
    return githubWorkspace;
  }
  return Directory.current.path;
}
