# Activity Calendar Design

**Date:** 2026-03-02
**Scope:** Streak/activity heatmap calendar in Progress screen, ~2 files

---

## Problem

The Progress screen shows streak and XP as plain text cards. Users cannot see
*where* they've been studying — there is no sense of continuity or consistency.
Without a visual history, users don't feel the emotional pull to "keep the chain".

---

## Solution

Add a GitHub-style activity heatmap to the top of the Progress screen showing
the last 16 weeks (112 days) of SRS review activity. Each day = one colored
square; color intensity = number of items reviewed. A streak row beneath the
calendar shows the current streak count and a color legend.

---

## Data

`fetchReviewHistory({int limit})` in `LessonRepository` queries `userProgress`
where `reviewedCount > 0`, ordered by `day DESC`. Days with zero reviews are
absent from the result — the widget fills those as empty cells.

Add one new provider:

```dart
// lib/data/repositories/lesson_repository.dart
final activityCalendarProvider = FutureProvider<List<ReviewDaySummary>>(
  (ref) => ref.watch(lessonRepositoryProvider).fetchReviewHistory(limit: 112),
);
```

Streak count comes from the existing `progressSummaryProvider`
(`summary.streak`).

---

## Widget: `_ActivityCalendar`

Placed at the top of the `ProgressScreen` `ListView`, before the stat cards.

### Layout

```
┌─ Activity ─────────────────────────────────────────┐
│      Jan        Feb        Mar                      │
│  M  □  □  □  ■  □  □  □  ■  ■  □  □  ■            │
│  T  □  ■  □  □  ■  □  ■  □  ■  ■  □  □            │
│  W  ■  ■  □  □  □  ■  ■  ■  □  □  ■  □            │
│  T  □  □  ■  ■  □  □  □  ■  □  ■  ■  ■            │
│  F  □  □  □  □  ■  ■  ■  □  ■  □  □  ■            │
│  S  □  □  ■  □  □  □  ■  □  □  ■  □  □            │
│  S  □  ■  □  □  □  ■  □  □  □  □  ■  [today]      │
│                                                     │
│  🔥 12-day streak          Ít ░ ▒ ▓ █ Nhiều         │
└─────────────────────────────────────────────────────┘
```

### Grid construction

- 16 columns (weeks), 7 rows (Mon–Sun), newest week on the right
- Align the rightmost column to today's weekday; pad earlier columns with empty cells
- Month labels: render above first column where the month changes
- Day labels (M T W T F S S) on the left

### Cell styling

| `reviewed` count | Color | Hex |
|---|---|---|
| 0 | Grey | `0xFFE8ECF5` |
| 1–5 | Light blue | `0xFFBDD5F5` |
| 6–15 | Medium blue | `0xFF5B9FE8` |
| 16+ | Dark blue | `0xFF1A6FD8` |

- Cell size: **10×10 px**, gap: **3 px**, `BorderRadius(3)`
- Today's cell: additional `Border.all(color: 0xFF1A6FD8, width: 1.5)`
- Tap: `Tooltip` showing `"MMM d — N reviews"` (using `MaterialLocalizations`)
- Overflow: `SingleChildScrollView(scrollDirection: Axis.horizontal)`

### Bottom row

```
Row(mainAxisAlignment: spaceBetween)
├── 🔥 <streak> day streak   ← from progressSummaryProvider
└── Ít  □░▒▓  Nhiều          ← 4 colored boxes + labels
```

- Streak: `Icon(local_fire_department)` + text, orange `0xFFF97316`
- Legend: 4 small cells (same 10×10) in the 4 colors + "Ít" / "Nhiều" text, `textSub` color

---

## Files

| File | Change |
|---|---|
| `lib/data/repositories/lesson_repository.dart` | Add `activityCalendarProvider` |
| `lib/features/progress/progress_screen.dart` | Watch provider; add `_ActivityCalendar` widget |

---

## Verification

- `flutter analyze lib/` → no issues
- Manual: Progress screen shows 16-week grid, today's cell has border
- Manual: Days with reviews show correct color intensity
- Manual: Days without reviews show grey
- Manual: Streak count matches header bar streak capsule
- Manual: Legend visible at bottom-right of calendar
