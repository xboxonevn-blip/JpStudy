import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/utils/grammar_example_quality.dart';
import 'package:jpstudy/data/utils/grammar_english_notation.dart';

import '../../../core/app_language.dart';

enum GrammarQuestionType {
  sentenceBuilder,
  cloze,
  multipleChoice,
  reverseMultipleChoice,
  contextChoice,
  errorCorrection,
  transformation,
  pairContrast,
  errorReason,
}

class GeneratedQuestion {
  const GeneratedQuestion({
    required this.type,
    required this.point,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.familyKey,
    required this.stemKey,
    required this.answerShapeKey,
    this.explanation,
    this.feedback,
  });

  final GrammarQuestionType type;
  final GrammarPoint point;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String familyKey;
  final String stemKey;
  final String answerShapeKey;
  final String? explanation;
  final String? feedback;
}

class GrammarQuestionGenerator {
  static const List<List<String>> _minimalPairPack = [
    ['は', 'が'],
    ['に', 'で'],
    ['を', 'が'],
    ['から', 'まで'],
    ['より', 'ほど'],
    ['ている', 'てある'],
    ['たい', 'ほしい'],
    ['そう', 'よう'],
    ['ために', 'ように'],
    ['ことができる', 'られる'],
  ];

  /// Generate practice questions from grammar point details.
  static List<GeneratedQuestion> generateQuestions(
    List<({GrammarPoint point, List<GrammarExample> examples})> details, {
    List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    final questions = <GeneratedQuestion>[];
    final dedupeKeys = <String>{};
    final examplePool = <({GrammarPoint point, GrammarExample example})>[
      for (final detail in details)
        for (final example in detail.examples)
          (point: detail.point, example: example),
    ];

    for (final detail in details) {
      final point = detail.point;
      final pointMeaning = _localizedPointMeaning(point, language);
      final pointExplanation = _localizedPointExplanation(point, language);
      final exampleQuality = GrammarExampleQualityAssessor.assessBlock(
        grammarPoint: point.grammarPoint,
        examples: detail.examples.map(_toQualitySeed).toList(growable: false),
        locale: _qualityLocaleFor(language),
      );
      final primaryExample = _bestExampleForBlock(
        detail.examples,
        exampleQuality,
      );
      final sentenceBuilderExamples = _prioritizedExamplesForKind(
        detail.examples,
        exampleQuality,
        GrammarExampleQuestionKind.sentenceBuilder,
      );
      final clozeExamples = _prioritizedExamplesForKind(
        detail.examples,
        exampleQuality,
        GrammarExampleQuestionKind.cloze,
      );
      final contextExamples = _prioritizedExamplesForKind(
        detail.examples,
        exampleQuality,
        GrammarExampleQuestionKind.contextChoice,
      );
      final replacementExamples = _prioritizedExamplesForKind(
        detail.examples,
        exampleQuality,
        GrammarExampleQuestionKind.errorCorrection,
      );
      final transformationExamples = _prioritizedExamplesForKind(
        detail.examples,
        exampleQuality,
        GrammarExampleQuestionKind.transformation,
      );

      _addQuestion(
        questions,
        dedupeKeys,
        _buildReverseMeaningQuestion(
          point: point,
          pointMeaning: pointMeaning,
          pointExplanation: pointExplanation,
          allPoints: allPoints,
          language: language,
        ),
      );

      _addQuestion(
        questions,
        dedupeKeys,
        _buildMeaningQuestion(
          point: point,
          pointMeaning: pointMeaning,
          pointExplanation: pointExplanation,
          allPoints: allPoints,
          language: language,
        ),
      );

      _addQuestion(
        questions,
        dedupeKeys,
        _buildPairContrastQuestion(
          point: point,
          pointMeaning: pointMeaning,
          pointExplanation: pointExplanation,
          primaryExample: primaryExample,
          allPoints: allPoints,
          language: language,
        ),
      );

      for (final example in sentenceBuilderExamples) {
        final localizedTranslation = _localizedExampleTranslation(
          example,
          language,
        );
        final sentenceTokens = _tokenizeSentence(example.japanese);

        if (sentenceTokens.isNotEmpty) {
          _addQuestion(
            questions,
            dedupeKeys,
            GeneratedQuestion(
              type: GrammarQuestionType.sentenceBuilder,
              point: point,
              question: _tr(
                language,
                en: 'Arrange the sentence.',
                vi: 'Ghép thành câu hoàn chỉnh.',
                ja: '文を並び替えてください。',
              ),
              correctAnswer: example.japanese,
              options: sentenceTokens,
              familyKey: 'builder_${point.id}',
              stemKey: _normalizeStem(example.japanese),
              answerShapeKey: 'builder_${sentenceTokens.length}',
              explanation: localizedTranslation,
              feedback: _tr(
                language,
                en: 'Target pattern: ${_localizedPatternFormula(point, language)}. ${pointExplanation.trim()}',
                vi: 'Mẫu ngữ pháp: ${point.grammarPoint}. ${pointExplanation.trim()}',
                ja: '使うべき文型: ${point.grammarPoint}。${pointExplanation.trim()}',
              ),
            ),
          );
        }
      }

      for (final example in clozeExamples) {
        _addQuestion(
          questions,
          dedupeKeys,
          _buildClozeQuestion(
            point: point,
            pointMeaning: pointMeaning,
            pointExplanation: pointExplanation,
            example: example,
            examplePool: examplePool,
            allPoints: allPoints,
            language: language,
          ),
        );
      }

      for (final example in contextExamples) {
        _addQuestion(
          questions,
          dedupeKeys,
          _buildContextChoiceQuestion(
            point: point,
            pointMeaning: pointMeaning,
            pointExplanation: pointExplanation,
            targetExample: example,
            examplePool: examplePool,
            language: language,
          ),
        );
      }

      for (final example in replacementExamples) {
        _addQuestion(
          questions,
          dedupeKeys,
          _buildErrorCorrectionQuestion(
            point: point,
            pointMeaning: pointMeaning,
            pointExplanation: pointExplanation,
            example: example,
            allPoints: allPoints,
            language: language,
          ),
        );

        _addQuestion(
          questions,
          dedupeKeys,
          _buildErrorReasonQuestion(
            point: point,
            pointMeaning: pointMeaning,
            pointExplanation: pointExplanation,
            example: example,
            allPoints: allPoints,
            language: language,
          ),
        );
      }

      for (final example in transformationExamples) {
        _addQuestion(
          questions,
          dedupeKeys,
          _buildTransformationQuestion(
            point: point,
            pointMeaning: pointMeaning,
            pointExplanation: pointExplanation,
            example: example,
            language: language,
          ),
        );
      }
    }

    return questions;
  }

  static void _addQuestion(
    List<GeneratedQuestion> out,
    Set<String> dedupeKeys,
    GeneratedQuestion? question,
  ) {
    if (question == null) return;
    if (question.options.isEmpty) return;

    final key = '${question.type}:${question.point.id}:${question.question}';
    if (dedupeKeys.add(key)) {
      out.add(question);
    }
  }

  static GrammarExampleSeedData _toQualitySeed(GrammarExample example) {
    return GrammarExampleSeedData(
      sentence: example.japanese,
      translation: example.translation,
      translationEn: example.translationEn,
      translationVi: example.translationVi,
    );
  }

  static GrammarExampleLocale _qualityLocaleFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return GrammarExampleLocale.en;
      case AppLanguage.vi:
        return GrammarExampleLocale.vi;
      case AppLanguage.ja:
        return GrammarExampleLocale.ja;
    }
  }

  static GrammarExample? _bestExampleForBlock(
    List<GrammarExample> examples,
    GrammarExampleBlockQualityAssessment quality,
  ) {
    final best = quality.bestOverall;
    if (best == null || best.index < 0 || best.index >= examples.length) {
      return examples.isEmpty ? null : examples.first;
    }
    return examples[best.index];
  }

  static List<GrammarExample> _prioritizedExamplesForKind(
    List<GrammarExample> examples,
    GrammarExampleBlockQualityAssessment quality,
    GrammarExampleQuestionKind kind,
  ) {
    final limit = _exampleLimitFor(kind);
    final prioritized = <GrammarExample>[];
    for (final item in quality.prioritizedFor(kind, limit: limit)) {
      if (item.index < 0 || item.index >= examples.length) continue;
      prioritized.add(examples[item.index]);
    }
    return prioritized;
  }

  static int _exampleLimitFor(GrammarExampleQuestionKind kind) {
    switch (kind) {
      case GrammarExampleQuestionKind.sentenceBuilder:
        return 4;
      case GrammarExampleQuestionKind.cloze:
        return 4;
      case GrammarExampleQuestionKind.contextChoice:
        return 3;
      case GrammarExampleQuestionKind.errorCorrection:
        return 3;
      case GrammarExampleQuestionKind.errorReason:
        return 3;
      case GrammarExampleQuestionKind.transformation:
        return 2;
    }
  }

  static GeneratedQuestion? _buildReverseMeaningQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    if (allPoints == null || allPoints.isEmpty) return null;

    final patternLabel = _localizedPatternLabel(point, language);
    final distractors = _pickRelatedGrammarPoints(
      target: point,
      pool: allPoints,
      count: 3,
      language: language,
    ).map((p) => _localizedPatternLabel(p, language)).toList(growable: false);
    if (distractors.length < 2) return null;

    final options = _uniqueShuffled([patternLabel, ...distractors]);
    if (options.length < 3) return null;

    final questionText = _tr(
      language,
      en: 'Which pattern matches: "$pointMeaning"?',
      vi: 'Mẫu nào có nghĩa là: "$pointMeaning"?',
      ja: '「$pointMeaning」に合う文型はどれですか？',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.reverseMultipleChoice,
      point: point,
      question: questionText,
      correctAnswer: patternLabel,
      options: options,
      familyKey: 'reverse_meaning_${point.id}',
      stemKey: _normalizeStem(questionText),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointExplanation,
      feedback: _tr(
        language,
        en: 'Use $patternLabel when you mean: $pointMeaning.',
        vi: 'Dùng $patternLabel để diễn đạt: $pointMeaning.',
        ja: '$pointMeaning を表すときは $patternLabel を使います。',
      ),
    );
  }

  static GeneratedQuestion? _buildMeaningQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    if (allPoints == null || allPoints.isEmpty) return null;

    final patternLabel = _localizedPatternLabel(point, language);
    final distractors = _pickRelatedGrammarPoints(
      target: point,
      pool: allPoints,
      count: 3,
      language: language,
    ).map((p) => _localizedPointMeaning(p, language)).toList(growable: false);
    if (distractors.length < 2) return null;

    final options = _uniqueShuffled([pointMeaning, ...distractors]);
    if (options.length < 3) return null;

    final questionText = _tr(
      language,
      en: 'What is the best meaning of "$patternLabel"?',
      vi: '"$patternLabel" có nghĩa là gì?',
      ja: '「$patternLabel」の意味として最も適切なのはどれですか？',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.multipleChoice,
      point: point,
      question: questionText,
      correctAnswer: pointMeaning,
      options: options,
      familyKey: 'meaning_${point.id}',
      stemKey: _normalizeStem(questionText),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointExplanation,
      feedback: pointExplanation,
    );
  }

  static GeneratedQuestion? _buildPairContrastQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required GrammarExample? primaryExample,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    if (allPoints == null || allPoints.isEmpty) return null;

    final contrast = _pickContrastPoint(point, allPoints);
    if (contrast == null) return null;
    final patternLabel = _localizedPatternLabel(point, language);
    final contrastLabel = _localizedPatternLabel(contrast, language);

    final context = primaryExample == null
        ? pointMeaning
        : _localizedExampleTranslation(primaryExample, language);
    final questionText = _tr(
      language,
      en: 'Contrast drill\nA: $patternLabel  vs  B: $contrastLabel\nContext: $context\nWhich pattern fits better?',
      vi: 'Phân biệt mẫu\nA: $patternLabel  vs  B: $contrastLabel\nNgữ cảnh: $context\nChọn đáp án phù hợp.',
      ja: '対比ドリル\nA: $patternLabel  vs  B: $contrastLabel\n文脈: $context\nより適切な文型はどれですか？',
    );

    final options = _uniqueShuffled([patternLabel, contrastLabel]);
    if (options.length < 2) return null;

    return GeneratedQuestion(
      type: GrammarQuestionType.pairContrast,
      point: point,
      question: questionText,
      correctAnswer: patternLabel,
      options: options,
      familyKey: 'contrast_${point.id}_${contrast.id}',
      stemKey: _normalizeStem(questionText),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointExplanation,
      feedback: _tr(
        language,
        en: 'Pick $patternLabel for this nuance. Contrast option: $contrastLabel (minimal pair).',
        vi: 'Sắc thái này nên dùng $patternLabel. Mẫu đối chiếu là $contrastLabel.',
        ja: 'このニュアンスでは $patternLabel が適切です。対比候補は $contrastLabel です。',
      ),
    );
  }

  static GrammarPoint? _pickContrastPoint(
    GrammarPoint point,
    List<GrammarPoint> allPoints,
  ) {
    final self = _normalizePattern(point.grammarPoint);
    final pool = allPoints
        .where((candidate) => candidate.id != point.id)
        .toList(growable: false);
    if (pool.isEmpty) return null;

    for (final pair in _minimalPairPack) {
      final selfToken = pair.firstWhere(
        (token) => self.contains(_normalizePattern(token)),
        orElse: () => '',
      );
      if (selfToken.isEmpty) continue;
      for (final token in pair) {
        if (token == selfToken) continue;
        final normalized = _normalizePattern(token);
        for (final candidate in pool) {
          if (_normalizePattern(candidate.grammarPoint).contains(normalized)) {
            return candidate;
          }
        }
      }
    }

    for (final candidate in pool) {
      if (candidate.jlptLevel == point.jlptLevel) {
        return candidate;
      }
    }
    return pool.first;
  }

  static GeneratedQuestion? _buildClozeQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required GrammarExample example,
    required List<({GrammarPoint point, GrammarExample example})> examplePool,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    if (!example.japanese.contains(point.grammarPoint)) return null;
    if (allPoints == null || allPoints.isEmpty) return null;

    final patternFormula = _localizedPatternFormula(point, language);
    if (!_isUsablePatternChoice(patternFormula)) return null;
    if (_shouldSkipClozeForPattern(point, example, patternFormula)) return null;

    final distractors = _buildClozeDistractors(
      point: point,
      example: example,
      examplePool: examplePool,
      allPoints: allPoints,
      language: language,
      targetFormula: patternFormula,
    );

    final options = _uniqueShuffled([patternFormula, ...distractors]);
    if (options.length < 3) return null;

    final questionText = example.japanese.replaceFirst(
      point.grammarPoint,
      '{blank}',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.cloze,
      point: point,
      question: questionText,
      correctAnswer: patternFormula,
      options: options,
      familyKey: 'cloze_${point.id}',
      stemKey: _normalizeStem(questionText),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointMeaning,
      feedback: _tr(
        language,
        en: 'Expected $patternFormula. It matches "$pointMeaning". ${pointExplanation.trim()}',
        vi: 'Đáp án đúng là ${point.grammarPoint}. Mẫu này khớp với "$pointMeaning". ${pointExplanation.trim()}',
        ja: '正解は ${point.grammarPoint} です。「$pointMeaning」に合います。${pointExplanation.trim()}',
      ),
    );
  }

  static GeneratedQuestion? _buildContextChoiceQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required GrammarExample targetExample,
    required List<({GrammarPoint point, GrammarExample example})> examplePool,
    required AppLanguage language,
  }) {
    final prompt = _localizedExampleTranslation(targetExample, language).trim();
    if (_shouldSkipContextChoiceForExample(
      example: targetExample,
      prompt: prompt,
    )) {
      return null;
    }
    final patternFormula = _localizedPatternFormula(point, language);

    final distractors = _pickContextDistractorSentences(
      point: point,
      targetExample: targetExample,
      examplePool: examplePool,
      language: language,
    );
    if (distractors.length < 2) return null;

    final options = _uniqueShuffled([targetExample.japanese, ...distractors]);
    if (options.length < 3) return null;

    final questionText = _tr(
      language,
      en: 'Pick the sentence that best matches this context:\n$prompt',
      vi: 'Chọn câu phù hợp nhất với ngữ cảnh sau:\n$prompt',
      ja: '次の文脈に最も合う文を選んでください:\n$prompt',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.contextChoice,
      point: point,
      question: questionText,
      correctAnswer: targetExample.japanese,
      options: options,
      familyKey: 'context_${point.id}',
      stemKey: _normalizeStem(prompt),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointExplanation,
      feedback: _tr(
        language,
        en: 'Correct because it uses $patternFormula in context.',
        vi: 'Đúng vì câu này dùng ${point.grammarPoint} đúng ngữ cảnh.',
        ja: '文脈に合う ${point.grammarPoint} が使われているため正解です。',
      ),
    );
  }

  static GeneratedQuestion? _buildErrorCorrectionQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required GrammarExample example,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    final patternFormula = _localizedPatternFormula(point, language);
    if (_shouldSkipReplacementQuestionForPattern(
      point,
      example,
      patternFormula,
    )) {
      return null;
    }

    final corrupted = _buildCorruptedSentence(
      point: point,
      example: example,
      allPoints: allPoints,
      language: language,
    );
    if (corrupted == null) return null;

    final replacementFormula = _localizedPatternFormula(
      corrupted.replacementPoint,
      language,
    );
    final options = _uniqueShuffled([
      patternFormula,
      replacementFormula,
      ...corrupted.alternativePoints
          .map((item) => _localizedPatternFormula(item, language))
          .take(2),
    ]);
    if (options.length < 3) return null;

    final questionText = _tr(
      language,
      en: 'This sentence has a grammar mistake:\n${corrupted.wrongSentence}\nWhich pattern fixes it?',
      vi: 'Câu sau bị sai ngữ pháp:\n${corrupted.wrongSentence}\nHãy chọn mẫu đúng để sửa.',
      ja: '次の文には文法の誤りがあります:\n${corrupted.wrongSentence}\nどの文型で直せますか？',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.errorCorrection,
      point: point,
      question: questionText,
      correctAnswer: patternFormula,
      options: options,
      familyKey: 'error_fix_${point.id}',
      stemKey: _normalizeStem(corrupted.wrongSentence),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointMeaning,
      feedback: _tr(
        language,
        en: 'Use $patternFormula. Correct sentence: ${corrupted.correctSentence}',
        vi: 'Nên dùng ${point.grammarPoint}. Câu đúng: ${corrupted.correctSentence}',
        ja: '${point.grammarPoint} を使います。正しい文: ${corrupted.correctSentence}',
      ),
    );
  }

  static GeneratedQuestion? _buildErrorReasonQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required GrammarExample example,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    final patternFormula = _localizedPatternFormula(point, language);
    if (_shouldSkipReplacementQuestionForPattern(
      point,
      example,
      patternFormula,
    )) {
      return null;
    }

    final corrupted = _buildCorruptedSentence(
      point: point,
      example: example,
      allPoints: allPoints,
      language: language,
    );
    if (corrupted == null) return null;

    final replacementFormula = _localizedPatternFormula(
      corrupted.replacementPoint,
      language,
    );
    final correctReason = _tr(
      language,
      en: 'The pattern "$replacementFormula" does not match this meaning. Use "$patternFormula".',
      vi: 'Mẫu "${corrupted.replacement}" không hợp nghĩa. Cần dùng "${point.grammarPoint}".',
      ja: '「${corrupted.replacement}」はこの意味に合いません。「${point.grammarPoint}」を使います。',
    );

    final options = _uniqueShuffled([
      correctReason,
      _tr(
        language,
        en: 'Only kanji writing is wrong; grammar is fine.',
        vi: 'Chỉ sai cách viết kanji, ngữ pháp vẫn đúng.',
        ja: '漢字の書き方だけが誤りで、文法自体は正しい。',
      ),
      _tr(
        language,
        en: 'Word order alone is the issue; pattern choice is correct.',
        vi: 'Chỉ sai trật tự từ; việc chọn mẫu ngữ pháp là đúng.',
        ja: '語順だけが問題で、文型の選択は正しい。',
      ),
      _tr(
        language,
        en: 'The sentence lacks vocabulary, not grammar.',
        vi: 'Vấn đề là thiếu từ vựng, không phải ngữ pháp.',
        ja: '問題は語彙不足で、文法の誤りではない。',
      ),
    ]);
    if (options.length < 3) return null;

    final questionText = _tr(
      language,
      en: 'Why is this sentence wrong?\n${corrupted.wrongSentence}',
      vi: 'Vì sao câu này sai?\n${corrupted.wrongSentence}',
      ja: 'この文が誤りなのはなぜですか？\n${corrupted.wrongSentence}',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.errorReason,
      point: point,
      question: questionText,
      correctAnswer: correctReason,
      options: options,
      familyKey: 'error_reason_${point.id}',
      stemKey: _normalizeStem(corrupted.wrongSentence),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointExplanation,
      feedback: _tr(
        language,
        en: 'Correct sentence: ${corrupted.correctSentence}',
        vi: 'Câu đúng: ${corrupted.correctSentence}',
        ja: '正しい文: ${corrupted.correctSentence}',
      ),
    );
  }

  static GeneratedQuestion? _buildTransformationQuestion({
    required GrammarPoint point,
    required String pointMeaning,
    required String pointExplanation,
    required GrammarExample example,
    required AppLanguage language,
  }) {
    if (_shouldSkipTransformationForExample(example)) return null;

    final transformed = _transformToNegative(example.japanese);
    if (transformed == null || transformed == example.japanese) return null;

    final options = _uniqueShuffled([
      transformed,
      example.japanese,
      _softVariant(example.japanese),
      _softVariant(transformed),
      _trimSentencePunctuation(example.japanese),
      _trimSentencePunctuation(transformed),
    ]);
    if (options.length < 3) return null;

    final questionText = _tr(
      language,
      en: 'Transform this sentence to negative form:\n${example.japanese}',
      vi: 'Hãy đổi câu sau sang dạng phủ định:\n${example.japanese}',
      ja: '次の文を否定形に変えてください:\n${example.japanese}',
    );

    return GeneratedQuestion(
      type: GrammarQuestionType.transformation,
      point: point,
      question: questionText,
      correctAnswer: transformed,
      options: options,
      familyKey: 'transform_${point.id}',
      stemKey: _normalizeStem(example.japanese),
      answerShapeKey: 'choice_${options.length}',
      explanation: pointMeaning,
      feedback: _tr(
        language,
        en: 'Negative form: ${example.japanese} -> $transformed. ${pointExplanation.trim()}',
        vi: 'Dạng phủ định: ${example.japanese} -> $transformed. ${pointExplanation.trim()}',
        ja: '否定形: ${example.japanese} -> $transformed。${pointExplanation.trim()}',
      ),
    );
  }

  static _CorruptedSentence? _buildCorruptedSentence({
    required GrammarPoint point,
    required GrammarExample example,
    required List<GrammarPoint>? allPoints,
    required AppLanguage language,
  }) {
    if (allPoints == null || allPoints.isEmpty) return null;
    final targetPattern = point.grammarPoint.trim();
    if (targetPattern.isEmpty) return null;
    if (!_isEmbeddableSurfacePattern(targetPattern)) return null;
    if (!example.japanese.contains(targetPattern)) return null;

    final alternatives = _pickRelatedGrammarPoints(
      target: point,
      pool: allPoints,
      count: 5,
      language: language,
    );
    String? replacement;
    for (final value in alternatives.map((p) => p.grammarPoint)) {
      final candidate = value.trim();
      if (!_isEmbeddableSurfacePattern(candidate)) {
        continue;
      }
      replacement = candidate;
      break;
    }
    if (replacement == null) return null;

    final replacementPoint = alternatives.firstWhere(
      (item) => item.grammarPoint == replacement,
    );

    return _CorruptedSentence(
      wrongSentence: example.japanese.replaceFirst(targetPattern, replacement),
      correctSentence: example.japanese,
      replacement: replacement,
      replacementPoint: replacementPoint,
      alternativePoints: alternatives
          .where((item) => item.grammarPoint.trim().isNotEmpty)
          .toList(growable: false),
    );
  }

  static String? _transformToNegative(String sentence) {
    return GrammarExampleQualityAssessor.transformToNegative(sentence);
  }

  static String _softVariant(String sentence) {
    var value = sentence.trim();
    if (value.endsWith('。')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.endsWith('です')) {
      return '$valueか';
    }
    if (value.endsWith('ます')) {
      return '$valueか';
    }
    if (value.endsWith('ない')) {
      return '$valueか';
    }
    return value;
  }

  static String _trimSentencePunctuation(String sentence) {
    return sentence.trim().replaceFirst(RegExp(r'[。！？?!]+$'), '');
  }

  static List<String> _tokenizeSentence(String sentence) {
    final trimmed = sentence.trim();
    if (trimmed.isEmpty) return const [];

    // Dialogue sentences like「Q。…A。」— tokenize only the answer part.
    if (trimmed.contains('…')) {
      final parts = trimmed.split('…');
      final answer = parts.last.trim();
      if (answer.isNotEmpty) {
        return _tokenizeSentence(answer);
      }
    }

    // Sentences with explicit spaces — split on whitespace.
    if (trimmed.contains(' ')) {
      return trimmed
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList(growable: false);
    }

    // Japanese morpheme-boundary chunking.
    // Single-pass: use a regex with alternation (longest patterns first) to
    // insert a split-marker (\x00) before each verbal/copula ending and after
    // each postpositional particle. Because it's one pass, longer patterns
    // like「ですか」are matched before their substrings like「です」.
    const splitMark = '\x00';

    // Verbal/copula endings — longest alternatives first so the regex engine
    // matches「ですか」before trying「です」etc.
    final verbalEndingRe = RegExp(
      'じゃありません|ではありません|じゃないです'
      '|なければなりません|なくてもいいです|かもしれません'
      '|てはいけません|てはいけない|てもいいです'
      '|ていただけます|ていただきます|ていません'
      '|ています|てあります|ていました|ていた|てある|てきます'
      '|でしょう|ましょう|ください'
      '|ません|ました|ますか|ますね|ますよ|ます'
      '|ですか|ですね|ですよ|です',
    );

    // Insert split markers before each verbal ending (single pass)
    var work = trimmed.replaceAllMapped(
      verbalEndingRe,
      (m) => '$splitMark${m.group(0)}',
    );

    // Postpositional particles: insert split marker after each.
    // 「で」excluded — it's a substring of「です」and would corrupt endings
    // already split in the previous step.
    for (final particle in ['は', 'が', 'を', 'に', 'も', 'と', 'の', 'へ']) {
      work = work.replaceAll(particle, '$particle$splitMark');
    }

    // Remove any split mark that immediately precedes sentence-final punctuation
    work = work.replaceAllMapped(
      RegExp('$splitMark([。、！？])'),
      (m) => m.group(1)!,
    );

    final rawChunks = work
        .split(splitMark)
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList(growable: true);

    // Merge very short stray fragments with the preceding chunk.
    final merged = <String>[];
    for (final chunk in rawChunks) {
      if (merged.isNotEmpty && chunk.runes.length <= 1) {
        merged[merged.length - 1] = merged.last + chunk;
      } else {
        merged.add(chunk);
      }
    }

    if (merged.length >= 2) return merged;

    // Fallback: split into 3-character groups for very short sentences.
    final runes = trimmed.runes.toList();
    final pairs = <String>[];
    const step = 3;
    for (var i = 0; i < runes.length; i += step) {
      final end = (i + step).clamp(0, runes.length);
      pairs.add(String.fromCharCodes(runes.sublist(i, end)));
    }
    return pairs.isEmpty ? [trimmed] : pairs;
  }

  static List<GrammarPoint> _pickRelatedGrammarPoints({
    required GrammarPoint target,
    required List<GrammarPoint> pool,
    required int count,
    required AppLanguage language,
  }) {
    final ranked = _rankRelatedGrammarPoints(
      target: target,
      pool: pool,
      language: language,
      targetFormula: _localizedPatternFormula(target, language),
    );
    return ranked.take(count).toList(growable: false);
  }

  static List<String> _pickContextDistractorSentences({
    required GrammarPoint point,
    required GrammarExample targetExample,
    required List<({GrammarPoint point, GrammarExample example})> examplePool,
    required AppLanguage language,
  }) {
    final targetSentence = targetExample.japanese.trim();
    final targetPrompt = _localizedExampleTranslation(
      targetExample,
      language,
    ).trim();

    final ranked = <({String sentence, int score})>[];
    for (final item in examplePool) {
      final sentence = item.example.japanese.trim();
      if (item.point.id == point.id) continue;
      if (sentence.isEmpty || sentence == targetSentence) continue;

      final prompt = _localizedExampleTranslation(
        item.example,
        language,
      ).trim();
      if (!_hasUsableContextPrompt(prompt, sentence)) continue;

      ranked.add((
        sentence: sentence,
        score: _contextDistractorScore(
          targetPoint: point,
          targetExample: targetExample,
          targetPrompt: targetPrompt,
          candidatePoint: item.point,
          candidateExample: item.example,
          candidatePrompt: prompt,
        ),
      ));
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.sentence.compareTo(b.sentence);
    });

    final used = <String>{};
    final result = <String>[];
    for (final item in ranked) {
      if (!used.add(item.sentence)) continue;
      result.add(item.sentence);
      if (result.length >= 3) break;
    }
    return result;
  }

  static int _contextDistractorScore({
    required GrammarPoint targetPoint,
    required GrammarExample targetExample,
    required String targetPrompt,
    required GrammarPoint candidatePoint,
    required GrammarExample candidateExample,
    required String candidatePrompt,
  }) {
    var score = 0;
    final targetSurface = _exampleSurfaceFamily(targetExample.japanese);
    final candidateSurface = _exampleSurfaceFamily(candidateExample.japanese);

    if (candidatePoint.lessonId != null &&
        candidatePoint.lessonId == targetPoint.lessonId) {
      score += 5;
    }
    if (candidatePoint.jlptLevel == targetPoint.jlptLevel) {
      score += 3;
    }
    if (_hasSimilarSentenceEnding(
      targetExample.japanese,
      candidateExample.japanese,
    )) {
      score += 4;
    }
    if (targetSurface == candidateSurface) {
      score += 4;
    } else if (targetSurface != 'statement' ||
        candidateSurface != 'statement') {
      score -= 3;
    }

    final translationOverlap = _meaningTokenOverlap(
      targetPrompt,
      candidatePrompt,
    );
    score += translationOverlap * 2;

    final translationDelta = (targetPrompt.length - candidatePrompt.length)
        .abs();
    if (translationDelta <= 12) {
      score += 2;
    } else if (translationDelta <= 24) {
      score += 1;
    }

    final sentenceDelta =
        (targetExample.japanese.length - candidateExample.japanese.length)
            .abs();
    if (sentenceDelta <= 6) {
      score += 2;
    } else if (sentenceDelta <= 12) {
      score += 1;
    }

    return score;
  }

  static int _meaningTokenOverlap(String left, String right) {
    final leftTokens = _meaningTokens(left);
    final rightTokens = _meaningTokens(right);
    if (leftTokens.isEmpty || rightTokens.isEmpty) return 0;
    return leftTokens.intersection(rightTokens).length;
  }

  static Set<String> _meaningTokens(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return const <String>{};

    final wordTokens = normalized
        .split(RegExp(r'[^a-z0-9\u00c0-\u1ef9]+'))
        .where((token) => token.length >= 2)
        .toSet();
    if (wordTokens.isNotEmpty) {
      return wordTokens;
    }

    final compact = normalized.replaceAll(RegExp(r'\s+'), '');
    if (compact.runes.length < 2) {
      return compact.isEmpty ? const <String>{} : {compact};
    }

    final chars = compact.runes
        .map(String.fromCharCode)
        .toList(growable: false);
    final bigrams = <String>{};
    for (var i = 0; i < chars.length - 1; i++) {
      bigrams.add('${chars[i]}${chars[i + 1]}');
    }
    return bigrams;
  }

  static List<String> _buildClozeDistractors({
    required GrammarPoint point,
    required GrammarExample example,
    required List<({GrammarPoint point, GrammarExample example})> examplePool,
    required List<GrammarPoint> allPoints,
    required AppLanguage language,
    required String targetFormula,
  }) {
    final distractors = <String>{};

    if (_looksLikeStandaloneSentence(targetFormula)) {
      final sentenceDistractors = _candidateSentenceDistractors(
        point: point,
        example: example,
        examplePool: examplePool,
      );
      distractors.addAll(sentenceDistractors);
    }

    final rankedPoints = _rankRelatedGrammarPoints(
      target: point,
      pool: allPoints,
      language: language,
      targetFormula: targetFormula,
    );

    for (final candidate in rankedPoints) {
      final candidateFormula = _localizedPatternFormula(candidate, language);
      if (!_isUsablePatternChoice(candidateFormula)) continue;
      if (!_matchesClozeProfile(targetFormula, candidateFormula)) continue;
      distractors.add(candidateFormula);
      if (distractors.length >= 3) break;
    }

    return distractors.take(3).toList(growable: false);
  }

  static List<String> _candidateSentenceDistractors({
    required GrammarPoint point,
    required GrammarExample example,
    required List<({GrammarPoint point, GrammarExample example})> examplePool,
  }) {
    final targetLead = _leadingSentenceClause(example.japanese);
    if (targetLead.isEmpty) return const [];

    final candidates = <String>{};
    for (final item in examplePool) {
      if (item.example.japanese.trim() == example.japanese.trim()) continue;
      final lead = _leadingSentenceClause(item.example.japanese);
      if (lead.isEmpty || lead == targetLead) continue;
      if (!_looksLikeStandaloneSentence(lead)) continue;
      if (!_hasSimilarSentenceEnding(targetLead, lead)) continue;
      candidates.add(lead);
      if (candidates.length >= 3) break;
    }
    return candidates.toList(growable: false);
  }

  static List<GrammarPoint> _rankRelatedGrammarPoints({
    required GrammarPoint target,
    required List<GrammarPoint> pool,
    required AppLanguage language,
    required String targetFormula,
  }) {
    final candidates = pool.where((item) => item.id != target.id).toList()
      ..shuffle();

    candidates.sort((a, b) {
      final scoreB = _relatedPointScore(
        target: target,
        candidate: b,
        language: language,
        targetFormula: targetFormula,
      );
      final scoreA = _relatedPointScore(
        target: target,
        candidate: a,
        language: language,
        targetFormula: targetFormula,
      );
      return scoreB.compareTo(scoreA);
    });

    return candidates;
  }

  static int _relatedPointScore({
    required GrammarPoint target,
    required GrammarPoint candidate,
    required AppLanguage language,
    required String targetFormula,
  }) {
    final candidateFormula = _localizedPatternFormula(candidate, language);
    var score = 0;

    if (candidate.lessonId != null && candidate.lessonId == target.lessonId) {
      score += 5;
    }
    if (candidate.jlptLevel == target.jlptLevel) {
      score += 3;
    }
    if (_matchesClozeProfile(targetFormula, candidateFormula)) {
      score += 4;
    }
    if (_hasSimilarSentenceEnding(targetFormula, candidateFormula)) {
      score += 3;
    }
    if (_placeholderCount(targetFormula) ==
        _placeholderCount(candidateFormula)) {
      score += 2;
    }
    final targetType = _patternShapeType(targetFormula);
    final candidateType = _patternShapeType(candidateFormula);
    if (targetType == candidateType) {
      score += 2;
    }
    return score;
  }

  static bool _matchesClozeProfile(String target, String candidate) {
    if (!_isUsablePatternChoice(candidate)) return false;
    final targetType = _patternShapeType(target);
    final candidateType = _patternShapeType(candidate);
    if (targetType != candidateType) return false;

    if (_looksLikeStandaloneSentence(target)) {
      return _hasSimilarSentenceEnding(target, candidate);
    }

    final targetPlaceholders = _placeholderCount(target);
    final candidatePlaceholders = _placeholderCount(candidate);
    if (targetPlaceholders > 0 || candidatePlaceholders > 0) {
      return (targetPlaceholders - candidatePlaceholders).abs() <= 1;
    }

    return (target.length - candidate.length).abs() <= 10;
  }

  static bool _shouldSkipClozeForPattern(
    GrammarPoint point,
    GrammarExample example,
    String patternFormula,
  ) {
    if (!_isUsablePatternChoice(patternFormula)) return true;
    final rawPattern = point.grammarPoint.trim();
    if (rawPattern.isEmpty) return true;

    final exampleText = example.japanese.trim();
    if (_looksLikeExchangePrompt(rawPattern) &&
        exampleText.startsWith(rawPattern)) {
      return true;
    }

    final blanked = exampleText.replaceFirst(rawPattern, '{blank}');
    if (blanked == exampleText || blanked.trim() == '{blank}') {
      return true;
    }

    return false;
  }

  static bool _shouldSkipReplacementQuestionForPattern(
    GrammarPoint point,
    GrammarExample example,
    String patternFormula,
  ) {
    if (!_isUsablePatternChoice(patternFormula)) return true;
    final rawPattern = point.grammarPoint.trim();
    if (!_isEmbeddableSurfacePattern(rawPattern)) return true;

    final exampleText = example.japanese.trim();
    if (_looksLikeStandaloneSentence(rawPattern) &&
        exampleText.startsWith(rawPattern)) {
      return true;
    }

    final replaced = exampleText.replaceFirst(rawPattern, '{replacement}');
    if (replaced == exampleText || replaced.trim() == '{replacement}') {
      return true;
    }

    return false;
  }

  static bool _shouldSkipContextChoiceForExample({
    required GrammarExample example,
    required String prompt,
  }) {
    final sentence = example.japanese.trim();
    if (!_hasUsableContextPrompt(prompt, sentence)) return true;
    return _isDialogueSentence(sentence);
  }

  static bool _hasUsableContextPrompt(String prompt, String sentence) {
    return GrammarExampleQualityAssessor.hasUsableContextPrompt(
      prompt,
      sentence,
    );
  }

  static bool _shouldSkipTransformationForExample(GrammarExample example) {
    return !GrammarExampleQualityAssessor.supportsTransformation(
      example.japanese,
    );
  }

  static bool _isUsablePatternChoice(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (containsVietnameseGrammarText(trimmed)) return false;
    const blocked = <String>{
      'Grammar pattern',
      'Target pattern',
      'Question pattern',
    };
    return !blocked.contains(trimmed);
  }

  static bool _isEmbeddableSurfacePattern(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (containsVietnameseGrammarText(trimmed)) return false;
    if (_placeholderCount(trimmed) > 0) return false;
    return !RegExp(r'[~～〜〇○◯□△◇_＿/／]').hasMatch(trimmed);
  }

  static bool _isDialogueSentence(String value) {
    return GrammarExampleQualityAssessor.surfaceFamilyForSentence(value) ==
        GrammarExampleSurfaceFamily.dialogue;
  }

  static bool _looksLikeExchangePrompt(String value) {
    final trimmed = value.trim();
    return _looksLikeStandaloneSentence(trimmed) &&
        (trimmed.contains('ですか') ||
            trimmed.endsWith('か') ||
            trimmed.contains('どちら') ||
            trimmed.contains('どこ') ||
            trimmed.contains('何'));
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
    final matches = RegExp(
      r'(^|[^A-Za-z])(N\d*|V\d*|A\d*|S\d*)(?=$|[^A-Za-z])',
    ).allMatches(value).length;
    return matches;
  }

  static String _patternShapeType(String value) {
    final trimmed = value.trim();
    if (_looksLikeStandaloneSentence(trimmed)) return 'sentence';
    if (_placeholderCount(trimmed) > 0) return 'formula';
    if (trimmed.length <= 5 && !trimmed.contains(' ')) return 'token';
    return 'phrase';
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

  static String _exampleSurfaceFamily(String sentence) {
    switch (GrammarExampleQualityAssessor.surfaceFamilyForSentence(sentence)) {
      case GrammarExampleSurfaceFamily.dialogue:
        return 'dialogue';
      case GrammarExampleSurfaceFamily.question:
        return 'question';
      case GrammarExampleSurfaceFamily.statement:
        return 'statement';
    }
  }

  static bool _hasSimilarSentenceEnding(String a, String b) {
    final left = a.trim();
    final right = b.trim();
    if (left.isEmpty || right.isEmpty) return false;
    final endings = <String>[
      'どちらですか',
      'どこですか',
      '何ですか',
      'ですか',
      'ますか',
      'です',
      'ます',
      'なら',
    ];
    for (final ending in endings) {
      if (left.endsWith(ending) && right.endsWith(ending)) {
        return true;
      }
    }
    return false;
  }

  static List<String> _uniqueShuffled(List<String> values) {
    final list = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    list.shuffle();
    return list;
  }

  static String _normalizeStem(String input) {
    return input.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _normalizePattern(String input) {
    return input
        .replaceAll(RegExp(r'[\s\u3000\(\)\[\]{}<>]'), '')
        .toLowerCase();
  }

  static String _localizedPointMeaning(
    GrammarPoint point,
    AppLanguage language,
  ) {
    switch (language) {
      case AppLanguage.vi:
        return (point.meaningVi ?? point.meaning).trim();
      case AppLanguage.en:
        return resolveEnglishGrammarMeaning(
          meaningEn: point.meaningEn,
          titleEn: point.titleEn,
          connectionEn: point.connectionEn,
          connection: point.connection,
          grammarPoint: point.grammarPoint,
        );
      case AppLanguage.ja:
        return point.meaning.trim().isEmpty
            ? point.grammarPoint
            : point.meaning.trim();
    }
  }

  static String _localizedPatternLabel(
    GrammarPoint point,
    AppLanguage language,
  ) {
    switch (language) {
      case AppLanguage.vi:
        return point.grammarPoint.trim();
      case AppLanguage.en:
        return resolveEnglishGrammarLabel(
          titleEn: point.titleEn,
          meaningEn: point.meaningEn,
          connectionEn: point.connectionEn,
          connection: point.connection,
          grammarPoint: point.grammarPoint,
        );
      case AppLanguage.ja:
        return point.grammarPoint.trim();
    }
  }

  static String _localizedPatternFormula(
    GrammarPoint point,
    AppLanguage language,
  ) {
    switch (language) {
      case AppLanguage.vi:
        return point.grammarPoint.trim();
      case AppLanguage.en:
        final rawPattern = point.grammarPoint.trim();
        if (rawPattern.isNotEmpty &&
            !containsVietnameseGrammarText(rawPattern)) {
          return normalizeGrammarStructureEn(rawPattern);
        }
        return resolveEnglishGrammarConnection(
          connectionEn: point.connectionEn,
          connection: point.connection,
          grammarPoint: point.grammarPoint,
          titleEn: point.titleEn,
          meaningEn: point.meaningEn,
        );
      case AppLanguage.ja:
        return point.grammarPoint.trim();
    }
  }

  static String _localizedPointExplanation(
    GrammarPoint point,
    AppLanguage language,
  ) {
    switch (language) {
      case AppLanguage.vi:
        return (point.explanationVi ?? point.explanation).trim();
      case AppLanguage.en:
        return resolveEnglishGrammarExplanation(
          explanationEn: point.explanationEn,
          explanation: point.explanation,
          label: _localizedPatternLabel(point, language),
        );
      case AppLanguage.ja:
        return point.explanation.trim();
    }
  }

  static String _localizedExampleTranslation(
    GrammarExample example,
    AppLanguage language,
  ) {
    switch (language) {
      case AppLanguage.vi:
        return (example.translationVi ?? example.translation).trim();
      case AppLanguage.en:
        return resolveEnglishGrammarExampleTranslation(
          japanese: example.japanese,
          translationEn: example.translationEn,
          translation: example.translation,
        );
      case AppLanguage.ja:
        return example.translation.trim();
    }
  }

  static String _tr(
    AppLanguage language, {
    required String en,
    required String vi,
    required String ja,
  }) {
    switch (language) {
      case AppLanguage.en:
        return en;
      case AppLanguage.vi:
        return vi;
      case AppLanguage.ja:
        return ja;
    }
  }
}

class _CorruptedSentence {
  const _CorruptedSentence({
    required this.wrongSentence,
    required this.correctSentence,
    required this.replacement,
    required this.replacementPoint,
    required this.alternativePoints,
  });

  final String wrongSentence;
  final String correctSentence;
  final String replacement;
  final GrammarPoint replacementPoint;
  final List<GrammarPoint> alternativePoints;
}
