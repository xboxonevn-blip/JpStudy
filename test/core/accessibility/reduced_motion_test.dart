import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/accessibility/reduced_motion.dart';

// ---------------------------------------------------------------------------
// Why this test exists
// ---------------------------------------------------------------------------
// `reducedMotionDuration` is the single canonical gate for honoring the
// user's OS-level Reduce Motion preference across the app. Every call site
// that threads an animation duration through it trusts this function to:
//
//   * collapse to Duration.zero when `MediaQuery.disableAnimations` is true
//   * return the requested duration unchanged otherwise
//
// A regression in either branch — e.g. dropping the MediaQuery read, or
// returning `normal` even when disableAnimations is true — would silently
// break accessibility across every screen that uses the helper. These tests
// pin both branches at the helper level, so individual call sites don't
// need to re-test the same logic.
// ---------------------------------------------------------------------------

/// Renders a sentinel widget that captures the helper's return value for a
/// given `disableAnimations` MediaQuery value. A Builder is used to ensure
/// the helper is called with a descendant context of the injected
/// [MediaQuery], so `MediaQuery.of(context)` returns the overridden data.
Future<Duration> _captureDuration(
  WidgetTester tester, {
  required bool disableAnimations,
  required Duration normal,
}) async {
  late Duration captured;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            captured = reducedMotionDuration(context, normal);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return captured;
}

Future<bool> _captureReducedMotionEnabled(
  WidgetTester tester, {
  required bool disableAnimations,
}) async {
  late bool captured;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            captured = reducedMotionEnabled(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  group('reducedMotionDuration', () {
    testWidgets(
      'disableAnimations=true → returns Duration.zero regardless of input',
      (tester) async {
        for (final normal in const [
          Duration(milliseconds: 50),
          Duration(milliseconds: 180),
          Duration(milliseconds: 500),
          Duration(seconds: 1),
        ]) {
          final result = await _captureDuration(
            tester,
            disableAnimations: true,
            normal: normal,
          );
          expect(
            result,
            Duration.zero,
            reason: 'disableAnimations=true must override every input value',
          );
        }
      },
    );

    testWidgets(
      'disableAnimations=false → returns the input duration unchanged',
      (tester) async {
        for (final normal in const [
          Duration(milliseconds: 50),
          Duration(milliseconds: 180),
          Duration(milliseconds: 500),
          Duration(seconds: 1),
        ]) {
          final result = await _captureDuration(
            tester,
            disableAnimations: false,
            normal: normal,
          );
          expect(
            result,
            normal,
            reason: 'disableAnimations=false must pass through the input',
          );
        }
      },
    );

    testWidgets('Duration.zero in, Duration.zero out (no-op is idempotent)', (
      tester,
    ) async {
      final result = await _captureDuration(
        tester,
        disableAnimations: false,
        normal: Duration.zero,
      );
      expect(result, Duration.zero);
    });
  });

  group('reducedMotionEnabled', () {
    testWidgets('mirrors MediaQuery.disableAnimations', (tester) async {
      expect(
        await _captureReducedMotionEnabled(tester, disableAnimations: true),
        isTrue,
      );
      expect(
        await _captureReducedMotionEnabled(tester, disableAnimations: false),
        isFalse,
      );
    });
  });
}
