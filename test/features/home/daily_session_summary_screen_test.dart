import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/home/providers/coach_session_provider.dart';
import 'package:jpstudy/features/home/providers/continue_provider.dart';
import 'package:jpstudy/features/home/providers/daily_session_progress_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart'
    show dashboardProvider, DashboardState;
import 'package:jpstudy/features/home/screens/daily_session_summary_screen.dart';
import 'package:jpstudy/features/vocab/vocab_ghost_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDashboard = DashboardState(
  streak: 0,
  todayXp: 30,
  vocabDue: 2,
  grammarDue: 1,
  kanjiDue: 0,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

const _kProgress = DailySessionProgress(
  dateKey: '2026-03-24',
  started: true,
  doneSteps: {3},
  lastRoute: '/practice',
  updatedAt: null,
);

const _kCoachPlan = CoachSessionPlan(
  step1: CoachStep(
    target: 'Review 3 due items',
    detail: '2 vocab · 1 grammar',
    icon: Icons.schedule_rounded,
    color: Color(0xFF2563EB),
  ),
  step2: CoachStep(
    target: 'No weak spots left',
    detail: null,
    icon: Icons.verified_outlined,
    color: Color(0xFF16A34A),
  ),
  step3: CoachStep(
    target: 'Read an immersion article',
    detail: 'Save unknown words to grow your SRS queue',
    icon: Icons.article_rounded,
    color: Color(0xFF059669),
  ),
);

const _kContinueAction = ContinueAction(
  type: ContinueActionType.practiceMixed,
  label: 'Practice',
);

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const DailySessionSummaryScreen()),
  ],
);

Widget buildScreen() => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith((ref) => AppLanguage.en),
    dashboardProvider.overrideWith((ref) => Stream.value(_kDashboard)),
    dailySessionProgressProvider.overrideWith((ref) async => _kProgress),
    coachSessionPlanProvider.overrideWith((ref) => _kCoachPlan),
    continueActionProvider.overrideWith((ref) async => _kContinueAction),
    vocabGhostsProvider.overrideWith((ref) async => const []),
  ],
  child: MaterialApp.router(routerConfig: _router),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Daily Coach Summary title', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Daily Coach Summary'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows Session complete hero title', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Session complete!'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('shows summary line with percent', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text("You closed 67% of today's guided session."),
      findsOneWidget,
    );
    await tester.pumpWidget(Container());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
