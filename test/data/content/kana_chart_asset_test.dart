import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final kanaAsset = File('assets/data/content/kana/kana_chart.json');

  Map<String, dynamic> loadKanaAsset() {
    return jsonDecode(kanaAsset.readAsStringSync()) as Map<String, dynamic>;
  }

  test('kana chart asset covers basic and compound kana from Drive scan', () {
    final asset = loadKanaAsset();

    expect(asset['schemaVersion'], 1);
    expect(asset['dataset'], 'kana');
    expect(asset['sourceScan'], isA<Map<String, dynamic>>());

    final scripts = asset['scripts'] as Map<String, dynamic>;
    expect(scripts.keys, containsAll(<String>['hiragana', 'katakana']));

    final hiragana = scripts['hiragana'] as Map<String, dynamic>;
    final katakana = scripts['katakana'] as Map<String, dynamic>;

    expect(hiragana['entries'], hasLength(71));
    expect(katakana['entries'], hasLength(71));
    expect(hiragana['compounds'], hasLength(33));
    expect(katakana['compounds'], hasLength(33));

    final hiraEntries = _indexByKana(hiragana['entries'] as List<dynamic>);
    final kataEntries = _indexByKana(katakana['entries'] as List<dynamic>);
    final hiraCompounds = _indexByKana(hiragana['compounds'] as List<dynamic>);
    final kataCompounds = _indexByKana(katakana['compounds'] as List<dynamic>);

    expect(hiraEntries['あ']?['romaji'], 'a');
    expect(hiraEntries['が']?['strokes'], 5);
    expect(hiraEntries['ぱ']?['row'], 'h');
    expect(hiraEntries['ん']?['romaji'], 'n');
    expect(hiraCompounds['きゃ']?['romaji'], 'kya');
    expect(hiraCompounds['ぴょ']?['romaji'], 'pyo');

    expect(kataEntries['ア']?['romaji'], 'a');
    expect(kataEntries['ガ']?['strokes'], 4);
    expect(kataEntries['パ']?['row'], 'h');
    expect(kataEntries['ン']?['romaji'], 'n');
    expect(kataCompounds['キャ']?['romaji'], 'kya');
    expect(kataCompounds['ピョ']?['romaji'], 'pyo');
  });

  test('kana asset is registered for Flutter runtime loading', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final index =
        jsonDecode(File('assets/data/content/index.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(pubspec, contains('assets/data/content/kana/'));
    expect(index['datasets'], contains('kana'));
  });

  test('kana asset does not depend on blocked web sources', () {
    final raw = kanaAsset.readAsStringSync();

    expect(raw, isNot(contains('thocodehoctiengnhat.com')));
    expect(raw, isNot(contains('nhaikanji.com')));
  });
}

Map<String, Map<String, dynamic>> _indexByKana(List<dynamic> entries) {
  return {
    for (final entry in entries.cast<Map<String, dynamic>>())
      entry['kana'] as String: entry,
  };
}
