import '../../../core/app_language.dart';
import '../../../data/db/app_database.dart';
import 'grammar_question_generator.dart';

class GrammarPracticeBank {
  const GrammarPracticeBank._();

  static List<GeneratedQuestion> buildGenerated({
    required List<({GrammarPoint point, List<GrammarExample> examples})>
    details,
    required List<GrammarPoint> allPoints,
    required AppLanguage language,
  }) {
    return GrammarQuestionGenerator.generateQuestions(
      details,
      allPoints: allPoints,
      language: language,
    );
  }
}
