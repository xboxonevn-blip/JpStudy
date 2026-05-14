import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/research/kanji_unihan_spot_check.dart';

void main() {
  test(
    'checks sampled kanji Han-Viet values against Unihan kVietnamese',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'jpstudy_kanji_unihan_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final contentRoot = Directory('${tempDir.path}/content');
      await _writeKanjiFile(contentRoot, 'n3', [
        _entry(id: 'n3_k001', level: 'N3', character: '作', hanViet: 'Tác'),
        _entry(id: 'n3_k002', level: 'N3', character: '法', hanViet: 'Luật'),
      ]);
      await _writeKanjiFile(contentRoot, 'n2', [
        _entry(id: 'n2_k001', level: 'N2', character: '呼'),
      ]);
      await _writeKanjiFile(contentRoot, 'n1', [
        _entry(id: 'n1_k001', level: 'N1', character: '青', hanViet: 'Thanh'),
      ]);

      final unihanReadings = File('${tempDir.path}/Unihan_Readings.txt');
      await unihanReadings.writeAsString(
        [
          'U+4F5C\tkVietnamese\ttác',
          'U+6CD5\tkVietnamese\tpháp',
          'U+547C\tkVietnamese\thô',
        ].join('\n'),
      );

      final report = await KanjiUnihanSpotCheckRunner.run(
        contentRoot: contentRoot,
        unihanReadings: unihanReadings,
        sampleSize: 10,
        seed: 'unit-seed',
      );

      expect(report.totalCandidates, 4);
      expect(report.sampled, hasLength(4));
      expect(report.exactMatches, 1);
      expect(report.mismatches, 1);
      expect(report.missingLocalHanViet, 1);
      expect(report.missingUnihanVietnamese, 1);

      final byCharacter = {
        for (final row in report.sampled) row.character: row,
      };
      expect(byCharacter['作']!.status, KanjiUnihanSpotCheckStatus.match);
      expect(byCharacter['法']!.status, KanjiUnihanSpotCheckStatus.mismatch);
      expect(
        byCharacter['呼']!.status,
        KanjiUnihanSpotCheckStatus.missingLocalHanViet,
      );
      expect(
        byCharacter['青']!.status,
        KanjiUnihanSpotCheckStatus.missingUnihanVietnamese,
      );
    },
  );
}

Future<void> _writeKanjiFile(
  Directory contentRoot,
  String level,
  List<Map<String, Object?>> entries,
) async {
  await File('${contentRoot.path}/kanji/$level/lesson_01.json')
      .create(recursive: true)
      .then(
        (file) => file.writeAsString(
          jsonEncode({'level': level.toUpperCase(), 'entries': entries}),
        ),
      );
}

Map<String, Object?> _entry({
  required String id,
  required String level,
  required String character,
  String? hanViet,
}) {
  return {
    'kanjiId': id,
    'level': level,
    'character': character,
    if (hanViet != null) 'labels': {'hanViet': hanViet},
  };
}
