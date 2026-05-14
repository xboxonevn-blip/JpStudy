import 'dart:io';

import 'package:jpstudy/core/research/web_perf_budget.dart';

void main(List<String> args) {
  final buildRoot = Directory(
    _optionalValue(args, '--build-root') ?? 'build/web',
  );
  final budget = WebPerfBudget.fromFile(
    File(_optionalValue(args, '--budget') ?? _defaultBudgetPath),
  );
  final report = WebPerfBudgetChecker.scan(
    buildRoot: buildRoot,
    budget: budget,
  );
  stdout.writeln(report.toMarkdown());
  if (args.contains('--fail-on-violation') && report.hasViolations) {
    exitCode = 1;
  }
}

const _defaultBudgetPath = 'docs/research/D7-performance/web_perf_budget.json';

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
