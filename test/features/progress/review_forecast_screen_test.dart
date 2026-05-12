import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/progress/providers/review_forecast_provider.dart';
import 'package:jpstudy/features/progress/screens/review_forecast_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

// 14 days starting today — day-0 has 5 vocab, days 1-13 have 2 vocab each.
// weekTotal (first 7) = 5 + 6*2 = 17.
final _kDays = List.generate(
  14,
  (i) => ForecastDay(
    date: DateTime(2026, 4, 28).add(Duration(days: i)),
    vocabDue: i == 0 ? 5 : 2,
  ),
);

const _kBuckets = [
  StabilityBucket(
    label: 'Critical',
    minStability: 0,
    maxStability: 2,
    vocabCount: 10,
  ),
  StabilityBucket(
    label: 'Weak',
    minStability: 2,
    maxStability: 7,
    grammarCount: 5,
  ),
  StabilityBucket(
    label: 'Growing',
    minStability: 7,
    maxStability: 21,
    kanjiCount: 8,
  ),
  StabilityBucket(
    label: 'Strong',
    minStability: 21,
    maxStability: 60,
    vocabCount: 15,
  ),
  StabilityBucket(
    label: 'Mastered',
    minStability: 60,
    maxStability: 999,
    vocabCount: 20,
  ),
];

const _kConfidence = ConfidenceBreakdown(
  again: 5,
  hard: 10,
  good: 20,
  easy: 15,
);

// totalTracked=58, totalDueNow=5, avgStability=12.5
final _kForecast = ReviewForecast(
  days: _kDays,
  stabilityBuckets: _kBuckets,
  confidence: _kConfidence,
  totalTracked: 58,
  totalDueNow: 5,
  avgStability: 12.5,
);

// Empty confidence snapshot — confidence section should be hidden.
final _kForecastNoConfidence = ReviewForecast(
  days: _kDays,
  stabilityBuckets: _kBuckets,
  confidence: const ConfidenceBreakdown(),
  totalTracked: 58,
  totalDueNow: 5,
  avgStability: 12.5,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// The _LegendDot widget uses Theme.of(context).extension<AppThemePalette>()!
// (no null fallback), so we must provide the extension in the test theme.
final _kTheme = ThemeData.light().copyWith(
  extensions: const [AppThemePalette.light],
);

Widget _buildScreen({
  AppLanguage language = AppLanguage.en,
  ReviewForecast? forecast,
  Object? error,
}) {
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      reviewForecastProvider.overrideWith((_) async {
        if (error != null) throw error;
        return forecast ?? _kForecast;
      }),
    ],
    child: MaterialApp(theme: _kTheme, home: const ReviewForecastScreen()),
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

  testWidgets('renders app bar title and hero stats', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Review Forecast'), findsWidgets);
    // Hero stat values
    expect(find.text('5'), findsWidgets); // Due Today = totalDueNow
    expect(find.text('17'), findsOneWidget); // This Week = weekTotal
    expect(find.text('58'), findsOneWidget); // Tracked = totalTracked
    // Hero stat labels
    expect(find.text('Due Today'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('Tracked'), findsOneWidget);
  });

  testWidgets('avg stability row displays formatted value', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.textContaining('Avg Stability: 12.5'), findsOneWidget);
  });

  testWidgets('14-day forecast section label is visible', (tester) async {
    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('14-Day Forecast'), findsOneWidget);
    // Chart legend items
    expect(find.text('Vocab'), findsOneWidget);
    expect(find.text('Grammar'), findsOneWidget);
    expect(find.text('Kanji'), findsOneWidget);
  });

  testWidgets('memory strength section shows bucket labels', (tester) async {
    tester.view.physicalSize = const Size(1440, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Memory Strength'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Strong'), findsOneWidget);
    expect(find.text('Mastered'), findsOneWidget);
  });

  testWidgets('confidence section is shown when confidence.total > 0', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_buildScreen());
    await _pump(tester);

    expect(find.text('Review Confidence'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
  });

  testWidgets('confidence section is absent when confidence.total == 0', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen(forecast: _kForecastNoConfidence));
    await _pump(tester);

    expect(find.text('Review Confidence'), findsNothing);
  });

  testWidgets('error state renders friendly error widget', (tester) async {
    await tester.pumpWidget(_buildScreen(error: Exception('DB failure')));
    await _pump(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('VI locale shows Vietnamese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.vi));
    await _pump(tester);

    expect(find.text('Dự báo ôn tập'), findsWidgets);
  });

  testWidgets('JA locale shows Japanese app bar title', (tester) async {
    await tester.pumpWidget(_buildScreen(language: AppLanguage.ja));
    await _pump(tester);

    expect(find.text('復習予報'), findsWidgets);
  });
}
