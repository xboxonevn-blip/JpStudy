import 'dart:io';

import 'package:jpstudy/core/research/kanji_unihan_spot_check.dart';

void main(List<String> args) async {
  final contentRoot = Directory(
    _optionalValue(args, '--content-root') ?? 'assets/data/content',
  );
  final unihanReadings = File(
    _optionalValue(args, '--unihan-readings') ??
        '.codex/sources/Unihan/Unihan_Readings.txt',
  );
  final sampleSize =
      int.tryParse(_optionalValue(args, '--sample-size') ?? '') ?? 50;
  final seed = _optionalValue(args, '--seed') ?? 'jpstudy-d2-q2.6-v1';
  final levels =
      _optionalValue(args, '--levels')
          ?.split(',')
          .map((level) => level.trim())
          .where((level) => level.isNotEmpty)
          .toList() ??
      const ['N3', 'N2', 'N1'];

  final report = await KanjiUnihanSpotCheckRunner.run(
    contentRoot: contentRoot,
    unihanReadings: unihanReadings,
    sampleSize: sampleSize,
    seed: seed,
    levels: levels,
  );
  stdout.writeln(
    report.toMarkdown(
      contentRoot: contentRoot.path,
      unihanReadings: unihanReadings.path,
    ),
  );
}

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
