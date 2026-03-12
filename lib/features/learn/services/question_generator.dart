import 'dart:math';

import 'package:jpstudy/core/app_language.dart';

import '../../../data/models/vocab_item.dart';
import '../models/question.dart';
import '../models/question_type.dart';

/// Service to generate questions for Learn Mode
class QuestionGenerator {
  final Random _random = Random();
  static final RegExp _kanaOnlyRegex = RegExp(
    r'^[\u3040-\u309F\u30A0-\u30FF\u30FB\u30FC]+$',
  );

  /// Generate a batch of questions from vocabulary items
  List<Question> generateQuestions({
    required List<VocabItem> items,
    required List<QuestionType> enabledTypes,
    int count = 20,
    AppLanguage language = AppLanguage.en,
    bool shuffleItems = true,
  }) {
    if (items.isEmpty || enabledTypes.isEmpty) return [];

    final questions = <Question>[];
    final candidateItems = List<VocabItem>.from(items);
    if (shuffleItems) {
      candidateItems.shuffle(_random);
    }

    for (int i = 0; i < count && i < candidateItems.length; i++) {
      final item = candidateItems[i];
      final type = enabledTypes[_random.nextInt(enabledTypes.length)];

      final question = _generateQuestion(
        item: item,
        type: type,
        allItems: items,
        language: language,
      );

      if (question != null) {
        questions.add(question);
      }
    }

    return questions;
  }

  /// Generate a single question for a specific item and type
  Question? generateQuestionForItem({
    required VocabItem item,
    required QuestionType type,
    required List<VocabItem> allItems,
    AppLanguage language = AppLanguage.en,
  }) {
    return _generateQuestion(
      item: item,
      type: type,
      allItems: allItems,
      language: language,
    );
  }

  /// Generate questions for a specific round with adaptive difficulty
  List<Question> generateAdaptiveRound({
    required List<VocabItem> items,
    required int round,
    required List<int> weakTermIds,
    AppLanguage language = AppLanguage.en,
  }) {
    // Round 1: All terms as multiple choice (easy)
    // Round 2: Weak terms as fill-in-blank (harder)
    // Round 3+: Mix of types for remaining weak terms

    final targetItems = round == 1
        ? items
        : items.where((item) => weakTermIds.contains(item.id)).toList();

    if (targetItems.isEmpty) return [];

    final questionType = switch (round) {
      1 => QuestionType.multipleChoice,
      2 => QuestionType.fillBlank,
      _ =>
        _random.nextBool()
            ? QuestionType.trueFalse
            : QuestionType.multipleChoice,
    };

    return generateQuestions(
      items: targetItems,
      enabledTypes: [questionType],
      count: targetItems.length,
      language: language,
    );
  }

  Question? _generateQuestion({
    required VocabItem item,
    required QuestionType type,
    required List<VocabItem> allItems,
    required AppLanguage language,
  }) {
    switch (type) {
      case QuestionType.multipleChoice:
        return _generateMultipleChoice(item, allItems, language);
      case QuestionType.trueFalse:
        return _generateTrueFalse(item, allItems, language);
      case QuestionType.fillBlank:
        return _generateFillBlank(item, language);
    }
  }

  Question _generateMultipleChoice(
    VocabItem item,
    List<VocabItem> allItems,
    AppLanguage language,
  ) {
    // Generate 3 wrong options (distractors)
    final distractors = _selectDistractors(item, allItems, count: 3);
    final correctMeaning = item.displayMeaning(language);
    final options = [
      correctMeaning,
      ...distractors.map((d) => d.displayMeaning(language)),
    ]..shuffle(_random);

    return Question(
      id: 'mcq_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: QuestionType.multipleChoice,
      targetItem: item,
      questionText: language.questionMeaningPrompt(item.term),
      correctAnswer: correctMeaning,
      options: options,
    );
  }

  Question _generateTrueFalse(
    VocabItem item,
    List<VocabItem> allItems,
    AppLanguage language,
  ) {
    bool isTrue = _random.nextBool();

    String normalizeMeaning(String value) => value.trim().toLowerCase();

    final correctMeaning = item.displayMeaning(language);
    String shownMeaning = correctMeaning;

    if (!isTrue) {
      // Pick a wrong meaning that is actually different from the correct one.
      final wrongItems = allItems.where((i) => i.id != item.id).toList();
      if (wrongItems.isNotEmpty) {
        wrongItems.shuffle(_random);
        final target = normalizeMeaning(correctMeaning);
        String? candidate;
        for (final wrong in wrongItems) {
          final meaning = wrong.displayMeaning(language);
          if (meaning.trim().isEmpty) {
            continue;
          }
          if (normalizeMeaning(meaning) != target) {
            candidate = meaning;
            break;
          }
        }

        if (candidate != null) {
          shownMeaning = candidate;
        } else {
          // Avoid false negatives when meanings collide.
          isTrue = true;
          shownMeaning = correctMeaning;
        }
      } else {
        isTrue = true;
        shownMeaning = correctMeaning;
      }
    }

    return Question(
      id: 'tf_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: QuestionType.trueFalse,
      targetItem: item,
      questionText: language.questionTrueFalsePrompt(item.term, shownMeaning),
      correctAnswer: isTrue ? 'true' : 'false',
      isStatementTrue: isTrue,
    );
  }

  Question _generateFillBlank(VocabItem item, AppLanguage language) {
    // Ask for meaning or reading
    var askForMeaning = _random.nextBool();
    if (!askForMeaning && _isKanaOnly(item.term)) {
      askForMeaning = true;
    }
    if (askForMeaning) {
      final answer = item.displayMeaning(language);
      return Question(
        id: 'fb_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: QuestionType.fillBlank,
        targetItem: item,
        questionText: language.questionMeaningPrompt(item.term),
        correctAnswer: answer,
        expectsReading: false,
        hint: answer.isNotEmpty ? '${answer[0]}...' : null,
      );
    } else {
      return Question(
        id: 'fb_${item.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: QuestionType.fillBlank,
        targetItem: item,
        questionText: language.questionReadingPrompt(item.term),
        correctAnswer: item.reading ?? item.term,
        expectsReading: true,
        hint: item.reading?.isNotEmpty == true
            ? '${item.reading![0]}...'
            : null,
      );
    }
  }

  bool _isKanaOnly(String term) {
    final value = term.trim();
    if (value.isEmpty) return false;
    return _kanaOnlyRegex.hasMatch(value);
  }

  /// Select distractor items for multiple choice (similar difficulty/category)
  List<VocabItem> _selectDistractors(
    VocabItem target,
    List<VocabItem> allItems, {
    int count = 3,
  }) {
    // Filter out the target item
    final candidates = allItems.where((item) => item.id != target.id).toList();

    if (candidates.length <= count) {
      return candidates;
    }

    // Prefer items from same level/category for harder distractors
    final sameLevel = candidates
        .where((item) => item.level == target.level)
        .toList();

    final selected = <VocabItem>[];
    final source = sameLevel.length >= count ? sameLevel : candidates;

    source.shuffle(_random);
    selected.addAll(source.take(count));

    return selected;
  }
}
