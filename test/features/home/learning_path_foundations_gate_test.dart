import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/foundations/providers/foundations_providers.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/home/screens/learning_path_screen.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dashboard = DashboardState(
  streak: 0,
  todayXp: 0,
  vocabDue: 0,
  grammarDue: 0,
  kanjiDue: 0,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

class _CompleteFoundationsProgressController
    extends FoundationsProgressController {
  @override
  FoundationsProgress build() => FoundationsProgress(
    studied: Set.unmodifiable(
      List.generate(foundationsKanaTotal, (index) => 'kana_$index'),
    ),
  );
}

Widget _buildScreen({
  required SharedPreferences preferences,
  required StudyLevel level,
  required AppDatabase appDb,
  required ContentDatabase contentDb,
}) {
  final repo = LessonRepository(appDb, contentDb);
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(AppLanguage.en),
      ),
      studyLevelProvider.overrideWith((ref) => level),
      databaseProvider.overrideWithValue(appDb),
      lessonRepositoryProvider.overrideWithValue(repo),
      dashboardProvider.overrideWith((ref) => Stream.value(_dashboard)),
      continueActionProvider.overrideWith(
        (ref) async => const ContinueAction(
          type: ContinueActionType.vocabReview,
          label: 'Review vocab',
          count: 0,
        ),
      ),
      grammarGhostCountProvider.overrideWith((ref) async* {
        yield 0;
      }),
      weaknessRadarProvider.overrideWith((ref) async => <WeaknessRadarItem>[]),
      recoveryPackProvider.overrideWith((ref) async => null),
      dailySessionProgressProvider.overrideWith(
        (ref) async => DailySessionProgress.empty('2026-05-14'),
      ),
      backupStatusProvider.overrideWith(
        (ref) async => const BackupStatus(enabled: false, lastBackupAt: null),
      ),
      foundationsProgressProvider.overrideWith(
        () => _CompleteFoundationsProgressController(),
      ),
      appSettingsControllerProvider.overrideWith(() => AppSettingsController()),
      dataSettingsControllerProvider.overrideWith(
        () => DataSettingsController(),
      ),
    ],
    child: const MaterialApp(home: LearningPathScreen()),
  );
}

void main() {
  late AppDatabase appDb;
  late ContentDatabase contentDb;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    appDb = AppDatabase(executor: NativeDatabase.memory());
    contentDb = ContentDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() async {
    await contentDb.close();
    await appDb.close();
  });

  void configureView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester, StudyLevel level) async {
    await tester.pumpWidget(
      _buildScreen(
        preferences: preferences,
        level: level,
        appDb: appDb,
        contentDb: contentDb,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> cleanUp(WidgetTester tester) async {
    await tester.pumpWidget(Container());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  }

  testWidgets('shows foundations card for N5 even when kana is complete', (
    tester,
  ) async {
    configureView(tester);
    await pumpHome(tester, StudyLevel.n5);

    expect(find.textContaining('Foundations -'), findsOneWidget);
    expect(find.text('208/208 kana (100%)'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('hides foundations card for non-N5 levels', (tester) async {
    configureView(tester);
    await pumpHome(tester, StudyLevel.n4);

    expect(find.textContaining('Foundations -'), findsNothing);
    expect(find.text('208/208 kana (100%)'), findsNothing);
    await cleanUp(tester);
  });

  testWidgets('updates foundations visibility when level changes live', (
    tester,
  ) async {
    configureView(tester);
    await pumpHome(tester, StudyLevel.n4);

    expect(find.textContaining('Foundations -'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(LearningPathScreen)),
    );
    container.read(studyLevelProvider.notifier).state = StudyLevel.n5;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('Foundations -'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('shows textbook roadmap for upper-level learners', (
    tester,
  ) async {
    configureView(tester);
    await pumpHome(tester, StudyLevel.n3);

    expect(find.text('Textbook roadmap'), findsOneWidget);
    expect(find.textContaining('Hajimete N3'), findsOneWidget);
    expect(find.textContaining('Shin Kanzen N3'), findsWidgets);
    expect(find.textContaining('Listening'), findsNothing);
    expect(find.textContaining('Month 1'), findsNothing);
    expect(find.textContaining('At your pace'), findsWidgets);
    await cleanUp(tester);
  });
}
