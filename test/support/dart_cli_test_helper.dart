import 'dart:convert';
import 'dart:io';

Future<ProcessResult> runDartTool(
  List<String> arguments, {
  String? workingDirectory,
  Encoding? stdoutEncoding,
  Encoding? stderrEncoding,
}) async {
  final repoRoot = workingDirectory ?? _repoRoot();
  final lockDir = Directory('$repoRoot/.dart_tool/jpstudy_test_locks');
  await lockDir.create(recursive: true);
  final lockFile = File('${lockDir.path}/dart_run_native_assets.lock');
  final lock = await lockFile.open(mode: FileMode.append);

  try {
    await lock.lock(FileLock.exclusive);
    return Process.run(
      Platform.isWindows ? 'dart.bat' : 'dart',
      ['run', ...arguments],
      workingDirectory: repoRoot,
      stdoutEncoding: stdoutEncoding ?? systemEncoding,
      stderrEncoding: stderrEncoding ?? systemEncoding,
    );
  } finally {
    await lock.unlock();
    await lock.close();
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
