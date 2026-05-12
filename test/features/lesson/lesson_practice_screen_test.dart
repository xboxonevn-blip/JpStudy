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
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/lesson/lesson_practice_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLessonPracticeRepository extends LessonRepository {
  FakeLessonPracticeRepository(super.db, super.contentDb);

  @override
  Future<String> getLessonTitle(int lessonId, String fallback) async =>
      'Lesson 1';

  @override
  Future<UserLessonData> ensureLesson({
    required int lessonId,
    required String level,
    required String title,
  }) async {
    return UserLessonData(
      id: lessonId,
      level: level,
      title: title,
      description: '',
      tags: '',
      isPublic: true,
      isCustomTitle: false,
      learnTermLimit: 10,
      testQuestionLimit: 10,
      matchPairLimit: 6,
      updatedAt: DateTime(2026, 3, 24),
    );
  }

  @override
  Future<void> seedTermsIfEmpty(int lessonId, String currentLevelLabel) async {}

  @override
  Future<void> seedGrammarIfEmpty(
    int lessonId,
    String currentLevelLabel,
  ) async {}

  @override
  Future<List<UserLessonTermData>> fetchTerms(int lessonId) async => const [];
}

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late LessonRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
    repo = FakeLessonPracticeRepository(appDb, contentDb);
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  Widget buildScreen() => ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      lessonRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(
      home: LessonPracticeScreen(lessonId: 1, mode: LessonPracticeMode.learn),
    ),
  );

  testWidgets('shows empty-state when no lesson terms exist', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    expect(
      find.text('${AppLanguage.en.learnModeLabel}: Lesson 1'),
      findsOneWidget,
    );
    expect(find.text(AppLanguage.en.noTermsAvailableLabel), findsOneWidget);
  });
}
