import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/repositories/radical_repository.dart';

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) {
      throw Exception('Unable to load asset: "$key".');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final value = _assets[key];
    if (value == null) {
      throw Exception('Unable to load asset: "$key".');
    }
    final bytes = utf8.encode(value);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

void main() {
  test('falls back to source radicals asset when primary asset is missing', () async {
    final bundle = _FakeAssetBundle({
      'assets/data/support/kanji/radicals_214.source.json':
          '[{"id":1,"kanji":"一","strokes":1,"vi_meaning":"nhat","vi_meaning_raw":"nhat"}]',
    });

    final repo = RadicalRepository(bundle: bundle);
    final items = await repo.loadAll();

    expect(items, isNotEmpty);
    expect(items.first.id, 1);
    expect(items.first.kanji, '一');
  });

  test('falls back to source radicals asset when primary asset is empty', () async {
    final bundle = _FakeAssetBundle({
      'assets/data/support/kanji/radicals_214.json': '   ',
      'assets/data/support/kanji/radicals_214.source.json':
          '[{"id":2,"kanji":"丨","strokes":1,"vi_meaning":"so","vi_meaning_raw":"so"}]',
    });

    final repo = RadicalRepository(bundle: bundle);
    final items = await repo.loadAll();

    expect(items, isNotEmpty);
    expect(items.first.id, 2);
    expect(items.first.kanji, '丨');
  });
}
