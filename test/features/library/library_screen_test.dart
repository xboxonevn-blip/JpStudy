import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/library/library_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLesson = LessonMeta(
  id: 1,
  level: 'N5',
  title: 'Lesson 1',
  isCustomTitle: false,
  tags: '',
  termCount: 20,
  completedCount: 8,
  dueCount: 3,
  updatedAt: null,
);

GoRouter _router() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LibraryScreen()),
    GoRoute(
      path: '/lesson/:id',
      builder: (_, state) =>
          Scaffold(body: Text('Lesson Route ${state.pathParameters['id']}')),
    ),
    GoRoute(
      path: '/search',
      builder: (_, _) => const Scaffold(body: Text('Search Route')),
    ),
    GoRoute(
      path: '/vocab',
      builder: (_, _) => const Scaffold(body: Text('Vocab Route')),
    ),
    GoRoute(
      path: '/grammar',
      builder: (_, _) => const Scaffold(body: Text('Grammar Route')),
    ),
  ],
);

Widget buildLibraryScreen({
  List<LessonMeta> lessons = const [_kLesson],
  bool shouldThrow = false,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonMetaProvider('N5').overrideWith((ref) async {
        if (shouldThrow) {
          throw Exception('boom');
        }
        return lessons;
      }),
    ],
    child: MaterialApp.router(routerConfig: _router()),
  );
}

Future<void> _pumpScreen(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> _tapAndWait(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Library AppBar title', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    expect(find.text('Library'), findsWidgets);
  });

  testWidgets('shows Open lessons hero CTA', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    expect(find.text('Open lessons'), findsOneWidget);
  });

  testWidgets('shows lesson title from lessonMetaProvider', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    expect(find.text('Lesson 1'), findsWidgets);
  });

  testWidgets('shows empty state when no lessons available', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen(lessons: const []));
    expect(find.text('No lessons for this level yet.'), findsOneWidget);
  });

  testWidgets('shows load error when lesson provider fails', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen(shouldThrow: true));
    expect(find.text(AppLanguage.en.loadErrorLabel), findsOneWidget);
  });

  testWidgets('shows sections and lessons headers', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Open content by area'), findsOneWidget);
  });

  testWidgets('shows quick access cards for vocab and grammar', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Terms by level'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Points and examples'), findsOneWidget);
  });

  testWidgets('search app bar button navigates to search route', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    await _tapAndWait(tester, find.byIcon(Icons.search_rounded));
    expect(find.text('Search Route'), findsOneWidget);
  });

  testWidgets('hero CTA navigates to first lesson id from provider', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    await _tapAndWait(tester, find.text('Open lessons'));
    expect(find.text('Lesson Route 1'), findsOneWidget);
  });

  testWidgets('hero CTA falls back to level default lesson id when no lessons exist',
      (tester) async {
    await _pumpScreen(tester, buildLibraryScreen(lessons: const []));
    await _tapAndWait(tester, find.text('Open lessons'));
    expect(find.text('Lesson Route 1'), findsOneWidget);
  });

  testWidgets('quick access vocab card navigates to vocab route', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    await _tapAndWait(tester, find.text('Vocab').first);
    expect(find.text('Vocab Route'), findsOneWidget);
  });

  testWidgets('quick access grammar card navigates to grammar route',
      (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    await _tapAndWait(tester, find.text('Grammar').first);
    expect(find.text('Grammar Route'), findsOneWidget);
  });

  testWidgets('lesson tile shows due count when due lessons exist', (tester) async {
    await _pumpScreen(tester, buildLibraryScreen());
    expect(find.text('3 due'), findsOneWidget);
  });

  testWidgets('lesson tile shows completed progress when due count is zero',
      (tester) async {
    const lesson = LessonMeta(
      id: 2,
      level: 'N5',
      title: 'Lesson 2',
      isCustomTitle: false,
      tags: '',
      termCount: 10,
      completedCount: 4,
      dueCount: 0,
      updatedAt: null,
    );

    await _pumpScreen(tester, buildLibraryScreen(lessons: const [lesson]));
    expect(find.text('4/10'), findsOneWidget);
    expect(find.text('4/10 complete'), findsOneWidget);
  });
}
