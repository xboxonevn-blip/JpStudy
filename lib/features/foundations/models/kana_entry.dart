class KanaEntry {
  const KanaEntry({
    required this.order,
    required this.kana,
    required this.romaji,
    required this.row,
    required this.column,
    this.strokes,
    this.mark,
  });

  final int order;
  final String kana;
  final String romaji;
  final String row;
  final String column;
  final int? strokes;
  final String? mark;

  factory KanaEntry.fromJson(Map<String, dynamic> json) {
    return KanaEntry(
      order: json['order'] as int? ?? 0,
      kana: json['kana'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      row: json['row'] as String? ?? '',
      column: json['column'] as String? ?? '',
      strokes: json['strokes'] as int?,
      mark: json['mark'] as String?,
    );
  }
}

class KanaCompound {
  const KanaCompound({
    required this.order,
    required this.kana,
    required this.romaji,
    required this.row,
    required this.column,
  });

  final int order;
  final String kana;
  final String romaji;
  final String row;
  final String column;

  factory KanaCompound.fromJson(Map<String, dynamic> json) {
    return KanaCompound(
      order: json['order'] as int? ?? 0,
      kana: json['kana'] as String? ?? '',
      romaji: json['romaji'] as String? ?? '',
      row: json['row'] as String? ?? '',
      column: json['column'] as String? ?? '',
    );
  }
}

class KanaScriptChart {
  const KanaScriptChart({
    required this.label,
    required this.entries,
    required this.compounds,
  });

  final String label;
  final List<KanaEntry> entries;
  final List<KanaCompound> compounds;

  factory KanaScriptChart.fromJson(Map<String, dynamic> json) {
    final entries = json['entries'] as List<dynamic>? ?? const [];
    final compounds = json['compounds'] as List<dynamic>? ?? const [];
    return KanaScriptChart(
      label: json['label'] as String? ?? '',
      entries: entries
          .cast<Map<String, dynamic>>()
          .map(KanaEntry.fromJson)
          .toList(growable: false),
      compounds: compounds
          .cast<Map<String, dynamic>>()
          .map(KanaCompound.fromJson)
          .toList(growable: false),
    );
  }
}

class KanaChart {
  const KanaChart({required this.hiragana, required this.katakana});

  final KanaScriptChart hiragana;
  final KanaScriptChart katakana;

  int get totalCount =>
      hiragana.entries.length +
      hiragana.compounds.length +
      katakana.entries.length +
      katakana.compounds.length;

  factory KanaChart.fromJson(Map<String, dynamic> json) {
    final scripts = json['scripts'] as Map<String, dynamic>? ?? const {};
    return KanaChart(
      hiragana: KanaScriptChart.fromJson(
        scripts['hiragana'] as Map<String, dynamic>? ?? const {},
      ),
      katakana: KanaScriptChart.fromJson(
        scripts['katakana'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
