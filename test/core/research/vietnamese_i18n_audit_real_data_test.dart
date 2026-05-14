import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/vietnamese_i18n_audit.dart';

void main() {
  test('runtime Dart source has no mojibake markers', () {
    final report = VietnameseI18nAuditRunner.scan(
      appLanguageFile: File('lib/core/app_language.dart'),
      libRoot: Directory('lib'),
      contentRoot: Directory('assets/data/content'),
      docsRoot: Directory('docs'),
    );

    expect(report.mojibakeHits, isEmpty);
  });

  test('audited docs and source files are UTF-8 readable', () {
    final report = VietnameseI18nAuditRunner.scan(
      appLanguageFile: File('lib/core/app_language.dart'),
      libRoot: Directory('lib'),
      contentRoot: Directory('assets/data/content'),
      docsRoot: Directory('docs'),
    );

    expect(report.decodeErrorHits, isEmpty);
  });
}
