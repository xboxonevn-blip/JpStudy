import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final events = <String>[];
  final params = <Map<String, Object>?>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add(name);
    params.add(parameters);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('saveTermReview logs an SRS review completion event', () async {
    final fake = _FakeFirebaseAnalytics();
    final repo = LessonRepository(
      db,
      contentDb,
      analyticsService: AnalyticsService(instance: fake, enabled: true),
    );

    await repo.saveTermReview(termId: 301, quality: 3);

    expect(fake.events, ['srs_review_completed']);
    expect(fake.params.single, {
      'item_type': 'vocab',
      'rating': 3,
      'level': 'unknown',
      'interval_days': isA<double>(),
    });
  });

  test(
    'seedGrammarIfEmpty seeds the requested JLPT level when content DB opened on another active level',
    () async {
      SharedPreferences.setMockInitialValues({'onboarding.level': 'N5'});

      await repository.seedGrammarIfEmpty(1, 'N3');

      final points = await repository.fetchGrammarForLevel('N3', 1);
      expect(points, isNotEmpty);
      expect(points.every((item) => item.point.jlptLevel == 'N3'), isTrue);
    },
  );

  test('seedTermsIfEmpty reads upper-level ShinKanzen lesson tags', () async {
    const lessonId = 901;
    await repository.ensureLesson(
      lessonId: lessonId,
      level: 'N2',
      title: 'N2 source-aware test',
    );
    for (var i = 0; i < 55; i++) {
      await contentDb
          .into(contentDb.vocab)
          .insert(
            VocabCompanion.insert(
              id: Value(100000 + i),
              term: '別語$i',
              reading: Value('べつご$i'),
              meaning: 'nhiễu $i',
              series: const Value('ShinKanzen'),
              level: 'N2',
              tags: const Value('shinkanzen_999,tanos,jlpt-vocab'),
            ),
          );
    }
    await contentDb
        .into(contentDb.vocab)
        .insert(
          VocabCompanion.insert(
            id: const Value(100901),
            term: '相変わらず',
            reading: const Value('あいかわらず'),
            meaning: 'như mọi khi; vẫn như cũ',
            meaningEn: const Value('as ever; as usual; the same'),
            series: const Value('ShinKanzen'),
            level: 'N2',
            tags: const Value('shinkanzen_901,tanos,jlpt-vocab'),
          ),
        );

    await repository.seedTermsIfEmpty(lessonId, 'N2');

    final terms = await repository.fetchTerms(lessonId);
    expect(terms, hasLength(1));
    expect(terms.single.term, '相変わらず');
    expect(terms.single.definition, 'như mọi khi; vẫn như cũ');
    expect(terms.single.definitionEn, 'as ever; as usual; the same');
  });

  test(
    'seedTermsIfEmpty loads canonical lesson vocab for every JLPT level',
    () async {
      const cases = [
        (level: 'N5', lessonId: 1, expectedTerm: '私'),
        (level: 'N4', lessonId: 26, expectedTerm: '見ます'),
        (level: 'N3', lessonId: 1, expectedTerm: '愛'),
        (level: 'N2', lessonId: 1, expectedTerm: 'あいかわらず'),
        (level: 'N1', lessonId: 1, expectedTerm: '嗚呼'),
      ];

      for (final item in cases) {
        await db.delete(db.userLessonTerm).go();
        await db.delete(db.userLesson).go();
        await repository.ensureLesson(
          lessonId: item.lessonId,
          level: item.level,
          title: '${item.level} lesson ${item.lessonId}',
        );
        await repository.seedTermsIfEmpty(item.lessonId, item.level);

        final terms = await repository.fetchTerms(item.lessonId);
        expect(terms, isNotEmpty, reason: '${item.level} lesson should load');
        expect(terms.first.term, item.expectedTerm);
        expect(
          terms.every((term) => term.definition.trim().isNotEmpty),
          isTrue,
          reason: '${item.level} terms should have Vietnamese definitions',
        );
      }
    },
  );

  test(
    'curriculum storage lesson IDs keep same-number levels separate',
    () async {
      final n5StorageId = LessonRepository.curriculumStorageLessonId('N5', 1);
      final n3StorageId = LessonRepository.curriculumStorageLessonId('N3', 1);

      expect(n5StorageId, isNot(n3StorageId));

      await repository.ensureLesson(
        lessonId: n5StorageId,
        level: 'N5',
        title: 'N5 lesson 1',
      );
      await repository.seedTermsIfEmpty(n5StorageId, 'N5', sourceLessonId: 1);

      await repository.ensureLesson(
        lessonId: n3StorageId,
        level: 'N3',
        title: 'N3 lesson 1',
      );
      await repository.seedTermsIfEmpty(n3StorageId, 'N3', sourceLessonId: 1);

      final n5Terms = await repository.fetchTerms(n5StorageId);
      final n3Terms = await repository.fetchTerms(n3StorageId);

      expect(n5Terms, isNotEmpty);
      expect(n3Terms, isNotEmpty);
      expect(n5Terms.first.term, '私');
      expect(n3Terms.first.term, '愛');
    },
  );
}
