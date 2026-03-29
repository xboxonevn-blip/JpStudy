import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/vocab/vocab_screen.dart';
import 'package:jpstudy/features/vocab/screens/minna_lesson_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeVocabLessonRepository extends LessonRepository {
  _FakeVocabLessonRepository({required this.bank})
    : super(
        AppDatabase(executor: NativeDatabase.memory()),
        ContentDatabase(executor: NativeDatabase.memory()),
      );

  final Map<String, List<VocabItem>> bank;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    return bank[level] ?? const [];
  }

  @override
  Future<List<VocabItem>> getVocabByLevelAndSeries(
    String level,
    String series,
  ) async {
    return bank[level] ?? const [];
  }

  @override
  Future<List<VocabItem>> getVocabByLessonRange(
    String level, {
    required int startLesson,
    required int endLesson,
    String series = 'minna',
  }) async {
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
}

VocabItem _item(int id, String term, String level) => VocabItem(
  id: id,
  term: term,
  reading: term,
  meaning: 'meaning $id',
  meaningEn: 'meaning $id',
  level: level,
);

Widget _buildScreen({required LessonRepository repo}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonRepositoryProvider.overrideWithValue(repo),
      allDueTermsProvider.overrideWith((ref) async => const []),
      nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: const MaterialApp(home: VocabScreen()),
  );
}

Widget _buildRouterScreen({required LessonRepository repo}) {
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
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n4),
      lessonRepositoryProvider.overrideWithValue(repo),
      allDueTermsProvider.overrideWith((ref) async => const []),
      nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

Future<void> _pumpCatalog(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
  });

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
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
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
    expect(find.text('Lessons 1?25'), findsWidgets);
  });

  testWidgets(
    'N2 core track opens preview dialog when data exists but review is not wired',
    (tester) async {
      final repo = _FakeVocabLessonRepository(
        bank: {
          'N5': List.generate(5, (i) => _item(i + 1, 'n5_$i', 'N5')),
          'N4': List.generate(5, (i) => _item(i + 11, 'n4_$i', 'N4')),
          'N3': List.generate(5, (i) => _item(i + 21, 'n3_$i', 'N3')),
          'N2': List.generate(3, (i) => _item(i + 31, 'n2_$i', 'N2')),
          'N1': List.generate(2, (i) => _item(i + 41, 'n1_$i', 'N1')),
        },
      );

      await tester.pumpWidget(_buildScreen(repo: repo));
      await _pumpCatalog(tester);

      await tester.ensureVisible(
        find.byKey(const ValueKey('program_n2_n2_core')),
      );
      await _pumpCatalog(tester);

      await tester.tap(find.byKey(const ValueKey('program_n2_n2_core')));
      await _pumpCatalog(tester);

      expect(find.text('Track preview'), findsOneWidget);
      expect(find.textContaining('Hajimete no Nihongo Tango'), findsWidgets);
      expect(find.text('3 terms'), findsWidgets);
      expect(find.text('38 chapters seeded'), findsOneWidget);
    },
  );

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

    await tester.pumpWidget(_buildScreen(repo: repo));
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
            appLanguageProvider.overrideWith((ref) => AppLanguage.en),
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
      expect(find.text('Lessons 1?25'), findsWidgets);
    },
  );

  testWidgets('VocabScreen opens review flow for active level cards only', (
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

    await tester.pumpWidget(_buildRouterScreen(repo: repo));
    await _pumpCatalog(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('program_n5_n5_core')),
    );
    await _pumpCatalog(tester);

    await tester.tap(find.byKey(const ValueKey('program_n5_n5_core')));
    await _pumpCatalog(tester);

    expect(find.textContaining('REVIEW_N5_'), findsOneWidget);
  });
}
