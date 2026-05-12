import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/flashcards/models/flashcard_session.dart';
import 'package:jpstudy/features/flashcards/widgets/flashcard_summary.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart'
    show dashboardProvider, DashboardState;
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
const _kEmptyDashboard = DashboardState(
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

const _kContinueAction = ContinueAction(
  type: ContinueActionType.practiceMixed,
  label: 'Practice',
);

FlashcardSession _session({
  List<int> known = const [],
  List<int> needPractice = const [],
}) => FlashcardSession(
  sessionId: 'test',
  lessonId: 1,
  startedAt: DateTime(2026, 1, 1, 10),
  completedAt: DateTime(2026, 1, 1, 10, 5),
  knownTermIds: known,
  needPracticeTermIds: needPractice,
);

Widget buildSummary(FlashcardSession session) => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith(
      (ref) => AppLanguageController.test(AppLanguage.en),
    ),
    dashboardProvider.overrideWith((ref) => Stream.value(_kEmptyDashboard)),
    vocabGhostsProvider.overrideWith((ref) async => const []),
    continueActionProvider.overrideWith((ref) async => _kContinueAction),
  ],
  child: MaterialApp(home: FlashcardSummaryScreen(session: session)),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows "Session Complete!" in AppBar', (tester) async {
    await tester.pumpWidget(buildSummary(_session()));
    await tester.pump();
    expect(find.text('Session Complete!'), findsOneWidget);
    // Flush any pending async work before teardown
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows accuracy percentage', (tester) async {
    final session = _session(known: [1, 2, 3, 4], needPractice: [5, 6]);
    await tester.pumpWidget(buildSummary(session));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // 4 known / 6 total = 66%
    expect(find.text('66%'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows 100% when all cards known', (tester) async {
    final session = _session(known: [1, 2, 3]);
    await tester.pumpWidget(buildSummary(session));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('100%'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows Done button', (tester) async {
    await tester.pumpWidget(buildSummary(_session(known: [1])));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Done'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
