class KanjiItem {
  const KanjiItem({
    required this.id,
    required this.lessonId,
    required this.character,
    required this.strokeCount,
    this.onyomi,
    this.kunyomi,
    required this.meaning,
    this.meaningEn,
    this.mnemonicVi,
    this.mnemonicEn,
    this.decomposition,
    required this.examples,
    required this.jlptLevel,
  });

  final int id;
  final int lessonId;
  final String character;
  final int strokeCount;
  final String? onyomi;
  final String? kunyomi;
  final String meaning;
  final String? meaningEn;
  final String? mnemonicVi;
  final String? mnemonicEn;
  final KanjiDecomposition? decomposition;
  final List<KanjiExample> examples;
  final String jlptLevel;
}

class KanjiDecomposition {
  const KanjiDecomposition({
    this.hanViet,
    this.structure,
    this.components = const [],
    this.componentNames = const [],
    this.relatedKanji = const [],
  });

  final String? hanViet;
  final String? structure;
  final List<String> components;
  final List<String> componentNames;
  final List<String> relatedKanji;

  bool get hasContent =>
      (hanViet?.trim().isNotEmpty ?? false) ||
      (structure?.trim().isNotEmpty ?? false) ||
      components.isNotEmpty ||
      componentNames.isNotEmpty ||
      relatedKanji.isNotEmpty;

  factory KanjiDecomposition.fromJson(Map<String, dynamic> json) {
    List<String> readStringList(String key) {
      final raw = json[key];
      if (raw is! List) {
        return const [];
      }
      return raw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    String? readOptional(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final text = raw.toString().trim();
      return text.isEmpty ? null : text;
    }

    return KanjiDecomposition(
      hanViet: readOptional('hanViet'),
      structure: readOptional('structure'),
      components: readStringList('components'),
      componentNames: readStringList('componentNames'),
      relatedKanji: readStringList('relatedKanji'),
    );
  }

  Map<String, dynamic> toJson() => {
    if (hanViet != null && hanViet!.trim().isNotEmpty) 'hanViet': hanViet,
    if (structure != null && structure!.trim().isNotEmpty)
      'structure': structure,
    if (components.isNotEmpty) 'components': components,
    if (componentNames.isNotEmpty) 'componentNames': componentNames,
    if (relatedKanji.isNotEmpty) 'relatedKanji': relatedKanji,
  };
}

class KanjiExample {
  const KanjiExample({
    this.word = '',
    this.reading = '',
    this.meaning = '',
    this.meaningEn,
    this.sourceVocabId,
    this.sourceSenseId,
  });

  final String word;
  final String reading;
  final String meaning;
  final String? meaningEn;
  final String? sourceVocabId;
  final String? sourceSenseId;

  bool get hasSourceRef =>
      (sourceSenseId?.trim().isNotEmpty ?? false) ||
      (sourceVocabId?.trim().isNotEmpty ?? false);

  KanjiExample resolvedWith({
    required String word,
    required String reading,
    required String meaning,
    String? meaningEn,
  }) {
    return KanjiExample(
      word: word,
      reading: reading,
      meaning: meaning,
      meaningEn: meaningEn,
      sourceVocabId: sourceVocabId,
      sourceSenseId: sourceSenseId,
    );
  }

  Map<String, dynamic> toJson() => {
    if (word.trim().isNotEmpty) 'word': word,
    if (reading.trim().isNotEmpty) 'reading': reading,
    if (meaning.trim().isNotEmpty) 'meaning': meaning,
    if (meaningEn != null && meaningEn!.trim().isNotEmpty)
      'meaningEn': meaningEn,
    if (sourceVocabId != null && sourceVocabId!.trim().isNotEmpty)
      'sourceVocabId': sourceVocabId,
    if (sourceSenseId != null && sourceSenseId!.trim().isNotEmpty)
      'sourceSenseId': sourceSenseId,
  };

  factory KanjiExample.fromJson(Map<String, dynamic> json) {
    String? readOptional(String key) {
      final raw = json[key];
      if (raw == null) return null;
      final value = raw.toString().trim();
      return value.isEmpty ? null : value;
    }

    return KanjiExample(
      word: readOptional('word') ?? '',
      reading: readOptional('reading') ?? '',
      meaning: readOptional('meaning') ?? '',
      meaningEn: readOptional('meaningEn'),
      sourceVocabId: readOptional('sourceVocabId'),
      sourceSenseId: readOptional('sourceSenseId'),
    );
  }
}
