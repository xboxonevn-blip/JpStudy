enum JlptReadingQuestionType { mainIdea, detail, inference }

class JlptReadingQuestion {
  const JlptReadingQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final JlptReadingQuestionType type;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class JlptReadingPassage {
  const JlptReadingPassage({
    required this.id,
    required this.title,
    required this.level,
    required this.recommendedMinutes,
    required this.body,
    required this.questions,
  });

  final String id;
  final String title;
  final String level;
  final int recommendedMinutes;
  final String body;
  final List<JlptReadingQuestion> questions;
}
