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
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/lesson/lesson_edit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeLessonEditRepository extends LessonRepository {
  FakeLessonEditRepository(super.db, super.contentDb);

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
    repo = FakeLessonEditRepository(appDb, contentDb);
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  Widget buildScreen() => ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          databaseProvider.overrideWithValue(appDb),
          lessonRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: LessonEditScreen(lessonId: 1)),
      );

  testWidgets('shows back button and done button after loading',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.text(AppLanguage.en.doneLabel), findsOneWidget);
  });

  testWidgets('shows title, description, and tags fields after loading',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump();
    expect(find.text(AppLanguage.en.titleLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.descriptionLabel), findsOneWidget);
    expect(find.text(AppLanguage.en.tagsLabel), findsOneWidget);
  });
}
