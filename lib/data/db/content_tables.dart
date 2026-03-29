import 'package:drift/drift.dart';

class Vocab extends Table {
  @override
  String get tableName => 'vocab';

  IntColumn get id => integer()();
  TextColumn get term => text()();
  TextColumn get reading => text().nullable()();
  TextColumn get meaning => text()(); // Vietnamese
  TextColumn get meaningEn => text().nullable()(); // English
  TextColumn get kanjiMeaning => text().nullable()();
  // Back-reference to normalized vocab assets for cross-dataset linking.
  TextColumn get sourceVocabId => text().nullable()();
  TextColumn get sourceSenseId => text().nullable()();
  TextColumn get series => text().withDefault(const Constant('minna'))();
  TextColumn get level => text()();
  TextColumn get tags => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class GrammarPoint extends Table {
  @override
  String get tableName => 'grammar_point';

  IntColumn get id => integer()();
  IntColumn get lessonId => integer()(); // Linked to Minna Lesson (1-50)
  TextColumn get title => text()(); // e.g. "N1 は N2 です"
  TextColumn get titleEn =>
      text().nullable()(); // e.g. "N1 is N2 (Noun Sentence)"
  TextColumn get structure => text()(); // Formula (Vietnamese)
  TextColumn get structureEn => text().nullable()(); // Formula (English)
  TextColumn get explanation => text()(); // Vietnamese (Default)
  TextColumn get explanationEn => text().nullable()(); // English
  TextColumn get level => text()(); // N5/N4
  TextColumn get tags => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class GrammarExample extends Table {
  @override
  String get tableName => 'grammar_example';

  IntColumn get id => integer()();
  IntColumn get grammarPointId => integer().references(GrammarPoint, #id)();
  TextColumn get sentence => text()(); // Japanese
  TextColumn get translation => text()(); // Vietnamese (Default)
  TextColumn get translationEn => text().nullable()(); // English

  @override
  Set<Column> get primaryKey => {id};
}

class Question extends Table {
  @override
  String get tableName => 'question';

  IntColumn get id => integer()();
  TextColumn get level => text()();
  TextColumn get prompt => text()();
  TextColumn get choicesJson => text()();
  IntColumn get correctIndex => integer()();
  IntColumn get grammarId => integer().nullable()();
  TextColumn get explanation => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MockTest extends Table {
  @override
  String get tableName => 'mock_test';

  IntColumn get id => integer()();
  TextColumn get level => text()();
  TextColumn get title => text()();
  IntColumn get durationSeconds => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class MockTestSection extends Table {
  @override
  String get tableName => 'mock_test_section';

  IntColumn get id => integer()();
  IntColumn get testId => integer()();
  TextColumn get title => text()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class MockTestQuestionMap extends Table {
  @override
  String get tableName => 'mock_test_question_map';

  IntColumn get id => integer()();
  IntColumn get testId => integer()();
  IntColumn get sectionId => integer()();
  IntColumn get questionId => integer()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProgress extends Table {
  @override
  String get tableName => 'user_progress';

  IntColumn get vocabId => integer().references(Vocab, #id)();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get missedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {vocabId};
}

class Kanji extends Table {
  @override
  String get tableName => 'kanji';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get lessonId => integer()(); // Linked to Minna Lesson (1-50)
  TextColumn get character => text()(); // e.g. "日"
  IntColumn get strokeCount => integer()();
  TextColumn get onyomi => text().nullable()(); // Comma separated
  TextColumn get kunyomi => text().nullable()(); // Comma separated
  TextColumn get meaning => text()(); // Vietnamese
  TextColumn get meaningEn => text().nullable()(); // English
  TextColumn get mnemonicVi => text().nullable()(); // Vietnamese Mnemonic
  TextColumn get mnemonicEn => text().nullable()(); // English Mnemonic
  TextColumn get decompositionJson => text().nullable()(); // Embedded structure
  TextColumn get examplesJson => text()(); // JSON string of examples
  TextColumn get jlptLevel => text()(); // N5/N4
}
