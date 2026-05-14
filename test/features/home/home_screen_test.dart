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
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/home_screen.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDashboard = DashboardState(
  streak: 5,
  todayXp: 18,
  vocabDue: 3,
  grammarDue: 2,
  kanjiDue: 1,
  vocabMistakeCount: 0,
  grammarMistakeCount: 1,
  kanjiMistakeCount: 0,
  totalMistakeCount: 1,
);

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

  Widget buildScreen({
    required bool? onboardingDone,
    StudyLevel level = StudyLevel.n5,
    DashboardState dashboard = _kDashboard,
  }) => ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => level),
      onboardingDoneProvider.overrideWith((ref) => onboardingDone),
      appInitProvider.overrideWith((ref) async {}),
      databaseProvider.overrideWithValue(appDb),
      lessonRepositoryProvider.overrideWithValue(repo),
      dashboardProvider.overrideWith((ref) => Stream.value(dashboard)),
      continueActionProvider.overrideWith(
        (ref) async => const ContinueAction(
          type: ContinueActionType.vocabReview,
          label: 'Review vocab',
          count: 3,
        ),
      ),
      grammarGhostCountProvider.overrideWith((ref) async* {
        yield 0;
      }),
      weaknessRadarProvider.overrideWith((ref) async => <WeaknessRadarItem>[]),
      recoveryPackProvider.overrideWith((ref) async => null),
      dailySessionProgressProvider.overrideWith(
        (ref) async => DailySessionProgress.empty('2024-01-01'),
      ),
      backupStatusProvider.overrideWith(
        (ref) async => const BackupStatus(enabled: false, lastBackupAt: null),
      ),
      appSettingsControllerProvider.overrideWith(() => AppSettingsController()),
      dataSettingsControllerProvider.overrideWith(
        () => DataSettingsController(),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );

  void configureView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 2560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void configureMobileView(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
  }

  // Cleanly dispose: replace with empty container and drain timers.
  Future<void> cleanUp(WidgetTester tester) async {
    await tester.pumpWidget(Container());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  }

  group('onboarding routing', () {
    testWidgets('shows loading indicator when onboarding state is null', (
      tester,
    ) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: null));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows onboarding screen when onboarding is incomplete', (
      tester,
    ) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: false));
      await pumpAndSettle(tester);
      expect(find.text(AppLanguage.en.onboardingWelcomeTitle), findsOneWidget);
    });
  });

  group('home screen — onboarding complete', () {
    testWidgets('renders LearningPathScreen when onboarding is done', (
      tester,
    ) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: true));
      await pumpAndSettle(tester);
      expect(find.byType(LearningPathScreen), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('shows header bar with streak and XP stats', (tester) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: true));
      await pumpAndSettle(tester);

      // Streak count from dashboard
      expect(find.text('5'), findsWidgets);
      // XP shows "18/50" (below 50 goal)
      expect(find.text('18/50'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('shows settings icon in header', (tester) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: true));
      await pumpAndSettle(tester);
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('shows level badge in header', (tester) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: true));
      await pumpAndSettle(tester);
      // N5 level label should appear in both header stats and level menu
      expect(find.text('N5'), findsWidgets);
      await cleanUp(tester);
    });

    testWidgets('shows language pill with EN', (tester) async {
      configureView(tester);
      await tester.pumpWidget(buildScreen(onboardingDone: true));
      await pumpAndSettle(tester);
      expect(find.text('EN'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('mobile home shows foundations card for N5', (tester) async {
      configureMobileView(tester);
      await tester.pumpWidget(
        buildScreen(onboardingDone: true, level: StudyLevel.n5),
      );
      await pumpAndSettle(tester);

      expect(find.text('Foundations'), findsOneWidget);
      await cleanUp(tester);
    });

    testWidgets('mobile home hides foundations card for non-N5 levels', (
      tester,
    ) async {
      configureMobileView(tester);
      await tester.pumpWidget(
        buildScreen(onboardingDone: true, level: StudyLevel.n4),
      );
      await pumpAndSettle(tester);

      expect(find.text('Foundations'), findsNothing);
      await cleanUp(tester);
    });

    testWidgets('shows reviews due count in header', (tester) async {
      configureView(tester);
      await tester.pumpWidget(
        buildScreen(onboardingDone: true, dashboard: _kDashboard),
      );
      await pumpAndSettle(tester);
      // vocabDue(3) + grammarDue(2) = 5 in the header stats
      expect(find.text('5'), findsWidgets);
      await cleanUp(tester);
    });

    testWidgets('XP shows simple number when goal reached', (tester) async {
      configureView(tester);
      await tester.pumpWidget(
        buildScreen(
          onboardingDone: true,
          dashboard: const DashboardState(
            streak: 1,
            todayXp: 60,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
        ),
      );
      await pumpAndSettle(tester);
      // When XP >= 50, shows just "60" not "60/50"
      expect(find.text('60'), findsWidgets);
      expect(find.text('60/50'), findsNothing);
      await cleanUp(tester);
    });
  });
}
