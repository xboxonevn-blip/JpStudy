import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/vocab/providers/vocab_home_provider.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeVocabRepo extends LessonRepository {
  _FakeVocabRepo({this.bank = const {}, this.dueTerms = const []})
    : super(
        AppDatabase(executor: NativeDatabase.memory()),
        ContentDatabase(executor: NativeDatabase.memory()),
      );

  /// level → items for hajimete series
  final Map<String, List<VocabItem>> bank;

  /// level → items for minna series (lesson-range queries)
  final Map<String, List<VocabItem>> minnaBank = const {};

  /// Simulated due terms for allDueTermsProvider
  final List<UserLessonTermData> dueTerms;

  @override
  Future<List<VocabItem>> getVocabByLevelAndSeries(
    String level,
    String series,
  ) async {
    if (series == 'minna') return minnaBank[level] ?? const [];
    return bank[level] ?? const [];
  }

  @override
  Future<List<VocabItem>> getVocabByLessonRange(
    String level, {
    required int startLesson,
    required int endLesson,
    String series = 'minna',
  }) async {
    return minnaBank[level] ?? const [];
  }

  @override
  Future<List<UserLessonTermData>> fetchAllDueTerms() async => dueTerms;

  @override
  Future<int> countVocabByLevelAndSeries(String level, String series) async {
    if (series == 'minna') {
      return minnaBank[level]?.length ?? 0;
    }
    return bank[level]?.length ?? 0;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

VocabItem _makeVocab(int id, String level) => VocabItem(
  id: id,
  term: 'term$id',
  reading: 'よみ$id',
  meaning: 'meaning $id',
  meaningEn: 'meaning $id',
  level: level,
);

UserLessonTermData _makeDueTerm(int id) => UserLessonTermData(
  id: id,
  lessonId: 1,
  term: 'term$id',
  reading: 'よみ$id',
  definition: 'def $id',
  definitionEn: 'def $id',
  mnemonicVi: '',
  mnemonicEn: '',
  kanjiMeaning: '',
  isStarred: false,
  isLearned: false,
  orderIndex: id,
);

ProviderContainer _buildContainer({
  required LessonRepository repo,
  StudyLevel level = StudyLevel.n5,
  DateTime? nextReview,
  int? dueCount,
}) {
  return ProviderContainer(
    overrides: [
      studyLevelProvider.overrideWith((ref) => level),
      lessonRepositoryProvider.overrideWithValue(repo),
      dashboardProvider.overrideWith(
        (ref) => Stream.value(
          DashboardState(
            streak: 0,
            todayXp: 0,
            vocabDue: dueCount ?? (repo as _FakeVocabRepo).dueTerms.length,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
        ),
      ),
      allDueTermsProvider.overrideWith((ref) async {
        return (repo as _FakeVocabRepo).dueTerms;
      }),
      vocabNextReviewSnapshotProvider.overrideWith((ref) => nextReview),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('vocabHomeSectionProvider', () {
    test('returns zero dueCount when no terms are due', () async {
      final container = _buildContainer(repo: _FakeVocabRepo());
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      expect(result.dueCount, equals(0));
    });

    test('dueCount reflects allDueTermsProvider result', () async {
      final due = List.generate(7, _makeDueTerm);
      final container = _buildContainer(
        repo: _FakeVocabRepo(dueTerms: due),
        dueCount: due.length,
      );
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      expect(result.dueCount, equals(7));
    });

    test('selectedLevelCode follows studyLevelProvider', () async {
      final container = _buildContainer(
        repo: _FakeVocabRepo(),
        level: StudyLevel.n4,
      );
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      expect(result.selectedLevelCode, equals('N4'));
    });

    test('nextReview is surfaced when provider yields a date', () async {
      final reviewDate = DateTime(2026, 4, 1, 9);
      final container = _buildContainer(
        repo: _FakeVocabRepo(),
        nextReview: reviewDate,
      );
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      expect(result.nextReview, equals(reviewDate));
    });

    test('nextReview is null when provider yields null', () async {
      final container = _buildContainer(repo: _FakeVocabRepo());
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      expect(result.nextReview, isNull);
    });

    test('liveTracks contains all interactive JLPT lanes', () async {
      final container = _buildContainer(repo: _FakeVocabRepo());
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      expect(result.liveTracks.length, equals(7));
      expect(
        result.liveTracks.map((t) => t.key),
        containsAll([
          'n5_core',
          'n5_minna',
          'n4_core',
          'n4_minna',
          'n3_core',
          'n2_core',
          'n1_core',
        ]),
      );
    });

    test(
      'previewTracks only contains future non-JLPT roadmap entries',
      () async {
        final container = _buildContainer(repo: _FakeVocabRepo());
        addTearDown(container.dispose);

        final result = await container.read(vocabHomeSectionProvider.future);

        expect(result.previewTracks.length, equals(1));
        expect(result.previewTracks.single.key, equals('se_core'));
      },
    );

    test('n5_core track is interactive when data exists', () async {
      final n5 = List.generate(10, (i) => _makeVocab(i + 1, 'N5'));
      final container = _buildContainer(repo: _FakeVocabRepo(bank: {'N5': n5}));
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      final n5Core = result.liveTracks.firstWhere((t) => t.key == 'n5_core');
      expect(n5Core.termCount, equals(10));
      expect(n5Core.isInteractive, isTrue);
      expect(n5Core.isPreview, isFalse);
    });

    test('n5_core track is not interactive when empty', () async {
      final container = _buildContainer(repo: _FakeVocabRepo());
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      final n5Core = result.liveTracks.firstWhere((t) => t.key == 'n5_core');
      expect(n5Core.termCount, equals(0));
      expect(n5Core.isInteractive, isFalse);
    });

    test('minna tracks are marked as companion', () async {
      final container = _buildContainer(repo: _FakeVocabRepo());
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      for (final track in result.liveTracks.where(
        (t) => t.key.contains('minna'),
      )) {
        expect(
          track.isCompanion,
          isTrue,
          reason: '${track.key} should be companion',
        );
      }
    });

    test('core tracks are not companion', () async {
      final container = _buildContainer(repo: _FakeVocabRepo());
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      for (final track in result.liveTracks.where(
        (t) => t.key.contains('core'),
      )) {
        expect(
          track.isCompanion,
          isFalse,
          reason: '${track.key} should not be companion',
        );
      }
    });

    test(
      'recommendedTrack returns the track matching selectedLevelCode',
      () async {
        final n5 = List.generate(5, (i) => _makeVocab(i + 1, 'N5'));
        final container = _buildContainer(
          repo: _FakeVocabRepo(bank: {'N5': n5}),
          level: StudyLevel.n5,
        );
        addTearDown(container.dispose);

        final result = await container.read(vocabHomeSectionProvider.future);

        final recommended = result.recommendedTrack;
        expect(recommended, isNotNull);
        expect(recommended!.levelCode, equals('N5'));
        expect(recommended.isCompanion, isFalse);
      },
    );

    test('upper JLPT core tracks are interactive when data exists', () async {
      final n3 = List.generate(3, (i) => _makeVocab(200 + i, 'N3'));
      final container = _buildContainer(repo: _FakeVocabRepo(bank: {'N3': n3}));
      addTearDown(container.dispose);

      final result = await container.read(vocabHomeSectionProvider.future);

      final n3Track = result.liveTracks.firstWhere((t) => t.key == 'n3_core');
      expect(n3Track.isInteractive, isTrue);
      expect(n3Track.isPreview, isFalse);
      expect(n3Track.termCount, equals(3));
    });
  });
}
