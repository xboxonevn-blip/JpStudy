import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/features/common/widgets/sakura_particles.dart';

void main() {
  testWidgets('SakuraParticles can reseed safely when petalCount changes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox.expand(child: SakuraParticles())),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox.expand(child: SakuraParticles(petalCount: 34)),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SakuraParticles), findsOneWidget);
  });
}
