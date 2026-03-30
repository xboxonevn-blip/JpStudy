class VocabReviewArgs {
  const VocabReviewArgs({
    required this.source,
    this.levelCode,
    this.series,
    this.lessonStart,
    this.lessonEnd,
    this.title,
    this.subtitle,
  });

  final String source;
  final String? levelCode;
  final String? series;
  final int? lessonStart;
  final int? lessonEnd;
  final String? title;
  final String? subtitle;

  bool get hasLessonRange => lessonStart != null && lessonEnd != null;

  Map<String, String> toQueryParameters() {
    return {
      if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
      if (subtitle != null && subtitle!.trim().isNotEmpty)
        'subtitle': subtitle!.trim(),
      if (lessonStart != null) 'lessonStart': '$lessonStart',
      if (lessonEnd != null) 'lessonEnd': '$lessonEnd',
      if (levelCode != null && levelCode!.trim().isNotEmpty)
        'level': levelCode!.trim(),
      if (series != null && series!.trim().isNotEmpty) 'series': series!.trim(),
      'source': source,
    };
  }

  factory VocabReviewArgs.fromLegacyQuery(Map<String, String> query) {
    return VocabReviewArgs(
      source: query['source'] ?? 'legacy',
      levelCode: query['level'],
      series: query['series'],
      lessonStart: int.tryParse(query['lessonStart'] ?? ''),
      lessonEnd: int.tryParse(query['lessonEnd'] ?? ''),
      title: query['title'],
      subtitle: query['subtitle'],
    );
  }
}
