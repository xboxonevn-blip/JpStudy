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
import 'package:jpstudy/features/grammar/services/grammar_question_generator.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/weakness_radar_provider.dart';
import 'package:jpstudy/features/immersion/models/immersion_article.dart';
import 'package:jpstudy/features/immersion/providers/immersion_providers.dart';
import 'package:jpstudy/features/immersion/services/immersion_service.dart';
import 'package:jpstudy/features/progress/providers/mastery_provider.dart';
import 'package:jpstudy/features/search/search_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
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

void main() {
  Future<void> seedGrammarPoint(
    AppDatabase db, {
    required int lessonId,
    required String grammarPoint,
    required String titleEn,
    required String sentence,
    required String translationEn,
  }) async {
    final grammarId = await db
        .into(db.grammarPoints)
        .insert(
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

    await db
        .into(db.grammarExamples)
        .insert(
          GrammarExamplesCompanion.insert(
            grammarId: grammarId,
            japanese: sentence,
            translation: translationEn,
            translationVi: Value(translationEn),
            translationEn: Value(translationEn),
          ),
        );
  }

  testWidgets('App shell routes stay mountable across core study screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1600);
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
      await contentDb.close();
      await appDb.close();
    });

    await seedGrammarPoint(
      appDb,
      lessonId: 1,
      grammarPoint: 'だけ',
      titleEn: 'Only',
      sentence: '水だけ飲みます。',
      translationEn: 'I only drink water.',
    );
    await seedGrammarPoint(
      appDb,
      lessonId: 2,
      grammarPoint: 'から',
      titleEn: 'Because',
      sentence: '忙しいから、行きません。',
      translationEn: 'Because I am busy, I will not go.',
    );
    await seedGrammarPoint(
      appDb,
      lessonId: 3,
      grammarPoint: 'です',
      titleEn: 'To be',
      sentence: '私は学生です。',
      translationEn: 'I am a student.',
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
          grammarGhostCountProvider.overrideWith((ref) => Stream.value(0)),
          vocabGhostCountProvider.overrideWith((ref) => Stream.value(0)),
          nextVocabReviewProvider.overrideWith((ref) => Stream.value(null)),
          nextKanjiReviewProvider.overrideWith((ref) => Stream.value(null)),
          nextGrammarReviewProvider.overrideWith((ref) => Stream.value(null)),
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
            (ref) async =>
                const BackupStatus(enabled: true, lastBackupAt: null),
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
              longestStreak: 15,
              totalDaysStudied: 42,
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
          masterySnapshotProvider.overrideWith(
            (ref) async => const MasterySnapshot(levels: []),
          ),
          searchIndexProvider.overrideWith((ref) async => const []),
          immersionServiceProvider.overrideWithValue(immersionService),
        ],
        child: const App(),
      ),
    );

    addTearDown(() async {
      AppRouter.router.go('/');
      await tester.pumpAndSettle();
    });

    AppRouter.router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Start session'), findsOneWidget);
    expect(find.text('JLPT prep'), findsAtLeastNWidgets(1));

    AppRouter.router.go('/study');
    await tester.pumpAndSettle();
    expect(find.text('Today plan'), findsOneWidget);
    expect(find.text('Run Recall Sprint first'), findsWidgets);

    AppRouter.router.go('/library');
    await tester.pumpAndSettle();
    expect(find.text('Sections'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);

    AppRouter.router.go('/search');
    await tester.pumpAndSettle();
    expect(find.text('Lookup'), findsAtLeastNWidgets(1));
    expect(find.text('Current search bank'), findsOneWidget);

    AppRouter.router.go('/progress');
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Review history'), findsOneWidget);

    AppRouter.router.go('/me');
    await tester.pumpAndSettle();
    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Data'), findsOneWidget);

    AppRouter.router.go('/me/data');
    await tester.pumpAndSettle();
    expect(find.text('Data controls'), findsAtLeastNWidgets(1));
    expect(find.text('Manual backup', skipOffstage: false), findsOneWidget);

    AppRouter.router.go('/immersion');
    await tester.pumpAndSettle();
    expect(find.text('Local article', skipOffstage: false), findsWidgets);

    AppRouter.router.go(
      '/grammar-practice',
      extra: {
        'allowedTypes': [GrammarQuestionType.reverseMultipleChoice],
      },
    );
    await tester.pumpAndSettle();
    expect(find.text('Session: Mastery'), findsOneWidget);
    expect(find.text('Source: Practice queue'), findsOneWidget);
  });
}
