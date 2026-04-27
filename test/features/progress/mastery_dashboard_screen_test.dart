import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/progress/providers/mastery_provider.dart';
import 'package:jpstudy/features/progress/screens/mastery_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _kN5Vocab = CategoryMastery(
  total: 100,
  studied: 60,
  learning: 10,
  young: 20,
  mature: 30,
);

const _kN5Grammar = CategoryMastery(
  total: 50,
  studied: 40,
  learning: 5,
  young: 10,
  mature: 25,
);

const _kN5Kanji = CategoryMastery(
  total: 80,
  studied: 50,
  learning: 8,
  young: 12,
  mature: 30,
);

const _kN5 = LevelMastery(
  level: 'N5',
  vocab: _kN5Vocab,
  grammar: _kN5Grammar,
  kanji: _kN5Kanji,
);

/// totalItems=230, totalStudied=150, totalMature=85  →  37%
const _kSnapshot = MasterySnapshot(levels: [_kN5]);

const _kEmptySnapshot = MasterySnapshot(levels: []);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({
  AppLanguage language = AppLanguage.en,
  MasterySnapshot? snapshot,
  Object? error,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => language),
      masterySnapshotProvider.overrideWith((_) async {
        if (error != null) throw error;
        return snapshot ?? _kSnapshot;
      }),
    ],
    child: const MaterialApp(home: MasteryDashboardScreen()),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders app bar title and hero card with overall stats',
      (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    // AppBar title
    expect(find.text('JLPT Mastery'), findsWidgets);
    // Hero subtitle shows correct mastered/total
    expect(find.textContaining('85 of 230'), findsOneWidget);
    // Overall percentage chip
    expect(find.text('37%'), findsWidgets);
  });

  testWidgets('overall progress rings show studied/mastered/total values',
      (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('150'), findsOneWidget); // Studied ring value
    expect(find.text('85'), findsWidgets);   // Mastered ring value (also in level card)
    expect(find.text('230'), findsOneWidget); // Total ring value
    expect(find.text('Studied'), findsOneWidget);
    expect(find.text('Mastered'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('renders per-level mastery card for N5', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('N5'), findsWidgets);
    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Kanji'), findsOneWidget);
  });

  testWidgets('empty snapshot renders 0% overall stats', (tester) async {
    await tester.pumpWidget(_buildScreen(snapshot: _kEmptySnapshot));
    await _pump(tester);

    // With no levels, totals are all 0 → 0%
    expect(find.text('0%'), findsWidgets);
    expect(find.textContaining('0 of 0'), findsOneWidget);
  });

  testWidgets('error state renders friendly error widget', (tester) async {
    await tester.pumpWidget(
      _buildScreen(error: Exception('DB failure')),
    );
    await _pump(tester);

    // ErrorStateWidget maps unknown errors to the generic label
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('VI locale shows Vietnamese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Tiến độ JLPT'), findsWidgets);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('JLPT 習熟度'), findsWidgets);
  });
}
