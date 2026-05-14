import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/goal_provider.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/shared_preferences_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/home/widgets/goal_selection_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

Widget _buildBanner({
  required SharedPreferences preferences,
  StudyGoal? goal,
  StudyLevel? level = StudyLevel.n5,
  AppLanguage language = AppLanguage.vi,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      appLanguageProvider.overrideWith(
        (ref) => AppLanguageController.test(language),
      ),
      studyLevelProvider.overrideWith((ref) => level),
      studyGoalProvider.overrideWith((ref) => goal),
    ],
    child: const MaterialApp(home: Scaffold(body: GoalSelectionBanner())),
  );
}

void main() {
  testWidgets('shows goal chips when level is set and no goal exists', (
    tester,
  ) async {
    await tester.pumpWidget(_buildBanner(preferences: await _prefs({})));
    await tester.pump();

    expect(find.text('Bạn học để làm gì?'), findsOneWidget);
    expect(find.text('Thi JLPT'), findsOneWidget);
    expect(find.text('Đọc manga & tin tức'), findsOneWidget);
    expect(find.text('Luyện viết'), findsOneWidget);
    expect(find.text('Để sau'), findsOneWidget);
  });

  testWidgets('saving a goal persists it and fades the banner out', (
    tester,
  ) async {
    final preferences = await _prefs({});
    await tester.pumpWidget(_buildBanner(preferences: preferences));
    await tester.pump();

    await tester.tap(find.text('Thi JLPT'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(preferences.getString(prefOnboardingGoal), StudyGoal.jlpt.name);
    expect(find.text('Bạn học để làm gì?'), findsNothing);
  });

  testWidgets('later stores a seven day skip window and hides banner', (
    tester,
  ) async {
    final before = DateTime.now().add(const Duration(days: 6));
    final preferences = await _prefs({});
    await tester.pumpWidget(_buildBanner(preferences: preferences));
    await tester.pump();

    await tester.tap(find.text('Để sau'));
    await tester.pump();
    await tester.pumpAndSettle();

    final skipUntil = DateTime.fromMillisecondsSinceEpoch(
      preferences.getInt(prefOnboardingGoalSkipUntil)!,
    );
    expect(skipUntil.isAfter(before), isTrue);
    expect(find.text('Bạn học để làm gì?'), findsNothing);
  });

  testWidgets('does not show when a goal already exists', (tester) async {
    await tester.pumpWidget(
      _buildBanner(
        preferences: await _prefs({prefOnboardingGoal: StudyGoal.reading.name}),
        goal: StudyGoal.reading,
      ),
    );
    await tester.pump();

    expect(find.text('Bạn học để làm gì?'), findsNothing);
  });

  testWidgets('does not show during a future skip window', (tester) async {
    final future = DateTime.now().add(const Duration(days: 1));
    await tester.pumpWidget(
      _buildBanner(
        preferences: await _prefs({
          prefOnboardingGoalSkipUntil: future.millisecondsSinceEpoch,
        }),
      ),
    );
    await tester.pump();

    expect(find.text('Bạn học để làm gì?'), findsNothing);
  });
}
