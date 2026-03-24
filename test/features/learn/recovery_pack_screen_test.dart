import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/services/recovery_pack_service.dart';
import 'package:jpstudy/features/home/providers/recovery_pack_provider.dart';
import 'package:jpstudy/features/learn/screens/recovery_pack_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget buildScreen({RecoveryPack? pack}) => ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        recoveryPackProvider.overrideWith((ref) async => pack),
      ],
      child: const MaterialApp(home: RecoveryPackScreen()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows Recovery Pack app bar title', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    expect(find.text('Recovery Pack'), findsAtLeastNWidgets(1));
  });

  testWidgets('shows empty state when no pack available', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('No recovery pack available'), findsOneWidget);
  });

  testWidgets('shows inventory icon in empty state', (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
