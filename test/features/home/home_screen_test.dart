import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/home/models/practice_destination.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late LessonRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
    repo = LessonRepository(appDb, contentDb);
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  Widget buildScreen({required bool? onboardingDone}) => ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
          onboardingDoneProvider.overrideWith((ref) => onboardingDone),
          appInitProvider.overrideWith((ref) async {}),
          databaseProvider.overrideWithValue(appDb),
          lessonRepositoryProvider.overrideWithValue(repo),
          dashboardProvider.overrideWith(
            (ref) => Stream.value(
              const DashboardState(
                streak: 5,
                todayXp: 18,
                vocabDue: 3,
                grammarDue: 2,
                kanjiDue: 1,
                vocabMistakeCount: 0,
                grammarMistakeCount: 1,
                kanjiMistakeCount: 0,
                totalMistakeCount: 1,
              ),
            ),
          ),
          continueActionProvider.overrideWith(
            (ref) async => const ContinueAction(
              type: ContinueActionType.vocabReview,
              label: 'Review vocab',
              count: 3,
            ),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      );

  testWidgets('shows loading indicator when onboarding state is null',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(onboardingDone: null));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows onboarding screen when onboarding is incomplete',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildScreen(onboardingDone: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(AppLanguage.en.onboardingWelcomeTitle), findsOneWidget);
  });

}
