class HanVietRule {
  const HanVietRule({
    required this.id,
    required this.title,
    required this.pattern,
    required this.examples,
    this.explanation,
    this.sourceIds,
  });

  final String id;
  final String title;
  final String pattern;
  final String? explanation;
  final List<HanVietExample> examples;
  final List<String>? sourceIds;

  factory HanVietRule.fromJson(Map<String, dynamic> json) {
    final examples = json['examples'] as List<dynamic>? ?? const [];
    final sourceIds = json['sourceIds'] as List<dynamic>?;
    return HanVietRule(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? _titleFromJson(json),
      pattern: json['pattern'] as String? ?? '',
      explanation: json['explanation'] as String? ?? json['noteVi'] as String?,
      examples: examples
          .cast<Map<String, dynamic>>()
          .map(HanVietExample.fromJson)
          .toList(growable: false),
      sourceIds: sourceIds?.map((value) => value.toString()).toList(),
    );
  }

  static String _titleFromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String? ?? '').trim();
    final onHints = json['onHint'] as List<dynamic>? ?? const [];
    final hint = onHints.map((value) => value.toString()).join('/');
    if (id.isEmpty) {
      return hint.isEmpty ? 'Han-Viet rule' : 'Han-Viet -> $hint';
    }
    final compact = id
        .replaceAll('initial-', 'Initial ')
        .replaceAll('final-', 'Final ')
        .replaceAll('rime-', 'Rime ')
        .replaceAll('long-vowel-', 'Long vowel ')
        .replaceAll('usage-', 'Usage ')
        .replaceAll('exception-', 'Exception ')
        .replaceAll('-', ' -> ');
    return hint.isEmpty ? compact : '$compact ($hint)';
  }
}

class HanVietExample {
  const HanVietExample({
    required this.kanji,
    required this.onyomi,
    required this.hanViet,
    this.meaning,
  });

  final String kanji;
  final String onyomi;
  final String hanViet;
  final String? meaning;

  factory HanVietExample.fromJson(Map<String, dynamic> json) {
    return HanVietExample(
      kanji: json['kanji'] as String? ?? '',
      onyomi:
          json['onyomi'] as String? ??
          json['kana'] as String? ??
          json['romaji'] as String? ??
          '',
      hanViet: json['hanViet'] as String? ?? '',
      meaning: json['meaning'] as String? ?? json['romaji'] as String?,
    );
  }
}

class HanVietSource {
  const HanVietSource({required this.id, required this.title, this.domain});

  final String id;
  final String title;
  final String? domain;

  factory HanVietSource.fromJson(Map<String, dynamic> json) {
    return HanVietSource(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      domain: json['domain'] as String?,
    );
  }
}

class HanVietRuleSet {
  const HanVietRuleSet({required this.rules, required this.sources});

  final List<HanVietRule> rules;
  final List<HanVietSource> sources;

  Map<String, HanVietSource> get sourcesById => {
    for (final source in sources) source.id: source,
  };

  factory HanVietRuleSet.fromJson(Map<String, dynamic> json) {
    final rules = json['rules'] as List<dynamic>? ?? const [];
    final sources = json['sources'] as List<dynamic>? ?? const [];
    return HanVietRuleSet(
      rules: rules
          .cast<Map<String, dynamic>>()
          .map(HanVietRule.fromJson)
          .toList(growable: false),
      sources: sources
          .cast<Map<String, dynamic>>()
          .map(HanVietSource.fromJson)
          .toList(growable: false),
    );
  }
}
