import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/radicals_han_viet_audit.dart';

void main() {
  test('audits Kangxi radical Han-Viet display against Unihan', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'jpstudy_radicals_audit_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final radicals = File('${tempDir.path}/radicals_214.json');
    await radicals.writeAsString(
      jsonEncode([
        _radical(1, '一', 'Nhất', 'nhat'),
        _radical(2, '丶', 'Chủ · điểm', 'chu (diem)'),
        _radical(3, '乙', 'Ất · cán ất', 'at (can at)'),
        _radical(4, '木', 'Móc · gỗ', 'moc (go)'),
        _radical(5, '☃', 'Tuyết · snow', 'tuyet (snow)'),
      ]),
    );

    final unihanReadings = File('${tempDir.path}/Unihan_Readings.txt');
    await unihanReadings.writeAsString(
      [
        'U+4E00\tkVietnamese\tnhất',
        'U+4E36\tkVietnamese\tchủ',
        'U+4E59\tkVietnamese\tất',
        'U+6728\tkVietnamese\tmộc',
      ].join('\n'),
    );

    final report = await RadicalsHanVietAuditRunner.run(
      radicalsFile: radicals,
      unihanReadings: unihanReadings,
      topLimit: 10,
    );

    expect(report.totalChecked, 5);
    expect(report.exactMatches, 1);
    expect(report.nearMatches, 2);
    expect(report.mismatches, 1);
    expect(report.missing, 1);
    expect(report.patterns['duplicate-gloss'], 1);

    final byId = {for (final row in report.rows) row.id: row};
    expect(byId[2]!.status, RadicalAuditStatus.nearMatch);
    expect(byId[3]!.patterns, contains('duplicate-gloss'));
    expect(byId[4]!.status, RadicalAuditStatus.mismatch);
    expect(byId[5]!.status, RadicalAuditStatus.missing);
    expect(report.topCorrections.first.id, 4);

    final markdown = report.toMarkdown(
      radicalsPath: radicals.path,
      unihanReadingsPath: unihanReadings.path,
    );
    expect(markdown, contains('# D2.Q2.7 Radicals Han-Viet Audit'));
    expect(markdown, contains('| Total checked | 5 |'));
    expect(markdown, contains('| 4 | 木 | Móc · gỗ | mộc | mismatch |'));
  });
}

Map<String, Object?> _radical(
  int id,
  String kanji,
  String viMeaning,
  String raw,
) {
  return {
    'id': id,
    'kanji': kanji,
    'strokes': 1,
    'vi_meaning': viMeaning,
    'vi_meaning_raw': raw,
  };
}
