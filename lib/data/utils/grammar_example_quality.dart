enum GrammarExampleLocale { en, vi, ja }

enum GrammarExampleQuestionKind {
  sentenceBuilder,
  cloze,
  contextChoice,
  errorCorrection,
  errorReason,
  transformation,
}

enum GrammarExampleSurfaceFamily { statement, question, dialogue }

class GrammarExampleSeedData {
  const GrammarExampleSeedData({
    required this.sentence,
    required this.translation,
    this.translationEn,
    this.translationVi,
  });

  final String sentence;
  final String translation;
  final String? translationEn;
  final String? translationVi;
}

class GrammarExampleQualityAssessment {
  const GrammarExampleQualityAssessment({
    required this.index,
    required this.example,
    required this.surfaceFamily,
    required this.localizedPrompt,
    required this.hasUsablePrompt,
    required this.overallScore,
    required this.questionScores,
    required this.notes,
  });

  final int index;
  final GrammarExampleSeedData example;
  final GrammarExampleSurfaceFamily surfaceFamily;
  final String localizedPrompt;
  final bool hasUsablePrompt;
  final int overallScore;
  final Map<GrammarExampleQuestionKind, int> questionScores;
  final List<String> notes;

  bool supports(GrammarExampleQuestionKind kind) => scoreFor(kind) > 0;

  int scoreFor(GrammarExampleQuestionKind kind) => questionScores[kind] ?? 0;

  List<String> supportedKinds() => questionScores.entries
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key.name)
      .toList(growable: false);
}

class GrammarExampleBlockQualityAssessment {
  const GrammarExampleBlockQualityAssessment({
    required this.grammarPoint,
    required this.locale,
    required this.blockScore,
    required this.examples,
    required this.coverageCounts,
  });

  final String grammarPoint;
  final GrammarExampleLocale locale;
  final int blockScore;
  final List<GrammarExampleQualityAssessment> examples;
  final Map<GrammarExampleQuestionKind, int> coverageCounts;

  GrammarExampleQualityAssessment? get bestOverall {
    if (examples.isEmpty) return null;
    final sorted = [...examples]
      ..sort((a, b) {
        final byScore = b.overallScore.compareTo(a.overallScore);
        if (byScore != 0) return byScore;
        return a.index.compareTo(b.index);
      });
    return sorted.first;
  }

  List<GrammarExampleQualityAssessment> prioritizedFor(
    GrammarExampleQuestionKind kind, {
    int? limit,
  }) {
    final sorted = examples.where((item) => item.supports(kind)).toList()
      ..sort((a, b) {
        final byQuestion = b.scoreFor(kind).compareTo(a.scoreFor(kind));
        if (byQuestion != 0) return byQuestion;
        final byOverall = b.overallScore.compareTo(a.overallScore);
        if (byOverall != 0) return byOverall;
        return a.index.compareTo(b.index);
      });
    if (limit == null || sorted.length <= limit) {
      return sorted;
    }
    return sorted.take(limit).toList(growable: false);
  }
}

class GrammarExampleQualityAssessor {
  // RegExp objects compiled once per class load, not per call.
  static final _whitespaceRe = RegExp(r'\s+');
  static final _unusablePatternCharsRe = RegExp(r'[~～〜〇○◯□△◇_＿/／]');
  static final _promptNormRe = RegExp(r'[\s\u3000。！？?!….,，．]');
  static final _placeholderRe = RegExp(
    r'(^|[^A-Za-z])(N\d*|V\d*|A\d*|S\d*)(?=$|[^A-Za-z])',
  );

  // Rune code set for _lastNonPunctuationChar — replaces per-character RegExp.
  static const Set<int> _terminalPunctAndSpaceRunes = {
    0x20,   // space
    0x09,   // tab
    0x0A,   // LF
    0x0D,   // CR
    0x3000, // 　 ideographic space
    0x3002, // 。
    0xFF01, // ！
    0xFF1F, // ？
    0x21,   // !
    0x3F,   // ?
  };

  static GrammarExampleBlockQualityAssessment assessBlock({
    required String grammarPoint,
    required List<GrammarExampleSeedData> examples,
    required GrammarExampleLocale locale,
  }) {
    final normalizedPattern = grammarPoint.trim();
    final assessments = <GrammarExampleQualityAssessment>[];

    for (var index = 0; index < examples.length; index++) {
      final example = examples[index];
      final sentence = example.sentence.trim();
      final prompt = localizedPrompt(example, locale).trim();
      final usablePrompt = hasUsableContextPrompt(prompt, sentence);
      final surfaceFamily = surfaceFamilyForSentence(sentence);
      final notes = <String>[];

      if (sentence.isEmpty) {
        notes.add('empty_sentence');
      }
      if (prompt.isEmpty) {
        notes.add('missing_${locale.name}_prompt');
      } else if (!usablePrompt) {
        notes.add('prompt_falls_back_to_source');
      }
      if (surfaceFamily == GrammarExampleSurfaceFamily.dialogue) {
        notes.add('dialogue_example');
      } else if (surfaceFamily == GrammarExampleSurfaceFamily.question) {
        notes.add('question_sentence');
      }

      final questionScores = <GrammarExampleQuestionKind, int>{
        GrammarExampleQuestionKind.sentenceBuilder: _sentenceBuilderScore(
          sentence: sentence,
          surfaceFamily: surfaceFamily,
        ),
        GrammarExampleQuestionKind.cloze: _clozeScore(
          sentence: sentence,
          grammarPoint: normalizedPattern,
          surfaceFamily: surfaceFamily,
        ),
        GrammarExampleQuestionKind.contextChoice: _contextChoiceScore(
          sentence: sentence,
          prompt: prompt,
          usablePrompt: usablePrompt,
          surfaceFamily: surfaceFamily,
        ),
        GrammarExampleQuestionKind.errorCorrection: _replacementScore(
          sentence: sentence,
          grammarPoint: normalizedPattern,
          surfaceFamily: surfaceFamily,
        ),
        GrammarExampleQuestionKind.errorReason: _replacementScore(
          sentence: sentence,
          grammarPoint: normalizedPattern,
          surfaceFamily: surfaceFamily,
        ),
        GrammarExampleQuestionKind.transformation: _transformationScore(
          sentence: sentence,
          prompt: prompt,
          surfaceFamily: surfaceFamily,
        ),
      };

      final overallScore = _overallScore(
        sentence: sentence,
        prompt: prompt,
        usablePrompt: usablePrompt,
        surfaceFamily: surfaceFamily,
        questionScores: questionScores,
      );

      assessments.add(
        GrammarExampleQualityAssessment(
          index: index,
          example: example,
          surfaceFamily: surfaceFamily,
          localizedPrompt: prompt,
          hasUsablePrompt: usablePrompt,
          overallScore: overallScore,
          questionScores: questionScores,
          notes: notes,
        ),
      );
    }

    final coverageCounts = <GrammarExampleQuestionKind, int>{
      for (final kind in GrammarExampleQuestionKind.values)
        kind: assessments.where((item) => item.supports(kind)).length,
    };

    final blockScore = _blockScore(
      exampleCount: examples.length,
      assessments: assessments,
      coverageCounts: coverageCounts,
    );

    return GrammarExampleBlockQualityAssessment(
      grammarPoint: normalizedPattern,
      locale: locale,
      blockScore: blockScore,
      examples: assessments,
      coverageCounts: coverageCounts,
    );
  }

  static String localizedPrompt(
    GrammarExampleSeedData example,
    GrammarExampleLocale locale,
  ) {
    switch (locale) {
      case GrammarExampleLocale.en:
        return (example.translationEn ?? example.translation).trim();
      case GrammarExampleLocale.vi:
        return (example.translationVi ?? example.translation).trim();
      case GrammarExampleLocale.ja:
        return example.translation.trim();
    }
  }

  static GrammarExampleSurfaceFamily surfaceFamilyForSentence(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.contains('…')) {
      return GrammarExampleSurfaceFamily.dialogue;
    }
    if (looksLikeQuestionSentence(trimmed)) {
      return GrammarExampleSurfaceFamily.question;
    }
    return GrammarExampleSurfaceFamily.statement;
  }

  static bool hasUsableContextPrompt(String prompt, String sentence) {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return false;
    return _normalizePromptCompare(trimmedPrompt) !=
        _normalizePromptCompare(sentence);
  }

  static bool looksLikeQuestionSentence(String value) {
    final trimmed = _leadingSentenceClause(value).trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('？') || trimmed.contains('?')) return true;
    final noPeriod = trimmed.endsWith('。')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    return noPeriod.endsWith('ですか') ||
        noPeriod.endsWith('ますか') ||
        noPeriod.endsWith('か');
  }

  static bool looksLikeExchangePrompt(String value) {
    final trimmed = value.trim();
    return _looksLikeStandaloneSentence(trimmed) &&
        (trimmed.contains('ですか') ||
            trimmed.endsWith('か') ||
            trimmed.contains('どちら') ||
            trimmed.contains('どこ') ||
            trimmed.contains('何'));
  }

  static bool isEmbeddableSurfacePattern(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (_placeholderCount(trimmed) > 0) return false;
    return !_unusablePatternCharsRe.hasMatch(trimmed);
  }

  static bool supportsTransformation(String sentence) {
    return transformToNegative(sentence) != null;
  }

  static String? transformToNegative(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) return null;
    if (surfaceFamilyForSentence(trimmed) !=
        GrammarExampleSurfaceFamily.statement) {
      return null;
    }

    final punctuation = _terminalPunctuation(trimmed);
    final core = punctuation == null
        ? trimmed
        : trimmed.substring(0, trimmed.length - punctuation.length);
    if (core.isEmpty || _isRequestLikeCore(core) || _isAlreadyNegativeCore(core)) {
      return null;
    }

    final transformed = _transformCoreToNegative(core);
    if (transformed == null || transformed == core) {
      return null;
    }
    return punctuation == null ? transformed : '$transformed$punctuation';
  }

  static bool isAlreadyNegativeStatement(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) return false;
    final punctuation = _terminalPunctuation(trimmed);
    final core = punctuation == null
        ? trimmed
        : trimmed.substring(0, trimmed.length - punctuation.length);
    return _isAlreadyNegativeCore(core);
  }

  static int _sentenceBuilderScore({
    required String sentence,
    required GrammarExampleSurfaceFamily surfaceFamily,
  }) {
    if (sentence.isEmpty) return 0;
    var score = 50;
    score += _lengthScore(sentence, shortPenalty: -6);

    switch (surfaceFamily) {
      case GrammarExampleSurfaceFamily.statement:
        score += 12;
      case GrammarExampleSurfaceFamily.question:
        score += 8;
      case GrammarExampleSurfaceFamily.dialogue:
        score += 2;
    }

    if (_tokenLikeChunkCount(sentence) >= 2) {
      score += 6;
    }
    return score.clamp(0, 100);
  }

  static int _clozeScore({
    required String sentence,
    required String grammarPoint,
    required GrammarExampleSurfaceFamily surfaceFamily,
  }) {
    if (sentence.isEmpty || grammarPoint.isEmpty) return 0;
    if (!sentence.contains(grammarPoint)) return 0;
    if (looksLikeExchangePrompt(grammarPoint) &&
        sentence.trim().startsWith(grammarPoint)) {
      return 0;
    }

    final blanked = sentence.replaceFirst(grammarPoint, '{blank}');
    if (blanked == sentence || blanked.trim() == '{blank}') return 0;

    var score = 58;
    score += _lengthScore(sentence, shortPenalty: -8);
    switch (surfaceFamily) {
      case GrammarExampleSurfaceFamily.statement:
        score += 12;
      case GrammarExampleSurfaceFamily.question:
        score += 8;
      case GrammarExampleSurfaceFamily.dialogue:
        score -= 4;
    }
    return score.clamp(0, 100);
  }

  static int _contextChoiceScore({
    required String sentence,
    required String prompt,
    required bool usablePrompt,
    required GrammarExampleSurfaceFamily surfaceFamily,
  }) {
    if (sentence.isEmpty || prompt.isEmpty || !usablePrompt) return 0;
    if (surfaceFamily == GrammarExampleSurfaceFamily.dialogue) return 0;

    var score = 62;
    score += _lengthScore(prompt, shortPenalty: -10);
    switch (surfaceFamily) {
      case GrammarExampleSurfaceFamily.statement:
        score += 14;
      case GrammarExampleSurfaceFamily.question:
        score += 10;
      case GrammarExampleSurfaceFamily.dialogue:
        score += 0;
    }
    return score.clamp(0, 100);
  }

  static int _replacementScore({
    required String sentence,
    required String grammarPoint,
    required GrammarExampleSurfaceFamily surfaceFamily,
  }) {
    if (sentence.isEmpty || grammarPoint.isEmpty) return 0;
    if (!isEmbeddableSurfacePattern(grammarPoint)) return 0;
    if (!sentence.contains(grammarPoint)) return 0;
    if (surfaceFamily == GrammarExampleSurfaceFamily.dialogue) return 0;
    if (_looksLikeStandaloneSentence(grammarPoint) &&
        sentence.trim().startsWith(grammarPoint)) {
      return 0;
    }
    final replaced = sentence.replaceFirst(grammarPoint, '{replacement}');
    if (replaced == sentence || replaced.trim() == '{replacement}') return 0;

    var score = 54;
    score += _lengthScore(sentence, shortPenalty: -12);
    switch (surfaceFamily) {
      case GrammarExampleSurfaceFamily.statement:
        score += 12;
      case GrammarExampleSurfaceFamily.question:
        score += 6;
      case GrammarExampleSurfaceFamily.dialogue:
        score += 0;
    }
    return score.clamp(0, 100);
  }

  static int _transformationScore({
    required String sentence,
    required String prompt,
    required GrammarExampleSurfaceFamily surfaceFamily,
  }) {
    if (surfaceFamily != GrammarExampleSurfaceFamily.statement) return 0;
    if (_transformableEnding(sentence) == null) return 0;

    var score = 66;
    score += _lengthScore(sentence, shortPenalty: -8);
    if (prompt.trim().isNotEmpty) {
      score += 6;
    }
    return score.clamp(0, 100);
  }

  static int _overallScore({
    required String sentence,
    required String prompt,
    required bool usablePrompt,
    required GrammarExampleSurfaceFamily surfaceFamily,
    required Map<GrammarExampleQuestionKind, int> questionScores,
  }) {
    if (sentence.isEmpty) return 0;

    var score = 36;
    score += _lengthScore(sentence, shortPenalty: -10);

    if (prompt.trim().isNotEmpty) {
      score += usablePrompt ? 14 : 4;
    }

    switch (surfaceFamily) {
      case GrammarExampleSurfaceFamily.statement:
        score += 10;
      case GrammarExampleSurfaceFamily.question:
        score += 6;
      case GrammarExampleSurfaceFamily.dialogue:
        score -= 2;
    }

    final supportCount = questionScores.values
        .where((value) => value > 0)
        .length;
    score += supportCount * 4;
    return score.clamp(0, 100);
  }

  static int _blockScore({
    required int exampleCount,
    required List<GrammarExampleQualityAssessment> assessments,
    required Map<GrammarExampleQuestionKind, int> coverageCounts,
  }) {
    if (assessments.isEmpty || exampleCount <= 0) return 0;

    final averageExampleScore =
        assessments.map((item) => item.overallScore).reduce((a, b) => a + b) /
        assessments.length;

    var score = averageExampleScore.round();
    for (final kind in GrammarExampleQuestionKind.values) {
      final coverage = coverageCounts[kind] ?? 0;
      if (coverage == 0) continue;
      score += coverage >= 3 ? 4 : 2;
    }
    if (exampleCount >= 10) {
      score += 4;
    }
    return score.clamp(0, 100);
  }

  static int _lengthScore(String value, {required int shortPenalty}) {
    final length = value.runes.length;
    if (length < 6) return shortPenalty;
    if (length <= 30) return 10;
    if (length <= 48) return 5;
    if (length <= 72) return 1;
    return -6;
  }

  static int _tokenLikeChunkCount(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) return 0;
    if (trimmed.contains(' ')) {
      return trimmed
          .split(_whitespaceRe)
          .where((part) => part.isNotEmpty)
          .length;
    }

    var rough = trimmed;
    for (final marker in ['ですか', 'ますか', 'でした', 'です', 'ます']) {
      rough = rough.replaceAll(marker, '$marker ');
    }
    for (final particle in ['は', 'が', 'を', 'に', 'も', 'と', 'の', 'へ']) {
      rough = rough.replaceAll(particle, '$particle ');
    }
    return rough
        .split(_whitespaceRe)
        .where((part) => part.trim().isNotEmpty)
        .length;
  }

  static String? _transformableEnding(String sentence) {
    final transformed = transformToNegative(sentence);
    if (transformed == null) return null;
    return transformed;
  }

  static String? _transformCoreToNegative(String core) {
    if (_isRequestLikeCore(core)) {
      return null;
    }

    const directRules = <MapEntry<String, String>>[
      MapEntry('でございました', 'ではございませんでした'),
      MapEntry('ございました', 'ございませんでした'),
      MapEntry('ていました', 'ていませんでした'),
      MapEntry('ました', 'ませんでした'),
      MapEntry('でした', 'ではありませんでした'),
      MapEntry('でございます', 'ではございません'),
      MapEntry('ございます', 'ございません'),
      MapEntry('ています', 'ていません'),
      MapEntry('ていた', 'ていなかった'),
      MapEntry('ている', 'ていない'),
      MapEntry('ます', 'ません'),
      MapEntry('です', 'ではありません'),
      MapEntry('でしたら', 'ではありませんでしたら'),
      MapEntry('する', 'しない'),
      MapEntry('した', 'しなかった'),
      MapEntry('来る', '来ない'),
      MapEntry('来た', '来なかった'),
      MapEntry('くる', 'こない'),
      MapEntry('きた', 'こなかった'),
      MapEntry('ある', 'ない'),
      MapEntry('いい', 'よくない'),
      MapEntry('よい', 'よくない'),
    ];

    for (final rule in directRules) {
      if (core.endsWith(rule.key)) {
        return '${core.substring(0, core.length - rule.key.length)}${rule.value}';
      }
    }

    if (core.endsWith('たい')) {
      return '${core.substring(0, core.length - 1)}くない';
    }
    if (core.endsWith('かった') && !_isAlreadyNegativeCore(core)) {
      return '${core.substring(0, core.length - 2)}くなかった';
    }

    if (core.endsWith('た') && _looksLikeIchidanPast(core)) {
      return '${core.substring(0, core.length - 1)}なかった';
    }

    if (core.endsWith('る') && _looksLikeIchidanDictionary(core)) {
      return '${core.substring(0, core.length - 1)}ない';
    }

    const godanRules = <MapEntry<String, String>>[
      MapEntry('う', 'わない'),
      MapEntry('く', 'かない'),
      MapEntry('ぐ', 'がない'),
      MapEntry('す', 'さない'),
      MapEntry('つ', 'たない'),
      MapEntry('ぬ', 'なない'),
      MapEntry('ぶ', 'ばない'),
      MapEntry('む', 'まない'),
      MapEntry('る', 'らない'),
    ];
    for (final rule in godanRules) {
      if (core.endsWith(rule.key)) {
        return '${core.substring(0, core.length - rule.key.length)}${rule.value}';
      }
    }

    if (core.endsWith('い')) {
      return '${core.substring(0, core.length - 1)}くない';
    }

    if (core.endsWith('だ')) {
      return '${core.substring(0, core.length - 1)}ではない';
    }

    return null;
  }

  static String? _terminalPunctuation(String value) {
    if (value.isEmpty) return null;
    const punctuation = <String>{'。', '！', '？', '!', '?'};
    final last = String.fromCharCode(value.runes.last);
    return punctuation.contains(last) ? last : null;
  }

  static bool _isAlreadyNegativeCore(String core) {
    const endings = <String>[
      'ではありませんでした',
      'じゃありませんでした',
      'ませんでした',
      'ていませんでした',
      'ではございませんでした',
      'ではありません',
      'じゃありません',
      'ございません',
      'ていません',
      'ません',
      'ではない',
      'じゃない',
      'ていない',
      'くなかった',
      'なかった',
      'くない',
    ];
    if (endings.any(core.endsWith)) {
      return true;
    }

    const expectedNegativePhrases = <String>[
      'はずがない',
      'わけではない',
      'わけにはいかない',
      'ことはない',
      'そうにない',
      'に違いない',
      'ことがない',
      '可能性がない',
    ];
    if (expectedNegativePhrases.any(core.endsWith)) {
      return true;
    }

    if (!core.endsWith('ない')) {
      return false;
    }

    final stem = core.substring(0, core.length - 2);
    final last = _lastNonPunctuationChar(stem);
    if (last == null) return false;
    const aRowNegativeKana = {'わ', 'か', 'が', 'さ', 'た', 'な', 'ば', 'ま'};
    if (aRowNegativeKana.contains(last)) {
      return true;
    }
    if (_ichidanKana.contains(last)) {
      return true;
    }
    return last == 'し' || last == 'こ' || last == '来' || stem.endsWith('てい');
  }

  static bool _isRequestLikeCore(String core) {
    const endings = <String>[
      'ください',
      'くださいませ',
      'ましょう',
      'ましょうか',
      'てもかまいません',
      'なくてもかまいません',
      'てはいけません',
      'ないでください',
      'なければなりません',
      'なくてはいけません',
      'べきではない',
      'てはならない',
    ];
    return endings.any(core.endsWith);
  }

  static bool _looksLikeIchidanPast(String core) {
    if (!core.endsWith('た') || core.runes.length < 2) return false;
    final previous = _lastNonPunctuationChar(core.substring(0, core.length - 1));
    if (previous == null) return false;
    if (_ichidanKana.contains(previous)) return true;
    return false;
  }

  static bool _looksLikeIchidanDictionary(String core) {
    if (!core.endsWith('る') || core.runes.length < 2) return false;
    if (_godanRuExceptions.any(core.endsWith)) return false;
    final previous = _lastNonPunctuationChar(core.substring(0, core.length - 1));
    if (previous == null) return false;
    if (_ichidanKana.contains(previous)) return true;
    return false;
  }

  static String? _lastNonPunctuationChar(String value) {
    // Use a const rune-code set instead of a per-character RegExp to avoid
    // allocating one RegExp object (and one String) per character checked.
    final runes = value.runes.toList(growable: false);
    for (var i = runes.length - 1; i >= 0; i--) {
      if (!_terminalPunctAndSpaceRunes.contains(runes[i])) {
        return String.fromCharCode(runes[i]);
      }
    }
    return null;
  }

  static const Set<String> _ichidanKana = {
    'い',
    'き',
    'ぎ',
    'し',
    'じ',
    'ち',
    'ぢ',
    'に',
    'ひ',
    'び',
    'ぴ',
    'み',
    'り',
    'え',
    'け',
    'げ',
    'せ',
    'ぜ',
    'て',
    'で',
    'ね',
    'へ',
    'べ',
    'ぺ',
    'め',
    'れ',
  };

  static const List<String> _godanRuExceptions = [
    '帰る',
    '入る',
    '走る',
    '切る',
    '知る',
    '要る',
    '限る',
    '滑る',
    '焦る',
    '参る',
    '交じる',
    '交る',
    '握る',
    'しゃべる',
  ];

  static String _normalizePromptCompare(String input) {
    return input.replaceAll(_promptNormRe, '').trim();
  }

  static String _leadingSentenceClause(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('…')) {
      final parts = trimmed.split('…');
      final lead = parts.first.trim();
      if (lead.isNotEmpty) return lead;
    }
    final firstPeriod = trimmed.indexOf('。');
    if (firstPeriod > 0) {
      return trimmed.substring(0, firstPeriod).trim();
    }
    return trimmed;
  }

  static bool _looksLikeStandaloneSentence(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (_placeholderCount(trimmed) > 0) return false;
    if (trimmed.runes.length <= 4 &&
        !trimmed.contains('。') &&
        !trimmed.contains('？') &&
        !trimmed.contains('?')) {
      return false;
    }
    return trimmed.contains('。') ||
        trimmed.contains('？') ||
        trimmed.contains('?') ||
        trimmed.endsWith('です') ||
        trimmed.endsWith('ます') ||
        trimmed.endsWith('ですか') ||
        trimmed.endsWith('ますか') ||
        trimmed.endsWith('か');
  }

  static int _placeholderCount(String value) {
    return _placeholderRe.allMatches(value).length;
  }
}
