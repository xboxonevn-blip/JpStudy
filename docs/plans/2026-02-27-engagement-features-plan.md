# Engagement Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Wire grammar SRS review to `GrammarPracticeScreen`, show next vocab review timing when nothing is due, and warn users when their streak is at risk.

**Architecture:** Three independent improvements: (1) pass due grammar IDs through `ContinueAction.data` so the "Start" button routes directly to a grammar quiz instead of the list screen; (2) add a `getNextScheduledReview()` query to `SrsDao` and display the timing in the vocab screen; (3) add a one-line danger zone warning to `DailySessionCard` when streak > 0, todayXp == 0, and hour ≥ 20.

**Tech Stack:** Flutter · Riverpod 2.x (StreamProvider, FutureProvider) · Drift ORM · GoRouter

---

## Task 1: Grammar SRS Wire

Route grammar due reviews to `GrammarPracticeScreen` with the correct IDs instead of the generic grammar list screen.

**Files:**
- Modify: `lib/features/home/providers/continue_provider.dart`
- Modify: `lib/features/home/widgets/daily_session_card.dart`
- Modify: `lib/features/home/widgets/next_step_suggestions.dart`

---

### Step 1: Update `continue_provider.dart` — add grammar IDs to `ContinueAction.data`

`continue_provider.dart` currently yields `data: null` for `grammarReview`. We need to fetch the due point IDs and pass them.

Add this import at the top:
```dart
import '../../../data/repositories/grammar_repository.dart';
```

Replace the `grammarReview` branch (currently lines ~26-33) with:
```dart
// Priority 1: Grammar Due
if (dashboard.grammarDue > 0) {
  final grammarRepo = ref.watch(grammarRepositoryProvider);
  final duePoints = await grammarRepo.fetchDuePoints();
  final dueIds = duePoints.map((p) => p.id).toList();
  yield ContinueAction(
    type: ContinueActionType.grammarReview,
    label: language.reviewGrammarLabel,
    count: dashboard.grammarDue,
    data: dueIds,  // List<int> of grammar point IDs due for review
  );
  return;
}
```

Note: `fetchDuePoints()` returns `Future<List<GrammarPoint>>`. `GrammarPoint` is a Drift-generated data class with `.id` (int).

### Step 2: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 3: Update `daily_session_card.dart` — route to `/grammar-practice` with IDs

In `_openDueRoute`, find the `grammarReview` case and replace:
```dart
// BEFORE
case ContinueActionType.grammarReview:
  return const _DailyRoute(route: '/grammar', step: 1);
```
with:
```dart
// AFTER
case ContinueActionType.grammarReview:
  final ids = continueAction?.data;
  if (ids is List && ids.isNotEmpty) {
    return _DailyRoute(
      route: '/grammar-practice',
      extra: List<int>.from(ids),
      step: 1,
    );
  }
  return const _DailyRoute(route: '/grammar', step: 1); // fallback
```

### Step 4: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 5: Update `next_step_suggestions.dart` — route to `/grammar-practice` with IDs

In `_navigateToDue`, find the `grammarReview` case:
```dart
// BEFORE
case ContinueActionType.grammarReview:
  context.push('/grammar');
  return;
```
Replace with:
```dart
// AFTER
case ContinueActionType.grammarReview:
  final ids = action?.data;
  if (ids is List && ids.isNotEmpty) {
    context.push('/grammar-practice', extra: List<int>.from(ids));
  } else {
    context.push('/grammar');
  }
  return;
```

### Step 6: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 7: Commit Task 1

```bash
git add lib/features/home/providers/continue_provider.dart \
        lib/features/home/widgets/daily_session_card.dart \
        lib/features/home/widgets/next_step_suggestions.dart
git commit -m "feat(A1): wire grammar SRS due reviews to GrammarPracticeScreen"
```

---

## Task 2: FSRS Next Review Chip

Show "Next review in Xh Ym" in the vocab screen when no vocab items are currently due.

**Files:**
- Modify: `lib/data/daos/srs_dao.dart`
- Modify: `lib/data/repositories/lesson_repository.dart`
- Modify: `lib/features/vocab/vocab_screen.dart`

---

### Step 1: Add `getNextScheduledReview()` to `SrsDao`

In `lib/data/daos/srs_dao.dart`, after the `getDueReviews()` method, add:

```dart
/// Returns the nearest future review date (minimum nextReviewAt > now).
/// Returns null if no SRS state exists yet.
Future<DateTime?> getNextScheduledReview() async {
  final row = await (select(srsState)
        ..where((t) => t.nextReviewAt.isBiggerThanValue(DateTime.now()))
        ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
        ..limit(1))
      .getSingleOrNull();
  return row?.nextReviewAt;
}
```

`OrderingTerm` is from `package:drift/drift.dart` which is already imported at the top of the file.

### Step 2: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 3: Add `nextVocabReviewProvider` to `lesson_repository.dart`

In `lib/data/repositories/lesson_repository.dart`, after `allDueTermsProvider` (around line 65), add:

```dart
/// Returns the nearest future vocab review date, or null if no SRS state exists.
final nextVocabReviewProvider = FutureProvider<DateTime?>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.srsDao.getNextScheduledReview();
});
```

`databaseProvider` is already imported at the top of this file (`lib/data/db/database_provider.dart`).

### Step 4: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 5: Update `_VocabContent` in `vocab_screen.dart`

The `_VocabContent` widget is a `ConsumerWidget`. Its `build` method already watches `dueTermsAsync = ref.watch(allDueTermsProvider)`.

**Add watch for next review:**
In `_VocabContent.build`, after:
```dart
final dueTermsAsync = ref.watch(allDueTermsProvider);
```
add:
```dart
final nextReviewAsync = ref.watch(nextVocabReviewProvider);
```

**Replace the due button block.** Currently the block is:
```dart
if (dueTermsAsync.hasValue && dueTermsAsync.value!.isNotEmpty)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: ClayButton( ... ),
  ),
```

Replace it with:
```dart
if (dueTermsAsync.hasValue && dueTermsAsync.value!.isNotEmpty)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: ClayButton(
      label: '${language.reviewAction} (${dueTermsAsync.value!.length})',
      icon: Icons.rate_review,
      style: ClayButtonStyle.primary,
      isExpanded: true,
      onPressed: () => context.push('/vocab/review'),
    ),
  ),
if (dueTermsAsync.hasValue && dueTermsAsync.value!.isEmpty)
  Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: _NextReviewChip(nextReviewAt: nextReviewAsync.valueOrNull),
  ),
```

**Add `_NextReviewChip` private widget** at the bottom of `vocab_screen.dart` (outside all classes, before the last `}`):

```dart
class _NextReviewChip extends StatelessWidget {
  const _NextReviewChip({required this.nextReviewAt});

  final DateTime? nextReviewAt;

  @override
  Widget build(BuildContext context) {
    final String text;
    if (nextReviewAt == null) {
      text = 'Complete a lesson to activate spaced review';
    } else {
      final diff = nextReviewAt!.difference(DateTime.now());
      final String timing;
      if (diff.inMinutes < 60) {
        timing = '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        timing = m > 0 ? '${h}h ${m}m' : '${h}h';
      } else {
        timing = 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
      }
      text = '✅  All caught up! Next review $timing';
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppThemeV2.textSub,
      ),
    );
  }
}
```

`AppThemeV2` is already imported in `vocab_screen.dart` (`package:jpstudy/theme/app_theme_v2.dart`).

### Step 6: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 7: Commit Task 2

```bash
git add lib/data/daos/srs_dao.dart \
        lib/data/repositories/lesson_repository.dart \
        lib/features/vocab/vocab_screen.dart
git commit -m "feat(A3): show next SRS review timing in vocab screen when nothing is due"
```

---

## Task 3: Streak Danger Zone

Add a one-line warning inside `DailySessionCard` when the user's streak is at risk (streak > 0, no XP today, hour ≥ 20).

**Files:**
- Modify: `lib/features/home/widgets/daily_session_card.dart`

---

### Step 1: Compute `streakAtRisk` in `DailySessionCard.build`

In `_DailySessionCardState.build`, after the `completionPercent` calculation, add:

```dart
final streakAtRisk = (dashboard?.streak ?? 0) > 0 &&
    (dashboard?.todayXp ?? 0) == 0 &&
    DateTime.now().hour >= 20;
```

### Step 2: Add warning row to the card's Column

Inside the dark gradient `Container`, the `Column` currently has items ending with `_BackupStatusLine`. Add the streak warning **before** `_BackupStatusLine`:

```dart
if (streakAtRisk) ...[
  const SizedBox(height: 6),
  Row(
    children: [
      const Icon(
        Icons.local_fire_department_rounded,
        size: 14,
        color: Color(0xFFFF6B00),
      ),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          '${dashboard!.streak}-day streak at risk — practice now to keep it!',
          style: const TextStyle(
            color: Color(0xFFFF6B00),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  ),
],
```

### Step 3: Run `flutter analyze lib/`

Expected: No issues.

---

### Step 4: Commit Task 3

```bash
git add lib/features/home/widgets/daily_session_card.dart
git commit -m "feat: add streak danger zone warning in DailySessionCard"
```

---

## Final Verification

```bash
flutter analyze lib/
```

Expected: `No issues found!`

Manual checks:
1. **Grammar SRS**: Trigger grammar due state (e.g., add a SRS state with past `nextReviewAt` for a grammar point). Press "Start" on `DailySessionCard`. Confirm you land on the grammar quiz screen, not the grammar list.
2. **FSRS chip**: Open Vocab screen when no vocab is due. Confirm "✅ All caught up! Next review Xh" appears. When no SRS state exists at all, confirm fallback text shows.
3. **Streak warning**: Confirm the warning row is present only when `streak > 0`, `todayXp == 0`, and `hour >= 20`.
