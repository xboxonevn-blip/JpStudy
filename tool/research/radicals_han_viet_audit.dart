import 'dart:io';

import 'package:jpstudy/core/research/radicals_han_viet_audit.dart';

void main(List<String> args) async {
  final radicalsFile = File(
    _optionalValue(args, '--radicals') ??
        'assets/data/support/kanji/radicals_214.json',
  );
  final unihanReadings = File(
    _optionalValue(args, '--unihan-readings') ??
        '.codex/sources/Unihan/Unihan_Readings.txt',
  );
  final topLimit = int.tryParse(_optionalValue(args, '--top-limit') ?? '') ?? 30;
  final output = _optionalValue(args, '--output');

  final report = await RadicalsHanVietAuditRunner.run(
    radicalsFile: radicalsFile,
    unihanReadings: unihanReadings,
    topLimit: topLimit,
  );
  final markdown = report.toMarkdown(
    radicalsPath: radicalsFile.path,
    unihanReadingsPath: unihanReadings.path,
  );

  if (output == null) {
    stdout.writeln(markdown);
    return;
  }

  final outputFile = File(output);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync('$markdown\n');
  stdout.writeln('Wrote ${outputFile.path}');
}

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
