import 'dart:io';

import 'package:jpstudy/core/research/vietnamese_i18n_audit.dart';

void main(List<String> args) {
  final appLanguageFile = File(
    _optionalValue(args, '--app-language') ?? 'lib/core/app_language.dart',
  );
  final libRoot = Directory(_optionalValue(args, '--lib-root') ?? 'lib');
  final contentRoot = Directory(
    _optionalValue(args, '--content-root') ?? 'assets/data/content',
  );
  final docsRoot = Directory(_optionalValue(args, '--docs-root') ?? 'docs');

  final report = VietnameseI18nAuditRunner.scan(
    appLanguageFile: appLanguageFile,
    libRoot: libRoot,
    contentRoot: contentRoot,
    docsRoot: docsRoot,
  );
  stdout.writeln(
    report.toMarkdown(
      appLanguagePath: appLanguageFile.path,
      libRootPath: libRoot.path,
      contentRootPath: contentRoot.path,
      docsRootPath: docsRoot.path,
    ),
  );
}

String? _optionalValue(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0 || index + 1 >= args.length) return null;
  return args[index + 1];
}
