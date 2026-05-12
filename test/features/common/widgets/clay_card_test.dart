import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/common/widgets/clay_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildHarness({
  Widget child = const Text('content'),
  Color? color,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ClayCard(
          color: color,
          padding: padding,
          onTap: onTap,
          child: child,
        ),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ClayCard', () {
    testWidgets('renders its child widget', (tester) async {
      await tester.pumpWidget(_buildHarness(child: const Text('Hello')));
      await _pump(tester);

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('accepts a custom color without throwing', (tester) async {
      await tester.pumpWidget(_buildHarness(color: Colors.blue));
      await _pump(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('applies custom padding to the inner Container', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildHarness(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: const Text('padded'),
        ),
      );
      await _pump(tester);

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(
        container.padding,
        equals(const EdgeInsets.symmetric(horizontal: 32, vertical: 8)),
      );
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildHarness(onTap: () => tapped = true));
      await _pump(tester);

      await tester.tap(find.byType(GestureDetector));
      await _pump(tester);

      expect(tapped, isTrue);
    });

    testWidgets('onTap is optional — tapping without callback does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(_buildHarness()); // onTap = null
      await _pump(tester);

      await tester.tap(find.byType(GestureDetector));
      await _pump(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('is wrapped in a Semantics container', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byType(GestureDetector),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.container, isTrue);
    });

    testWidgets('renders BorderRadius.circular(16) decoration', (tester) async {
      await tester.pumpWidget(_buildHarness());
      await _pump(tester);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, equals(BorderRadius.circular(16)));
    });
  });
}
