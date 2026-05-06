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

class ComprehensionQuestion {
  const ComprehensionQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.questionVi,
    this.optionsVi,
    this.explanationVi,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String? questionVi;
  final List<String>? optionsVi;
  final String? explanationVi;

  factory ComprehensionQuestion.fromJson(Map<String, dynamic> json) {
    return ComprehensionQuestion(
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      correctIndex: json['correctIndex'] as int? ?? 0,
      questionVi: json['questionVi']?.toString(),
      optionsVi: (json['optionsVi'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      explanationVi: json['explanationVi']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'questionVi': questionVi,
      'options': options,
      'optionsVi': optionsVi,
      'correctIndex': correctIndex,
      'explanationVi': explanationVi,
    };
  }
}

class ImmersionArticle {
  static const localSourceLabel = 'JpStudy Original';
  static const _fallbackLevel = 'N5';

  static final _jlptLevelExactRe = RegExp(r'^N[1-5]$');
  static final _nonAlphanumRe = RegExp(r'[^A-Z0-9]');
  static final _jlptLevelCompactRe = RegExp(r'N([1-5])');
  static final _digitOnlyLevelRe = RegExp(r'^([1-5])$');

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
    this.comprehensionQuestions = const [],
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
  final List<ComprehensionQuestion> comprehensionQuestions;

  String get level => officialLevel;

  bool get hasEstimatedDifficulty =>
      estimatedDifficulty != null && estimatedDifficulty!.trim().isNotEmpty;

  String get effectiveDifficulty =>
      hasEstimatedDifficulty ? estimatedDifficulty! : officialLevel;

  factory ImmersionArticle.fromJson(
    Map<String, dynamic> json, {
    String? expectedLevel,
    String? fallbackSource,
  }) {
    final paragraphsRaw = json['paragraphs'] as List<dynamic>? ?? const [];
    final paragraphs = paragraphsRaw
        .map(
          (p) => (p as List<dynamic>)
              .map((t) => ImmersionToken.fromJson(t as Map<String, dynamic>))
              .toList(),
        )
        .toList();
    final estimatedDifficulty = normalizeDifficultyLabel(
      json['estimatedDifficulty']?.toString(),
    );
    return ImmersionArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleFurigana: _cleanOptionalText(json['titleFurigana']?.toString()),
      officialLevel: normalizeOfficialLevel(
        expectedLevel ??
            json['officialLevel']?.toString() ??
            json['level']?.toString(),
      ),
      estimatedDifficulty: estimatedDifficulty,
      source: normalizeSourceLabel(
        json['source']?.toString(),
        fallback: fallbackSource ?? localSourceLabel,
      ),
      publishedAt:
          DateTime.tryParse(json['publishedAt']?.toString() ?? '') ??
          DateTime.now(),
      paragraphs: paragraphs,
      translation: _cleanOptionalText(json['translation']?.toString()),
      comprehensionQuestions:
          (json['comprehensionQuestions'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(ComprehensionQuestion.fromJson)
              .toList(),
    );
  }

  ImmersionArticle copyWith({
    String? id,
    String? title,
    String? titleFurigana,
    String? officialLevel,
    String? estimatedDifficulty,
    String? source,
    DateTime? publishedAt,
    List<List<ImmersionToken>>? paragraphs,
    String? translation,
    List<ComprehensionQuestion>? comprehensionQuestions,
  }) {
    return ImmersionArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      titleFurigana: _cleanOptionalText(titleFurigana ?? this.titleFurigana),
      officialLevel: normalizeOfficialLevel(
        officialLevel ?? this.officialLevel,
      ),
      estimatedDifficulty: normalizeDifficultyLabel(
        estimatedDifficulty ?? this.estimatedDifficulty,
      ),
      source: normalizeSourceLabel(source ?? this.source),
      publishedAt: publishedAt ?? this.publishedAt,
      paragraphs: paragraphs ?? this.paragraphs,
      translation: _cleanOptionalText(translation ?? this.translation),
      comprehensionQuestions:
          comprehensionQuestions ?? this.comprehensionQuestions,
    );
  }

  static String normalizeOfficialLevel(
    String? raw, {
    String fallback = _fallbackLevel,
  }) {
    final normalized = _cleanOptionalText(raw)?.toUpperCase();
    if (normalized == null) {
      return fallback;
    }

    if (_jlptLevelExactRe.hasMatch(normalized)) {
      return normalized;
    }

    final compact = normalized.replaceAll(_nonAlphanumRe, '');
    final compactMatch = _jlptLevelCompactRe.firstMatch(compact);
    if (compactMatch != null) {
      return 'N${compactMatch.group(1)}';
    }

    final digitOnlyMatch = _digitOnlyLevelRe.firstMatch(compact);
    if (digitOnlyMatch != null) {
      return 'N${digitOnlyMatch.group(1)}';
    }

    return fallback;
  }

  static String? normalizeDifficultyLabel(String? raw) {
    final normalized = _cleanOptionalText(raw);
    if (normalized == null) {
      return null;
    }
    return normalizeOfficialLevel(normalized, fallback: normalized);
  }

  static String normalizeSourceLabel(
    String? raw, {
    String fallback = localSourceLabel,
  }) {
    final normalized = _cleanOptionalText(raw);
    if (normalized == null) {
      return fallback;
    }

    final lower = normalized.toLowerCase();
    if (lower == 'sample' ||
        lower == 'local' ||
        lower == 'local sample' ||
        lower == 'jpstudy' ||
        lower == 'jpstudy original') {
      return localSourceLabel;
    }

    return normalized;
  }

  static String? _cleanOptionalText(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
      'comprehensionQuestions': comprehensionQuestions
          .map((q) => q.toJson())
          .toList(),
    };
  }
}
