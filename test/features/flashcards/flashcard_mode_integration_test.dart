import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/flashcards/integration/flashcard_mode_integration.dart';
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

Widget _build(
  AsyncValue<List<UserLessonTermData>> termsValue, {
  StudyLevel level = StudyLevel.n5,
}) {
  final args = LessonTermsArgs(1, level.shortLabel, 'Test Lesson');
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => AppLanguage.en),
      studyLevelProvider.overrideWith((ref) => level),
      lessonTermsProvider(args).overrideWith((ref) async {
        return termsValue.when(
          data: (d) => d,
          loading: () => throw const AsyncLoading(),
          error: (e, s) => throw e,
        );
      }),
      for (int i = 1; i <= 3; i++)
        srsStateProvider(i).overrideWith((ref) async => null),
    ],
    child: const MaterialApp(
      home: FlashcardModeIntegration(lessonId: 1, lessonTitle: 'Test Lesson'),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows EnhancedFlashcardScreen when terms load', (tester) async {
    final terms = [_term(1, '食べる'), _term(2, '飲む'), _term(3, '行く')];
    await tester.pumpWidget(_build(AsyncData(terms)));
    await tester.pumpAndSettle();
    expect(find.text('Test Lesson'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows first card term after load', (tester) async {
    final terms = [_term(1, '食べる'), _term(2, '飲む')];
    await tester.pumpWidget(_build(AsyncData(terms)));
    await tester.pumpAndSettle();
    expect(find.text('食べる'), findsOneWidget);
  });

  testWidgets('shows no-terms message when list is empty', (tester) async {
    await tester.pumpWidget(_build(const AsyncData([])));
    await tester.pumpAndSettle();
    expect(find.text('No terms available for this lesson.'), findsOneWidget);
  });
}
