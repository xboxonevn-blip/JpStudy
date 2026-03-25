import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/common/widgets/clay_card.dart';

void main() {
  group('ClayButton', () {
    testWidgets('renders uppercase label by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ClayButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('TEST BUTTON'), findsOneWidget);
      expect(find.byType(ClayButton), findsOneWidget);
    });

    testWidgets('respects upperCase: false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ClayButton(
              label: 'Test Button',
              upperCase: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.text('TEST BUTTON'), findsNothing);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ClayButton(
              label: 'Save',
              icon: Icons.save,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ClayButton(
              label: 'Tap me',
              onPressed: () => tapped++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ClayButton));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('does not invoke onPressed when disabled', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ClayButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ClayButton));
      await tester.pump();
      expect(tapped, 0);
    });

    testWidgets('semantics exposes merged label and disabled state',
        (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ClayButton(
              label: 'Semantic Label',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(ClayButton)),
        matchesSemantics(
          label: 'Semantic Label\nSEMANTIC LABEL',
          hasEnabledState: true,
          isButton: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('honors width and height parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ClayButton(
              label: 'Sized',
              width: 180,
              height: 56,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedContainer),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.constraints, isNull);
    });
  });

  group('ClayCard', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ClayCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byType(ClayCard), findsOneWidget);
    });

    testWidgets('invokes onTap when provided', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ClayCard(
              onTap: () => tapped++,
              child: const Text('Tap Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ClayCard));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('applies custom padding and color', (tester) async {
      const customColor = Colors.amber;
      const customPadding = EdgeInsets.all(24);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ClayCard(
              color: customColor,
              padding: customPadding,
              child: Text('Styled Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ClayCard),
          matching: find.byType(Container),
        ).first,
      );
      expect(container.padding, customPadding);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('exposes semantics node', (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ClayCard(child: Text('Semantic Card')),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(ClayCard)),
        isNotNull,
      );
      semantics.dispose();
    });
  });
}
