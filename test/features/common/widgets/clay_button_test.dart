import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';

// ---------------------------------------------------------------------------
// Why this test exists
// ---------------------------------------------------------------------------
// ClayButton is the app's primary tappable button and renders in onboarding,
// home, results, and dozens of other screens. Its press animation slides the
// button 4 px down over 50 ms. For users who have the OS Reduce Motion
// accessibility setting enabled, that slide must collapse to Duration.zero —
// otherwise every single tap in the app shows a motion the user asked to
// suppress.
//
// These tests pin the `MediaQuery.disableAnimations` gate on the button's
// AnimatedContainer so a refactor can't silently drop it.
// ---------------------------------------------------------------------------

Widget _host({required bool disableAnimations}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(
      body: ClayButton(label: 'Go', onPressed: () {}),
    ),
  ),
);

Duration _buttonAnimDuration(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(ClayButton),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.duration;
}

void main() {
  testWidgets(
    'disableAnimations=true → press animation collapses to Duration.zero',
    (tester) async {
      await tester.pumpWidget(_host(disableAnimations: true));
      await tester.pumpAndSettle();
      expect(_buttonAnimDuration(tester), Duration.zero);
    },
  );

  testWidgets(
    'disableAnimations=false → press animation keeps its 50 ms duration',
    (tester) async {
      await tester.pumpWidget(_host(disableAnimations: false));
      await tester.pumpAndSettle();
      expect(_buttonAnimDuration(tester), const Duration(milliseconds: 50));
    },
  );
}
