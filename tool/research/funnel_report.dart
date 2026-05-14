import 'dart:convert';
import 'dart:io';

import 'package:jpstudy/core/research/north_star_eval.dart';

void main(List<String> args) {
  final events = _readInput(args);
  final windowStart = DateTime.parse(_requiredValue(args, '--window-start'));
  final windowEnd =
      _optionalDate(args, '--window-end') ??
      windowStart.add(const Duration(days: 14));
  final report = NorthStarFunnelEvaluator.evaluate(
    events,
    windowStart: windowStart,
    windowEnd: windowEnd,
  );
  stdout.writeln(report.toMarkdown());
}

List<NorthStarEvent> _readInput(List<String> args) {
  if (args.first == '--events') {
    return _readEvents(File(_requiredValue(args, '--events')));
  }
  if (args.first == '--ga4-events') {
    return _readGa4Events(File(_requiredValue(args, '--ga4-events')));
  }
  throw ArgumentError('Use --events <json> or --ga4-events <json>');
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
