import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/features/common/widgets/error_state_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildWidget({
  AppLanguage language = AppLanguage.en,
  Object error = 'some generic error',
  VoidCallback? onRetry,
  String? customMessage,
  bool compact = false,
}) {
  return ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: ErrorStateWidget(
          error: error,
          onRetry: onRetry,
          customMessage: customMessage,
          compact: compact,
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

double _contrast(Color foreground, Color background) {
  final resolvedForeground = foreground.a < 1
      ? Color.alphaBlend(foreground, background)
      : foreground;
  final foregroundLuminance = resolvedForeground.computeLuminance() + 0.05;
  final backgroundLuminance = background.computeLuminance() + 0.05;
  return foregroundLuminance > backgroundLuminance
      ? foregroundLuminance / backgroundLuminance
      : backgroundLuminance / foregroundLuminance;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('generic error maps to genericErrorLabel', (tester) async {
    await tester.pumpWidget(_buildWidget(error: Exception('unknown failure')));
    await _pump(tester);

    // EN genericErrorLabel
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('SocketException maps to noInternetErrorLabel', (tester) async {
    await tester.pumpWidget(
      _buildWidget(error: Exception('SocketException: Connection refused')),
    );
    await _pump(tester);

    expect(
      find.text('No internet connection. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('Connection keyword maps to noInternetErrorLabel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildWidget(error: Exception('Connection failed')),
    );
    await _pump(tester);

    expect(
      find.text('No internet connection. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('TimeoutException maps to timeoutErrorLabel', (tester) async {
    // NOTE: do NOT include 'Connection' in the message — that branch fires first.
    await tester.pumpWidget(
      _buildWidget(error: Exception('TimeoutException: request took too long')),
    );
    await _pump(tester);

    expect(find.text('Request timed out. Please try again.'), findsOneWidget);
  });

  testWidgets('customMessage overrides friendly message mapping', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildWidget(
        error: Exception('SocketException'),
        customMessage: 'Database connection failed.',
      ),
    );
    await _pump(tester);

    // Custom message shown instead of the internet-error label
    expect(find.text('Database connection failed.'), findsOneWidget);
    expect(
      find.text('No internet connection. Please try again.'),
      findsNothing,
    );
  });

  testWidgets('retry button is absent when onRetry is null', (tester) async {
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('retry button is present when onRetry is provided', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget(onRetry: () {}));
    await _pump(tester);

    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('tapping retry button invokes the callback', (tester) async {
    var called = false;
    await tester.pumpWidget(_buildWidget(onRetry: () => called = true));
    await _pump(tester);

    await tester.tap(find.text('Retry'));
    await _pump(tester);

    expect(called, isTrue);
  });

  testWidgets('VI locale shows Vietnamese retry label', (tester) async {
    await tester.pumpWidget(
      _buildWidget(language: AppLanguage.vi, onRetry: () {}),
    );
    await _pump(tester);

    // VI retryLabel = 'Làm lại'
    expect(find.text('Làm lại'), findsOneWidget);
  });

  testWidgets('JA locale shows Japanese error message', (tester) async {
    await tester.pumpWidget(_buildWidget(language: AppLanguage.ja));
    await _pump(tester);

    // JA genericErrorLabel
    expect(find.text('問題が発生しました。もう一度お試しください。'), findsOneWidget);
  });

  testWidgets('active error copy meets light-surface AA contrast', (
    tester,
  ) async {
    await tester.pumpWidget(_buildWidget());
    await _pump(tester);

    final text = tester.widget<Text>(
      find.text('Something went wrong. Please try again.'),
    );
    final color = text.style?.color;
    expect(color, isNotNull);
    expect(
      _contrast(color!, AppThemePalette.light.elevated),
      greaterThanOrEqualTo(4.5),
    );
  });
}
