import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/vietnamese_i18n_audit.dart';

void main() {
  test(
    'counts localized app-language returns and missing Vietnamese',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'jpstudy_i18n_audit_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final appLanguage = File('${tempDir.path}/lib/core/app_language.dart');
      await appLanguage.create(recursive: true);
      await appLanguage.writeAsString('''
enum AppLanguage { en, vi, ja }

extension Copy on AppLanguage {
  String get title {
    switch (this) {
      case AppLanguage.en:
        return 'Learn';
      case AppLanguage.vi:
        return 'Học';
      case AppLanguage.ja:
        return '学ぶ';
    }
  }

  String get emptyVi {
    switch (this) {
      case AppLanguage.en:
        return 'Review';
      case AppLanguage.vi:
        return '';
      case AppLanguage.ja:
        return '復習';
    }
  }
}
''');

      final report = VietnameseI18nAuditRunner.scan(
        appLanguageFile: appLanguage,
        libRoot: Directory('${tempDir.path}/lib'),
        contentRoot: Directory('${tempDir.path}/assets/data/content'),
        docsRoot: Directory('${tempDir.path}/docs'),
      );

      expect(report.appLanguage.lineCount, greaterThan(0));
      expect(report.appLanguage.localizedReturns['en'], 2);
      expect(report.appLanguage.localizedReturns['vi'], 2);
      expect(report.appLanguage.localizedReturns['ja'], 2);
      expect(report.appLanguage.emptyLocalizedReturns, 1);
      expect(report.appLanguage.todoLocalizedReturns, 0);
    },
  );

  test('finds hardcoded Vietnamese and mojibake markers by root', () async {
    final tempDir = await Directory.systemTemp.createTemp('jpstudy_i18n_scan_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final appLanguage = File('${tempDir.path}/lib/core/app_language.dart');
    await appLanguage.create(recursive: true);
    await appLanguage.writeAsString("const appLanguageCopy = 'Tiếng Việt';\n");
    final feature = File('${tempDir.path}/lib/features/foo.dart');
    await feature.create(recursive: true);
    await feature.writeAsString("""
final label = 'Đề thi';
// ensureLesson â†’ seedTermsIfEmpty
""");
    final markerDefinition = File('${tempDir.path}/lib/features/markers.dart');
    await markerDefinition.writeAsString("const markers = ['�'];\n");
    final scannerSource = File(
      '${tempDir.path}/lib/core/research/vietnamese_i18n_audit.dart',
    );
    await scannerSource.create(recursive: true);
    await scannerSource.writeAsString("RegExp('â†');\n");
    final otherResearchSource = File(
      '${tempDir.path}/lib/core/research/vietnamese_typography_audit.dart',
    );
    await otherResearchSource.writeAsString("RegExp('Á');\n");
    final content = File('${tempDir.path}/assets/data/content/bad.json');
    await content.create(recursive: true);
    await content.writeAsString('{"text":"Ã¡"}');
    final docs = File('${tempDir.path}/docs/bad.md');
    await docs.create(recursive: true);
    await docs.writeAsString('Bad Â¡ marker');
    final invalidDocs = File('${tempDir.path}/docs/invalid.md');
    await invalidDocs.writeAsBytes([0xff]);
    final researchDocs = File(
      '${tempDir.path}/docs/research/D3-vietnamese/Q3.3-experiment.md',
    );
    await researchDocs.create(recursive: true);
    await researchDocs.writeAsString('- `â†`\n');

    final report = VietnameseI18nAuditRunner.scan(
      appLanguageFile: appLanguage,
      libRoot: Directory('${tempDir.path}/lib'),
      contentRoot: Directory('${tempDir.path}/assets/data/content'),
      docsRoot: Directory('${tempDir.path}/docs'),
    );

    expect(report.hardcodedVietnameseHits, hasLength(1));
    expect(
      report.hardcodedVietnameseHits.single.filePath,
      feature.path.replaceAll('\\', '/'),
    );
    expect(report.mojibakeHits, hasLength(3));
    expect(report.mojibakeByRoot['lib'], 1);
    expect(report.mojibakeByRoot['content'], 1);
    expect(report.mojibakeByRoot['docs'], 1);
    expect(report.decodeErrorHits, hasLength(1));
    expect(report.decodeErrorHits.single.filePath, contains('invalid.md'));
  });
}
