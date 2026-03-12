import 'question_type.dart';

class LearnConfig {
  const LearnConfig({
    this.questionCount = 20,
    this.enabledTypes = const [
      QuestionType.multipleChoice,
      QuestionType.trueFalse,
      QuestionType.fillBlank,
    ],
    this.shuffleQuestions = true,
    this.enableHints = true,
    this.showCorrectAnswer = true,
  });

  final int questionCount;
  final List<QuestionType> enabledTypes;
  final bool shuffleQuestions;
  final bool enableHints;
  final bool showCorrectAnswer;

  LearnConfig copyWith({
    int? questionCount,
    List<QuestionType>? enabledTypes,
    bool? shuffleQuestions,
    bool? enableHints,
    bool? showCorrectAnswer,
  }) {
    return LearnConfig(
      questionCount: questionCount ?? this.questionCount,
      enabledTypes: enabledTypes ?? this.enabledTypes,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      enableHints: enableHints ?? this.enableHints,
      showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
    );
  }

  LearnConfig normalized({required int maxQuestions}) {
    final safeMax = maxQuestions < 1 ? 1 : maxQuestions;
    final safeTypes = enabledTypes.isEmpty
        ? const [QuestionType.multipleChoice]
        : enabledTypes;
    return copyWith(
      questionCount: questionCount.clamp(1, safeMax),
      enabledTypes: safeTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionCount': questionCount,
      'enabledTypes': enabledTypes.map((type) => type.name).toList(),
      'shuffleQuestions': shuffleQuestions,
      'enableHints': enableHints,
      'showCorrectAnswer': showCorrectAnswer,
    };
  }

  static LearnConfig fromJson(Map<String, dynamic> json) {
    final parsedTypes = (json['enabledTypes'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .map(
          (value) => QuestionType.values.firstWhere(
            (type) => type.name == value,
            orElse: () => QuestionType.multipleChoice,
          ),
        )
        .toList();

    return LearnConfig(
      questionCount: json['questionCount'] as int? ?? 20,
      enabledTypes: parsedTypes.isEmpty
          ? const [
              QuestionType.multipleChoice,
              QuestionType.trueFalse,
              QuestionType.fillBlank,
            ]
          : parsedTypes,
      shuffleQuestions: json['shuffleQuestions'] as bool? ?? true,
      enableHints: json['enableHints'] as bool? ?? true,
      showCorrectAnswer: json['showCorrectAnswer'] as bool? ?? true,
    );
  }
}
