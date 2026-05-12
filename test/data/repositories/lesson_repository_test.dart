import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonRepository repository;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
    repository = LessonRepository(db, contentDb);
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test(
    'initializeLessonSrs should populate SRS state and mark terms as learned',
    () async {
      // Arrange: Create a lesson and add terms
      const lessonId = 1;
      await db
          .into(db.userLesson)
          .insert(
            UserLessonCompanion.insert(
              id: const Value(lessonId),
              level: 'N5',
              title: 'Test Lesson',
              updatedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrReplace,
          );

      await db
          .into(db.userLessonTerm)
          .insert(
            UserLessonTermCompanion.insert(
              id: const Value(101),
              lessonId: lessonId,
              term: const Value('Term 1'),
              reading: const Value('Reading 1'),
              definition: const Value('Def 1'),
              orderIndex: const Value(1),
              isLearned: const Value(false),
            ),
          );
      await db
          .into(db.userLessonTerm)
          .insert(
            UserLessonTermCompanion.insert(
              id: const Value(102),
              lessonId: lessonId,
              term: const Value('Term 2'),
              reading: const Value('Reading 2'),
              definition: const Value('Def 2'),
              orderIndex: const Value(2),
              isLearned: const Value(false),
            ),
          );

      // Act
      await repository.initializeLessonSrs(lessonId);

      // Assert
      // Check SRS State
      final srsStates = await db.select(db.srsState).get();
      expect(srsStates.length, 2);
      expect(srsStates.any((s) => s.vocabId == 101), true);
      expect(srsStates.any((s) => s.vocabId == 102), true);

      // Check Next Review is recently set
      final now = DateTime.now();
      for (final state in srsStates) {
        // verify nextReviewAt is reasonable (not in far future or past, but explicitly set to 'now' in logic)
        // Since we can't inject 'now' into repo easily without clock abstraction, we check it's close to test's 'now'
        final diff = state.nextReviewAt.difference(now).inSeconds.abs();
        expect(diff < 10, true, reason: 'nextReviewAt should be close to now');
        expect(state.box, 1);
        expect(state.repetitions, 0);
      }

      // Check Terms are Learned
      final terms = await db.select(db.userLessonTerm).get();
      expect(terms.every((t) => t.isLearned), true);
    },
  );

  test(
    'fetchVocabTermsByIds returns correct level from parent lesson',
    () async {
      // Arrange: N4 lesson with one term
      const lessonId = 10;
      await db
          .into(db.userLesson)
          .insert(
            UserLessonCompanion.insert(
              id: const Value(lessonId),
              level: 'N4',
              title: 'N4 Lesson',
              updatedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrReplace,
          );

      await db
          .into(db.userLessonTerm)
          .insert(
            UserLessonTermCompanion.insert(
              id: const Value(201),
              lessonId: lessonId,
              term: const Value('走る'),
              reading: const Value('はしる'),
              definition: const Value('chạy'),
              orderIndex: const Value(1),
            ),
          );

      // Also add an N3 lesson with a term
      const lessonIdN3 = 11;
      await db
          .into(db.userLesson)
          .insert(
            UserLessonCompanion.insert(
              id: const Value(lessonIdN3),
              level: 'N3',
              title: 'N3 Lesson',
              updatedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.insertOrReplace,
          );

      await db
          .into(db.userLessonTerm)
          .insert(
            UserLessonTermCompanion.insert(
              id: const Value(202),
              lessonId: lessonIdN3,
              term: const Value('確認'),
              reading: const Value('かくにん'),
              definition: const Value('xác nhận'),
              orderIndex: const Value(1),
            ),
          );

      // Act
      final results = await repository.fetchVocabTermsByIds([201, 202]);

      // Assert
      expect(results.length, 2);
      final n4Item = results.firstWhere((v) => v.id == 201);
      final n3Item = results.firstWhere((v) => v.id == 202);
      expect(
        n4Item.level,
        'N4',
        reason: 'N4 lesson term must not be misclassified as N5',
      );
      expect(
        n3Item.level,
        'N3',
        reason: 'N3 lesson term must not be misclassified as N5',
      );
    },
  );
}
