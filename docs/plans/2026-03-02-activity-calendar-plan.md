# Activity Calendar Implementation Plan

**Goal:** Add a GitHub-style 16-week activity heatmap (streak calendar) to the top of the Progress screen, showing daily review counts with color intensity, current streak, and a color legend.

**Architecture:** A new `activityCalendarProvider` (wraps existing `fetchReviewHistory(limit:112)`) feeds a pure widget `_ActivityCalendar` added to the top of `ProgressScreen`'s ListView. Grid is built by date-math from today's weekday, coloring cells by reviewed count. Streak count from existing `progressSummaryProvider`.

**Tech Stack:** Flutter/Dart, Riverpod 2.x (`FutureProvider`), Drift (existing DAO, no changes), `MaterialLocalizations` for date formatting.

---

### Task 1: Add `activityCalendarProvider`

**Files:**
- Modify: `lib/data/repositories/lesson_repository.dart` (after `reviewHistoryProvider` ~line 91)

**Step 1: Add provider**

Insert after the `reviewHistoryProvider` declaration (around line 91):

```dart
final activityCalendarProvider = FutureProvider<List<ReviewDaySummary>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.fetchReviewHistory(limit: 112);
});
```

> Note: `fetchReviewHistory` already accepts `limit` param and queries `userProgress` where `reviewedCount > 0`. Days with zero reviews are absent — the widget fills those as empty cells.

**Step 2: Verify analyze**

```bash
flutter analyze lib/data/repositories/lesson_repository.dart
```
Expected: No issues found.

**Step 3: Commit**

```bash
git add lib/data/repositories/lesson_repository.dart
git commit -m "feat(progress): add activityCalendarProvider for 16-week history"
```

---

### Task 2: Add `_ActivityCalendar` widget to ProgressScreen

**Files:**
- Modify: `lib/features/progress/progress_screen.dart`

**Step 1: Add imports (if not already present)**

Ensure these are at the top of `progress_screen.dart`:
```dart
import 'package:jpstudy/data/repositories/lesson_repository.dart';
```
(already imported — `progressSummaryProvider` is already watched there)

**Step 2: Wire `_ActivityCalendar` into the ListView**

In `ProgressScreen.build`, inside the `summaryAsync.when(data: ...)` block, add `_ActivityCalendar()` as the **first** child of the `ListView`:

```dart
return ListView(
  padding: const EdgeInsets.all(20),
  children: [
    const _ActivityCalendar(),   // ← ADD THIS
    const SizedBox(height: 16),  // ← ADD THIS
    _StatCard(
      label: language.progressStreakLabel,
      ...
```

**Step 3: Add the `_ActivityCalendar` widget class**

Add at the **bottom** of `progress_screen.dart`, after the last class:

```dart
class _ActivityCalendar extends ConsumerWidget {
  const _ActivityCalendar();

  static const int _weeks = 16;
  static const double _cellSize = 10;
  static const double _cellGap = 3;
  static const List<Color> _palette = [
    Color(0xFFE8ECF5), // 0 reviews
    Color(0xFFBDD5F5), // 1–5
    Color(0xFF5B9FE8), // 6–15
    Color(0xFF1A6FD8), // 16+
  ];

  Color _color(int reviewed) {
    if (reviewed <= 0) return _palette[0];
    if (reviewed <= 5) return _palette[1];
    if (reviewed <= 15) return _palette[2];
    return _palette[3];
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _shortMonth(int month) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[month - 1];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarAsync = ref.watch(activityCalendarProvider);
    final streak = ref.watch(progressSummaryProvider).asData?.value.streak ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A2E3A59), blurRadius: 18, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          calendarAsync.when(
            data: (history) => _buildGrid(context, history),
            loading: () => const SizedBox(
              height: 88,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox(height: 88),
          ),
          const SizedBox(height: 10),
          _buildBottomRow(streak),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<ReviewDaySummary> history) {
    // Build sparse lookup map
    final map = <String, int>{};
    for (final s in history) {
      map[_dateKey(s.day)] = s.reviewed;
    }

    final today = DateTime.now();
    // Monday of current week
    final mondayThisWeek = today.subtract(Duration(days: today.weekday - 1));
    // Start = Monday 15 weeks ago
    final startDate = mondayThisWeek.subtract(const Duration(days: 15 * 7));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels (M T W T F S S)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 14), // spacer for month row
              for (final label in const ['M', 'T', 'W', 'T', 'F', 'S', 'S']) ...[
                SizedBox(
                  height: _cellSize,
                  width: 12,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 8, color: Color(0xFF6B7390)),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: _cellGap),
              ],
            ],
          ),
          const SizedBox(width: _cellGap + 2),
          // Week columns
          for (int col = 0; col < _weeks; col++) ...[
            _buildWeekColumn(context, col, startDate, map, today),
            if (col < _weeks - 1) const SizedBox(width: _cellGap),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekColumn(
    BuildContext context,
    int col,
    DateTime startDate,
    Map<String, int> map,
    DateTime today,
  ) {
    final weekMonday = startDate.add(Duration(days: col * 7));

    // Month label: show when this column starts a new month
    String? monthLabel;
    if (col == 0) {
      monthLabel = _shortMonth(weekMonday.month);
    } else {
      final prevMonday = startDate.add(Duration(days: (col - 1) * 7));
      if (weekMonday.month != prevMonday.month) {
        monthLabel = _shortMonth(weekMonday.month);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 14,
          child: monthLabel != null
              ? Text(
                  monthLabel,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Color(0xFF6B7390),
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        for (int row = 0; row < 7; row++) ...[
          _buildCell(context, weekMonday.add(Duration(days: row)), map, today),
          if (row < 6) const SizedBox(height: _cellGap),
        ],
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    DateTime date,
    Map<String, int> map,
    DateTime today,
  ) {
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final isFuture = dateOnly.isAfter(todayOnly);
    final isToday = dateOnly == todayOnly;
    final key = _dateKey(date);
    final reviewed = isFuture ? 0 : (map[key] ?? 0);

    final box = Container(
      width: _cellSize,
      height: _cellSize,
      decoration: BoxDecoration(
        color: isFuture ? Colors.transparent : _color(reviewed),
        borderRadius: BorderRadius.circular(3),
        border: isToday
            ? Border.all(color: const Color(0xFF1A6FD8), width: 1.5)
            : null,
      ),
    );

    if (isFuture) return box;

    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatMediumDate(date);
    final tooltip = reviewed > 0 ? '$dateLabel — $reviewed reviews' : dateLabel;

    return Tooltip(message: tooltip, child: box);
  }

  Widget _buildBottomRow(int streak) {
    return Row(
      children: [
        const Icon(
          Icons.local_fire_department_rounded,
          size: 14,
          color: Color(0xFFF97316),
        ),
        const SizedBox(width: 4),
        Text(
          '$streak-day streak',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF97316),
          ),
        ),
        const Spacer(),
        const Text('Ít', style: TextStyle(fontSize: 10, color: Color(0xFF6B7390))),
        const SizedBox(width: 4),
        for (final color in _palette) ...[
          Container(
            width: _cellSize,
            height: _cellSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: _cellGap),
        ],
        const Text('Nhiều', style: TextStyle(fontSize: 10, color: Color(0xFF6B7390))),
      ],
    );
  }
}
```

**Step 4: Run analyze**

```bash
flutter analyze lib/features/progress/progress_screen.dart
```
Expected: No issues found.

**Step 5: Commit**

```bash
git add lib/features/progress/progress_screen.dart
git commit -m "feat(progress): add _ActivityCalendar heatmap with streak + legend"
```

---

### Task 3: Write widget smoke test

**Files:**
- Create: `test/features/progress/activity_calendar_test.dart`

**Step 1: Create test file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/progress/progress_screen.dart';

void main() {
  group('ProgressScreen activity calendar', () {
    testWidgets('renders Activity heading with empty history', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityCalendarProvider.overrideWith(
              (ref) async => const [],
            ),
            progressSummaryProvider.overrideWith(
              (ref) async => const ProgressSummary(
                streak: 5,
                todayXp: 20,
                totalXp: 400,
                totalAttempts: 12,
                totalCorrect: 100,
                totalQuestions: 120,
              ),
            ),
            reviewHistoryProvider.overrideWith((ref) async => const []),
            attemptHistoryProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );

      await tester.pump(); // let FutureProviders resolve
      await tester.pump();

      expect(find.text('Activity'), findsOneWidget);
    });

    testWidgets('shows streak count in bottom row', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityCalendarProvider.overrideWith(
              (ref) async => const [],
            ),
            progressSummaryProvider.overrideWith(
              (ref) async => const ProgressSummary(
                streak: 7,
                todayXp: 0,
                totalXp: 0,
                totalAttempts: 0,
                totalCorrect: 0,
                totalQuestions: 0,
              ),
            ),
            reviewHistoryProvider.overrideWith((ref) async => const []),
            attemptHistoryProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.textContaining('7-day streak'), findsOneWidget);
    });
  });
}
```

**Step 2: Run tests**

```bash
flutter test test/features/progress/activity_calendar_test.dart --reporter compact
```
Expected: All tests pass.

**Step 3: Commit**

```bash
git add test/features/progress/activity_calendar_test.dart
git commit -m "test(progress): add smoke tests for _ActivityCalendar widget"
```

---

### Task 4: Full verify & push

**Step 1: Analyze entire lib**

```bash
flutter analyze lib/
```
Expected: No issues found.

**Step 2: Run all tests**

```bash
flutter test --reporter compact
```
Expected: Previous 38 pass + 2 new pass = 40 pass, 2 pre-existing failures in `mock_exam_walkthrough_test.dart`.

**Step 3: Push**

```bash
git push origin main
```
