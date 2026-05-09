import '../daos/learn_dao.dart';
import '../daos/test_dao.dart';
import '../daos/srs_dao.dart';
import '../daos/achievement_dao.dart';
import '../daos/grammar_dao.dart';
import '../daos/mistake_dao.dart';
import '../daos/kanji_srs_dao.dart';
import '../daos/kana_srs_dao.dart';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'settings_tables.dart';
import 'study_tables.dart';
import 'grammar_tables.dart';
import 'mistake_tables.dart';
import 'kanji_tables.dart';
import 'tables.dart';

part 'app_database.g.dart';

class KanaSrsState extends Table {
  TextColumn get kana => text()();
  TextColumn get script => text()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {kana};
}

@DriftDatabase(
  tables: [
    SrsState,
    KanjiSrsState,
    KanaSrsState,
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
    KanaSrsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 29;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedLessons();
      await _createPerformanceIndexes();
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
      if (from < 26) {
        await _createPerformanceIndexes();
      }
      if (from < 27) {
        // Remove duplicate srs_state rows (keep the row with the highest id
        // for each vocab_id â€” most recently inserted, most up-to-date state).
        await customStatement(
          'DELETE FROM srs_state '
          'WHERE id NOT IN ('
          '  SELECT MAX(id) FROM srs_state GROUP BY vocab_id'
          ')',
        );
        // Add UNIQUE index to enforce one SRS state row per vocab term.
        // Makes initializeSrsState (INSERT OR IGNORE) truly idempotent.
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_srs_state_vocab_unique '
          'ON srs_state(vocab_id)',
        );
        // Same for grammar_srs_state â€” one row per grammar point.
        await customStatement(
          'DELETE FROM grammar_srs_state '
          'WHERE id NOT IN ('
          '  SELECT MAX(id) FROM grammar_srs_state GROUP BY grammar_id'
          ')',
        );
        await customStatement(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_grammar_srs_state_grammar_unique '
          'ON grammar_srs_state(grammar_id)',
        );
      }
      if (from < 28) {
        await _createSessionIndexes();
      }
      if (from < 29) {
        await migrator.createTable(kanaSrsState);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_kana_srs_due_at ON kana_srs_state(due_at)',
        );
      }
    },
    beforeOpen: (details) async {
      // Only reseed on first install or after an upgrade â€” on routine opens
      // all 75 INSERT OR IGNORE calls are guaranteed no-ops and waste
      // 75 round-trips to the background isolate on every app start.
      if (details.wasCreated || details.hadUpgrade) {
        await _seedLessons();
      }
    },
  );

  Future<void> _createPerformanceIndexes() async {
    // SRS due-date indexes â€” every dashboard heartbeat scans these columns.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_srs_next_review ON srs_state(next_review_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_srs_next_review ON grammar_srs_state(next_review_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_kanji_srs_next_review ON kanji_srs_state(next_review_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_kana_srs_due_at ON kana_srs_state(due_at)',
    );
    // Grammar lookup indexes â€” queried by level on every practice screen open.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_points_jlpt ON grammar_points(jlpt_level)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_points_lesson ON grammar_points(lesson_id)',
    );
    // FK indexes SQLite does not create automatically.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_examples_grammar ON grammar_examples(grammar_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_lesson_term_lesson ON user_lesson_term(lesson_id)',
    );
    // Ghost reviews â€” queried by ghost_reviews_due > 0 for ghost session load.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_grammar_srs_ghost ON grammar_srs_state(ghost_reviews_due)',
    );
    await _createSessionIndexes();
  }

  Future<void> _createSessionIndexes() async {
    // Learn/test session lookup by lesson â€” every lesson screen open hits these.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_learn_sessions_lesson '
      'ON learn_sessions(lesson_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_test_sessions_lesson '
      'ON test_sessions(lesson_id)',
    );
    // Answer FK indexes â€” session answer lookups without full-table scans.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_learn_answers_session '
      'ON learn_answers(session_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_test_answers_session '
      'ON test_answers(session_id)',
    );
    // UserProgress day lookup â€” scanned on every dashboard and XP update.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_user_progress_day ON user_progress(day)',
    );
    // UserMistakes top-N by type â€” weakness radar and mistake screen both
    // filter by type + order by last_mistake_at + wrong_count DESC.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_user_mistakes_type_date '
      'ON user_mistakes(type, last_mistake_at DESC)',
    );
    // Attempt + AttemptAnswer indexes â€” ghost grammar query filters on these.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attempt_mode ON attempt(mode)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attempt_answer_attempt '
      'ON attempt_answer(attempt_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_attempt_answer_question_correct '
      'ON attempt_answer(question_id, is_correct)',
    );
  }

  Future<void> _seedLessons() async {
    // batch() sends all 75 inserts in a single round-trip to the DB isolate
    // instead of 75 sequential message-passing calls.
    final now = DateTime.now();
    await batch((b) {
      for (final spec in _lessonSeedSpecs) {
        for (var i = spec.startLesson; i <= spec.endLesson; i++) {
          b.insert(
            userLesson,
            UserLessonCompanion.insert(
              id: Value(i),
              level: spec.level,
              title: 'Lesson $i',
              description: const Value(''),
              isPublic: const Value(true),
              isCustomTitle: const Value(false),
              updatedAt: Value(now),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
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
