import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/vietnamese_typography_audit.dart';

void main() {
  test('samples Vietnamese app-language and hardcoded Dart strings', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_vi_typography_',
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
        return 'Học từ vựng...';
      case AppLanguage.ja:
        return '学ぶ';
    }
  }
}
''');

    final feature = File('${tempDir.path}/lib/features/foo.dart');
    await feature.create(recursive: true);
    await feature.writeAsString("""
final label = 'Tạo deck mới';
final clean = 'Ôn tập';
""");

    final report = VietnameseTypographyAuditRunner.scan(
      appLanguageFile: appLanguage,
      libRoot: Directory('${tempDir.path}/lib'),
      sampleSize: 10,
      seed: 7,
    );

    expect(report.candidates, hasLength(3));
    expect(report.sample, hasLength(3));
    expect(report.issueCounts['ascii_ellipsis'], 1);
    expect(report.issueCounts['raw_english_term'], 1);
    expect(report.averageScore, closeTo(4.0, 0.01));
  });

  test('keeps fixed-seed samples deterministic', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_vi_typography_seed_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final appLanguage = File('${tempDir.path}/lib/core/app_language.dart');
    await appLanguage.create(recursive: true);
    await appLanguage.writeAsString('enum AppLanguage { en, vi, ja }\n');

    final feature = File('${tempDir.path}/lib/features/foo.dart');
    await feature.create(recursive: true);
    await feature.writeAsString(
      [
        for (var i = 0; i < 12; i++) "final label$i = 'Mục $i đã ôn';",
      ].join('\n'),
    );

    final first = VietnameseTypographyAuditRunner.scan(
      appLanguageFile: appLanguage,
      libRoot: Directory('${tempDir.path}/lib'),
      sampleSize: 5,
      seed: 42,
    );
    final second = VietnameseTypographyAuditRunner.scan(
      appLanguageFile: appLanguage,
      libRoot: Directory('${tempDir.path}/lib'),
      sampleSize: 5,
      seed: 42,
    );

    expect(
      first.sample.map((candidate) => candidate.text),
      second.sample.map((candidate) => candidate.text),
    );
    expect(first.sample, hasLength(5));
  });

  test(
    'does not treat Dart ternary interpolation as visible punctuation',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'jpstudy_vi_typography_interpolation_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final appLanguage = File('${tempDir.path}/lib/core/app_language.dart');
      await appLanguage.create(recursive: true);
      await appLanguage.writeAsString('enum AppLanguage { en, vi, ja }\n');

      final feature = File('${tempDir.path}/lib/features/foo.dart');
      await feature.create(recursive: true);
      await feature.writeAsString(
        r"final label = 'Có ${count == 1 ? count : count} mục';",
      );

      final report = VietnameseTypographyAuditRunner.scan(
        appLanguageFile: appLanguage,
        libRoot: Directory('${tempDir.path}/lib'),
        sampleSize: 10,
        seed: 3,
      );

      expect(report.candidates, hasLength(1));
      expect(
        report.issueCounts.containsKey('space_before_punctuation'),
        isFalse,
      );
      expect(report.averageScore, 5);
    },
  );
}
