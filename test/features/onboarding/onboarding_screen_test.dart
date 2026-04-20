import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/db/content_database.dart';
import 'package:jpstudy/data/models/vocab_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/onboarding/onboarding_screen.dart';

class FakeOnboardingLessonRepository extends LessonRepository {
  FakeOnboardingLessonRepository(
    super.db,
    super.contentDb, {
    required this.itemsByLevel,
  });

  final Map<String, List<VocabItem>> itemsByLevel;

  @override
  Future<List<VocabItem>> getVocabByLevel(String level) async {
    return itemsByLevel[level] ?? const [];
  }
}

void main() {
  testWidgets('Onboarding unlocks first session after preview answer', (
    tester,
  ) async {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final contentDb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeOnboardingLessonRepository(
      db,
      contentDb,
      itemsByLevel: {
        'N5': const [
          VocabItem(
            id: 1,
            term: '日本',
            reading: 'にほん',
            meaning: 'Nhat Ban',
            meaningEn: 'Japan',
            level: 'N5',
          ),
          VocabItem(
            id: 2,
            term: '学生',
            reading: 'がくせい',
            meaning: 'Hoc sinh',
            meaningEn: 'Student',
            level: 'N5',
          ),
          VocabItem(
            id: 3,
            term: '水',
            reading: 'みず',
            meaning: 'Nuoc',
            meaningEn: 'Water',
            level: 'N5',
          ),
        ],
      },
    );
    addTearDown(() async {
      await contentDb.close();
      await db.close();
    });

    StudyLevel? completedLevel;
    StudyGoal? completedGoal;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLanguageProvider.overrideWith((ref) => AppLanguage.en),
          lessonRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: OnboardingScreen(
            onComplete: (level, goal) {
              completedLevel = level;
              completedGoal = goal;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('N5'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('JLPT Exam Prep'));
    await tester.pump();

    final nextButton = tester.widget<ClayButton>(
      find.byKey(const ValueKey('onboarding_goal_next')),
    );
    expect(nextButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('onboarding_goal_next')));
    await tester.pumpAndSettle();

    final lockedStartButton = tester.widget<ClayButton>(
      find.byKey(const ValueKey('onboarding_first_win_start')),
    );
    expect(lockedStartButton.onPressed, isNull);
    expect(
      find.text('Answer this one preview question to unlock your first session.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('onboarding_preview_option_0')));
    await tester.pumpAndSettle();

    final unlockedStartButton = tester.widget<ClayButton>(
      find.byKey(const ValueKey('onboarding_first_win_start')),
    );
    expect(unlockedStartButton.onPressed, isNotNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('onboarding_first_win_start')),
    );
    await tester.tap(find.byKey(const ValueKey('onboarding_first_win_start')));
    await tester.pump();

    expect(completedLevel, StudyLevel.n5);
    expect(completedGoal, StudyGoal.jlpt);
  });

  // ---------------------------------------------------------------------------
  // Reduced-motion (accessibility) support
  // ---------------------------------------------------------------------------
  //
  // The onboarding screen contains several AnimatedContainer tweens (progress
  // dots, goal cards, option pills). When the OS reports `disableAnimations`
  // (iOS "Reduce Motion" / Android "Remove animations"), these must collapse
  // to Duration.zero so the user doesn't see any motion. These tests pin the
  // `_onboardingAnimDuration` gate so a future refactor can't silently drop it.

  Widget hostOnboarding({required bool disableAnimations}) {
    final db = AppDatabase(executor: NativeDatabase.memory());
    final contentDb = ContentDatabase(executor: NativeDatabase.memory());
    final repo = FakeOnboardingLessonRepository(
      db,
      contentDb,
      itemsByLevel: const {},
    );
    addTearDown(() async {
      await contentDb.close();
      await db.close();
    });
    return ProviderScope(
      overrides: [
        appLanguageProvider.overrideWith((ref) => AppLanguage.en),
        lessonRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        // Inject the MediaQuery override above the OnboardingScreen build.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
          ),
          child: child!,
        ),
        home: OnboardingScreen(onComplete: (_, _) {}),
      ),
    );
  }

  testWidgets(
    'disableAnimations=true → all AnimatedContainer durations collapse to zero',
    (tester) async {
      await tester.pumpWidget(hostOnboarding(disableAnimations: true));
      await tester.pumpAndSettle();

      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      expect(
        containers,
        isNotEmpty,
        reason: 'progress dots render AnimatedContainers on every page',
      );
      for (final c in containers) {
        expect(
          c.duration,
          Duration.zero,
          reason:
              'reduced-motion gate must zero out the duration on every '
              'AnimatedContainer in the onboarding flow',
        );
      }
    },
  );

  testWidgets(
    'disableAnimations=false → AnimatedContainer durations remain non-zero',
    (tester) async {
      await tester.pumpWidget(hostOnboarding(disableAnimations: false));
      await tester.pumpAndSettle();

      final containers = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      expect(containers, isNotEmpty);
      for (final c in containers) {
        expect(
          c.duration,
          isNot(Duration.zero),
          reason: 'default motion must be preserved when the user has not '
              'requested reduced motion',
        );
      }
    },
  );
}
