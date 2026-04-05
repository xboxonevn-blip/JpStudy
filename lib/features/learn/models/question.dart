import '../../../data/models/vocab_item.dart';
import 'question_type.dart';

/// Represents a single question in Learn Mode
class Question {
  static final _alternativesSplitRe = RegExp(
    r'\s*(?:/|／|\bor\b|;|\|)\s*',
    caseSensitive: false,
  );
  final String id;
  final QuestionType type;
  final VocabItem targetItem;
  final String questionText;
  final String correctAnswer;
  final List<String>? options; // For multiple choice
  final bool? isStatementTrue; // For true/false
  final bool? expectsReading; // For fill-in-blank reading questions
  final String? hint; // For fill-in-blank

  const Question({
    required this.id,
    required this.type,
    required this.targetItem,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    this.isStatementTrue,
    this.expectsReading,
    this.hint,
  });

  /// Check if user's answer is correct
  bool checkAnswer(String userAnswer) {
    switch (type) {
      case QuestionType.multipleChoice:
        return userAnswer.toLowerCase().trim() ==
            correctAnswer.toLowerCase().trim();
      case QuestionType.trueFalse:
        return userAnswer.toLowerCase() ==
            (isStatementTrue! ? 'true' : 'false');
      case QuestionType.fillBlank:
        // Fuzzy matching for fill-in-blank with multiple acceptable meanings
        for (final candidate in _splitAlternatives(correctAnswer)) {
          if (_fuzzyMatch(userAnswer, candidate)) {
            return true;
          }
        }
        return false;
    }
  }

  List<String> _splitAlternatives(String target) {
    final raw = target.trim();
    if (raw.isEmpty) return const [''];

    final parts = raw
        .split(_alternativesSplitRe)
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.isEmpty ? [raw] : parts;
  }

  /// Fuzzy match allowing minor typos
  bool _fuzzyMatch(String input, String target) {
    final cleanInput = input.toLowerCase().trim();
    final cleanTarget = target.toLowerCase().trim();

    // Exact match
    if (cleanInput == cleanTarget) return true;

    // Allow edit distance of 1-2 for longer words
    if (cleanTarget.length > 4) {
      final distance = _levenshteinDistance(cleanInput, cleanTarget);
      return distance <= 2;
    }

    return false;
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> dp = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // deletion
          dp[i][j - 1] + 1, // insertion
          dp[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[s1.length][s2.length];
  }
}

/// Result of answering a question
class QuestionResult {
  final Question question;
  final String userAnswer;
  final bool isCorrect;
  final Duration timeTaken;
  final DateTime answeredAt;

  const QuestionResult({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
    required this.timeTaken,
    required this.answeredAt,
  });

  /// XP earned for this answer
  int get xpEarned {
    if (!isCorrect) return 0;

    int baseXP = 5;

    // Speed bonus (answered in < 3 seconds)
    if (timeTaken.inSeconds < 3) {
      baseXP += 2;
    }

    // Difficulty bonus
    baseXP += question.type.difficulty;

    return baseXP;
  }
}
