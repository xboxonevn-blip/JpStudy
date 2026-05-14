import 'dart:io';

import 'package:jpstudy/core/research/vietnamese_typography_audit.dart';

void main(List<String> args) {
  final appLanguageFile = File(
    _optionalValue(args, '--app-language') ?? 'lib/core/app_language.dart',
  );
  final libRoot = Directory(_optionalValue(args, '--lib-root') ?? 'lib');
  final sampleSize =
      int.tryParse(_optionalValue(args, '--sample-size') ?? '') ?? 100;
  final seed = int.tryParse(_optionalValue(args, '--seed') ?? '') ?? 20260514;

  final report = VietnameseTypographyAuditRunner.scan(
    appLanguageFile: appLanguageFile,
    libRoot: libRoot,
    sampleSize: sampleSize,
    seed: seed,
  );
  stdout.writeln(
    report.toMarkdown(
      appLanguagePath: appLanguageFile.path,
      libRootPath: libRoot.path,
    ),
  );
}

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
