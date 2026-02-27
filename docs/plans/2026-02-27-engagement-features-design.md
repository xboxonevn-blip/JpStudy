# Engagement Features Design: Grammar SRS Wire + FSRS Transparency + Streak Danger Zone

**Date:** 2026-02-27
**Scope:** 3 independent engagement improvements, ~5 files

---

## Context

After exploring the codebase, most roadmap items (A1, B1, B2) are already implemented.
Three concrete engagement gaps remain:

1. Grammar due → routes to `/grammar` list instead of a live SRS review session
2. Vocab screen shows no "next review" timing when nothing is due → user doesn't understand SRS pacing
3. No streak loss warning when user hasn't practiced late in the day

---

## Feature 1: Grammar SRS Wire

**Problem:** `ContinueActionType.grammarReview` in `DailySessionCard._openDueRoute` routes to
`/grammar` (the grammar list screen). User must navigate further to start a review.
Grammar's SRS infrastructure (`grammarDao.getDueReviews()`, `GrammarSrsState`) is fully in place.

**Solution:** Pass due grammar point IDs through `ContinueAction.data`, then route to
`/grammar-practice` with those IDs. The router already handles `state.extra is List<int>`.

### Changes

**`lib/features/home/providers/continue_provider.dart`**
- Add import: `grammar_repository.dart`
- When `dashboard.grammarDue > 0`:
  - Fetch `grammarRepo.fetchDuePoints()` → extract `.id` list
  - Set `data: dueIds` (List<int>) in the yielded `ContinueAction`

**`lib/features/home/widgets/daily_session_card.dart`**
- In `_openDueRoute`, case `grammarReview`:
  ```dart
  final ids = continueAction?.data;
  return ids is List && ids.isNotEmpty
      ? _DailyRoute(route: '/grammar-practice', extra: List<int>.from(ids), step: 1)
      : const _DailyRoute(route: '/grammar', step: 1); // fallback
  ```
- In `_nextDailyRoute` fallback `if ((dashboard?.grammarDue ?? 0) > 0)`:
  - Cannot easily pass IDs here (no continueAction available) → keep routing to `/grammar`
  - This fallback only triggers when `continueAction` is null, which is rare

**`lib/features/home/widgets/next_step_suggestions.dart`**
- When `totalDue > 0` and grammar has priority, navigate via `_navigateToDue`
- In `_navigateToDue`, case `grammarReview`:
  - Use `action?.data` IDs to push `/grammar-practice` with `List<int>.from(ids)`
  - Fallback: `/grammar` if no IDs

---

## Feature 2: FSRS "Next Review" Chip

**Problem:** Vocab screen shows a "Review Due (X)" button when items are due, but when due == 0
the user sees no information about when SRS will next surface words. Users lose trust in the system.

**Solution:** Add a `getNextScheduledReview()` method to `SrsDao`, expose it via a provider,
and display "Next review in Xh Ym" in the vocab screen header when nothing is due.

### Changes

**`lib/data/daos/srs_dao.dart`**
```dart
Future<DateTime?> getNextScheduledReview() async {
  final row = await (select(srsState)
    ..where((t) => t.nextReviewAt.isBiggerThanValue(DateTime.now()))
    ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
    ..limit(1)).getSingleOrNull();
  return row?.nextReviewAt;
}
```

**`lib/data/repositories/lesson_repository.dart`**
```dart
final nextVocabReviewProvider = FutureProvider<DateTime?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.srsDao.getNextScheduledReview();
});
```

**`lib/features/vocab/vocab_screen.dart`** (`_VocabContent.build`)
- Also watch `nextVocabReviewProvider`
- When `dueTermsAsync.value!.isEmpty`, show a styled row:
  - If `nextReview != null`: "✅ All caught up! Next review in Xh Ym"
    - Format: if < 1h → "Xm", if < 24h → "Xh Ym", else → "in X days"
  - If `nextReview == null` (no SRS state yet): "Start a lesson to activate spaced review"
- Text color: `AppThemeV2.textSub`, 13px, shown in the same padding as the "Review" button

---

## Feature 3: Streak Danger Zone

**Problem:** `DashboardState.streak` is tracked but there is no in-app warning when the
user is at risk of losing their streak (late in day, no XP earned today).

**Solution:** Add a single warning row in `DailySessionCard` when conditions are met.

### Condition
```
streak > 0 AND todayXp == 0 AND DateTime.now().hour >= 20
```

### Changes

**`lib/features/home/widgets/daily_session_card.dart`**
- Compute `streakAtRisk` in `build()` using `dashboard?.streak`, `dashboard?.todayXp`, and `DateTime.now().hour`
- Add a warning row inside the card's `Column`, placed just before the session steps `Wrap`:
  ```
  🔥 [streak] day streak at risk — practice to keep it!
  ```
  Style: amber/orange text (Color(0xFFFF6B00)), 12px, w700, only visible when `streakAtRisk`

---

## Files Summary

| File | Change |
|------|--------|
| `lib/features/home/providers/continue_provider.dart` | Add grammar IDs to ContinueAction.data |
| `lib/features/home/widgets/daily_session_card.dart` | Route grammar to /grammar-practice; add streak warning |
| `lib/features/home/widgets/next_step_suggestions.dart` | Route grammar to /grammar-practice with IDs |
| `lib/data/daos/srs_dao.dart` | Add getNextScheduledReview() |
| `lib/data/repositories/lesson_repository.dart` | Add nextVocabReviewProvider |
| `lib/features/vocab/vocab_screen.dart` | Show next review timing when due == 0 |

Total: 6 file touches

---

## Verification

- `flutter analyze lib/` → no issues
- Manual: trigger grammar due state → Start button → goes to grammar-practice quiz (not list)
- Manual: all vocab reviewed (due == 0) → "Next review in Xh Ym" shows in vocab screen
- Manual: set hour to ≥ 20, streak > 0, todayXp == 0 → warning row visible in DailySessionCard
