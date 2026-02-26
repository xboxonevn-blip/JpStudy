# D3: Onboarding Flow — Design Document

**Date:** 2026-02-27
**Status:** Approved

---

## Problem

New users see an empty level-selection screen (`LevelGate`) with no context about the app or what to do. There is no welcome experience, no goal-setting, and the selected level is not persisted across cold restarts (users must re-select on every launch).

---

## Goals

- First-install wizard: level → goal → start
- Persist level + goal to `SharedPreferences` so subsequent launches skip onboarding
- Goal is cosmetic only (displayed in profile/dashboard later, no logic impact yet)

---

## Architecture (Approach B — Extend HomeScreen)

```
app startup
  └── HomeScreen.build()
        ├── watch appInitProvider (FutureProvider<void>)
        │     reads SharedPreferences → sets studyLevelProvider + studyGoalProvider
        │     sets onboardingDoneProvider = true/false
        │
        ├── watch onboardingDoneProvider (StateProvider<bool?>)
        │     null  → loading spinner
        │     false → OnboardingScreen (full Scaffold, replaces HomeScreen entirely)
        │     true  → normal Scaffold (HeaderBar + LearningPathScreen)
        │
        └── HomeScreen._handleOnboardingComplete(level, goal)
              saves prefs → sets providers → sets onboardingDoneProvider = true
              (no invalidate, no loading flash)
```

**SharedPreferences keys:**
- `onboarding.completed` — `bool`
- `onboarding.level` — `'n5'` / `'n4'` / `'n3'`
- `onboarding.goal` — `'jlpt'` / `'reading'` / `'writing'`

---

## OnboardingScreen — 3-Page Wizard

```
Page 1: Chọn cấp độ
  ● ○ ○
  🎌  Chào mừng đến JpStudy!
  Hãy bắt đầu hành trình học tiếng Nhật
  [ N5  Nhập môn — 25 bài  › ]
  [ N4  Sơ trung cấp — 25 bài › ]
  [ N3  Trung cấp — 25 bài  › ]
  → tap card = auto-advance to page 2

Page 2: Chọn mục tiêu
  ● ● ○         [← Back]
  Mục tiêu học của bạn?
  [ 📋 Luyện thi JLPT    — Chuẩn bị kỳ thi JLPT  ○ ]
  [ 📖 Đọc tiếng Nhật    — Manga, tin tức, sách   ○ ]
  [ ✍️  Luyện viết        — Hiragana, Kanji        ○ ]
               [ Tiếp tục → ]

Page 3: Sẵn sàng!
  ● ● ●
              🎌
        Sẵn sàng rồi!
   Cấp độ: N5  •  Mục tiêu: Luyện thi JLPT
        [ Bắt đầu học! ]
```

- `PageController` with `physics: NeverScrollableScrollPhysics` (programmatic only)
- No swipe gesture — user must tap cards/buttons
- Back button on pages 2–3 (no back on page 1)
- Localized via `AppLanguage` (watches `appLanguageProvider`)
- Uses `JapaneseBackground` + `AppThemeV2` for consistent aesthetics

---

## Files Changed

| File | Action |
|------|--------|
| `lib/core/study_goal.dart` | CREATE — `StudyGoal` enum + `StudyGoalExtension` (label, description, icon) |
| `lib/core/goal_provider.dart` | CREATE — `studyGoalProvider StateProvider<StudyGoal?>` |
| `lib/core/onboarding_provider.dart` | CREATE — `appInitProvider FutureProvider<void>` + `onboardingDoneProvider StateProvider<bool?>` |
| `lib/features/onboarding/onboarding_screen.dart` | CREATE — 3-page wizard |
| `lib/features/home/home_screen.dart` | MODIFY — watch `onboardingDoneProvider`, return `OnboardingScreen` or normal Scaffold |
| `lib/core/app_language.dart` | MODIFY — add onboarding strings (welcome, goal labels/descriptions) |

---

## Key Design Decisions

1. **Scaffold architecture** — `OnboardingScreen` is a full `Scaffold`; `HomeScreen.build()` returns it directly (no nesting) to avoid Scaffold-in-Scaffold Flutter warning.

2. **No loading flash on completion** — `onboardingDoneProvider` is a `StateProvider<bool?>` set synchronously after save. `appInitProvider` only runs once at startup; completion bypasses it entirely.

3. **Existing users** — Users with existing data but no `onboarding.completed` flag will see the wizard once on next launch. This is acceptable (dev-only users at this stage).

4. **StudyLevel persistence** — `appInitProvider` reads `onboarding.level` from prefs and sets `studyLevelProvider` on every cold start. This fixes the "re-select level on every restart" bug as a side effect.

---

## Out of Scope

- Language selection in onboarding (use HeaderBar after completing wizard)
- Fancy animations / hero transitions
- Profile picture / name input
- Skip button
