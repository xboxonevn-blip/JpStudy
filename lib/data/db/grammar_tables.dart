import 'package:drift/drift.dart';

/// Table to store Grammar Points (Concepts)
/// Based on Bunpro/JLPT data structure
class GrammarPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lessonId => integer().nullable()(); // Linked to UserLesson
  TextColumn get grammarPoint =>
      text().withLength(min: 1, max: 255)(); // e.g. "〜てはいけない"
  TextColumn get titleEn => text().nullable()(); // English Title
  TextColumn get meaning => text()(); // Default meaning
  TextColumn get meaningVi => text().nullable()(); // Vietnamese meaning
  TextColumn get meaningEn => text().nullable()(); // English meaning
  TextColumn get connection => text()(); // e.g. "Verb-て + は + いけない"
  TextColumn get connectionEn => text().nullable()(); // English structure
  TextColumn get explanation => text()(); // Default explanation
  TextColumn get explanationVi => text().nullable()(); // Vietnamese explanation
  TextColumn get explanationEn => text().nullable()(); // English explanation
  TextColumn get jlptLevel =>
      text().withLength(min: 2, max: 2)(); // e.g. "N5", "N4"
  BoolColumn get isLearned => boolean().withDefault(const Constant(false))();
}

/// Table to store Example Sentences for Grammar Points
class GrammarExamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get grammarId =>
      integer().references(GrammarPoints, #id, onDelete: KeyAction.cascade)();
  TextColumn get japanese => text()(); // Full japanese sentence
  TextColumn get translation => text()(); // Default translation
  TextColumn get translationVi => text().nullable()(); // Vietnamese translation
  TextColumn get translationEn => text().nullable()(); // English translation
}

/// Table to store SRS Progress for Grammar
/// Includes "Ghost Review" logic (tracking specific failures)
class GrammarSrsState extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get grammarId =>
      integer().references(GrammarPoints, #id, onDelete: KeyAction.cascade)();
  IntColumn get streak =>
      integer().withDefault(const Constant(0))(); // Current correct streak
  RealColumn get ease => real().withDefault(
    const Constant(2.5),
  )(); // Legacy ease factor (kept for migration)
  RealColumn get stability => real().withDefault(const Constant(1.0))();
  RealColumn get difficulty => real().withDefault(const Constant(5.0))();
  DateTimeColumn get nextReviewAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  // Ghost Review Logic
  // If > 0, this item is a "Ghost" generated from a mistake.
  // Reviews of ghosts don't advance the main SRS interval as much, or are auxiliary.
  IntColumn get ghostReviewsDue => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {grammarId},
  ];
}

/// Table to store Grammar Questions (Exercises)
/// Used for Practice Mode (Fill-in-blank, Multiple Choice, etc.)
class GrammarQuestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get grammarId =>
      integer().references(GrammarPoints, #id, onDelete: KeyAction.cascade)();

  // Type of question: 'fill_blank', 'multiple_choice', 'reorder', 'translate'
  TextColumn get type => text().withLength(min: 1, max: 50)();

  // The question prompt (e.g. "Complete the sentence", or the sentence with blank)
  TextColumn get question => text()();

  // The correct answer string
  TextColumn get correctAnswer => text()();

  // JSON list of options for multiple choice (optional)
  TextColumn get optionsJson => text().nullable()();

  // JSON list of correct order indices for reordering (optional)
  TextColumn get correctOrderJson => text().nullable()(); // e.g. "[0, 2, 1, 3]"

  // Explanation/Hint
  TextColumn get explanation => text().nullable()();
}
