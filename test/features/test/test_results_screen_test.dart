import 'package:drift/native.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_provider.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/auth/auth_user.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/auto_cloud_upload_coordinator.dart';
import 'package:jpstudy/core/services/cloud_storage_sync_service.dart';
import 'package:jpstudy/data/db/app_database.dart' as app_db;
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/me/providers/auto_cloud_upload_provider.dart';
import 'package:jpstudy/features/test/models/test_session.dart' as test_model;
import 'package:jpstudy/features/test/screens/test_results_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:jpstudy/shared/widgets/confidence_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCloudStorageSyncService implements CloudStorageSyncService {
  int uploadCalls = 0;

  @override
  Future<CloudStorageUploadResult> uploadEnvelope(
    Map<String, dynamic> envelope,
  ) async {
    uploadCalls += 1;
    return const CloudStorageUploadResult(
      decision: CloudStorageUploadDecision.uploaded,
    );
  }

  @override
  Future<CloudStorageDownloadResult> prepareDownload({
    String? passphrase,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<CloudStorageDeleteResult> deleteRemoteBackup() async {
    throw UnimplementedError();
  }
}

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final events = <String>[];
  final params = <Map<String, Object>?>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    events.add(name);
    params.add(parameters);
  }
}

const _item = VocabItem(
  id: 1,
  term: '水',
  reading: 'みず',
  meaning: 'water',
  meaningEn: 'water',
  level: 'N5',
);

const _question1 = Question(
  id: 'q1',
  type: QuestionType.multipleChoice,
  targetItem: _item,
  questionText: 'What does 水 mean?',
  correctAnswer: 'water',
  options: ['water', 'fire'],
);

const _question2 = Question(
  id: 'q2',
  type: QuestionType.trueFalse,
  targetItem: _item,
  questionText: '水 means fire.',
  correctAnswer: 'false',
  isStatementTrue: false,
);

final _session = test_model.TestSession(
  sessionId: 'test_1',
  lessonId: 1,
  startedAt: DateTime(2026, 3, 24, 10),
  completedAt: DateTime(2026, 3, 24, 10, 5),
  questions: const [_question1, _question2],
  answers: const [
    test_model.TestAnswer(
      questionIndex: 0,
      userAnswer: 'water',
      isCorrect: true,
    ),
    test_model.TestAnswer(
      questionIndex: 1,
      userAnswer: 'true',
      isCorrect: false,
    ),
  ],
);

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

const _continueAction = ContinueAction(
  type: ContinueActionType.practiceMixed,
  label: 'practice',
);

late SharedPreferences _prefs;

AutoCloudUploadCoordinator _autoUpload({
  required _FakeCloudStorageSyncService storage,
  AuthUser? user,
}) => AutoCloudUploadCoordinator(
  cloudStorageSync: storage,
  envelopeBuilder: () async => {'version': 2},
  authState: () => user,
  preferences: _prefs,
);

Widget buildScreen(
  app_db.AppDatabase db, {
  AutoCloudUploadCoordinator? autoUpload,
  AnalyticsService? analyticsService,
}) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    databaseProvider.overrideWithValue(db),
    autoCloudUploadProvider.overrideWithValue(
      autoUpload ??
          _autoUpload(storage: _FakeCloudStorageSyncService(), user: null),
    ),
    if (analyticsService != null)
      analyticsServiceProvider.overrideWithValue(analyticsService),
    recoveryPackProvider.overrideWith((ref) async => null),
    dashboardProvider.overrideWith((ref) => Stream.value(_dashboard)),
    continueActionProvider.overrideWith((ref) async => _continueAction),
    grammarGhostCountProvider.overrideWith((ref) async* {
      yield 0;
    }),
    vocabGhostCountProvider.overrideWith((ref) async* {
      yield 0;
    }),
    vocabGhostsProvider.overrideWith((ref) async => const []),
  ],
  child: MaterialApp(
    home: TestResultsScreen(session: _session, lessonTitle: 'Lesson 1'),
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('shows test results title and score summary', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(AppLanguage.en.testResultsTitle), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(
      find.text(AppLanguage.en.testCorrectSummaryLabel(1, 2)),
      findsOneWidget,
    );

    await tester.pumpWidget(Container());
    await tester.pump();
  });

  testWidgets('shows grade and XP earned', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(buildScreen(db));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('F'), findsOneWidget);
    expect(find.text('+5 XP'), findsOneWidget);

    await tester.pumpWidget(Container());
    await tester.pump();
  });

  testWidgets(
    'does not auto cloud upload while beta cloud backup is disabled',
    (tester) async {
      final db = app_db.AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);
      final storage = _FakeCloudStorageSyncService();

      await tester.pumpWidget(
        buildScreen(
          db,
          autoUpload: _autoUpload(
            storage: storage,
            user: const AuthUser(uid: 'uid-1'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(storage.uploadCalls, 0);
    },
  );

  testWidgets('rating test quality logs analytics event', (tester) async {
    final db = app_db.AppDatabase(executor: NativeDatabase.memory());
    addTearDown(db.close);
    final fakeAnalytics = _FakeFirebaseAnalytics();

    await tester.pumpWidget(
      buildScreen(
        db,
        analyticsService: AnalyticsService(
          instance: fakeAnalytics,
          enabled: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(StarRating), findsOneWidget);
    await tester.tap(find.byIcon(Icons.star_border_rounded).at(3));
    await tester.pump();

    expect(fakeAnalytics.events, contains('session_quality_rated'));
    expect(fakeAnalytics.params.last, {'mode': 'test', 'rating': 4});
  });
}
