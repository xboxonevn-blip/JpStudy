import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:jpstudy/core/goal_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:shared_preferences/shared_preferences.dart';

const prefOnboardingCompleted = 'onboarding.completed';
const prefOnboardingLevel = 'onboarding.level';
const prefOnboardingGoal = 'onboarding.goal';
const prefOnboardingGoalSkipUntil = 'onboarding.goal.skipUntil';

/// null = still loading, false = show onboarding, true = show home
final onboardingDoneProvider = StateProvider<bool?>((ref) => null);

Future<void> setPersistedStudyLevel(WidgetRef ref, StudyLevel level) async {
  ref.read(studyLevelProvider.notifier).state = level;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(prefOnboardingLevel, level.name);
}

/// Reads SharedPreferences once on startup.
/// Sets studyLevelProvider, studyGoalProvider, and onboardingDoneProvider.
final appInitProvider = FutureProvider<void>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(prefOnboardingCompleted) ?? false;

    if (completed) {
      final levelName = prefs.getString(prefOnboardingLevel);
      if (levelName != null) {
        final level = StudyLevel.values.firstWhere(
          (l) => l.name == levelName,
          orElse: () => StudyLevel.n5,
        );
        ref.read(studyLevelProvider.notifier).state = level;
      }

      final goalName = prefs.getString(prefOnboardingGoal);
      if (goalName != null) {
        final goal = StudyGoal.values.firstWhere(
          (g) => g.name == goalName,
          orElse: () => StudyGoal.jlpt,
        );
        ref.read(studyGoalProvider.notifier).state = goal;
      }
    }

    ref.read(onboardingDoneProvider.notifier).state = completed;
  } catch (_) {
    // On any prefs error, fall through to onboarding
    ref.read(onboardingDoneProvider.notifier).state = false;
  }
});
