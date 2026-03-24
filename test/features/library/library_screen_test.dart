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

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const LibraryScreen()),
    GoRoute(path: '/lesson/:id', builder: (_, _) => const Scaffold()),
    GoRoute(path: '/search', builder: (_, _) => const Scaffold()),
  ],
);

Widget buildLibraryScreen({List<LessonMeta> lessons = const [_kLesson]}) =>
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        lessonMetaProvider('N5').overrideWith((ref) async => lessons),
      ],
      child: MaterialApp.router(routerConfig: _router),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Library AppBar title', (tester) async {
    await tester.pumpWidget(buildLibraryScreen());
    await tester.pump();
    expect(find.text('Library'), findsWidgets);
  });

  testWidgets('shows Open lessons hero CTA', (tester) async {
    await tester.pumpWidget(buildLibraryScreen());
    await tester.pump();
    expect(find.text('Open lessons'), findsOneWidget);
  });

  testWidgets('shows lesson title from lessonMetaProvider', (tester) async {
    await tester.pumpWidget(buildLibraryScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Lesson 1'), findsWidgets);
  });

  testWidgets('shows empty state when no lessons available', (tester) async {
    await tester.pumpWidget(buildLibraryScreen(lessons: const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('No lessons for this level yet.'), findsOneWidget);
  });
}
