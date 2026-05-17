import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/services/fsrs_service.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/data/utils/hajimete_catalog_loader.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';
import 'package:jpstudy/features/vocab/models/vocab_review_args.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_detail_screen.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_detail_support.dart';
import 'package:jpstudy/features/vocab/screens/minna_lesson_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/shinkanzen_lesson_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:jpstudy/features/flashcards/widgets/enhanced_flashcard.dart';
import 'package:jpstudy/shared/widgets/confidence_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeVocabLessonRepository extends LessonRepository {
  _FakeVocabLessonRepository({
    required this.bank,
    this.hajimeteChapterTerms = const {},
    Map<int, SrsStateData> srsStates = const {},
  }) : super(
         AppDatabase(executor: NativeDatabase.memory()),
         ContentDatabase(executor: NativeDatabase.memory()),
       ) {
    this.srsStates = Map<int, SrsStateData>.from(srsStates);
  }

  final Map<String, List<VocabItem>> bank;
  final Map<String, List<UserLessonTermData>> hajimeteChapterTerms;
  late final Map<int, SrsStateData> srsStates;
  final levelSeriesCalls = <String>[];
  final lessonRangeCalls = <String>[];
  final countCalls = <String>[];

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    return bank[level] ?? const [];
  }

  @override
  Future<List<VocabItem>> getVocabByLevelAndSeries(
    String level,
    String series,
  ) async {
    levelSeriesCalls.add('$level:$series');
    return bank[level] ?? const [];
  }

  @override
  Future<List<VocabItem>> getVocabByLevelSeriesChapterRange(
    String level, {
    required String series,
    required int startChapter,
    required int endChapter,
  }) async {
    if (series != 'hajimete') {
      return bank[level] ?? const [];
    }
    final terms =
        hajimeteChapterTerms['$level:$startChapter'] ??
        const <UserLessonTermData>[];
    return [
      for (final term in terms)
        VocabItem(
          id: term.id,
          term: term.term,
          reading: term.reading,
          meaning: term.definition,
          meaningEn: term.definitionEn,
          kanjiMeaning: term.kanjiMeaning,
          level: level,
        ),
    ];
  }

  @override
  Future<List<UserLessonTermData>> fetchTermsForHajimeteChapter(
    String level, {
    required int chapterId,
    String? title,
  }) async {
    return hajimeteChapterTerms['$level:$chapterId'] ??
        const <UserLessonTermData>[];
  }

  @override
  Future<Map<int, SrsStateData>> getSrsStatesForIds(List<int> termIds) async {
    return {
      for (final id in termIds)
        if (srsStates.containsKey(id)) id: srsStates[id]!,
    };
  }

  @override
  Future<FsrsReviewResult?> saveTermReview({
    required int termId,
    required int quality,
  }) async {
    final previous = srsStates[termId];
    final nextReviewAt = DateTime.now().add(
      quality <= 2 ? const Duration(minutes: 10) : const Duration(days: 2),
    );
    srsStates[termId] = SrsStateData(
      id: previous?.id ?? termId,
      vocabId: termId,
      box: previous?.box ?? 1,
      repetitions: (previous?.repetitions ?? 0) + 1,
      ease: previous?.ease ?? 2.5,
      stability: previous?.stability ?? 1,
      difficulty: previous?.difficulty ?? 5,
      fsrsState: quality <= 2
          ? FsrsCardState.relearning.dbValue
          : FsrsCardState.review.dbValue,
      fsrsStep: quality <= 2 ? 0 : null,
      lastConfidence: quality,
      lastReviewedAt: DateTime.now(),
      nextReviewAt: nextReviewAt,
    );
    return FsrsReviewResult(
      stability: previous?.stability ?? 1,
      difficulty: previous?.difficulty ?? 5,
      retrievability: 0.9,
      intervalDays: quality <= 2 ? 0.0 : 2.0,
      nextReviewAt: nextReviewAt,
      cardState: quality <= 2 ? FsrsCardState.relearning : FsrsCardState.review,
      step: quality <= 2 ? 0 : null,
    );
  }

  @override
  Future<List<VocabItem>> getVocabByLessonRange(
    String level, {
    required int startLesson,
    required int endLesson,
    String series = 'minna',
  }) async {
    lessonRangeCalls.add('$level:$series:$startLesson-$endLesson');
    if (level == 'N5' && startLesson == 1 && endLesson == 25) {
      return bank['N5'] ?? const [];
    }
    if (level == 'N4' && startLesson == 26 && endLesson == 50) {
      return bank['N4'] ?? const [];
    }
    return bank[level] ?? const [];
  }

  @override
  Future<List<UserLessonTermData>> fetchTermsForLessonRange(
    String level, {
    required int startLesson,
    required int endLesson,
  }) async {
    final items = bank[level] ?? const [];
    return [
      for (var index = 0; index < items.length; index++)
        UserLessonTermData(
          id: items[index].id,
          lessonId: startLesson + (index % ((endLesson - startLesson) + 1)),
          term: items[index].term,
          reading: items[index].reading ?? '',
          definition: items[index].meaning,
          definitionEn: items[index].meaningEn ?? items[index].meaning,
          mnemonicVi: '',
          mnemonicEn: '',
          kanjiMeaning: items[index].kanjiMeaning ?? '',
          isStarred: false,
          isLearned: false,
          orderIndex: index,
        ),
    ];
  }

  @override
  Future<List<LessonMeta>> fetchLessonMeta(String level) async {
    final items = bank[level] ?? const [];
    final range = switch (level) {
      'N5' => (1, 25),
      'N4' => (26, 50),
      'N3' => (1, 28),
      'N2' => (1, 38),
      'N1' => (1, 50),
      _ => (1, items.isEmpty ? 1 : items.length),
    };
    final lessonCount = range.$2 - range.$1 + 1;
    final baseCount = lessonCount == 0 ? 0 : items.length ~/ lessonCount;
    final remainder = lessonCount == 0 ? 0 : items.length % lessonCount;
    return List.generate(lessonCount, (index) {
      final id = range.$1 + index;
      final termCount = baseCount + (index < remainder ? 1 : 0);
      final completedCount = index == 0 && termCount > 0 ? 1 : 0;
      final dueCount = index == 0 && termCount > 1 ? 1 : 0;
      return LessonMeta(
        id: id,
        level: level,
        title: 'Lesson $id',
        isCustomTitle: false,
        tags: '',
        termCount: termCount,
        completedCount: completedCount,
        dueCount: dueCount,
        updatedAt: null,
      );
    });
  }

  @override
  Future<int> countVocabByLevelAndSeries(String level, String series) async {
    countCalls.add('$level:$series');
    return bank[level]?.length ?? 0;
  }
}

VocabItem _item(int id, String term, String level) => VocabItem(
  id: id,
  term: term,
  reading: term,
  meaning: 'meaning $id',
  meaningEn: 'meaning $id',
  level: level,
);

Widget _buildScreen({
  required LessonRepository repo,
  StudyLevel level = StudyLevel.n5,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_prefs),
      studyLevelProvider.overrideWith((ref) => level),
      lessonRepositoryProvider.overrideWithValue(repo),
      dashboardProvider.overrideWith(
        (ref) => Stream.value(
          const DashboardState(
            streak: 0,
            todayXp: 0,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
        ),
      ),
      allDueTermsProvider.overrideWith((ref) async => const []),
      nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: const MaterialApp(home: VocabScreen()),
  );
}

Widget _buildRouterScreen({
  required LessonRepository repo,
  StudyLevel level = StudyLevel.n5,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const VocabScreen()),
      GoRoute(
        path: '/vocab/minna',
        builder: (context, state) => MinnaLessonCatalogScreen(
          levelCode: state.uri.queryParameters['level'] ?? 'N5',
          title: state.uri.queryParameters['title'] ?? 'Minna no Nihongo',
          subtitle: state.uri.queryParameters['subtitle'],
          lessonStart:
              int.tryParse(state.uri.queryParameters['lessonStart'] ?? '') ?? 1,
          lessonEnd:
              int.tryParse(state.uri.queryParameters['lessonEnd'] ?? '') ?? 25,
        ),
      ),
      GoRoute(
        path: '/vocab/hajimete',
        builder: (context, state) => HajimeteChapterCatalogScreen(
          levelCode: state.uri.queryParameters['level'] ?? 'N5',
          title:
              state.uri.queryParameters['title'] ?? 'Hajimete no Nihongo Tango',
          subtitle: state.uri.queryParameters['subtitle'],
        ),
      ),
      GoRoute(
        path: '/vocab/shinkanzen',
        builder: (context, state) => ShinkanzenLessonCatalogScreen(
          levelCode: state.uri.queryParameters['level'] ?? 'N3',
          title: state.uri.queryParameters['title'] ?? 'Shin Kanzen Master',
          subtitle: state.uri.queryParameters['subtitle'],
        ),
      ),
      GoRoute(
        path: '/vocab/hajimete/chapter',
        builder: (context, state) => HajimeteChapterDetailScreen(
          levelCode: state.uri.queryParameters['level'] ?? 'N5',
          chapterId:
              int.tryParse(
                state.uri.queryParameters['chapterId'] ??
                    state.uri.queryParameters['id'] ??
                    '',
              ) ??
              1,
          laneTitle:
              state.uri.queryParameters['title'] ?? 'Hajimete no Nihongo Tango',
        ),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) => Scaffold(
          body: Center(child: Text('LESSON_${state.pathParameters['id']}')),
        ),
      ),
      GoRoute(
        path: '/vocab/review',
        builder: (context, state) => Consumer(
          builder: (context, ref, _) {
            final level = ref.watch(studyLevelProvider);
            final start = state.uri.queryParameters['lessonStart'] ?? '';
            final end = state.uri.queryParameters['lessonEnd'] ?? '';
            final title = state.uri.queryParameters['title'] ?? '';
            return Scaffold(
              body: Center(
                child: Text(
                  'REVIEW_${level?.shortLabel ?? 'NONE'}_${start}_${end}_$title',
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_prefs),
      studyLevelProvider.overrideWith((ref) => level),
      lessonRepositoryProvider.overrideWithValue(repo),
      dashboardProvider.overrideWith(
        (ref) => Stream.value(
          const DashboardState(
            streak: 0,
            todayXp: 0,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
        ),
      ),
      allDueTermsProvider.overrideWith((ref) async => const []),
      nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _pumpCatalog(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(seconds: 2));
  });
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

late SharedPreferences _prefs;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({'app.locale': 'en'});
    _prefs = await SharedPreferences.getInstance();
  });

  test(
    'vocabCatalogProvider counts all tracks without hydrating rows',
    () async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': [_item(1, '?', 'N5')],
          'N4': [_item(2, '?', 'N4')],
          'N3': [_item(3, '?', 'N3')],
          'N2': [_item(4, '?', 'N2')],
          'N1': [_item(5, '?', 'N1')],
        },
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          lessonRepositoryProvider.overrideWithValue(repo),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 0,
                todayXp: 0,
                vocabDue: 0,
                grammarDue: 0,
                kanjiDue: 0,
                vocabMistakeCount: 0,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 0,
              ),
            ),
          ),
          nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(vocabCatalogProvider.future);

      expect(repo.levelSeriesCalls, isEmpty);
      expect(
        repo.countCalls,
        containsAll([
          'N5:hajimete',
          'N4:hajimete',
          'N3:hajimete',
          'N2:hajimete',
          'N1:hajimete',
          'N3:ShinKanzen',
          'N2:ShinKanzen',
          'N1:ShinKanzen',
        ]),
      );
      expect(repo.lessonRangeCalls, contains('N5:minna:1-25'));
      expect(repo.lessonRangeCalls, contains('N4:minna:26-50'));
    },
  );

  test(
    'vocabCatalogProvider unlocks every data-backed catalog program',
    () async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': [_item(1, 'n5', 'N5')],
          'N4': [_item(2, 'n4', 'N4')],
          'N3': [_item(3, 'n3', 'N3')],
          'N2': [_item(4, 'n2', 'N2')],
          'N1': [_item(5, 'n1', 'N1')],
        },
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          lessonRepositoryProvider.overrideWithValue(repo),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 0,
                todayXp: 0,
                vocabDue: 0,
                grammarDue: 0,
                kanjiDue: 0,
                vocabMistakeCount: 0,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 0,
              ),
            ),
          ),
          nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final sections = await container.read(vocabCatalogProvider.future);
      final programsByKey = <String, dynamic>{
        for (final dynamic section in sections)
          for (final dynamic program in section.programs) program.key: program,
      };

      for (final key in const [
        'n5_core',
        'n5_companion',
        'n4_core',
        'n4_companion',
        'n3_core',
        'n3_companion',
        'n2_core',
        'n2_companion',
        'n1_core',
        'n1_companion',
      ]) {
        final dynamic program = programsByKey[key];
        expect(program, isNotNull, reason: key);
        expect(program.isComingSoon, isFalse, reason: key);
        expect(program.isInteractive, isTrue, reason: key);
      }
    },
  );

  test(
    'vocabCatalogProvider falls back to bundled upper-level assets',
    () async {
      final repo = _FakeVocabLessonRepository(bank: const {});
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n3),
          lessonRepositoryProvider.overrideWithValue(repo),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 0,
                todayXp: 0,
                vocabDue: 0,
                grammarDue: 0,
                kanjiDue: 0,
                vocabMistakeCount: 0,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 0,
              ),
            ),
          ),
          nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final sections = await container.read(vocabCatalogProvider.future);
      final programsByKey = <String, dynamic>{
        for (final dynamic section in sections)
          for (final dynamic program in section.programs) program.key: program,
      };

      for (final key in const [
        'n3_core',
        'n3_companion',
        'n2_core',
        'n2_companion',
        'n1_core',
        'n1_companion',
      ]) {
        final dynamic program = programsByKey[key];
        expect(program, isNotNull, reason: key);
        expect(program.termCount, greaterThan(0), reason: key);
        expect(program.isComingSoon, isFalse, reason: key);
        expect(program.isInteractive, isTrue, reason: key);
      }
    },
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'app.locale': 'en',
      'foundations.softSuggest.vocab.shown': true,
    });
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('VocabScreen shows catalog hero and all level sections', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(6, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(7, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(8, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(3, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(2, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildScreen(repo: repo));
    await _pumpCatalog(tester);

    expect(find.byKey(const ValueKey('vocab_catalog_error')), findsNothing);
    expect(find.byKey(const ValueKey('vocab_catalog_hero')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_n5')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_n4')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_n3')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_n2')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_n1')), findsOneWidget);
    expect(find.byKey(const ValueKey('section_se')), findsOneWidget);
    expect(find.text('N5'), findsWidgets);
    expect(find.text('N4'), findsWidgets);
    expect(find.text('N3'), findsWidgets);
    expect(find.text('N2'), findsWidgets);
    expect(find.text('N1'), findsWidgets);
    expect(find.text('SE'), findsWidgets);
    expect(find.byKey(const ValueKey('program_n5_n5_core')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('program_n1_advanced_n1')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('vocab_today_section')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('vocab_today_review_cta')),
      findsOneWidget,
    );
  });

  testWidgets('VocabScreen prioritizes Today section before catalog', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(6, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(6, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(6, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(6, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(6, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildScreen(repo: repo));
    await _pumpCatalog(tester);

    final todayTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('vocab_today_section')),
    );
    final heroTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey('vocab_catalog_hero')),
    );
    expect(todayTopLeft.dy, lessThan(heroTopLeft.dy));
  });

  testWidgets('VocabScreen shows upper-level scope note for N3 level', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {'N3': List.generate(6, (i) => _item(i + 21, 'n3_$i', 'N3'))},
    );

    await tester.pumpWidget(_buildScreen(repo: repo, level: StudyLevel.n3));
    await _pumpCatalog(tester);

    expect(
      find.byKey(const ValueKey('content_draft_quality_note')),
      findsOneWidget,
    );
    expect(find.textContaining('N3+ uses JLPT-focused routes'), findsOneWidget);
  });

  testWidgets(
    'Today section hides companion shortcut when selected level has none',
    (tester) async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': List.generate(4, (i) => _item(i + 1, 'n5_$i', 'N5')),
          'N4': List.generate(4, (i) => _item(i + 11, 'n4_$i', 'N4')),
          'N3': List.generate(4, (i) => _item(i + 21, 'n3_$i', 'N3')),
        },
      );

      await tester.pumpWidget(_buildScreen(repo: repo, level: StudyLevel.n3));
      await _pumpCatalog(tester);

      expect(find.byKey(const ValueKey('vocab_today_section')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('vocab_today_review_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('vocab_today_companion_cta')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Vocab companion track opens Minna catalog flow', (tester) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(5, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(5, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildRouterScreen(repo: repo));
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n5_n5_companion')),
    );
    await _pumpCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('program_n5_n5_companion')));
    await _pumpCatalog(tester);

    expect(find.text('Minna N5'), findsOneWidget);
    expect(find.text('25 lessons'), findsOneWidget);
    expect(find.text('Lesson 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('minna_review_cta')), findsOneWidget);
  });

  testWidgets('Vietnamese catalog does not leak English companion badge', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'app.locale': 'vi'});
    _prefs = await SharedPreferences.getInstance();
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(5, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(5, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildRouterScreen(repo: repo));
    await _pumpCatalog(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n5_n5_companion')),
    );
    await _pumpCatalog(tester);

    expect(find.text('Companion'), findsNothing);
    expect(find.text('Bổ trợ'), findsNWidgets(2));
  });

  testWidgets('Minna catalog lesson card opens lesson detail route', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(30, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(8, (i) => _item(i + 31, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 61, 'n3_$i', 'N3')),
        'N2': List.generate(5, (i) => _item(i + 71, 'n2_$i', 'N2')),
        'N1': List.generate(5, (i) => _item(i + 81, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildRouterScreen(repo: repo));
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n5_n5_companion')),
    );
    await _pumpCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('program_n5_n5_companion')));
    await _pumpCatalog(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('minna_lesson_1')));
    await _pumpCatalog(tester);
    await tester.tap(find.byKey(const ValueKey('minna_lesson_1')));
    await _pumpCatalog(tester);

    expect(find.text('LESSON_1'), findsOneWidget);
  });

  testWidgets('Minna catalog review button opens range review', (tester) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(30, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(8, (i) => _item(i + 31, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 61, 'n3_$i', 'N3')),
        'N2': List.generate(5, (i) => _item(i + 71, 'n2_$i', 'N2')),
        'N1': List.generate(5, (i) => _item(i + 81, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildRouterScreen(repo: repo));
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n5_n5_companion')),
    );
    await _pumpCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('program_n5_n5_companion')));
    await _pumpCatalog(tester);

    await tester.ensureVisible(find.byKey(const ValueKey('minna_review_cta')));
    await _pumpCatalog(tester);
    await tester.tap(find.byKey(const ValueKey('minna_review_cta')));
    await _pumpCatalog(tester);

    expect(
      find.textContaining('REVIEW_N5_1_25_Minna no Nihongo I'),
      findsOneWidget,
    );
  });

  testWidgets('Companion review session shows lesson range metadata in preview', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(5, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(5, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    final router = GoRouter(
      initialLocation:
          '/vocab/review?title=Minna%20no%20Nihongo%20I&subtitle=Track%20dong%20hanh&lessonStart=1&lessonEnd=25',
      routes: [
        GoRoute(
          path: '/vocab/review',
          builder: (context, state) => const TermReviewScreen(
            sessionTitle: 'Minna no Nihongo I',
            sessionSubtitle: 'Track dong hanh',
            lessonStart: 1,
            lessonEnd: 25,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          lessonRepositoryProvider.overrideWithValue(repo),
          allDueTermsProvider.overrideWith(
            (ref) async => [
              UserLessonTermData(
                id: 1,
                lessonId: 1,
                term: '???',
                reading: '???',
                definition: 'eat',
                definitionEn: 'eat',
                mnemonicVi: '',
                mnemonicEn: '',
                kanjiMeaning: '',
                isStarred: false,
                isLearned: false,
                orderIndex: 0,
              ),
            ],
          ),
          nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await _pumpCatalog(tester);

    expect(find.text('Minna no Nihongo I'), findsWidgets);
    expect(find.text('Lessons 1–25'), findsWidgets);
  });

  testWidgets('N2 core track opens Hajimete chapter catalog when data exists', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(3, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(2, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(
      _buildRouterScreen(repo: repo, level: StudyLevel.n2),
    );
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n2_n2_core')),
    );
    await _pumpCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('program_n2_n2_core')));
    await _pumpCatalog(tester);

    expect(find.byType(HajimeteChapterCatalogScreen), findsOneWidget);
  });

  testWidgets('N1 core track opens Hajimete chapter catalog when data exists', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(3, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(4, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(
      _buildRouterScreen(repo: repo, level: StudyLevel.n1),
    );
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n1_n1_core')),
    );
    await _pumpCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('program_n1_n1_core')));
    await _pumpCatalog(tester);

    expect(find.byType(HajimeteChapterCatalogScreen), findsOneWidget);
  });

  testWidgets('Shin Kanzen companion cards show the canonical N3 track', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(3, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(2, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    await tester.pumpWidget(_buildScreen(repo: repo, level: StudyLevel.n3));
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n3_n3_companion')),
    );
    await _pumpCatalog(tester);

    final companionCard = find.byKey(const ValueKey('program_n3_n3_companion'));
    expect(
      find.descendant(of: companionCard, matching: find.text('Shin Kanzen')),
      findsOneWidget,
    );
  });

  testWidgets('Shin Kanzen companion tracks open indexed non-empty catalogs', (
    tester,
  ) async {
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
        'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
        'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
        'N2': List.generate(5, (i) => _item(i + 31, 'n2_$i', 'N2')),
        'N1': List.generate(5, (i) => _item(i + 41, 'n1_$i', 'N1')),
      },
    );

    for (final caseData in const [
      (
        level: StudyLevel.n3,
        cardKey: 'program_n3_n3_companion',
        text: 'Nouns - General 1',
      ),
      (level: StudyLevel.n2, cardKey: 'program_n2_n2_companion', text: '1-74'),
      (level: StudyLevel.n1, cardKey: 'program_n1_n1_companion', text: '1-140'),
    ]) {
      await tester.pumpWidget(
        _buildRouterScreen(repo: repo, level: caseData.level),
      );
      await _pumpCatalog(tester);

      await tester.ensureVisible(find.byKey(ValueKey(caseData.cardKey)));
      await _pumpCatalog(tester);
      await tester.tap(find.byKey(ValueKey(caseData.cardKey)));
      await _pumpCatalog(tester);

      expect(find.byType(ShinkanzenLessonCatalogScreen), findsOneWidget);
      expect(find.textContaining(caseData.text), findsWidgets);
      expect(find.text('0 terms'), findsNothing);
    }
  });

  testWidgets(
    'Companion review screen loads lesson-range terms even when due queue is empty',
    (tester) async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
          'N4': List.generate(4, (i) => _item(i + 11, 'n4_$i', 'N4')),
        },
      );

      final router = GoRouter(
        initialLocation:
            '/vocab/review?title=Minna%20no%20Nihongo%20I&subtitle=Track%20dong%20hanh&lessonStart=1&lessonEnd=25',
        routes: [
          GoRoute(
            path: '/vocab/review',
            builder: (context, state) => const TermReviewScreen(
              sessionTitle: 'Minna no Nihongo I',
              sessionSubtitle: 'Track dong hanh',
              lessonStart: 1,
              lessonEnd: 25,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(_prefs),
            studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
            lessonRepositoryProvider.overrideWithValue(repo),
            allDueTermsProvider.overrideWith(
              (ref) async => const <UserLessonTermData>[],
            ),
            nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await _pumpCatalog(tester);

      expect(find.text('5 terms due'), findsWidgets);
      expect(find.text('Lessons 1–25'), findsWidgets);
    },
  );

  testWidgets(
    'VocabScreen opens Hajimete chapter catalog for active core lane',
    (tester) async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
          'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
          'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
          'N2': List.generate(5, (i) => _item(i + 31, 'n2_$i', 'N2')),
          'N1': List.generate(5, (i) => _item(i + 41, 'n1_$i', 'N1')),
        },
      );

      await tester.pumpWidget(_buildRouterScreen(repo: repo));
      await _pumpCatalog(tester);

      await tester.ensureVisible(
        find.byKey(const ValueKey('program_n5_n5_core')),
      );
      await _pumpCatalog(tester);

      await tester.tap(find.byKey(const ValueKey('program_n5_n5_core')));
      await _pumpCatalog(tester);

      expect(find.byType(HajimeteChapterCatalogScreen), findsOneWidget);
    },
  );

  testWidgets('Hajimete chapter catalog shows saved learned due status', (
    tester,
  ) async {
    final now = DateTime.now();
    final chapterTerms = [
      UserLessonTermData(
        id: 101,
        lessonId: -905001,
        term: '????',
        reading: '????',
        definition: 'greeting',
        definitionEn: 'greeting',
        mnemonicVi: '',
        mnemonicEn: '',
        kanjiMeaning: '',
        isStarred: true,
        isLearned: true,
        orderIndex: 1,
      ),
      UserLessonTermData(
        id: 102,
        lessonId: -905001,
        term: '?????',
        reading: '?????',
        definition: 'thank you',
        definitionEn: 'thank you',
        mnemonicVi: '',
        mnemonicEn: '',
        kanjiMeaning: '',
        isStarred: false,
        isLearned: true,
        orderIndex: 2,
      ),
    ];
    final repo = _FakeVocabLessonRepository(
      bank: {
        'N5': [_item(101, '????', 'N5'), _item(102, '?????', 'N5')],
      },
      hajimeteChapterTerms: {'N5:1': chapterTerms},
      srsStates: {
        101: SrsStateData(
          id: 1,
          vocabId: 101,
          box: 1,
          repetitions: 1,
          ease: 2.5,
          stability: 1,
          difficulty: 5,
          fsrsState: FsrsCardState.review.dbValue,
          fsrsStep: null,
          lastConfidence: 3,
          lastReviewedAt: now.subtract(const Duration(days: 1)),
          nextReviewAt: now.subtract(const Duration(minutes: 5)),
        ),
        102: SrsStateData(
          id: 2,
          vocabId: 102,
          box: 1,
          repetitions: 1,
          ease: 2.5,
          stability: 1,
          difficulty: 5,
          fsrsState: FsrsCardState.review.dbValue,
          fsrsStep: null,
          lastConfidence: 4,
          lastReviewedAt: now.subtract(const Duration(hours: 2)),
          nextReviewAt: now.add(const Duration(days: 2)),
        ),
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          lessonRepositoryProvider.overrideWithValue(repo),
          hajimeteChapterCatalogProvider.overrideWith(
            (ref, args) async => const HajimeteChapterCatalog(
              levelCode: 'N5',
              chapters: [
                HajimeteChapterSummary(
                  chapterId: 1,
                  title: 'Greetings',
                  entryCount: 2,
                  previewTerms: ['????', '?????'],
                  sourceVocabIds: ['hv1', 'hv2'],
                ),
              ],
            ),
          ),
          allDueTermsProvider.overrideWith((ref) async => const []),
          nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const MaterialApp(
          home: HajimeteChapterCatalogScreen(
            levelCode: 'N5',
            title: 'Hajimete no Nihongo Tango',
          ),
        ),
      ),
    );

    await _pumpCatalog(tester);

    expect(
      find.byKey(const ValueKey('hajimete_status_saved_1_1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hajimete_status_learned_1_2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('hajimete_status_due_1_1')),
      findsOneWidget,
    );
  });

  testWidgets('Hajimete review stage locks stage layout and action bar', (
    tester,
  ) async {
    final now = DateTime.now();
    final detail = const HajimeteChapterDetail(
      levelCode: 'N5',
      chapterId: 1,
      title: 'Greetings',
      entries: [
        HajimeteChapterEntry(
          term: '????',
          reading: '????',
          meaningVi: 'ch?o h?i',
          meaningEn: 'greeting',
        ),
      ],
    );
    final item = _item(101, '????', 'N5');
    final userTerm = UserLessonTermData(
      id: 101,
      lessonId: -905001,
      term: '????',
      reading: '????',
      definition: 'greeting',
      definitionEn: 'greeting',
      mnemonicVi: '',
      mnemonicEn: '',
      kanjiMeaning: '',
      isStarred: false,
      isLearned: true,
      orderIndex: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          lessonRepositoryProvider.overrideWithValue(
            _FakeVocabLessonRepository(
              bank: {
                'N5': [item],
              },
            ),
          ),
          hajimeteChapterDetailProvider.overrideWith(
            (ref, arg) async => detail,
          ),
          hajimeteChapterItemsProvider.overrideWith((ref, arg) async => [item]),
          hajimeteChapterDueItemsProvider.overrideWith(
            (ref, arg) async => [item],
          ),
          hajimeteChapterSrsStatesProvider.overrideWith(
            (ref, arg) async => {
              101: SrsStateData(
                id: 1,
                vocabId: 101,
                box: 1,
                repetitions: 1,
                ease: 2.5,
                stability: 1,
                difficulty: 5,
                fsrsState: FsrsCardState.review.dbValue,
                fsrsStep: null,
                lastConfidence: 3,
                lastReviewedAt: now.subtract(const Duration(hours: 4)),
                nextReviewAt: now.subtract(const Duration(minutes: 1)),
              ),
            },
          ),
          hajimeteChapterUserTermsProvider.overrideWith(
            (ref, arg) async => [userTerm],
          ),
          hajimeteKanjiChapterProvider.overrideWith((ref, arg) async => null),
        ],
        child: const MaterialApp(
          home: HajimeteChapterDetailScreen(
            levelCode: 'N5',
            chapterId: 1,
            laneTitle: 'Hajimete no Nihongo Tango',
          ),
        ),
      ),
    );

    await _pumpCatalog(tester);
    await tester.tap(find.text('Review now'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('hajimete_review_stage')), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('hajimete_review_stage')))
          .height,
      460,
    );
    expect(find.byType(ConfidenceRatingWidget), findsOneWidget);
    expect(find.byType(EnhancedFlashcard), findsOneWidget);
  });

  testWidgets(
    'Hajimete review rating advances due queue and keeps stage locked',
    (tester) async {
      final now = DateTime.now();
      final item1 = _item(101, '????', 'N5');
      final item2 = _item(102, '?????', 'N5');
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': [item1, item2],
        },
        srsStates: {
          101: SrsStateData(
            id: 1,
            vocabId: 101,
            box: 1,
            repetitions: 1,
            ease: 2.5,
            stability: 1,
            difficulty: 5,
            fsrsState: FsrsCardState.review.dbValue,
            fsrsStep: null,
            lastConfidence: 3,
            lastReviewedAt: now.subtract(const Duration(hours: 1)),
            nextReviewAt: now.subtract(const Duration(minutes: 5)),
          ),
          102: SrsStateData(
            id: 2,
            vocabId: 102,
            box: 1,
            repetitions: 1,
            ease: 2.5,
            stability: 1,
            difficulty: 5,
            fsrsState: FsrsCardState.review.dbValue,
            fsrsStep: null,
            lastConfidence: 3,
            lastReviewedAt: now.subtract(const Duration(hours: 1)),
            nextReviewAt: now.subtract(const Duration(minutes: 4)),
          ),
        },
      );
      const detail = HajimeteChapterDetail(
        levelCode: 'N5',
        chapterId: 1,
        title: 'Greetings',
        entries: [
          HajimeteChapterEntry(
            term: '????',
            reading: '????',
            meaningVi: 'ch?o h?i',
            meaningEn: 'greeting',
          ),
          HajimeteChapterEntry(
            term: '?????',
            reading: '?????',
            meaningVi: 'c?m ?n',
            meaningEn: 'thank you',
          ),
        ],
      );
      final userTerms = [
        UserLessonTermData(
          id: 101,
          lessonId: -905001,
          term: '????',
          reading: '????',
          definition: 'greeting',
          definitionEn: 'greeting',
          mnemonicVi: '',
          mnemonicEn: '',
          kanjiMeaning: '',
          isStarred: false,
          isLearned: true,
          orderIndex: 1,
        ),
        UserLessonTermData(
          id: 102,
          lessonId: -905001,
          term: '?????',
          reading: '?????',
          definition: 'thank you',
          definitionEn: 'thank you',
          mnemonicVi: '',
          mnemonicEn: '',
          kanjiMeaning: '',
          isStarred: false,
          isLearned: true,
          orderIndex: 2,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(_prefs),
            lessonRepositoryProvider.overrideWithValue(repo),
            hajimeteChapterDetailProvider.overrideWith(
              (ref, arg) async => detail,
            ),
            hajimeteChapterItemsProvider.overrideWith(
              (ref, arg) async => [item1, item2],
            ),
            hajimeteChapterUserTermsProvider.overrideWith(
              (ref, arg) async => userTerms,
            ),
            hajimeteKanjiChapterProvider.overrideWith((ref, arg) async => null),
          ],
          child: const MaterialApp(
            home: HajimeteChapterDetailScreen(
              levelCode: 'N5',
              chapterId: 1,
              laneTitle: 'Hajimete no Nihongo Tango',
            ),
          ),
        ),
      );

      await _pumpCatalog(tester);
      await tester.tap(find.text('Review now'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('hajimete_review_stage')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('hajimete_card_review_101_hint')),
        findsOneWidget,
      );

      final goodButton = find.descendant(
        of: find.byType(ConfidenceRatingWidget),
        matching: find.text('Good'),
      );
      await tester.ensureVisible(goodButton);
      await tester.tap(goodButton, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('hajimete_review_stage')),
        findsOneWidget,
      );
      expect(find.byType(ConfidenceRatingWidget), findsOneWidget);
      expect(
        find.byKey(const ValueKey('hajimete_card_review_102_hint')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Vocab hub search finds Vietnamese, English, and Japanese terms',
    (tester) async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': [
            const VocabItem(
              id: 42,
              term: '食べます',
              reading: 'たべます',
              meaning: 'ăn',
              meaningEn: 'eat',
              level: 'N5',
            ),
          ],
        },
      );

      await tester.pumpWidget(_buildRouterScreen(repo: repo));
      await _pumpCatalog(tester);

      await tester.enterText(
        find.byKey(const ValueKey('vocab_search_field')),
        'an',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('食べます'), findsWidgets);

      await tester.enterText(
        find.byKey(const ValueKey('vocab_search_field')),
        'eat',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('食べます'), findsWidgets);

      await tester.enterText(
        find.byKey(const ValueKey('vocab_search_field')),
        '食べ',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('食べます'), findsWidgets);

      await tester.enterText(
        find.byKey(const ValueKey('vocab_search_field')),
        'tabemasu',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('食べます'), findsWidgets);
    },
  );

  testWidgets(
    'Hajimete core lane loads series terms even when due queue is empty',
    (tester) async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': List.generate(6, (i) => _item(i + 1, 'hajimete_$i', 'N5')),
        },
      );

      final router = GoRouter(
        initialLocation: '/vocab/review',
        routes: [
          GoRoute(
            path: '/vocab/review',
            builder: (context, state) => TermReviewScreen(
              reviewArgs: const VocabReviewArgs(
                source: 'core',
                levelCode: 'N5',
                series: 'hajimete',
                title: 'Hajimete no Nihongo Tango N5',
                subtitle:
                    'Chapter-based Hajimete track for N5 with seeded catalog data.',
              ),
              sessionTitle: 'Hajimete no Nihongo Tango N5',
              sessionSubtitle:
                  'Chapter-based Hajimete track for N5 with seeded catalog data.',
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(_prefs),
            studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
            lessonRepositoryProvider.overrideWithValue(repo),
            allDueTermsProvider.overrideWith(
              (ref) async => const <UserLessonTermData>[],
            ),
            nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await _pumpCatalog(tester);

      expect(find.text('6 terms due'), findsWidgets);
      expect(find.text('Hajimete no Nihongo Tango N5'), findsWidgets);
    },
  );
}
