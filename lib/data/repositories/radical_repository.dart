import 'package:flutter/services.dart';
import 'package:jpstudy/data/models/radical_item.dart';

class RadicalRepository {
  const RadicalRepository({AssetBundle? bundle}) : _bundle = bundle;

  static const _assetPath = 'assets/data/support/kanji/radicals_214.json';
  static const _fallbackAssetPath =
      'assets/data/support/kanji/radicals_214.source.json';

  final AssetBundle? _bundle;

  Future<List<RadicalItem>> loadAll() async {
    final bundle = _bundle ?? rootBundle;
    final raw = await _loadWithFallback(bundle, _assetPath);
    return RadicalItem.decodeList(raw);
  }

  Future<String> _loadWithFallback(
    AssetBundle bundle,
    String primaryPath,
  ) async {
    try {
      final primary = await bundle.loadString(primaryPath);
      if (primary.trim().isNotEmpty) {
        return primary;
      }
    } catch (_) {
      // Fall through to the bundled source copy below.
    }

    return bundle.loadString(_fallbackAssetPath);
  }
}
