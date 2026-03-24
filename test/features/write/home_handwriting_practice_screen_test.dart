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
}) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
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
      child: const MaterialApp(home: HomeHandwritingPracticeScreen()),
    );

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  testWidgets('shows level prompt when no study level is selected', (tester) async {
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

  testWidgets('shows handwriting practice screen when due kanji exist', (tester) async {
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

  testWidgets('shows all-caught-up screen when nothing is due or unseen', (tester) async {
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
}
