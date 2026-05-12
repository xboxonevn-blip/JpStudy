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

Widget buildScreen(List<UserLessonTermData> items) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    lessonTermsProvider(
      const LessonTermsArgs(1, 'N5', 'Test Lesson'),
    ).overrideWith((ref) async => items),
  ],
  child: const MaterialApp(
    home: LessonMatchScreen(lessonId: 1, lessonTitle: 'Test Lesson'),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Match app bar title with lesson title', (tester) async {
    await tester.pumpWidget(buildScreen([_term(1, '火', 'fire')]));
    await tester.pump();
    expect(
      find.text('${AppLanguage.en.matchModeLabel}: Test Lesson'),
      findsOneWidget,
    );
  });

  testWidgets('shows start button when terms exist', (tester) async {
    await tester.pumpWidget(
      buildScreen([
        _term(1, '火', 'fire'),
        _term(2, '水', 'water'),
        _term(3, '木', 'tree'),
      ]),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text(AppLanguage.en.startGameLabel.toUpperCase()),
      findsOneWidget,
    );
  });

  testWidgets('shows empty-state when no terms exist', (tester) async {
    await tester.pumpWidget(buildScreen(const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.noTermsAvailableLabel), findsOneWidget);
  });
}
