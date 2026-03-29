import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/games/match_game/lesson_match_screen.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserLessonTermData _term(int id, String term) => UserLessonTermData(
      id: id,
      lessonId: 1,
      term: term,
      reading: term,
      definition: 'def$id',
      definitionEn: 'en$id',
      mnemonicVi: '',
      mnemonicEn: '',
      kanjiMeaning: '',
      isStarred: false,
      isLearned: false,
      orderIndex: id,
    );

Widget _buildMatchScreen(List<UserLessonTermData> terms) {
  final args = LessonTermsArgs(1, StudyLevel.n5.shortLabel, 'Test Lesson');
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonTermsProvider(args).overrideWith((ref) async => terms),
    ],
    child: const MaterialApp(
      home: LessonMatchScreen(lessonId: 1, lessonTitle: 'Test Lesson'),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // --- Pure function: mode routing ---

  test('lessonPracticeModeFromPath parses all modes', () {
    expect(lessonPracticeModeFromPath('learn'), LessonPracticeMode.learn);
    expect(lessonPracticeModeFromPath('test'), LessonPracticeMode.test);
    expect(lessonPracticeModeFromPath('match'), LessonPracticeMode.match);
    expect(lessonPracticeModeFromPath('write'), LessonPracticeMode.write);
  });

  test('lessonPracticeModeFromPath returns null for unknown', () {
    expect(lessonPracticeModeFromPath('unknown'), isNull);
    expect(lessonPracticeModeFromPath(''), isNull);
  });

  // --- Widget tests for LessonMatchScreen (match mode target) ---

  testWidgets('LessonMatchScreen shows correct AppBar title', (tester) async {
    final terms = [_term(1, '食べる'), _term(2, '飲む'), _term(3, '行く')];
    await tester.pumpWidget(_buildMatchScreen(terms));
    await tester.pump();
    expect(
      find.text('${AppLanguage.en.matchModeLabel}: Test Lesson'),
      findsOneWidget,
    );
  });

  testWidgets('LessonMatchScreen shows start buttons when terms load',
      (tester) async {
    final terms = [_term(1, '食べる'), _term(2, '飲む'), _term(3, '行く')];
    await tester.pumpWidget(_buildMatchScreen(terms));
    await tester.pumpAndSettle();
    expect(find.text(AppLanguage.en.startGameLabel.toUpperCase()), findsOneWidget);
  });
}
