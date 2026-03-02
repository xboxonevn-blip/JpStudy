# Engagement Batch 2 Design: Achievements + SRS Retention + Kanji Chip + Week Summary

**Date:** 2026-03-02
**Scope:** 4 independent engagement features, ~8 files total

---

## Feature 1: Achievement Streak & Level Triggers + Home Popup

### Problem

`LearnSessionService._checkAchievements()` awards `perfectRound`, `speedDemon`,
`masteryComplete`, `firstLesson` — but `streak`, `levelUp`, `kanjiMaster`, and
`articleReader` are never triggered. The popup mechanism (`getPendingAchievements()`)
only fires in `LearnSummaryScreen`, so achievements earned outside learn sessions
are never shown.

### Solution

1. Add `hasAchievement(type, value)` to `AchievementDao` — prevents duplicate awards.
2. Add `_checkStreakAndLevelAchievements()` in `HomeScreen` using
   `ref.listen(dashboardProvider, ...)`. Milestones: streak 7, 14, 30, 60, 100 days;
   level-up when XP crosses `LearnSessionService.calculateLevel()` thresholds.
3. In `HomeScreen.initState`, add `postFrameCallback` → call
   `LearnSessionService.getPendingAchievements()` → loop and `showDialog`.

### Achievement Milestone Table

| Type | Condition | Value field |
|---|---|---|
| `streak` | streak ∈ {7, 14, 30, 60, 100} | day count |
| `levelUp` | `calculateLevel(totalXp)` > previous level | new level number |

### Key implementation detail

Use `ref.listen` in `build` (not `initState`) so it reacts to `dashboardProvider`
changes. Guard with `!mounted` before showing dialogs.

### Files

| File | Change |
|---|---|
| `lib/data/daos/achievement_dao.dart` | Add `hasAchievement(String type, int value)` |
| `lib/features/home/home_screen.dart` | Add `ref.listen` + `_checkMilestones()` + `_showPendingAchievements()` |

---

## Feature 2: SRS Retention Breakdown Card

### Problem

Progress screen shows stats as flat numbers. Users can't see whether their vocabulary
is actually moving toward long-term retention (FSRS "Mature" stage).

### Solution

Add `_SrsRetentionCard` to Progress screen after `_ActivityCalendar`. Shows item
counts by FSRS stability bracket in a stacked bar + label row.

### Stage definition (based on `stability` column in `srs_state`)

| Stage | Condition | Color |
|---|---|---|
| Learning | stability < 1.0 | `0xFFEF4444` (red) |
| Young | 1.0 ≤ stability < 21.0 | `0xFFEAB308` (yellow) |
| Mature | stability ≥ 21.0 | `0xFF22C55E` (green) |

Note: only items in `srs_state` are counted (i.e., items reviewed at least once).
"New" (never reviewed) items are excluded — their count varies by lesson selection.

### Layout

```
┌─ Vocabulary SRS ──────────────────────────────┐
│  484 items reviewed via SRS                   │
│  [████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░]       │
│  Learning 38  ·  Young 94  ·  Mature 352      │
└────────────────────────────────────────────────┘
```

- Stacked horizontal bar (proportional widths, `ClipRRect` with `BorderRadius(4)`)
- Count labels below bar
- No color for "0" segments

### Files

| File | Change |
|---|---|
| `lib/data/daos/srs_dao.dart` | Add `getStageBreakdown()` → `SrsStageBreakdown` |
| `lib/data/repositories/lesson_repository.dart` | Add `srsRetentionProvider` |
| `lib/features/progress/progress_screen.dart` | Add `_SrsRetentionCard` |

```dart
class SrsStageBreakdown {
  final int learning; // stability < 1.0
  final int young;    // 1.0 ≤ stability < 21.0
  final int mature;   // stability ≥ 21.0
  int get total => learning + young + mature;
}
```

```dart
Future<SrsStageBreakdown> getStageBreakdown() async {
  final rows = await select(srsState).get();
  int learning = 0, young = 0, mature = 0;
  for (final r in rows) {
    final s = r.stability ?? 0;
    if (s < 1.0) learning++;
    else if (s < 21.0) young++;
    else mature++;
  }
  return SrsStageBreakdown(learning: learning, young: young, mature: mature);
}
```

---

## Feature 3: Kanji "Next Review" Chip

### Problem

`HomeHandwritingPracticeScreen` shows all level kanji with no SRS timing info.
Users don't know when their next kanji SRS session is due.

### Solution

Port the vocab chip pattern to kanji. Add a small info row at the top of
`HomeHandwritingPracticeScreen` showing due count and next review timing.

- When `kanjiDue > 0`: "X kanji due for review" (tap → handled by home continue button, no nav here)
- When `kanjiDue == 0`: "✅ All caught up! Next review in Xh Ym" (or "Review ready now!" if overdue)

### New DAO method (same pattern as `SrsDao.getNextScheduledReview()`)

```dart
// KanjiSrsDao
Future<DateTime?> getNextScheduledReview() async {
  final row = await (select(kanjiSrsState)
    ..where((t) => t.nextReviewAt.isBiggerThanValue(DateTime.now()))
    ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
    ..limit(1)).getSingleOrNull();
  return row?.nextReviewAt;
}
```

### New provider (same pattern as `nextVocabReviewProvider`)

```dart
final nextKanjiReviewProvider = StreamProvider.autoDispose<DateTime?>((ref) async* {
  final db = ref.watch(databaseProvider);
  await for (final _ in db.kanjiSrsDao.watchDueReviewCount()) {
    yield await db.kanjiSrsDao.getNextScheduledReview();
  }
});
```

### UI placement

In `HomeHandwritingPracticeScreen.build`, after confirming `items.isNotEmpty`,
add a `_KanjiReviewChip` row above the `HandwritingPracticeScreen` call.
Watch `dashboardProvider` (for `kanjiDue`) and `nextKanjiReviewProvider`.

### Files

| File | Change |
|---|---|
| `lib/data/daos/kanji_srs_dao.dart` | Add `getNextScheduledReview()` |
| `lib/data/repositories/lesson_repository.dart` | Add `nextKanjiReviewProvider` |
| `lib/features/write/screens/home_handwriting_practice_screen.dart` | Add `_KanjiReviewChip` |

---

## Feature 4: Home Week Summary Row

### Problem

Home screen shows today's status only. Users have no sense of weekly progress,
making it hard to feel consistent improvement.

### Solution

Add a compact summary row between `DailySessionCard` and `NextStepSuggestions`
on the home screen showing this week's aggregate stats.

### Layout

```
📅  This week: 47 reviews · 83% accuracy · 5/7 days
```

- Single `Row` with `Icon(calendar_today)` + 3 stat chips
- Compact: 12px font, `AppThemeV2.textSub` color
- Tappable → navigates to `/progress`

### Data: `weekSummaryProvider`

```dart
class WeekSummary {
  final int totalReviewed;   // sum of ReviewDaySummary.reviewed for last 7 days
  final int accuracy;        // % correct from attempts in last 7 days (0 if no attempts)
  final int daysStudied;     // count of days with reviewed > 0
}

final weekSummaryProvider = FutureProvider<WeekSummary>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final history = await repo.fetchReviewHistory(limit: 7);
  final attempts = await repo.fetchAttemptHistory(limit: 50);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));

  final totalReviewed = history.fold(0, (s, d) => s + d.reviewed);
  final daysStudied = history.length;

  final weekAttempts = attempts.where((a) => a.startedAt.isAfter(cutoff)).toList();
  final totalCorrect = weekAttempts.fold(0, (s, a) => s + a.score);
  final totalQ = weekAttempts.fold(0, (s, a) => s + a.total);
  final accuracy = totalQ == 0 ? 0 : (totalCorrect / totalQ * 100).round();

  return WeekSummary(
    totalReviewed: totalReviewed,
    accuracy: accuracy,
    daysStudied: daysStudied,
  );
});
```

### Files

| File | Change |
|---|---|
| `lib/data/repositories/lesson_repository.dart` | Add `WeekSummary` class + `weekSummaryProvider` |
| `lib/features/home/widgets/daily_session_card.dart` | Add `_WeekSummaryRow` widget |

The `_WeekSummaryRow` is placed at the bottom of `DailySessionCard`'s Column,
below `_BackupStatusLine`, only shown when `totalReviewed > 0`.

---

## File Summary

| File | Features |
|---|---|
| `lib/data/daos/achievement_dao.dart` | F1: `hasAchievement()` |
| `lib/data/daos/srs_dao.dart` | F2: `getStageBreakdown()` |
| `lib/data/daos/kanji_srs_dao.dart` | F3: `getNextScheduledReview()` |
| `lib/data/repositories/lesson_repository.dart` | F2: `srsRetentionProvider`; F3: `nextKanjiReviewProvider`; F4: `WeekSummary` + `weekSummaryProvider` |
| `lib/features/home/home_screen.dart` | F1: milestone check + popup |
| `lib/features/progress/progress_screen.dart` | F2: `_SrsRetentionCard` |
| `lib/features/write/screens/home_handwriting_practice_screen.dart` | F3: `_KanjiReviewChip` |
| `lib/features/home/widgets/daily_session_card.dart` | F4: `_WeekSummaryRow` |

---

## Verification

- `flutter analyze lib/` → No issues
- F1: trigger a 7-day streak → popup appears on home screen next open; re-open → no duplicate popup
- F2: Progress screen shows SRS breakdown card with 3 colored segments
- F3: Kanji screen shows "Next review in Xh" when kanjiDue == 0
- F4: Home screen shows week summary row when user has reviewed items this week
