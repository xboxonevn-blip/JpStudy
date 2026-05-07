import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/session_storage.dart';
import 'package:jpstudy/core/services/session_storage_provider.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/learn/models/learn_config.dart';
import 'package:jpstudy/features/learn/models/learn_session.dart';
import 'package:jpstudy/features/learn/models/question.dart';
import 'package:jpstudy/features/learn/models/question_type.dart';
import 'package:jpstudy/features/learn/providers/learn_session_provider.dart';
import 'package:jpstudy/features/learn/screens/learn_screen.dart';
import 'package:jpstudy/features/learn/screens/learn_summary_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CapturingSessionStorage extends SessionStorage {
  final savedSnapshots = <LearnSessionSnapshot>[];
  final clearedLessonIds = <int>[];
  @override
  Future<void> saveLearnSession({required LearnSessionSnapshot snapshot}) async => savedSnapshots.add(snapshot);
  @override
  Future<void> clearLearnSession(int lessonId) async => clearedLessonIds.add(lessonId);
  @override
  Future<LearnSessionSnapshot?> loadLearnSession(int lessonId) async => null;
}

class TestLearnSessionNotifier extends LearnSessionNotifier {
  @override
  LearnSession? build() => null;
  @override
  void startSession({required int lessonId, required List<VocabItem> items, int questionCount = 20, bool shuffleQuestions = true, AppLanguage language = AppLanguage.en, List<QuestionType> enabledTypes = const [QuestionType.multipleChoice, QuestionType.trueFalse, QuestionType.fillBlank]}) {
    state = LearnSession(sessionId: 'test-session', lessonId: lessonId, startedAt: DateTime(2026, 1, 1), questions: [for (var i = 0; i < questionCount; i++) q(enabledTypes[i % enabledTypes.length], i)]);
  }
  @override
  Future<QuestionResult?> submitAnswer(String answer) async {
    final s = state, cq = state?.currentQuestion;
    if (s == null || cq == null) return null;
    final r = QuestionResult(question: cq, userAnswer: answer, isCorrect: cq.checkAnswer(answer), timeTaken: const Duration(seconds: 1), answeredAt: DateTime(2026, 1, 1));
    s.recordResult(r);
    state = s.copyWith(results: List<QuestionResult>.from(s.results));
    return r;
  }
  @override
  Future<void> nextQuestion() async {
    final s = state;
    if (s == null) return;
    state = s.currentQuestionIndex < s.questions.length - 1 ? s.copyWith(currentQuestionIndex: s.currentQuestionIndex + 1) : s.copyWith(completedAt: DateTime(2026, 1, 1, 0, 1));
  }
  @override
  void requeueQuestion(Question question) {
    final s = state;
    if (s != null) state = s.copyWith(questions: [...s.questions, question]);
  }
}

VocabItem item(int id) => VocabItem(id: id, term: '水$id', reading: 'みず$id', meaning: 'nước$id', meaningEn: 'water$id', mnemonicEn: 'hint$id', level: 'n5');
Question q(QuestionType type, int i) => Question(id: '${type.name}-$i', type: type, targetItem: item(i + 1), questionText: type == QuestionType.trueFalse ? 'This means water' : type == QuestionType.fillBlank ? 'Type meaning' : 'Choose meaning', correctAnswer: type == QuestionType.trueFalse ? 'true' : 'water', options: type == QuestionType.multipleChoice ? const ['water', 'fire'] : null, isStatementTrue: type == QuestionType.trueFalse ? true : null, hint: type == QuestionType.fillBlank ? 'w___r' : null);
LearnConfig cfg(QuestionType type, {int count = 1}) => LearnConfig(questionCount: count, enabledTypes: [type], shuffleQuestions: false);
const dash = DashboardState(streak: 0, todayXp: 0, vocabDue: 0, grammarDue: 0, kanjiDue: 0, vocabMistakeCount: 0, grammarMistakeCount: 0, kanjiMistakeCount: 0, totalMistakeCount: 0);

Future<ProviderContainer> pumpLearnScreen(WidgetTester tester, {required LearnConfig config, LearnSessionSnapshot? resumeSnapshot, CapturingSessionStorage? storage}) async {
  final c = ProviderContainer(overrides: [appLanguageProvider.overrideWith((ref) => AppLanguage.en), sessionStorageProvider.overrideWithValue(storage ?? CapturingSessionStorage()), learnSessionProvider.overrideWith(TestLearnSessionNotifier.new), dashboardProvider.overrideWith((ref) => Stream.value(dash))]);
  addTearDown(c.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: c, child: MaterialApp(home: LearnScreen(items: List.generate(5, item), lessonId: 1, lessonTitle: 'Test', config: config, resumeSnapshot: resumeSnapshot))));
  return c;
}

LearnSessionSnapshot resumeSnap() {
  final qs = [q(QuestionType.multipleChoice, 0), q(QuestionType.multipleChoice, 1)];
  return LearnSessionSnapshot(lessonId: 1, sessionId: 'resume-session', startedAt: DateTime(2026, 1, 1), currentRound: 1, currentQuestionIndex: 1, questions: qs, results: [QuestionResult(question: qs.first, userAnswer: 'water', isCorrect: true, timeTaken: const Duration(seconds: 1), answeredAt: DateTime(2026, 1, 1))], config: cfg(QuestionType.multipleChoice, count: 2), contextHintsShown: const {}, contextHintsRequeued: const {}, wrongRequeued: const {}, lastSavedAt: DateTime(2026, 1, 1));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('LearnScreen shows loading indicator when session is null', (tester) async {
    await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LearnScreen starts fresh session when no resume snapshot', (tester) async {
    final storage = CapturingSessionStorage();
    final c = await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice, count: 3), storage: storage);
    await tester.pumpAndSettle();
    expect(c.read(learnSessionProvider)!.questions, hasLength(3));
    expect(storage.savedSnapshots.single.questions, hasLength(3));
  });

  testWidgets('LearnScreen restores session from resume snapshot', (tester) async {
    final c = await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice, count: 2), resumeSnapshot: resumeSnap());
    await tester.pumpAndSettle();
    expect(c.read(learnSessionProvider)!.currentQuestionIndex, 1);
  });

  testWidgets('Multiple choice tap shows result UI for the chosen option', (tester) async {
    await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice));
    await tester.pumpAndSettle();
    await tester.tap(find.text('fire'));
    await tester.pumpAndSettle();
    expect(find.text(AppLanguage.en.willRetryLabel), findsOneWidget);
  });

  testWidgets('True/false tap shows result UI', (tester) async {
    await pumpLearnScreen(tester, config: cfg(QuestionType.trueFalse));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.trueLabel));
    await tester.pumpAndSettle();
    expect(find.text(AppLanguage.en.continueLabel), findsOneWidget);
  });

  testWidgets('Fill blank submit shows result UI', (tester) async {
    await pumpLearnScreen(tester, config: cfg(QuestionType.fillBlank));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'water');
    await tester.tap(find.text(AppLanguage.en.checkAnswerLabel));
    await tester.pumpAndSettle();
    expect(find.text(AppLanguage.en.continueLabel), findsOneWidget);
  });

  testWidgets('Wrong answer is added to _wrongRequeued tracking', (tester) async {
    final storage = CapturingSessionStorage();
    await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice), storage: storage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('fire'));
    await tester.pumpAndSettle();
    expect(storage.savedSnapshots.last.wrongRequeued, contains('multipleChoice-0'));
  });

  testWidgets('Session completion navigates to LearnSummaryScreen', (tester) async {
    final storage = CapturingSessionStorage();
    await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice), storage: storage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('water'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppLanguage.en.continueLabel));
    await tester.pumpAndSettle();
    expect(find.byType(LearnSummaryScreen), findsOneWidget);
    expect(storage.clearedLessonIds, contains(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Snapshot is saved after meaningful state change', (tester) async {
    final storage = CapturingSessionStorage();
    await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice), storage: storage);
    await tester.pumpAndSettle();
    await tester.tap(find.text('water'));
    await tester.pumpAndSettle();
    expect(storage.savedSnapshots.last.results.single.userAnswer, 'water');
  });

  testWidgets('Unmount during postFrameCallback does not crash', (tester) async {
    await pumpLearnScreen(tester, config: cfg(QuestionType.multipleChoice));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
