class ImmersionToken {
  const ImmersionToken({
    required this.surface,
    this.reading,
    this.meaningVi,
    this.meaningEn,
  });

  final String surface;
  final String? reading;
  final String? meaningVi;
  final String? meaningEn;

  bool get hasMeaning =>
      (meaningVi != null && meaningVi!.trim().isNotEmpty) ||
      (meaningEn != null && meaningEn!.trim().isNotEmpty);

  factory ImmersionToken.fromJson(Map<String, dynamic> json) {
    return ImmersionToken(
      surface: json['surface']?.toString() ?? '',
      reading: json['reading']?.toString(),
      meaningVi: json['meaningVi']?.toString(),
      meaningEn: json['meaningEn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surface': surface,
      'reading': reading,
      'meaningVi': meaningVi,
      'meaningEn': meaningEn,
    };
  }
}

class ImmersionArticle {
  const ImmersionArticle({
    required this.id,
    required this.title,
    this.titleFurigana,
    required this.officialLevel,
    this.estimatedDifficulty,
    required this.source,
    required this.publishedAt,
    required this.paragraphs,
    this.translation,
  });

  final String id;
  final String title;
  final String? titleFurigana;
  final String officialLevel;
  final String? estimatedDifficulty;
  final String source;
  final DateTime publishedAt;
  final List<List<ImmersionToken>> paragraphs;
  final String? translation;

  String get level => officialLevel;

  bool get hasEstimatedDifficulty =>
      estimatedDifficulty != null && estimatedDifficulty!.trim().isNotEmpty;

  String get effectiveDifficulty =>
      hasEstimatedDifficulty ? estimatedDifficulty! : officialLevel;

  factory ImmersionArticle.fromJson(Map<String, dynamic> json) {
    final paragraphsRaw = json['paragraphs'] as List<dynamic>? ?? const [];
    final paragraphs = paragraphsRaw
        .map(
          (p) => (p as List<dynamic>)
              .map((t) => ImmersionToken.fromJson(t as Map<String, dynamic>))
              .toList(),
        )
        .toList();
    final estimatedDifficulty = json['estimatedDifficulty']?.toString();
    return ImmersionArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleFurigana: json['titleFurigana']?.toString(),
      officialLevel:
          json['officialLevel']?.toString() ??
          json['level']?.toString() ??
          'N5',
      estimatedDifficulty:
          estimatedDifficulty == null || estimatedDifficulty.trim().isEmpty
          ? null
          : estimatedDifficulty,
      source: json['source']?.toString() ?? 'Sample',
      publishedAt:
          DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
      paragraphs: paragraphs,
      translation: json['translation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleFurigana': titleFurigana,
      'officialLevel': officialLevel,
      'estimatedDifficulty': estimatedDifficulty,
      'level': officialLevel,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'paragraphs': paragraphs
          .map((p) => p.map((t) => t.toJson()).toList())
          .toList(),
      'translation': translation,
    };
  }
}
