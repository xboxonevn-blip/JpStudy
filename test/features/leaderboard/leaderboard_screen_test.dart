import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/leaderboard/leaderboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Suppress share_plus platform channel calls in tests.
void _mockShareChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/share'),
    (_) async => null,
  );
}

Widget _buildScreen({AppLanguage language = AppLanguage.en}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => language),
      dashboardProvider.overrideWith(
        (ref) => Stream.value(
          const DashboardState(
            streak: 7,
            todayXp: 120,
            vocabDue: 0,
            grammarDue: 0,
            kanjiDue: 0,
            vocabMistakeCount: 0,
            grammarMistakeCount: 0,
            kanjiMistakeCount: 0,
            totalMistakeCount: 0,
          ),
        ),
      ),
      progressSummaryProvider.overrideWith(
        (_) async => const ProgressSummary(
          totalXp: 5000,
          todayXp: 120,
          streak: 7,
          longestStreak: 14,
          totalDaysStudied: 30,
          totalAttempts: 10,
          totalCorrect: 85,
          totalQuestions: 100,
        ),
      ),
      reviewHistoryProvider.overrideWith((_) async => const []),
      attemptHistoryProvider.overrideWith((_) async => const []),
    ],
    child: const MaterialApp(home: LeaderboardScreen()),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _mockShareChannel();
  });

  testWidgets('leaderboard screen renders title and metric pills', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('League'), findsOneWidget);
  });

  testWidgets('"Join challenge" tap shows snackbar (still a stub)', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.ensureVisible(find.text('Join challenge'));
    await _pump(tester);

    await tester.tap(find.text('Join challenge'));
    await _pump(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.textContaining('Challenge enrollment'),
      findsOneWidget,
    );
  });

  testWidgets('"Share snapshot" tap does NOT show a snackbar', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.ensureVisible(find.text('Share snapshot'));
    await _pump(tester);

    await tester.tap(find.text('Share snapshot'));
    await _pump(tester);

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('top learners list shows AoiSensei and You', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    await tester.scrollUntilVisible(
      find.text('AoiSensei'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await _pump(tester);

    expect(find.text('AoiSensei'), findsOneWidget);
    // "You" row appears for EN locale
    expect(find.text('You'), findsOneWidget);
  });

  testWidgets('VI locale shows Vietnamese labels', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Xếp hạng'), findsOneWidget);
    expect(find.text('Share snapshot'), findsNothing);
    expect(find.text('Chia sẻ snapshot'), findsOneWidget);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('ランキング'), findsOneWidget);
  });
}
