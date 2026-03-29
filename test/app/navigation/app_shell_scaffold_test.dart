import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/app.dart';
import 'package:jpstudy/app/navigation/app_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/providers/immersion_providers.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeImmersionService extends ImmersionService {
  _FakeImmersionService({required this.localArticles});

  final List<ImmersionArticle> localArticles;
  final Set<String> _readIds = <String>{};

  @override
  Future<List<ImmersionArticle>> loadLocalSamples() async => localArticles;

  @override
  Future<Set<String>> getReadArticleIds() async => {..._readIds};

  @override
  Future<void> markArticleAsRead(String id, bool isRead) async {
    if (isRead) {
      _readIds.add(id);
    } else {
      _readIds.remove(id);
    }
  }
}

Future<void> _seedGrammarPoint(
  AppDatabase db, {
  required int lessonId,
  required String grammarPoint,
  required String titleEn,
  required String sentence,
  required String translationEn,
}) async {
  final grammarId = await db.into(db.grammarPoints).insert(
        GrammarPointsCompanion.insert(
          lessonId: Value(lessonId),
          grammarPoint: grammarPoint,
          titleEn: Value(titleEn),
          meaning: 'Meaning for $grammarPoint',
          meaningVi: Value('Meaning for $grammarPoint'),
          meaningEn: Value('Meaning for $grammarPoint'),
          connection: grammarPoint,
          connectionEn: Value(grammarPoint),
          explanation: 'Use $grammarPoint correctly.',
          explanationVi: Value('Use $grammarPoint correctly.'),
          explanationEn: Value('Use $grammarPoint correctly.'),
          jlptLevel: 'N5',
          isLearned: const Value(false),
        ),
      );

  await db.into(db.grammarExamples).insert(
        GrammarExamplesCompanion.insert(
          grammarId: grammarId,
          japanese: sentence,
          translation: translationEn,
          translationVi: Value(translationEn),
          translationEn: Value(translationEn),
        ),
      );
}

Future<void> _pumpShellApp(
  WidgetTester tester, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(const {
    'backup.auto.enabled': true,
    'notifications.daily': false,
    'write.handwriting.strokeGuide.defaultExpanded': false,
  });

  final appDb = AppDatabase(executor: NativeDatabase.memory());
  final contentDb = ContentDatabase(executor: NativeDatabase.memory());
  final repo = LessonRepository(appDb, contentDb);
  addTearDown(() async {
    AppRouter.router.go('/');
    await tester.pumpAndSettle();
    await contentDb.close();
    await appDb.close();
  });

  await _seedGrammarPoint(
    appDb,
    lessonId: 1,
    grammarPoint: 'だけ',
    titleEn: 'Only',
    sentence: '水だけ飲みます。',
    translationEn: 'I only drink water.',
  );

  final immersionService = _FakeImmersionService(
    localArticles: [
      ImmersionArticle(
        id: 'local_n5_1',
        title: 'Local article',
        officialLevel: 'N5',
        source: ImmersionArticle.localSourceLabel,
        publishedAt: DateTime(2026, 3, 19),
        paragraphs: const [
          [
            ImmersionToken(
              surface: '日本語',
              reading: 'にほんご',
              meaningEn: 'Japanese language',
              meaningVi: 'tiếng Nhật',
            ),
          ],
        ],
        translation: 'This is a local reading sample.',
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
        onboardingDoneProvider.overrideWith((ref) => true),
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
        dailySessionProgressProvider.overrideWith(
          (ref) async => DailySessionProgress.empty('2026-03-19'),
        ),
        backupStatusProvider.overrideWith(
          (ref) async => const BackupStatus(enabled: true, lastBackupAt: null),
        ),
        cloudSyncStatusProvider.overrideWith(
          (ref) async => const CloudSyncStatus(
            target: null,
            lastSyncedAt: null,
            lastRemoteExportedAt: null,
            lastDirection: null,
          ),
        ),
        progressSummaryProvider.overrideWith(
          (ref) async => const ProgressSummary(
            totalXp: 420,
            todayXp: 36,
            streak: 8,
            totalAttempts: 48,
            totalCorrect: 39,
            totalQuestions: 48,
          ),
        ),
        reviewHistoryProvider.overrideWith(
          (ref) async => [
            ReviewDaySummary(
              day: DateTime(2026, 3, 18),
              reviewed: 12,
              again: 2,
              hard: 3,
              good: 5,
              easy: 2,
            ),
          ],
        ),
        activityCalendarProvider.overrideWith(
          (ref) async => [
            ReviewDaySummary(
              day: DateTime(2026, 3, 18),
              reviewed: 12,
              again: 2,
              hard: 3,
              good: 5,
              easy: 2,
            ),
          ],
        ),
        attemptHistoryProvider.overrideWith(
          (ref) async => [
            AttemptSummary(
              id: 1,
              mode: 'Grammar',
              level: 'N5',
              startedAt: DateTime(2026, 3, 19, 9, 30),
              finishedAt: DateTime(2026, 3, 19, 9, 38),
              score: 8,
              total: 10,
            ),
          ],
        ),
        srsRetentionProvider.overrideWith(
          (ref) async =>
              const SrsStageBreakdown(learning: 4, young: 7, mature: 9),
        ),
        weaknessRadarProvider.overrideWith((ref) async => const []),
        searchIndexProvider.overrideWith((ref) async => const []),
        immersionServiceProvider.overrideWithValue(immersionService),
      ],
      child: const App(),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('desktop shell shows top bar, sidebar, and roadmap by default', (
    tester,
  ) async {
    await _pumpShellApp(tester, size: const Size(1440, 1600));

    expect(find.text('JP Study'), findsOneWidget);
    expect(find.byTooltip('Choose language'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.text('Roadmap'), findsWidgets);
    expect(find.text('Kanji'), findsOneWidget);
    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Exams'), findsOneWidget);
    expect(find.text('Ranks'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);
  });

  testWidgets('mobile shell shows top bar, bottom nav, and more sheet', (
    tester,
  ) async {
    await _pumpShellApp(tester, size: const Size(390, 844));

    expect(find.text('JP Study'), findsOneWidget);
    expect(find.byTooltip('Choose language'), findsOneWidget);
    expect(find.text('Roadmap'), findsOneWidget);
    expect(find.text('Memory'), findsOneWidget);
    expect(find.text('Kanji'), findsOneWidget);
    expect(find.text('Exams'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Ranks'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.text('Community'), findsAtLeastNWidgets(1));
  });

  testWidgets('language picker updates shell labels', (tester) async {
    await _pumpShellApp(tester, size: const Size(1440, 1600));

    await tester.tap(find.byTooltip('Choose language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.ja.label).last);
    await tester.pumpAndSettle();

    expect(find.text('JP Study'), findsOneWidget);
    expect(find.text('JA'), findsAtLeastNWidgets(1));
    expect(find.text('ロードマップ'), findsWidgets);
    expect(find.text('漢字'), findsWidgets);
  });
}

