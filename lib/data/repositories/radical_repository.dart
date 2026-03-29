import 'package:flutter/services.dart';
import 'package:jpstudy/data/models/radical_item.dart';

class RadicalRepository {
  const RadicalRepository();

  static const _assetPath = 'assets/data/support/kanji/radicals_214.json';

  Future<List<RadicalItem>> loadAll() async {
    final raw = await rootBundle.loadString(_assetPath);
    return RadicalItem.decodeList(raw);
  }
}
