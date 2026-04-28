import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/common/widgets/compact_ui.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // AppSectionHeader
  // -------------------------------------------------------------------------

  group('AppSectionHeader', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSectionHeader(title: 'My Title')),
      );
      await _pump(tester);

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders caption when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppSectionHeader(
            title: 'Title',
            caption: 'Some caption text',
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('Some caption text'), findsOneWidget);
    });

    testWidgets('caption is absent when null', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSectionHeader(title: 'Title')),
      );
      await _pump(tester);

      // No second Text widget beyond the title
      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('renders action TextButton when actionLabel + onActionTap provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppSectionHeader(
            title: 'Title',
            actionLabel: 'See All',
            onActionTap: () {},
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('See All'), findsOneWidget);
    });

    testWidgets('action button fires onActionTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppSectionHeader(
            title: 'Title',
            actionLabel: 'Go',
            onActionTap: () => tapped = true,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.text('Go'));
      await _pump(tester);

      expect(tapped, isTrue);
    });

    testWidgets('action button absent when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppSectionHeader(title: 'Title')),
      );
      await _pump(tester);

      expect(find.byType(TextButton), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // AppStatusChip
  // -------------------------------------------------------------------------

  group('AppStatusChip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppStatusChip(label: 'Active')),
      );
      await _pump(tester);

      expect(find.text('Active'), findsOneWidget);
    });

    for (final tone in AppStatusTone.values) {
      testWidgets('renders ${tone.name} tone without throwing', (tester) async {
        await tester.pumpWidget(
          _wrap(AppStatusChip(label: 'Test', tone: tone)),
        );
        await _pump(tester);

        expect(find.text('Test'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  // -------------------------------------------------------------------------
  // AppProgressStrip
  // -------------------------------------------------------------------------

  group('AppProgressStrip', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppProgressStrip(value: 0.5, label: 'Progress')),
      );
      await _pump(tester);

      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets('FractionallySizedBox uses normalized value (0.5)', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppProgressStrip(value: 0.5, label: 'label')),
      );
      await _pump(tester);

      final fsb = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fsb.widthFactor, closeTo(0.5, 0.001));
    });

    testWidgets('clamps value > 1.0 to 1.0', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppProgressStrip(value: 2.5, label: 'over')),
      );
      await _pump(tester);

      final fsb = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fsb.widthFactor, closeTo(1.0, 0.001));
    });

    testWidgets('clamps value < 0.0 to 0.0', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppProgressStrip(value: -0.5, label: 'under')),
      );
      await _pump(tester);

      final fsb = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(fsb.widthFactor, closeTo(0.0, 0.001));
    });
  });

  // -------------------------------------------------------------------------
  // AppMetricPill
  // -------------------------------------------------------------------------

  group('AppMetricPill', () {
    testWidgets('renders label and value texts', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppMetricPill(label: 'Streak', value: '7 days')),
      );
      await _pump(tester);

      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // AppCompactRow
  // -------------------------------------------------------------------------

  group('AppCompactRow', () {
    testWidgets('renders title, subtitle and icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCompactRow(
            icon: Icons.star_rounded,
            title: 'Review',
            subtitle: 'Due today',
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Due today'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('fires onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          AppCompactRow(
            icon: Icons.star_rounded,
            title: 'Row',
            subtitle: 'sub',
            onTap: () => tapped = true,
          ),
        ),
      );
      await _pump(tester);

      await tester.tap(find.byType(InkWell));
      await _pump(tester);

      expect(tapped, isTrue);
    });

    testWidgets('optional status widget shown when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCompactRow(
            icon: Icons.star_rounded,
            title: 'Row',
            subtitle: 'sub',
            status: Text('NEW'),
          ),
        ),
      );
      await _pump(tester);

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('status widget absent when null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppCompactRow(
            icon: Icons.star_rounded,
            title: 'Row',
            subtitle: 'sub',
          ),
        ),
      );
      await _pump(tester);

      // 'NEW' status text should not appear
      expect(find.text('NEW'), findsNothing);
    });
  });
}
