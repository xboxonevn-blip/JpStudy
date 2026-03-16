import '../daos/learn_dao.dart';
import '../daos/test_dao.dart';
import '../daos/srs_dao.dart';
import '../daos/achievement_dao.dart';
import '../daos/grammar_dao.dart';
import '../daos/mistake_dao.dart';
import '../daos/kanji_srs_dao.dart';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'settings_tables.dart';
import 'study_tables.dart';
import 'grammar_tables.dart';
import 'mistake_tables.dart';
import 'kanji_tables.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SrsState,
    KanjiSrsState,
    UserProgress,
    Attempt,
    AttemptAnswer,
    // Grammar Tables
    GrammarPoints,
    GrammarExamples,
    GrammarSrsState,
    GrammarQuestions,
    UserLesson,

    UserLessonTerm,
    // Study Tables
    LearnSessions,
    LearnAnswers,
    TestSessions,
    TestAnswers,
    Achievements,
    // Settings Tables
    FlashcardSettings,
    LearnSettings,
    TestSettings,
    // Mistake Bank
    UserMistakes,
  ],
  daos: [
    LearnDao,
    TestDao,
    AchievementDao,
    SrsDao,
    GrammarDao,
    MistakeDao,
    KanjiSrsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 25;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedLessons();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(userLesson);
        await migrator.createTable(userLessonTerm);
      }
      if (from < 3) {
        await migrator.addColumn(userLesson, userLesson.isCustomTitle);
      }
      if (from < 4) {
        await _removeImagePathColumn(migrator);
      }
      if (from < 5) {
        await migrator.addColumn(userLessonTerm, userLessonTerm.isStarred);
        await migrator.addColumn(userLessonTerm, userLessonTerm.isLearned);
        await customStatement(
          "UPDATE user_lesson_term "
          "SET is_learned = CASE "
          "WHEN TRIM(definition) <> '' THEN 1 ELSE 0 END",
        );
      }
      if (from < 6) {
        await customStatement(
          "INSERT INTO srs_state "
          "(vocab_id, box, repetitions, ease, last_reviewed_at, next_review_at) "
          "SELECT id, 1, 0, 2.5, CURRENT_TIMESTAMP, datetime(CURRENT_TIMESTAMP, '+1 day') "
          "FROM user_lesson_term "
          "WHERE is_learned = 1 "
          "AND id NOT IN (SELECT vocab_id FROM srs_state)",
        );
      }
      if (from < 7) {
        await migrator.addColumn(userLesson, userLesson.tags);
      }
      if (from < 8) {
        await migrator.addColumn(userLesson, userLesson.learnTermLimit);
        await migrator.addColumn(userLesson, userLesson.testQuestionLimit);
        await migrator.addColumn(userLesson, userLesson.matchPairLimit);
        await migrator.addColumn(userProgress, userProgress.reviewedCount);
        await migrator.addColumn(userProgress, userProgress.reviewAgainCount);
        await migrator.addColumn(userProgress, userProgress.reviewHardCount);
        await migrator.addColumn(userProgress, userProgress.reviewGoodCount);
        await migrator.addColumn(userProgress, userProgress.reviewEasyCount);
      }
      if (from < 9) {
        await migrator.addColumn(userLessonTerm, userLessonTerm.kanjiMeaning);
      }
      if (from < 10) {
        await migrator.createTable(learnSessions);
        await migrator.createTable(learnAnswers);
        await migrator.createTable(testSessions);
        await migrator.createTable(testAnswers);
        await migrator.createTable(achievements);
      }
      if (from < 11) {
        await _safeAddColumn(migrator, srsState, srsState.lastConfidence);
        await migrator.createTable(flashcardSettings);
        await migrator.createTable(learnSettings);
        await migrator.createTable(testSettings);
      }
      if (from < 12) {
        await migrator.createTable(grammarPoints);
        await migrator.createTable(grammarExamples);
        await migrator.createTable(grammarSrsState);
      }
      if (from < 13) {
        await _safeAddColumn(migrator, grammarPoints, grammarPoints.meaningVi);
        await _safeAddColumn(
          migrator,
          grammarPoints,
          grammarPoints.explanationVi,
        );
        await _safeAddColumn(
          migrator,
          grammarExamples,
          grammarExamples.translationVi,
        );
      }
      if (from < 14) {
        await _seedLessons();
      }
      if (from < 15) {
        await _safeAddColumn(
          migrator,
          userLessonTerm,
          userLessonTerm.definitionEn,
        );
      }
      if (from < 16) {
        await _safeAddColumn(migrator, grammarPoints, grammarPoints.lessonId);
      }
      if (from < 18) {
        await _safeAddColumn(migrator, grammarPoints, grammarPoints.meaningEn);
        await _safeAddColumn(
          migrator,
          grammarPoints,
          grammarPoints.explanationEn,
        );
        await _safeAddColumn(
          migrator,
          grammarExamples,
          grammarExamples.translationEn,
        );
      }
      if (from < 19) {
        // Force resync English definitions for existing vocab
        await customStatement("UPDATE user_lesson_term SET is_learned = 0");
      }
      if (from < 20) {
        await migrator.createTable(grammarQuestions);
      }
      if (from < 21) {
        await migrator.addColumn(grammarPoints, grammarPoints.titleEn);
        await migrator.addColumn(grammarPoints, grammarPoints.connectionEn);
      }
      if (from < 22) {
        await migrator.createTable(userMistakes);
      }
      if (from < 23) {
        await _safeAddColumn(
          migrator,
          userLessonTerm,
          userLessonTerm.mnemonicVi,
        );
        await _safeAddColumn(
          migrator,
          userLessonTerm,
          userLessonTerm.mnemonicEn,
        );
        // Optionally force resync to get mnemonics
      }
      if (from < 24) {
        await customStatement(
          "UPDATE user_mistakes "
          "SET last_mistake_at = CAST(strftime('%s', last_mistake_at) AS INTEGER) * 1000 "
          "WHERE typeof(last_mistake_at) = 'text' "
          "AND strftime('%s', last_mistake_at) IS NOT NULL",
        );
        await customStatement(
          "UPDATE user_mistakes "
          "SET last_mistake_at = CAST(strftime('%s', 'now') AS INTEGER) * 1000 "
          "WHERE typeof(last_mistake_at) = 'text'",
        );
      }
      if (from < 25) {
        await _safeAddColumn(migrator, srsState, srsState.stability);
        await _safeAddColumn(migrator, srsState, srsState.difficulty);
        await _safeAddColumn(
          migrator,
          grammarSrsState,
          grammarSrsState.stability,
        );
        await _safeAddColumn(
          migrator,
          grammarSrsState,
          grammarSrsState.difficulty,
        );
        await _safeAddColumn(migrator, userMistakes, userMistakes.prompt);
        await _safeAddColumn(
          migrator,
          userMistakes,
          userMistakes.correctAnswer,
        );
        await _safeAddColumn(migrator, userMistakes, userMistakes.userAnswer);
        await _safeAddColumn(migrator, userMistakes, userMistakes.source);
        await _safeAddColumn(migrator, userMistakes, userMistakes.extraJson);
        await migrator.createTable(kanjiSrsState);
        await customStatement(
          "UPDATE srs_state SET stability = CASE "
          "WHEN last_reviewed_at IS NOT NULL "
          "THEN max(1, (julianday(next_review_at) - julianday(last_reviewed_at))) "
          "ELSE 1 END",
        );
        await customStatement(
          "UPDATE srs_state SET difficulty = max(1, min(10, 11 - (ease * 3)))",
        );
        await customStatement(
          "UPDATE grammar_srs_state SET stability = CASE "
          "WHEN last_reviewed_at IS NOT NULL "
          "THEN max(1, (julianday(next_review_at) - julianday(last_reviewed_at))) "
          "ELSE 1 END",
        );
        await customStatement(
          "UPDATE grammar_srs_state SET difficulty = max(1, min(10, 11 - (ease * 3)))",
        );
      }
    },
    beforeOpen: (details) async {
      await _seedLessons();
    },
  );

  Future<void> _seedLessons() async {
    for (final spec in _lessonSeedSpecs) {
      for (var i = spec.startLesson; i <= spec.endLesson; i++) {
        await into(userLesson).insert(
          UserLessonCompanion.insert(
            id: Value(i),
            level: spec.level,
            title: 'Lesson $i',
            description: const Value(''),
            isPublic: const Value(true),
            isCustomTitle: const Value(false),
            updatedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    }
  }

  Future<void> _removeImagePathColumn(Migrator migrator) async {
    await customStatement(
      'ALTER TABLE user_lesson_term RENAME TO user_lesson_term_old',
    );
    await migrator.createTable(userLessonTerm);
    await customStatement(
      'INSERT INTO user_lesson_term (id, lesson_id, term, reading, definition, order_index) '
      'SELECT id, lesson_id, term, reading, definition, order_index '
      'FROM user_lesson_term_old',
    );
    await customStatement('DROP TABLE user_lesson_term_old');
  }

  /// Safely add a column, ignoring errors if the column already exists
  Future<void> _safeAddColumn<T extends Object>(
    Migrator migrator,
    TableInfo table,
    Column<T> column,
  ) async {
    try {
      await migrator.addColumn(table, column as GeneratedColumn);
    } catch (e) {
      // Column already exists, ignore the error
      if (!e.toString().contains('duplicate column')) {
        rethrow;
      }
    }
  }
}

class _LessonSeedSpec {
  const _LessonSeedSpec(this.level, this.startLesson, this.endLesson);

  final String level;
  final int startLesson;
  final int endLesson;
}

const _lessonSeedSpecs = <_LessonSeedSpec>[
  _LessonSeedSpec('N5', 1, 25),
  _LessonSeedSpec('N4', 26, 50),
  _LessonSeedSpec('N3', 51, 75),
];

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'jpstudy',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
