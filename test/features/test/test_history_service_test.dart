import 'package:drift/native.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/analytics/analytics_service.dart';
import 'package:jpstudy/data/daos/test_dao.dart';
import 'package:jpstudy/data/db/app_database.dart' show AppDatabase;
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/test/models/test_session.dart';
import 'package:jpstudy/features/test/services/test_history_service.dart';

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

void main() {
  late AppDatabase db;
  late _FakeFirebaseAnalytics fakeAnalytics;
  late TestHistoryService service;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    fakeAnalytics = _FakeFirebaseAnalytics();
    service = TestHistoryService(
      TestDao(db),
      analyticsService: AnalyticsService(
        instance: fakeAnalytics,
        enabled: true,
      ),
    );
  });

  tearDown(() => db.close());

  test('saveTest logs N5 micro-quiz completion for N5 lessons', () async {
    await service.saveTest(_session(lessonId: 1));

    expect(fakeAnalytics.events, ['n5_micro_quiz_completed']);
    expect(fakeAnalytics.params.single, {
      'correct_count': 7,
      'total_count': 10,
      'accuracy': 0.7,
    });
  });

  test(
    'saveTest does not log N5 micro-quiz completion for N4 lessons',
    () async {
      await service.saveTest(_session(lessonId: 26));

      expect(fakeAnalytics.events, isEmpty);
    },
  );
}

TestSession _session({required int lessonId}) {
  final questions = [
    for (var index = 0; index < 10; index++)
      Question(
        id: 'q$index',
        type: QuestionType.multipleChoice,
        targetItem: VocabItem(
          id: index + 1,
          term: 'term$index',
          meaning: 'meaning$index',
          level: 'N5',
        ),
        questionText: 'question $index',
        correctAnswer: 'A',
        options: const ['A', 'B', 'C', 'D'],
      ),
  ];

  return TestSession(
    sessionId: 'session-$lessonId',
    lessonId: lessonId,
    startedAt: DateTime(2026, 5, 1, 8),
    completedAt: DateTime(2026, 5, 1, 8, 5),
    questions: questions,
    answers: [
      for (var index = 0; index < 10; index++)
        TestAnswer(
          questionIndex: index,
          userAnswer: index < 7 ? 'A' : 'B',
          isCorrect: index < 7,
          answeredAt: DateTime(2026, 5, 1, 8, index),
        ),
    ],
  );
}
