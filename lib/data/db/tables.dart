import 'package:drift/drift.dart';

class SrsState extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vocabId => integer()();
  IntColumn get box => integer().withDefault(const Constant(1))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  RealColumn get ease => real().withDefault(const Constant(2.5))();
  RealColumn get stability => real().withDefault(const Constant(1.0))();
  RealColumn get difficulty => real().withDefault(const Constant(5.0))();
  IntColumn get lastConfidence => integer().withDefault(
    const Constant(0),
  )(); // 0=unknown, 1=again, 2=hard, 3=good, 4=easy
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {vocabId},
  ];
}

class UserProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get day => dateTime()();
  IntColumn get xp => integer().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  IntColumn get reviewedCount => integer().withDefault(const Constant(0))();
  IntColumn get reviewAgainCount => integer().withDefault(const Constant(0))();
  IntColumn get reviewHardCount => integer().withDefault(const Constant(0))();
  IntColumn get reviewGoodCount => integer().withDefault(const Constant(0))();
  IntColumn get reviewEasyCount => integer().withDefault(const Constant(0))();
}

class Attempt extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mode => text()();
  TextColumn get level => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
  IntColumn get total => integer().nullable()();
}

class AttemptAnswer extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attemptId => integer().references(Attempt, #id)();
  IntColumn get questionId => integer()();
  IntColumn get selectedIndex => integer()();
  BoolColumn get isCorrect => boolean()();
}

class UserLesson extends Table {
  IntColumn get id => integer()();
  TextColumn get level => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  BoolColumn get isPublic => boolean().withDefault(const Constant(true))();
  BoolColumn get isCustomTitle =>
      boolean().withDefault(const Constant(false))();
  IntColumn get learnTermLimit => integer().withDefault(const Constant(0))();
  IntColumn get testQuestionLimit =>
      integer().withDefault(const Constant(12))();
  IntColumn get matchPairLimit => integer().withDefault(const Constant(8))();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserLessonTerm extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get lessonId => integer().references(UserLesson, #id)();
  TextColumn get term => text().withDefault(const Constant(''))();
  TextColumn get reading => text().withDefault(const Constant(''))();
  TextColumn get definition => text().withDefault(const Constant(''))();
  TextColumn get definitionEn =>
      text().withDefault(const Constant(''))(); // English definition
  TextColumn get mnemonicVi =>
      text().withDefault(const Constant(''))(); // Vietnamese Mnemonic
  TextColumn get mnemonicEn =>
      text().withDefault(const Constant(''))(); // English Mnemonic
  TextColumn get kanjiMeaning => text().withDefault(const Constant(''))();
  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();
  BoolColumn get isLearned => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}
