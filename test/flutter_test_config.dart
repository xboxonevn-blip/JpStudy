import 'package:drift/drift.dart';

Future<void> testExecutable(Future<void> Function() testMain) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}
