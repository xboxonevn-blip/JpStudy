import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/features/grammar/grammar_providers.dart';
import 'package:jpstudy/features/grammar/models/grammar_point_data.dart';
import 'package:jpstudy/features/grammar/screens/ghost_review_screen.dart';
import 'package:jpstudy/features/mistakes/repositories/mistake_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const _kPoint = GrammarPoint(
  id: 1,
  grammarPoint: 'てもいい',
  meaning: 'được phép',
  meaningVi: 'được phép',
  meaningEn: 'is okay to do',
  connection: 'V-て + もいい',
  explanation: 'Expresses permission to do something.',
  explanationVi: 'Dùng để diễn đạt sự cho phép.',
  explanationEn: 'Use this pattern to express that something is allowed.',
  jlptLevel: 'N5',
  isLearned: false,
);

// GrammarPointData has no const constructor — top-level final is fine
final _stubGhost = GrammarPointData(point: _kPoint, examples: const []);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen({
  AppLanguage language = AppLanguage.en,
  List<GrammarPointData>? ghosts,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => language),
      grammarGhostsProvider.overrideWith((_) async => ghosts ?? []),
      mistakesByTypeProvider('grammar').overrideWith(
        (_) async => const <UserMistake>[],
      ),
    ],
    child: const MaterialApp(home: GhostReviewScreen()),
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

  testWidgets('empty state shows empty title and subtitle', (tester) async {
    await tester.pumpWidget(_buildScreen(ghosts: const []));
    await _pump(tester);

    expect(find.text('No mistakes yet'), findsOneWidget);
    expect(find.text('You have not missed any grammar yet.'), findsOneWidget);
  });

  testWidgets('non-empty ghosts renders card with grammar point headline',
      (tester) async {
    await tester.pumpWidget(
      _buildScreen(language: AppLanguage.vi, ghosts: [_stubGhost]),
    );
    await _pump(tester);

    // VI locale uses grammarPoint directly as the card headline
    expect(find.text('てもいい'), findsOneWidget);
  });

  testWidgets('info button tap shows ghost review info snackbar',
      (tester) async {
    await tester.pumpWidget(_buildScreen(ghosts: const []));
    await _pump(tester);

    await tester.tap(find.byIcon(Icons.info_outline));
    await _pump(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Review grammar you missed recently.'), findsOneWidget);
  });

  testWidgets('FAB is visible when ghosts list is non-empty', (tester) async {
    await tester.pumpWidget(_buildScreen(ghosts: [_stubGhost]));
    await _pump(tester);

    // EN practiceGhostsLabel = 'Practice'
    expect(find.text('Practice'), findsOneWidget);
  });

  testWidgets('FAB is absent when ghosts list is empty', (tester) async {
    await tester.pumpWidget(_buildScreen(ghosts: const []));
    await _pump(tester);

    expect(find.text('Practice'), findsNothing);
  });

  testWidgets('tapping card expands to show connection section label',
      (tester) async {
    await tester.pumpWidget(_buildScreen(ghosts: [_stubGhost]));
    await _pump(tester);

    // Before expansion, the section labels are not rendered
    expect(find.text('CONNECTION'), findsNothing);

    // EN locale headline resolves to the connection value 'V-て + もいい'
    await tester.tap(find.textContaining('V-て'), warnIfMissed: false);
    await _pump(tester);

    // After expansion, section labels appear uppercased
    expect(find.text('CONNECTION'), findsOneWidget);
  });

  testWidgets('VI locale shows Vietnamese app bar title', (tester) async {
    await tester.pumpWidget(
      _buildScreen(language: AppLanguage.vi, ghosts: const []),
    );
    await _pump(tester);

    expect(find.text('Ôn lỗi ngữ pháp'), findsWidgets);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(
      _buildScreen(language: AppLanguage.ja, ghosts: const []),
    );
    await _pump(tester);

    expect(find.text('文法ミス復習'), findsWidgets);
  });
}
