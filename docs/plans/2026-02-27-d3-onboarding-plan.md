# D3: Onboarding Flow Implementation Plan

**Goal:** Add a 3-step first-install wizard (level → goal → start) that persists choices to SharedPreferences so subsequent cold starts skip the wizard.

**Architecture:** `appInitProvider` (FutureProvider) reads SharedPreferences on startup and sets `onboardingDoneProvider` (StateProvider<bool?>). `HomeScreen.build()` watches `onboardingDoneProvider`: null=loading spinner, false=OnboardingScreen, true=normal HeaderBar+LearningPathScreen. OnboardingScreen calls `onComplete(level, goal)` callback which saves prefs and directly sets `onboardingDoneProvider = true` — no FutureProvider invalidation, no loading flash.

**Tech Stack:** Flutter, Riverpod 2.x (StateProvider, FutureProvider), SharedPreferences, go_router, AppThemeV2, ClayButton, JapaneseBackground

---

### Task 1: Create `StudyGoal` enum

**Files:**
- Create: `lib/core/study_goal.dart`

**Step 1: Write the file**

```dart
import 'package:flutter/material.dart';
import 'app_language.dart';

enum StudyGoal { jlpt, reading, writing }

extension StudyGoalExtension on StudyGoal {
  String label(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return _labelEn;
      case AppLanguage.vi:
        return _labelVi;
      case AppLanguage.ja:
        return _labelJa;
    }
  }

  String description(AppLanguage language) {
    switch (language) {
      case AppLanguage.en:
        return _descEn;
      case AppLanguage.vi:
        return _descVi;
      case AppLanguage.ja:
        return _descJa;
    }
  }

  IconData get icon {
    switch (this) {
      case StudyGoal.jlpt:
        return Icons.assignment_outlined;
      case StudyGoal.reading:
        return Icons.menu_book_outlined;
      case StudyGoal.writing:
        return Icons.edit_outlined;
    }
  }

  String get _labelEn {
    switch (this) {
      case StudyGoal.jlpt:
        return 'JLPT Exam Prep';
      case StudyGoal.reading:
        return 'Read Japanese';
      case StudyGoal.writing:
        return 'Practice Writing';
    }
  }

  String get _labelVi {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Luyện thi JLPT';
      case StudyGoal.reading:
        return 'Đọc tiếng Nhật';
      case StudyGoal.writing:
        return 'Luyện viết';
    }
  }

  String get _labelJa {
    switch (this) {
      case StudyGoal.jlpt:
        return 'JLPT試験対策';
      case StudyGoal.reading:
        return '日本語の読み取り';
      case StudyGoal.writing:
        return '書き練習';
    }
  }

  String get _descEn {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Prepare for N5, N4, N3 exams';
      case StudyGoal.reading:
        return 'Manga, news, books';
      case StudyGoal.writing:
        return 'Hiragana, Katakana, Kanji';
    }
  }

  String get _descVi {
    switch (this) {
      case StudyGoal.jlpt:
        return 'Chuẩn bị kỳ thi N5, N4, N3';
      case StudyGoal.reading:
        return 'Manga, tin tức, sách';
      case StudyGoal.writing:
        return 'Hiragana, Katakana, Kanji';
    }
  }

  String get _descJa {
    switch (this) {
      case StudyGoal.jlpt:
        return 'N5、N4、N3試験に備える';
      case StudyGoal.reading:
        return 'マンガ、ニュース、本';
      case StudyGoal.writing:
        return 'ひらがな、カタカナ、漢字';
    }
  }
}
```

**Step 2: Run analyzer**

```
flutter analyze lib/core/study_goal.dart
```
Expected: No issues found.

**Step 3: Commit**

```bash
git add lib/core/study_goal.dart
git commit -m "feat(D3): add StudyGoal enum with labels and descriptions"
```

---

### Task 2: Create goal provider + onboarding providers

**Files:**
- Create: `lib/core/goal_provider.dart`
- Create: `lib/core/onboarding_provider.dart`

**Step 1: Write `goal_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'study_goal.dart';

final studyGoalProvider = StateProvider<StudyGoal?>((ref) => null);
```

**Step 2: Write `onboarding_provider.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'goal_provider.dart';
import 'level_provider.dart';
import 'study_goal.dart';
import 'study_level.dart';

const prefOnboardingCompleted = 'onboarding.completed';
const prefOnboardingLevel = 'onboarding.level';
const prefOnboardingGoal = 'onboarding.goal';

/// null = still loading, false = show onboarding, true = show home
final onboardingDoneProvider = StateProvider<bool?>((ref) => null);

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
```

**Step 3: Run analyzer**

```
flutter analyze lib/core/goal_provider.dart lib/core/onboarding_provider.dart
```
Expected: No issues found.

**Step 4: Commit**

```bash
git add lib/core/goal_provider.dart lib/core/onboarding_provider.dart
git commit -m "feat(D3): add goal provider and onboarding init providers"
```

---

### Task 3: Add onboarding strings to `app_language.dart`

**Files:**
- Modify: `lib/core/app_language.dart` (insert before the closing `}` at line 5522)

**Step 1: Add the new string getters**

Insert the following block immediately before the `}` at line 5522 (after `kanjiDashNoVocab`):

```dart
  String get onboardingWelcomeTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Welcome to JpStudy!';
      case AppLanguage.vi:
        return 'Chào mừng đến JpStudy!';
      case AppLanguage.ja:
        return 'JpStudyへようこそ！';
    }
  }

  String get onboardingWelcomeSubtitle {
    switch (this) {
      case AppLanguage.en:
        return 'Let\'s start your Japanese learning journey';
      case AppLanguage.vi:
        return 'Hãy bắt đầu hành trình học tiếng Nhật';
      case AppLanguage.ja:
        return '日本語学習の旅を始めましょう';
    }
  }

  String get onboardingLevelTitle {
    switch (this) {
      case AppLanguage.en:
        return 'Choose your JLPT level';
      case AppLanguage.vi:
        return 'Chọn cấp độ JLPT của bạn';
      case AppLanguage.ja:
        return 'JLPTレベルを選んでください';
    }
  }

  String get onboardingGoalTitle {
    switch (this) {
      case AppLanguage.en:
        return 'What\'s your learning goal?';
      case AppLanguage.vi:
        return 'Mục tiêu học của bạn?';
      case AppLanguage.ja:
        return '学習目標は何ですか？';
    }
  }

  String get onboardingReadyTitle {
    switch (this) {
      case AppLanguage.en:
        return 'You\'re all set!';
      case AppLanguage.vi:
        return 'Sẵn sàng rồi!';
      case AppLanguage.ja:
        return '準備完了！';
    }
  }

  String get onboardingStartButton {
    switch (this) {
      case AppLanguage.en:
        return 'Start Learning!';
      case AppLanguage.vi:
        return 'Bắt đầu học!';
      case AppLanguage.ja:
        return '学習開始！';
    }
  }

  String get onboardingNextButton {
    switch (this) {
      case AppLanguage.en:
        return 'Continue';
      case AppLanguage.vi:
        return 'Tiếp tục';
      case AppLanguage.ja:
        return '次へ';
    }
  }
```

**Step 2: Run analyzer**

```
flutter analyze lib/core/app_language.dart
```
Expected: No issues found.

**Step 3: Commit**

```bash
git add lib/core/app_language.dart
git commit -m "feat(D3): add onboarding localization strings"
```

---

### Task 4: Create `OnboardingScreen`

**Files:**
- Create: `lib/features/onboarding/onboarding_screen.dart`

**Step 1: Write the file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_v2.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/features/common/widgets/clay_button.dart';
import 'package:jpstudy/features/common/widgets/japanese_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final void Function(StudyLevel level, StudyGoal goal) onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  StudyLevel? _selectedLevel;
  StudyGoal? _selectedGoal;

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    return Scaffold(
      body: JapaneseBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              _ProgressDots(current: _currentPage, total: 3),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _LevelPage(
                      language: language,
                      onSelected: (level) {
                        setState(() => _selectedLevel = level);
                        _goToPage(1);
                      },
                    ),
                    _GoalPage(
                      language: language,
                      selected: _selectedGoal,
                      onSelected: (goal) => setState(() => _selectedGoal = goal),
                      onNext: () => _goToPage(2),
                      onBack: () => _goToPage(0),
                    ),
                    _ReadyPage(
                      language: language,
                      level: _selectedLevel,
                      goal: _selectedGoal,
                      onStart: () =>
                          widget.onComplete(_selectedLevel!, _selectedGoal!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Progress Dots ────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? AppThemeV2.primary
                : AppThemeV2.neutral,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─── Page 1: Level Selection ──────────────────────────────────────────────────

class _LevelPage extends StatelessWidget {
  const _LevelPage({required this.language, required this.onSelected});
  final AppLanguage language;
  final ValueChanged<StudyLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          language.onboardingWelcomeTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppThemeV2.textMain,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          language.onboardingWelcomeSubtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppThemeV2.textSub,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          language.onboardingLevelTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppThemeV2.textMain,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...StudyLevel.values.map(
          (level) => _OnboardingLevelCard(
            level: level,
            language: language,
            onSelected: onSelected,
          ),
        ),
      ],
    );
  }
}

class _OnboardingLevelCard extends StatelessWidget {
  const _OnboardingLevelCard({
    required this.level,
    required this.language,
    required this.onSelected,
  });
  final StudyLevel level;
  final AppLanguage language;
  final ValueChanged<StudyLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.folder_open, color: AppThemeV2.primary),
        ),
        title: Text(
          level.shortLabel,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          level.description(language),
          style: const TextStyle(color: AppThemeV2.textSub),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onSelected(level),
      ),
    );
  }
}

// ─── Page 2: Goal Selection ───────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  const _GoalPage({
    required this.language,
    required this.selected,
    required this.onSelected,
    required this.onNext,
    required this.onBack,
  });
  final AppLanguage language;
  final StudyGoal? selected;
  final ValueChanged<StudyGoal> onSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: AppThemeV2.textSub),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                language.onboardingGoalTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppThemeV2.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ...StudyGoal.values.map(
            (goal) => _GoalCard(
              goal: goal,
              language: language,
              isSelected: selected == goal,
              onTap: () => onSelected(goal),
            ),
          ),
          const Spacer(),
          ClayButton(
            label: language.onboardingNextButton,
            style: ClayButtonStyle.primary,
            isExpanded: true,
            onPressed: selected != null ? onNext : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });
  final StudyGoal goal;
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeV2.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppThemeV2.primary : const Color(0xFFE8ECF5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemeV2.primary.withValues(alpha: 0.15)
                    : const Color(0xFFEFF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(goal.icon,
                  color: isSelected
                      ? AppThemeV2.primary
                      : const Color(0xFF4255FF)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.label(language),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppThemeV2.primary
                          : AppThemeV2.textMain,
                    ),
                  ),
                  Text(
                    goal.description(language),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppThemeV2.textSub,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppThemeV2.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Page 3: Ready ────────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
    required this.language,
    required this.level,
    required this.goal,
    required this.onStart,
  });
  final AppLanguage language;
  final StudyLevel? level;
  final StudyGoal? goal;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎌', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            language.onboardingReadyTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppThemeV2.textMain,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (level != null && goal != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppThemeV2.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${level!.shortLabel}  •  ${goal!.label(language)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppThemeV2.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          ClayButton(
            label: language.onboardingStartButton,
            style: ClayButtonStyle.primary,
            isExpanded: true,
            icon: Icons.play_arrow_rounded,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Run analyzer**

```
flutter analyze lib/features/onboarding/onboarding_screen.dart
```
Expected: No issues found.

**Step 3: Commit**

```bash
git add lib/features/onboarding/onboarding_screen.dart
git commit -m "feat(D3): add OnboardingScreen with 3-page wizard"
```

---

### Task 5: Modify `HomeScreen`

**Files:**
- Modify: `lib/features/home/home_screen.dart`

**Step 1: Add imports at the top of the import block**

After the existing imports, add:
```dart
import 'package:jpstudy/core/goal_provider.dart';
import 'package:jpstudy/core/onboarding_provider.dart';
import 'package:jpstudy/core/study_goal.dart';
import 'package:jpstudy/features/onboarding/onboarding_screen.dart';
```

**Step 2: Replace the `build()` method**

Find and replace the entire `build()` method (lines 67–99):

```dart
  @override
  Widget build(BuildContext context) {
    // Trigger init on first build; result is tracked via onboardingDoneProvider.
    ref.watch(appInitProvider);
    final onboardingDone = ref.watch(onboardingDoneProvider);
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    // Loading: still reading SharedPreferences
    if (onboardingDone == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // First install: show onboarding wizard
    if (!onboardingDone) {
      return OnboardingScreen(onComplete: _handleOnboardingComplete);
    }

    // Normal: main app
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: HeaderBar(
          level: level,
          language: language,
          onLanguageTap: () => _showLanguageSheet(context),
          onLevelChanged: (selected) => _setLevel(selected),
          onSettingsTap: () => _showSettingsSheet(context),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: const LearningPathScreen(),
    );
  }
```

**Step 3: Add `_handleOnboardingComplete()` method**

Add this new method after `_setLevel()` (around line 107):

```dart
  Future<void> _handleOnboardingComplete(
    StudyLevel level,
    StudyGoal goal,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOnboardingCompleted, true);
    await prefs.setString(prefOnboardingLevel, level.name);
    await prefs.setString(prefOnboardingGoal, goal.name);
    ref.read(studyLevelProvider.notifier).state = level;
    ref.read(studyGoalProvider.notifier).state = goal;
    _setLevel(level); // also applies language guard (N3 → allow Japanese UI)
    ref.read(onboardingDoneProvider.notifier).state = true;
  }
```

**Step 4: Update Settings "Change level" tile**

Find this in `_showSettingsSheet` (around line 180–186):
```dart
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(language.levelMenuTitle),
                onTap: () {
                  ref.read(studyLevelProvider.notifier).state = null;
                  Navigator.of(context).pop();
                },
              ),
```

Replace `onTap` body:
```dart
                onTap: () {
                  Navigator.of(context).pop();
                  _resetOnboarding();
                },
```

**Step 5: Add `_resetOnboarding()` method**

Add after `_handleOnboardingComplete()`:

```dart
  Future<void> _resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefOnboardingCompleted, false);
    ref.read(onboardingDoneProvider.notifier).state = false;
  }
```

**Step 6: Remove now-unused `LevelGate` import**

Delete the line:
```dart
import 'package:jpstudy/features/home/widgets/level_gate.dart';
```

**Step 7: Run analyzer**

```
flutter analyze lib/features/home/home_screen.dart
```
Expected: No issues found.

**Step 8: Commit**

```bash
git add lib/features/home/home_screen.dart
git commit -m "feat(D3): wire OnboardingScreen into HomeScreen via onboardingDoneProvider"
```

---

### Task 6: Smoke Test + Final Analyze

**Step 1: Run full analyzer**

```
flutter analyze lib/
```
Expected: No issues found.

**Step 2: Manual smoke test — first launch**

1. Clear app data (or run on fresh simulator)
2. Launch app → should see OnboardingScreen (page 1: level selection)
3. Tap N5 → auto-advance to page 2 (goal)
4. Tap "Luyện thi JLPT" → "Continue" button activates
5. Tap Continue → page 3 (ready)
6. Verify summary chip shows "N5 • JLPT Exam Prep"
7. Tap "Start Learning!" → HomeScreen with LearningPathScreen (N5 level)

**Step 3: Manual smoke test — returning user**

1. Without clearing data, cold restart app
2. Should go directly to HomeScreen (skip wizard)
3. Level in HeaderBar should match N5 (or whatever was selected)

**Step 4: Manual smoke test — change level from Settings**

1. Open Settings sheet → tap "Select JLPT level"
2. Should show OnboardingScreen again
3. Select different level → complete wizard → back to HomeScreen with new level

**Step 5: Final commit (if any minor fixes)**

```bash
git add -u
git commit -m "fix(D3): analyzer and smoke test corrections"
```
```

---

## Summary of Files Changed

| File | Action |
|------|--------|
| `lib/core/study_goal.dart` | CREATE |
| `lib/core/goal_provider.dart` | CREATE |
| `lib/core/onboarding_provider.dart` | CREATE |
| `lib/core/app_language.dart` | MODIFY — 7 new string getters |
| `lib/features/onboarding/onboarding_screen.dart` | CREATE |
| `lib/features/home/home_screen.dart` | MODIFY — build(), +2 methods, Settings tile |
