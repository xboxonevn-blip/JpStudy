import 'dart:convert';
import 'dart:io';

import 'package:jpstudy/core/research/north_star_eval.dart';

const _seed = 'jpstudy-phase0-ns-v1';

void main(List<String> args) {
  final users = _readInput(args);
  final report = NorthStarEvaluator.evaluate(users);
  stdout.writeln(
    report.toMarkdown(seed: _seed, commitHash: _currentCommitHash()),
  );
}

List<NorthStarUserSnapshot> _readInput(List<String> args) {
  if (args.isEmpty) {
    return SyntheticNorthStarCohort.generate(seed: _seed);
  }
  if (args.first == '--events') {
    final events = _readEvents(File(_requiredValue(args, '--events')));
    final windowStart = DateTime.parse(_requiredValue(args, '--window-start'));
    final windowEnd =
        _optionalDate(args, '--window-end') ??
        windowStart.add(const Duration(days: 14));
    return NorthStarEventMapper.toUserSnapshots(
      events,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }
  if (args.first == '--ga4-events') {
    final events = _readGa4Events(File(_requiredValue(args, '--ga4-events')));
    final windowStart = DateTime.parse(_requiredValue(args, '--window-start'));
    final windowEnd =
        _optionalDate(args, '--window-end') ??
        windowStart.add(const Duration(days: 14));
    return NorthStarEventMapper.toUserSnapshots(
      events,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }
  if (args.first == '--simulate-users') {
    final windowStart = DateTime.parse(_requiredValue(args, '--window-start'));
    final windowEnd =
        _optionalDate(args, '--window-end') ??
        windowStart.add(const Duration(days: 14));
    final events = SyntheticNorthStarEventSimulator.generate(
      seed: _seed,
      userCount: int.parse(_requiredValue(args, '--simulate-users')),
      windowStart: windowStart,
    );
    return NorthStarEventMapper.toUserSnapshots(
      events,
      windowStart: windowStart,
      windowEnd: windowEnd,
    );
  }
  if (args.first == '--snapshots') {
    return _readUsers(File(_requiredValue(args, '--snapshots')));
  }
  return _readUsers(File(args.first));
}

List<NorthStarUserSnapshot> _readUsers(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
  return decoded
      .cast<Map<String, Object?>>()
      .map(NorthStarUserSnapshot.fromJson)
      .toList(growable: false);
}

List<NorthStarEvent> _readEvents(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
  return decoded
      .cast<Map<String, Object?>>()
      .map(NorthStarEvent.fromJson)
      .toList(growable: false);
}

List<NorthStarEvent> _readGa4Events(File file) {
  final decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
  final rows = decoded
      .cast<Map<dynamic, dynamic>>()
      .map((row) => Map<String, Object?>.from(row))
      .toList(growable: false);
  return NorthStarGa4EventMapper.toEvents(rows);
}

String _requiredValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) {
    throw ArgumentError('Missing $name');
  }
  return args[index + 1];
}

DateTime? _optionalDate(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return DateTime.parse(args[index + 1]);
}

String _currentCommitHash() {
  final result = Process.runSync('git', ['rev-parse', 'HEAD']);
  if (result.exitCode != 0) return 'unknown';
  return (result.stdout as String).trim();
}
