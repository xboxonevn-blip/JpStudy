import 'dart:convert';
import 'dart:io';

import 'package:jpstudy/core/research/north_star_eval.dart';

const _seed = 'jpstudy-phase0-ns-v1';

void main(List<String> args) {
  final users = args.isEmpty
      ? SyntheticNorthStarCohort.generate(seed: _seed)
      : _readUsers(File(args.first));
  final report = NorthStarEvaluator.evaluate(users);
  stdout.writeln(
    report.toMarkdown(seed: _seed, commitHash: _currentCommitHash()),
  );
}

List<NorthStarUserSnapshot> _readUsers(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
  return decoded
      .cast<Map<String, Object?>>()
      .map(NorthStarUserSnapshot.fromJson)
      .toList(growable: false);
}

String _currentCommitHash() {
  final result = Process.runSync('git', ['rev-parse', 'HEAD']);
  if (result.exitCode != 0) return 'unknown';
  return (result.stdout as String).trim();
}
