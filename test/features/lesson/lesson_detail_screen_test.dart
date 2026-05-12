import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/lesson/lesson_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

UserLessonTermData _term(int id, String term, String definition) =>
    UserLessonTermData(
      id: id,
      lessonId: 1,
      term: term,
      reading: '',
      definition: definition,
      definitionEn: definition,
      mnemonicVi: '',
      mnemonicEn: '',
      kanjiMeaning: '',
      isStarred: false,
      isLearned: false,
      orderIndex: id,
    );

Widget buildScreen(List<UserLessonTermData> terms) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    lessonTitleProvider(
      const LessonTitleArgs(1, 'Lesson 1'),
    ).overrideWith((ref) async => 'Lesson 1'),
    lessonTermsProvider(
      const LessonTermsArgs(1, 'N5', 'Lesson 1'),
    ).overrideWith((ref) async => terms),
    lessonDueTermsProvider(
      1,
    ).overrideWith((ref) async => const <UserLessonTermData>[]),
    srsStateProvider(1).overrideWith((ref) async => null),
  ],
  child: const MaterialApp(home: LessonDetailScreen(lessonId: 1)),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows app bar back control and lesson tabs', (tester) async {
    await tester.pumpWidget(buildScreen([_term(1, '犬', 'dog')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });

  testWidgets('shows tab bar with Flashcards, Grammar, Kanji tabs', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen([_term(1, '犬', 'dog')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.flashcardsAction), findsWidgets);
    expect(find.text(AppLanguage.en.grammarLabel), findsWidgets);
    expect(find.text(AppLanguage.en.kanjiLabel), findsWidgets);
  });
}
