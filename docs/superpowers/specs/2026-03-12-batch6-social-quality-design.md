# Batch 6 — Social Local + Quality Polish

## Context
App has 25+ features across 5 batches. Batch 6 adds social/motivational features (local, no backend) and quality improvements (testing + accessibility).

## F1: Achievement Wall

**Problem:** Achievements are a flat list. No visual hierarchy, no locked/unlocked states, no progress toward unearned achievements.

**Solution:** Transform achievements screen into a visual grid "wall" with categories and progress.

**Files modified:**
- `lib/features/me/achievements_screen.dart` — redesign list → grid wall
- `lib/core/app_language.dart` — new labels

**Design:**
1. Grid layout (2 columns) with `ClayCard` per achievement
2. Unlocked: full color icon + emoji + title + earned date
3. Locked: greyed out icon + "?" + hint text
4. Categories as section headers: "Milestones", "Mastery", "Firsts"
5. Progress bar for numeric achievements (streak shows "7/14 days")
6. Counter badge at top: "5 / 13 Unlocked"

**Data:** `AchievementDao.getAll()`, `AchievementType` enum (8 types), `StreakMilestone`

---

## F2: Personal Bests

**Problem:** Users complete tests/sessions with scores but have no record of personal bests. No motivation to improve.

**Solution:** Query existing `attempt` table for best scores; show "New Personal Best!" on results screens.

**New files:**
- `lib/data/daos/personal_best_dao.dart` — queries on existing `attempt` table
- `lib/features/me/widgets/personal_bests_card.dart` — UI card

**Files modified:**
- `lib/features/me/me_screen.dart` — add personal bests section
- `lib/features/test/screens/test_results_screen.dart` — "New Personal Best!" banner
- `lib/features/learn/screens/learn_summary_screen.dart` — same

**Design:**
1. `PersonalBestDao`: `SELECT MAX(score * 100.0 / total) as bestPct, COUNT(*) as attempts FROM attempt WHERE mode = ? AND level = ?`
2. Personal bests card on Me screen: best % per mode per level
3. Results screens: compare current vs best → show banner if new record
4. No new tables — uses existing `attempt` table

---

## F3: Challenge History

**Problem:** Weekly challenges vanish after the week ends. No record of past performance.

**Solution:** Archive completed challenges in SharedPreferences, show history on Me screen.

**New files:**
- `lib/features/home/providers/challenge_history_provider.dart`
- `lib/features/me/widgets/challenge_history_card.dart`

**Files modified:**
- `lib/features/home/providers/weekly_challenge_provider.dart` — archive on week transition
- `lib/features/me/me_screen.dart` — add history section

**Design:**
1. Storage: SharedPreferences `challenge.history` — JSON array of `{weekId, type, target, current, completed}`
2. Keep last 12 weeks, trim older
3. Archive previous week on new week detection
4. UI: scrollable list with status icons, summary "8/12 completed"

---

## F4: Test Coverage for Critical Screens

**Problem:** 15/24 features have zero tests.

**Solution:** Add widget tests for 5 highest-traffic untested screens.

**New files:**
- `test/features/vocab/vocab_screen_test.dart`
- `test/features/learn/learn_screen_test.dart`
- `test/features/grammar/ghost_review_screen_test.dart`
- `test/features/progress/progress_screen_test.dart`
- `test/features/home/learning_path_screen_test.dart`

**Per test:** smoke render, key interaction, error state verification.

---

## F5: Semantics Accessibility Layer

**Problem:** Zero `Semantics` widgets in codebase. Screen readers cannot navigate meaningfully.

**Solution:** Add Semantics to 5 highest-impact shared widgets.

**Files modified:**
- `lib/features/common/widgets/clay_button.dart` — `Semantics(button: true, label:)`
- `lib/features/common/widgets/clay_card.dart` — `Semantics(container: true)`
- `lib/features/common/widgets/error_state_widget.dart` — `Semantics(liveRegion: true)`
- `lib/features/home/widgets/daily_session_card.dart` — semantic labels for steps
- `lib/features/home/home_screen.dart` — semantic ordering

---

## Implementation Order

| # | Feature | Type | Impact |
|---|---------|------|--------|
| 1 | F1 Achievement Wall | Social | High |
| 2 | F2 Personal Bests | Social | High |
| 3 | F3 Challenge History | Social | Medium-High |
| 4 | F4 Test Coverage | Quality | Medium |
| 5 | F5 Semantics Layer | Quality | Medium |

## Verification
- `flutter analyze` — 0 errors
- `flutter test` — all pass
- F1: Me → Achievements shows grid with locked/unlocked states
- F2: Complete test → see "New Personal Best!" if score beats record
- F3: Me → Challenge History shows past weeks
- F4: 5 new test files pass
- F5: ClayButton/ClayCard have Semantics wrappers
