import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/kanji_hub/models/kanji_practice_args.dart';
import 'package:jpstudy/features/write/screens/handwriting_practice_screen.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeHomeHandwritingRepository extends LessonRepository {
  FakeHomeHandwritingRepository(
    super.db,
    super.contentDb, {
    required this.dueItems,
    required this.unseenItems,
    required this.allItems,
  });

  final List<KanjiItem> dueItems;
  final List<KanjiItem> unseenItems;
  final List<KanjiItem> allItems;

  @override
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async => dueItems;

  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async => unseenItems;

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async => allItems;
}

class FakeLevelAwareHomeHandwritingRepository extends LessonRepository {
  FakeLevelAwareHomeHandwritingRepository(
    super.db,
    super.contentDb, {
    this.dueItemsByLevel = const {},
    this.unseenItemsByLevel = const {},
    this.allItemsByLevel = const {},
  });

  final Map<String, List<KanjiItem>> dueItemsByLevel;
  final Map<String, List<KanjiItem>> unseenItemsByLevel;
  final Map<String, List<KanjiItem>> allItemsByLevel;

  @override
  Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async =>
      dueItemsByLevel[level] ?? const [];

  @override
  Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
    String level, {
    int limit = 15,
  }) async => unseenItemsByLevel[level] ?? const [];

  @override
  Future<List<KanjiItem>> fetchKanjiByLevel(String level) async =>
      allItemsByLevel[level] ?? const [];
}

KanjiItem _kanji(int id, String char) => KanjiItem(
  id: id,
  lessonId: 1,
  character: char,
  strokeCount: 4,
  meaning: 'meaning $char',
  meaningEn: 'meaning $char',
  onyomi: '',
  kunyomi: '',
  examples: const [],
  jlptLevel: 'N5',
);

Widget buildScreen({
  required StudyLevel? level,
  required LessonRepository repo,
  KanjiPracticeArgs? launchArgs,
}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    studyLevelProvider.overrideWith((ref) => level),
    lessonRepositoryProvider.overrideWithValue(repo),
    dashboardProvider.overrideWith(
      (ref) => Stream.value(
        const DashboardState(
          streak: 0,
          todayXp: 0,
          vocabDue: 0,
          grammarDue: 0,
          kanjiDue: 2,
          vocabMistakeCount: 0,
          grammarMistakeCount: 0,
          kanjiMistakeCount: 0,
          totalMistakeCount: 0,
        ),
      ),
    ),
  ],
  child: MaterialApp(
    home: HomeHandwritingPracticeScreen(launchArgs: launchArgs),
  ),
);

Widget buildScreenWithContainer({
  required ProviderContainer container,
  KanjiPracticeArgs? launchArgs,
}) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp(
    home: HomeHandwritingPracticeScreen(launchArgs: launchArgs),
  ),
);

void main() {
  test('random seed generation avoids web-unsafe 32-bit shift max', () {
    final source = File(
      'lib/features/write/screens/home_handwriting_practice_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('nextInt(1 << 32)')));
  });

  late AppDatabase appDb;
  late ContentDatabase contentDb;

  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  testWidgets('shows level prompt when no study level is selected', (
    tester,
  ) async {
    final repo = FakeHomeHandwritingRepository(
      appDb,
      contentDb,
      dueItems: const [],
      unseenItems: const [],
      allItems: const [],
    );

    await tester.pumpWidget(buildScreen(level: null, repo: repo));
    await tester.pump();

    expect(find.text(AppLanguage.en.handwritingLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.levelMenuTitle), findsOneWidget);
  });

  testWidgets('shows handwriting practice screen when due kanji exist', (
    tester,
  ) async {
    final repo = FakeHomeHandwritingRepository(
      appDb,
      contentDb,
      dueItems: [_kanji(1, '日'), _kanji(2, '月')],
      unseenItems: const [],
      allItems: const [],
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);
    expect(find.textContaining(AppLanguage.en.handwritingLabel), findsWidgets);
  });

  testWidgets('shows all-caught-up screen when nothing is due or unseen', (
    tester,
  ) async {
    final repo = FakeHomeHandwritingRepository(
      appDb,
      contentDb,
      dueItems: const [],
      unseenItems: const [],
      allItems: [_kanji(1, '日')],
    );

    await tester.pumpWidget(buildScreen(level: StudyLevel.n5, repo: repo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets(
    'refreshes scoped session when launchArgs change on the same level',
    (tester) async {
      final repo = FakeHomeHandwritingRepository(
        appDb,
        contentDb,
        dueItems: const [],
        unseenItems: const [],
        allItems: [_kanji(1, '日'), _kanji(2, '月')],
      );

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          repo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.write,
            source: 'due',
            kanjiIds: [1],
            preferredKanjiId: 1,
          ),
        ),
      );
      await pumpHomeScreen(tester);

      final firstSession = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(firstSession.items.map((item) => item.id).toList(), [1]);

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          repo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.write,
            source: 'due',
            kanjiIds: [2],
            preferredKanjiId: 2,
          ),
        ),
      );
      await pumpHomeScreen(tester);

      final secondSession = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(secondSession.items.map((item) => item.id).toList(), [2]);
    },
  );

  testWidgets(
    'source-only due launchArgs uses due items instead of the full level list',
    (tester) async {
      final repo = FakeHomeHandwritingRepository(
        appDb,
        contentDb,
        dueItems: [_kanji(3, '火')],
        unseenItems: [_kanji(4, '水')],
        allItems: [_kanji(1, '日'), _kanji(2, '月')],
      );

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          repo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.write,
            source: 'due',
            levelCode: 'N5',
          ),
        ),
      );
      await pumpHomeScreen(tester);

      final session = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(session.items.map((item) => item.id).toList(), [3]);
    },
  );

  testWidgets(
    'source-only new launchArgs uses unseen batch instead of the full level list',
    (tester) async {
      final repo = FakeHomeHandwritingRepository(
        appDb,
        contentDb,
        dueItems: [_kanji(3, '火')],
        unseenItems: [_kanji(4, '水')],
        allItems: [_kanji(1, '日'), _kanji(2, '月')],
      );

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          repo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.write,
            source: 'daily_plan_new',
            levelCode: 'N5',
          ),
        ),
      );
      await pumpHomeScreen(tester);

      final session = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(session.items.map((item) => item.id).toList(), [4]);
    },
  );

  testWidgets(
    'scoped launchArgs with no matches stays empty instead of falling back to unrelated items',
    (tester) async {
      final repo = FakeHomeHandwritingRepository(
        appDb,
        contentDb,
        dueItems: [_kanji(3, '火')],
        unseenItems: [_kanji(4, '水')],
        allItems: [_kanji(1, '日'), _kanji(2, '月')],
      );

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          repo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.write,
            source: 'due',
            kanjiIds: [99],
            preferredKanjiId: 99,
          ),
        ),
      );
      await pumpHomeScreen(tester);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final scopedSession = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(scopedSession.items, isEmpty);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNothing);
    },
  );

  testWidgets(
    'scoped launchArgs without due or new source show scoped availability instead of due label',
    (tester) async {
      final repo = FakeHomeHandwritingRepository(
        appDb,
        contentDb,
        dueItems: [_kanji(3, '火')],
        unseenItems: [_kanji(4, '水')],
        allItems: [_kanji(1, '日'), _kanji(2, '月')],
      );

      await tester.pumpWidget(
        buildScreen(
          level: StudyLevel.n5,
          repo: repo,
          launchArgs: const KanjiPracticeArgs(
            mode: KanjiPracticeMode.write,
            source: 'focus',
            kanjiIds: [1],
            preferredKanjiId: 1,
          ),
        ),
      );
      await pumpHomeScreen(tester);

      final session = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(session.items.map((item) => item.id).toList(), [1]);
      expect(session.lessonTitle, 'N5 — Handwriting');
    },
  );

  testWidgets(
    'changing level clears stale free mode items and reloads the new level',
    (tester) async {
      final repo = FakeLevelAwareHomeHandwritingRepository(
        appDb,
        contentDb,
        allItemsByLevel: {
          'N5': [_kanji(1, '日')],
          'N4': [_kanji(2, '月')],
        },
      );

      final container = ProviderContainer(
        overrides: [
          appLanguageProvider.overrideWith(
            (ref) => AppLanguageController.test(AppLanguage.en),
          ),
          lessonRepositoryProvider.overrideWithValue(repo),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 0,
                todayXp: 0,
                vocabDue: 0,
                grammarDue: 0,
                kanjiDue: 2,
                vocabMistakeCount: 0,
                grammarMistakeCount: 0,
                kanjiMistakeCount: 0,
                totalMistakeCount: 0,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(studyLevelProvider.notifier).state = StudyLevel.n5;

      await tester.pumpWidget(buildScreenWithContainer(container: container));
      await pumpHomeScreen(tester);

      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      await tester.tap(find.text(AppLanguage.en.handwritingFreePracticeLabel));
      await pumpHomeScreen(tester);

      final n5FreeSession = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(n5FreeSession.items.map((item) => item.id).toList(), [1]);

      container.read(studyLevelProvider.notifier).state = StudyLevel.n4;
      await pumpHomeScreen(tester);

      expect(find.byType(HandwritingPracticeScreen), findsNothing);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

      await tester.tap(find.text(AppLanguage.en.handwritingFreePracticeLabel));
      await pumpHomeScreen(tester);

      final n4FreeSession = tester.widget<HandwritingPracticeScreen>(
        find.byType(HandwritingPracticeScreen),
      );
      expect(n4FreeSession.items.map((item) => item.id).toList(), [2]);
    },
  );
}
