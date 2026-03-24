import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/core/services/cloud_sync_service.dart';
import 'package:jpstudy/core/theme_provider.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/cloud_sync_status_provider.dart';
import 'package:jpstudy/features/me/me_screen.dart';
import 'package:jpstudy/features/me/providers/app_settings_controller.dart';
import 'package:jpstudy/features/me/providers/data_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kEmptyCloudStatus = CloudSyncStatus(
  target: null,
  lastSyncedAt: null,
  lastRemoteExportedAt: null,
  lastDirection: null,
);

const _kSummary = ProgressSummary(
  totalXp: 0,
  todayXp: 0,
  streak: 0,
  totalAttempts: 0,
  totalCorrect: 0,
  totalQuestions: 0,
);

Widget buildMeScreen() => ProviderScope(
  overrides: [
    appLanguageProvider.overrideWith((ref) => AppLanguage.en),
    studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
    themeModeProvider.overrideWith((ref) => ThemeModeNotifier()),
    progressSummaryProvider.overrideWith((ref) async => _kSummary),
    cloudSyncStatusProvider.overrideWith((ref) async => _kEmptyCloudStatus),
    appSettingsControllerProvider.overrideWith(() => AppSettingsController()),
    dataSettingsControllerProvider.overrideWith(() => DataSettingsController()),
  ],
  child: const MaterialApp(home: MeScreen()),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows "Me" AppBar title', (tester) async {
    await tester.pumpWidget(buildMeScreen());
    await tester.pump();
    expect(find.text('Me'), findsWidgets);
    await tester.pumpWidget(Container());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  });

  testWidgets('shows achievements tile', (tester) async {
    await tester.pumpWidget(buildMeScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Awards'), findsWidgets);
    await tester.pumpWidget(Container());
    for (var i = 0; i < 5; i++) {
      await tester.pump(Duration.zero);
    }
  });
}
