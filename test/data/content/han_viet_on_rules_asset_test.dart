import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final rulesAsset =
      File('assets/data/content/kanji/han_viet_on_rules.json');

  Map<String, dynamic> loadRulesAsset() {
    return jsonDecode(rulesAsset.readAsStringSync()) as Map<String, dynamic>;
  }

  test('han viet to on-yomi rules asset has sourced heuristic rules', () {
    final asset = loadRulesAsset();

    expect(asset['schemaVersion'], 1);
    expect(asset['dataset'], 'han_viet_on_rules');
    expect(asset['scope'], contains('heuristic'));

    final sources = asset['sources'] as List<dynamic>;
    expect(sources, hasLength(greaterThanOrEqualTo(5)));
    expect(
      sources.map((source) => source['domain']),
      containsAll(<String>[
        'saromalang.com',
        'tiengnhatmoingay.com',
        'tailieuhoctiengnhat.com',
        'kosei.vn',
        'tuhoctiengnhat.vn',
      ]),
    );

    final rules = asset['rules'] as List<dynamic>;
    expect(rules, hasLength(greaterThanOrEqualTo(24)));
    expect(
      rules.map((rule) => rule['category']),
      containsAll(<String>[
        'usage',
        'initial',
        'rime',
        'final',
        'long_vowel',
        'exception',
      ]),
    );

    for (final rule in rules.cast<Map<String, dynamic>>()) {
      expect(rule['id'], isA<String>());
      expect(rule['pattern'], isA<String>());
      expect(rule['onHint'], isA<List<dynamic>>());
      expect(rule['confidence'], isA<num>());
      expect(rule['sourceIds'], isA<List<dynamic>>());
      expect(rule['examples'], isA<List<dynamic>>());
    }
  });

  test('han viet to on-yomi rules cover common learner mappings', () {
    final asset = loadRulesAsset();
    final rules = (asset['rules'] as List<dynamic>).cast<Map<String, dynamic>>();

    Map<String, dynamic> byId(String id) =>
        rules.singleWhere((rule) => rule['id'] == id);

    expect(byId('initial-l-to-r')['examples'], isNotEmpty);
    expect(byId('initial-c-k-kh-gi-h-qu-to-k')['onHint'], contains('k'));
    expect(byId('initial-b-ph-to-h-f')['onHint'], contains('h'));
    expect(byId('final-n-m-to-n')['onHint'], contains('n'));
    expect(byId('final-t-to-tsu-chi')['onHint'], contains('tsu'));
    expect(byId('final-p-to-long-or-tsu')['examples'], isNotEmpty);
    expect(byId('rime-inh-anh-enh-to-ei')['onHint'], contains('ei'));
    expect(byId('usage-kanji-compounds-often-use-on')['examples'], isNotEmpty);
  });

  test('han viet to on-yomi rules are registered and avoid blocked sources', () {
    final raw = rulesAsset.readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final index =
        jsonDecode(File('assets/data/content/index.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(pubspec, contains('assets/data/content/kanji/'));
    expect(index['datasets'], contains('hanVietOnRules'));
    expect(raw, isNot(contains('thocodehoctiengnhat.com')));
    expect(raw, isNot(contains('nhaikanji.com')));
  });
}
