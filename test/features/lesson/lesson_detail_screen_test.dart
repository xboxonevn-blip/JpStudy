import 'dart:async';

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

Widget buildScreen(
  List<UserLessonTermData> terms, {
  Future<List<UserLessonTermData>>? termsFuture,
}) {
  final fallbackTitle = AppLanguage.en.lessonTitle(1);
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonTitleProvider(
        LessonTitleArgs(1, fallbackTitle),
      ).overrideWith((ref) async => fallbackTitle),
      lessonTermsProvider(
        LessonTermsArgs(1, 'N5', fallbackTitle, sourceLessonId: 1),
      ).overrideWith((ref) => termsFuture ?? Future.value(terms)),
      lessonDueTermsProvider(
        1,
      ).overrideWith((ref) async => const <UserLessonTermData>[]),
      srsStateProvider(1).overrideWith((ref) async => null),
    ],
    child: const MaterialApp(home: LessonDetailScreen(lessonId: 1)),
  );
}

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

  testWidgets('does not show zero totals while lesson terms are loading', (
    tester,
  ) async {
    final pending = Completer<List<UserLessonTermData>>().future;

    await tester.pumpWidget(buildScreen(const [], termsFuture: pending));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text(AppLanguage.en.statsTotalLabel), findsNothing);
    expect(find.text('0'), findsNothing);
  });
}
