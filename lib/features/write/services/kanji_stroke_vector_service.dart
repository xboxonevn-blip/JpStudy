import 'dart:convert';

import 'package:flutter/services.dart';

class KanjiStrokeVectorService {
  KanjiStrokeVectorService._();

  static final KanjiStrokeVectorService instance = KanjiStrokeVectorService._();

  static const _assetPath = 'assets/data/support/kanji/kanjivg_stroke_paths_n5n4.json';

  static Map<String, KanjiStrokeVector>? debugVectorOverrides;

  Map<String, KanjiStrokeVector>? _vectors;

  static void setDebugVectorOverrides(Map<String, KanjiStrokeVector>? vectors) {
    debugVectorOverrides = vectors;
    instance._vectors = vectors;
  }

  Future<KanjiStrokeVector?> getVector(String character) async {
    await _ensureLoaded();
    return _vectors?[character];
  }

  Future<Map<String, KanjiStrokeVector>> getAllVectors() async {
    await _ensureLoaded();
    return _vectors ?? const {};
  }

  Future<void> _ensureLoaded() async {
    if (_vectors != null) return;
    if (debugVectorOverrides != null) {
      _vectors = debugVectorOverrides;
      return;
    }

    String raw;
    try {
      raw = (await rootBundle.loadString(
        _assetPath,
      )).replaceFirst('\uFEFF', '');
    } on Object {
      _vectors = const {};
      return;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final entries = decoded['entries'] as Map<String, dynamic>? ?? const {};

    final vectors = <String, KanjiStrokeVector>{};
    entries.forEach((character, value) {
      final payload = value as Map<String, dynamic>;
      vectors[character] = KanjiStrokeVector.fromJson(
        character: character,
        json: payload,
      );
    });
    _vectors = vectors;
  }
}

class KanjiStrokeVector {
  const KanjiStrokeVector({
    required this.character,
    required this.strokes,
    required this.viewBox,
    this.radicalStrokeIndexes = const <int>{},
    this.numberPositions = const [],
  });

  final String character;
  final List<String> strokes;
  final List<double> viewBox;
  final Set<int> radicalStrokeIndexes;
  final List<List<double>?> numberPositions;

  double get minX => viewBox[0];
  double get minY => viewBox[1];
  double get width => viewBox[2];
  double get height => viewBox[3];
  bool get hasRadicalData => radicalStrokeIndexes.isNotEmpty;

  factory KanjiStrokeVector.fromJson({
    required String character,
    required Map<String, dynamic> json,
  }) {
    final viewBox =
        (json['viewBox'] as List<dynamic>? ?? const [0, 0, 109, 109])
            .map((e) => (e as num).toDouble())
            .toList();
    while (viewBox.length < 4) {
      viewBox.add(0);
    }

    final radicalStrokeIndexes =
        (json['radicalStrokeIndexes'] as List<dynamic>? ?? const [])
            .map((e) => (e as num).toInt())
            .where((index) => index >= 0)
            .toSet();
    final numberPositions =
        (json['numberPositions'] as List<dynamic>? ?? const [])
            .map<List<double>?>((entry) {
              if (entry == null) return null;
              final values = (entry as List<dynamic>)
                  .map((e) => (e as num).toDouble())
                  .toList(growable: false);
              if (values.length < 2) return null;
              return [values[0], values[1]];
            })
            .toList(growable: false);

    return KanjiStrokeVector(
      character: character,
      strokes: (json['strokes'] as List<dynamic>? ?? const [])
          .map((e) => (e as String).trim())
          .where((d) => d.isNotEmpty)
          .toList(growable: false),
      viewBox: viewBox.take(4).toList(growable: false),
      radicalStrokeIndexes: radicalStrokeIndexes,
      numberPositions: numberPositions,
    );
  }
}
