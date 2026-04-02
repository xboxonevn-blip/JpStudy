import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/home/providers/backup_status_provider.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/home/widgets/discover_practice_panel.dart';

void main() {
  DashboardState buildDashboard({int mistakes = 0}) {
    return DashboardState(
      streak: 0,
      todayXp: 0,
      vocabDue: 0,
      grammarDue: 0,
      kanjiDue: 0,
      vocabMistakeCount: 0,
      grammarMistakeCount: 0,
      kanjiMistakeCount: mistakes,
      totalMistakeCount: mistakes,
    );
  }

  test('backup status reports fresh/old correctly', () {
    final fresh = BackupStatus(enabled: true, lastBackupAt: DateTime.now());
    expect(fresh.isStale, isFalse);

    final old = BackupStatus(
      enabled: true,
      lastBackupAt: DateTime.now().subtract(const Duration(days: 4)),
    );
    expect(old.isStale, isTrue);
  });

  testWidgets('discover panel expands and collapses', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith((_) => Stream.value(buildDashboard())),
          grammarGhostCountProvider.overrideWith((_) async* {
            yield 0;
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: DiscoverPracticePanel()),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedCrossFade>(
            find.byKey(const ValueKey('discover_practice_body')),
          )
          .crossFadeState,
      CrossFadeState.showFirst,
    );

    await tester.tap(find.byKey(const ValueKey('discover_practice_toggle')));
    await tester.pumpAndSettle(const Duration(milliseconds: 240));
    expect(
      tester
          .widget<AnimatedCrossFade>(
            find.byKey(const ValueKey('discover_practice_body')),
          )
          .crossFadeState,
      CrossFadeState.showSecond,
    );

    await tester.tap(find.byKey(const ValueKey('discover_practice_toggle')));
    await tester.pumpAndSettle(const Duration(milliseconds: 240));
    expect(
      tester
          .widget<AnimatedCrossFade>(
            find.byKey(const ValueKey('discover_practice_body')),
          )
          .crossFadeState,
      CrossFadeState.showFirst,
    );
  });
}
