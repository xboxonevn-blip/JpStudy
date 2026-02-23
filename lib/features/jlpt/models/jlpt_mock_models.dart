import '../models/jlpt_coach_models.dart';

class JlptMockQuestion {
  const JlptMockQuestion({
    required this.id,
    required this.area,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final JlptSkillArea area;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

class JlptMockSection {
  const JlptMockSection({
    required this.id,
    required this.title,
    required this.minutes,
    required this.questions,
  });

  final String id;
  final String title;
  final int minutes;
  final List<JlptMockQuestion> questions;
}
