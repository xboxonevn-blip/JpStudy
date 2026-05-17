import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/widgets/empty_state_widget.dart';

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

void main() {
  testWidgets('active empty-state subtitle meets light-surface AA contrast', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No results',
            subtitle: 'Try another search term.',
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Try another search term.'));
    final color = text.style?.color;
    expect(color, isNotNull);
    expect(
      _contrast(color!, AppThemePalette.light.elevated),
      greaterThanOrEqualTo(4.5),
    );
  });
}
