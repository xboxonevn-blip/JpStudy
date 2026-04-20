import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart' as domain;
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/providers/learn_session_provider.dart';
import 'package:jpstudy/features/learn/services/learn_session_service.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';

class _RecordingLearnSessionService extends LearnSessionService {
  _RecordingLearnSessionService(super.learnDao, super.achievementDao);

  bool shouldThrow = false;
  int saveCallCount = 0;

  @override
  Future<void> saveSession(domain.LearnSession session) async {
    saveCallCount++;
    if (shouldThrow) {
      throw StateError('saveSession failed');
    }
    return super.saveSession(session);
  }
}

Question _question(int id) => Question(
      id: 'q$id',
      type: QuestionType.multipleChoice,
      targetItem: VocabItem(
        id: id,
        term: 'term$id',
        meaning: 'meaning$id',
        level: 'N5',
      ),
      questionText: 'q$id?',
      correctAnswer: 'meaning$id',
    );

domain.LearnSession _singleQuestionSession() => domain.LearnSession(
      sessionId: 'sess-${DateTime.now().microsecondsSinceEpoch}',
      lessonId: 1,
      startedAt: DateTime(2025, 1, 1),
      questions: [_question(1)],
    );

void main() {
  late AppDatabase db;
  late _RecordingLearnSessionService service;
  late MistakeRepository mistakeRepo;
  late LearnSessionNotifier notifier;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    service = _RecordingLearnSessionService(LearnDao(db), AchievementDao(db));
    mistakeRepo = MistakeRepository(db.mistakeDao);
    notifier = LearnSessionNotifier(service, mistakeRepo);
  });

  tearDown(() async {
    notifier.dispose();
    await db.close();
  });

  group('nextQuestion at the final question', () {
    test('returns a Future that resolves only after saveSession completes',
        () async {
      notifier.restoreSession(_singleQuestionSession());
      expect(notifier.state!.currentQuestionIndex, equals(0));
      expect(notifier.state!.isComplete, isFalse);

      // Awaiting nextQuestion must guarantee the session has been persisted.
      // Returning a Future<void> is the contract that lets callers await
      // the persistence step before navigating away or unmounting.
      final result = notifier.nextQuestion();
      expect(result, isA<Future<void>>(),
          reason:
              'nextQuestion must return a Future so callers can await persistence');
      await result;

      expect(service.saveCallCount, equals(1),
          reason: 'awaited nextQuestion must persist the session exactly once');
      expect(notifier.state!.isComplete, isTrue,
          reason: 'state should reflect completion after a successful save');
    });
  });

  group('saveSession failure', () {
    test('state stays uncompleted when persistence throws', () async {
      service.shouldThrow = true;
      notifier.restoreSession(_singleQuestionSession());

      await expectLater(notifier.nextQuestion(), throwsA(isA<StateError>()));

      expect(notifier.state!.isComplete, isFalse,
          reason:
              'persist-then-mutate: a failed save must not leave state showing complete');
      expect(notifier.state!.completedAt, isNull);
    });
  });
}
