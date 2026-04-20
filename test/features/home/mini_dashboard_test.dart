import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/mini_dashboard.dart';

// ---------------------------------------------------------------------------
// Why these tests exist
// ---------------------------------------------------------------------------
// MiniDashboard is the ONLY consumer of dashboardProvider that explicitly
// handles the .error branch (every other caller uses valueOrNull to silently
// degrade). When the stream fails, the user needs an actionable surface:
//   1. A readable, localized message
//   2. A Retry button that re-runs the provider
//
// These tests pin that behaviour so a future refactor cannot silently drop
// the retry path (e.g. reverting to a decorative EmptyStateWidget with no
// action).
// ---------------------------------------------------------------------------

const _kDashboard = DashboardState(
  streak: 7,
  todayXp: 42,
  vocabDue: 0,
  grammarDue: 0,
  kanjiDue: 0,
  vocabMistakeCount: 0,
  grammarMistakeCount: 0,
  kanjiMistakeCount: 0,
  totalMistakeCount: 0,
);

Widget _host({
  required List<Override> overrides,
}) =>
    ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        grammarGhostCountProvider.overrideWith((ref) async* {
          yield 0;
        }),
        ...overrides,
      ],
      child: const MaterialApp(
        home: Scaffold(body: MiniDashboard(compact: true)),
      ),
    );

void main() {
  group('MiniDashboard error state', () {
    testWidgets(
      'shows localized error message and a Retry button when the stream fails',
      (tester) async {
        await tester.pumpWidget(
          _host(
            overrides: [
              dashboardProvider.overrideWith(
                (ref) => Stream<DashboardState>.error(Exception('boom')),
              ),
            ],
          ),
        );

        // Flush the error microtask into AsyncError.
        await tester.pump();

        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
          reason: 'generic error message should be visible',
        );
        expect(
          find.text('Retry'),
          findsOneWidget,
          reason: 'retry action must be reachable from the error state',
        );
      },
    );

    testWidgets(
      'tapping Retry re-runs the provider and the recovered data replaces the error UI',
      (tester) async {
        var callCount = 0;
        await tester.pumpWidget(
          _host(
            overrides: [
              // First build: error. After invalidate → second build: data.
              dashboardProvider.overrideWith((ref) {
                callCount++;
                return callCount == 1
                    ? Stream<DashboardState>.error(
                        Exception('first build fails'),
                      )
                    : Stream.value(_kDashboard);
              }),
            ],
          ),
        );

        // First error.
        await tester.pump();
        expect(find.text('Retry'), findsOneWidget);
        expect(callCount, equals(1));

        // User taps Retry → ref.invalidate(dashboardProvider) → builder re-runs.
        await tester.tap(find.text('Retry'));
        await tester.pump(); // schedule invalidate → next frame
        await tester.pump(); // data stream emits

        expect(
          callCount,
          equals(2),
          reason: 'onRetry must invalidate the provider so it rebuilds',
        );
        expect(
          find.text('Retry'),
          findsNothing,
          reason: 'success state replaces the error UI',
        );
        expect(
          find.text('7'),
          findsOneWidget,
          reason: 'streak value from recovered DashboardState should render',
        );
      },
    );
  });
}
