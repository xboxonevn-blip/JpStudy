import 'dart:io';

import 'package:jpstudy/core/research/kanji_coverage_audit.dart';

void main(List<String> args) async {
  final contentRoot = Directory(
    _optionalValue(args, '--content-root') ?? 'assets/data/content',
  );
  final kanjidic2Xml = File(
    _optionalValue(args, '--kanjidic2') ??
        '.codex/sources/kanjidic2/kanjidic2.xml',
  );

  final report = await KanjiCoverageAuditRunner.run(
    contentRoot: contentRoot,
    kanjidic2Xml: kanjidic2Xml,
  );
  stdout.writeln(
    report.toMarkdown(
      contentRoot: contentRoot.path,
      kanjidic2Xml: kanjidic2Xml.path,
    ),
  );
}

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
