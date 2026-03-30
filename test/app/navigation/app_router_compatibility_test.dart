import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/kanji_reading/screens/home_kanji_reading_screen.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/hajimete_chapter_detail_screen.dart';
import 'package:jpstudy/features/vocab/screens/vocab_match_session_screen.dart';
import 'package:jpstudy/features/vocab/screens/minna_lesson_catalog_screen.dart';
import 'package:jpstudy/features/vocab/screens/term_review_screen.dart';
import 'package:jpstudy/features/write/screens/home_handwriting_practice_screen.dart';

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    ],
    child: MaterialApp.router(routerConfig: AppRouter.router),
  );
}

void main() {
  tearDown(() {
    AppRouter.router.go('/');
  });

  testWidgets('legacy vocab review query route still opens term review', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go(
      '/vocab/review?title=Minna%20no%20Nihongo%20I&subtitle=Track%20dong%20hanh&lessonStart=1&lessonEnd=25',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TermReviewScreen), findsOneWidget);
  });

  testWidgets('legacy minna catalog query route still opens minna screen', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go(
      '/vocab/minna?level=N5&title=Minna%20no%20Nihongo%20I&lessonStart=1&lessonEnd=25',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(MinnaLessonCatalogScreen), findsOneWidget);
  });

  testWidgets('hajimete catalog query route opens chapter catalog', (tester) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go(
      '/vocab/hajimete?level=N5&title=Hajimete%20no%20Nihongo%20Tango%20N5',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HajimeteChapterCatalogScreen), findsOneWidget);
  });

  testWidgets('hajimete chapter query route opens detail screen', (tester) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go(
      '/vocab/hajimete/chapter?level=N5&chapterId=1&title=Hajimete%20no%20Nihongo%20Tango%20N5',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HajimeteChapterDetailScreen), findsOneWidget);
    expect(find.text('Kanji'), findsWidgets);
  });

  testWidgets('vocab match session fallback route opens screen', (tester) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go('/vocab/match-session');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(VocabMatchSessionScreen), findsOneWidget);
  });

  testWidgets('legacy kanji reading route still opens reading practice', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go('/practice/kanji-reading');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HomeKanjiReadingScreen), findsOneWidget);
  });

  testWidgets('legacy handwriting route still opens handwriting practice', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    AppRouter.router.go('/practice/handwriting');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(HomeHandwritingPracticeScreen), findsOneWidget);
  });
}
