import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'notifications.daily': true,
      'backup.auto.enabled': true,
      'write.handwriting.strokeGuide.defaultExpanded': false,
    });
  });

  testWidgets('Me screen shows moved settings sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressSummaryProvider.overrideWith(
            (ref) async => const ProgressSummary(
              totalXp: 120,
              todayXp: 18,
              streak: 4,
              totalAttempts: 20,
              totalCorrect: 16,
              totalQuestions: 20,
            ),
          ),
          cloudSyncStatusProvider.overrideWith(
            (ref) async => const CloudSyncStatus(
              target: null,
              lastSyncedAt: null,
              lastRemoteExportedAt: null,
              lastDirection: null,
            ),
          ),
        ],
        child: const MaterialApp(home: MeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('Display'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Reminders'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Reminders'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Data'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Data'), findsOneWidget);
    expect(find.text('Linked sync file'), findsOneWidget);
  });
}
