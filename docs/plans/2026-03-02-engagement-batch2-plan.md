# Engagement Batch 2 Implementation Plan

**Goal:** Add 4 independent engagement features: achievement streak/level triggers + home popup, SRS retention breakdown card, kanji next-review chip, and home week-summary row.

**Architecture:** Each feature is a self-contained vertical slice (DAO → provider → UI). Features share no state and can be implemented in any order. Features 2–4 follow patterns already established by the vocab next-review chip (A3) and the activity calendar.

**Tech Stack:** Flutter, Riverpod 2.x (FutureProvider, StreamProvider.autoDispose), Drift ORM (DAO methods), widget tests with `ProviderScope` overrides.

---

## Task 1: Achievement Milestone Triggers + Home Popup

**Files:**
- Modify: `lib/data/daos/achievement_dao.dart` (add `hasAchievement()`)
- Modify: `lib/features/home/home_screen.dart` (add milestone check + pending popup)
- Test: `test/data/daos/achievement_dao_test.dart` (new)

---

### Step 1: Write failing test for `hasAchievement()`

Create `test/data/daos/achievement_dao_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';

void main() {
  late AppDatabase db;
  late AchievementDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = AchievementDao(db);
  });

  tearDown(() => db.close());

  test('hasAchievement returns false when no matching row', () async {
    final result = await dao.hasAchievement('streak', 7);
    expect(result, isFalse);
  });

  test('hasAchievement returns true after inserting matching row', () async {
    await dao.addAchievement(AchievementsCompanion.insert(
      type: 'streak',
      value: 7,
      earnedAt: DateTime.now(),
      isNotified: const Value(false),
    ));
    final result = await dao.hasAchievement('streak', 7);
    expect(result, isTrue);
  });

  test('hasAchievement is false for same type but different value', () async {
    await dao.addAchievement(AchievementsCompanion.insert(
      type: 'streak',
      value: 7,
      earnedAt: DateTime.now(),
      isNotified: const Value(false),
    ));
    final result = await dao.hasAchievement('streak', 14);
    expect(result, isFalse);
  });
}
```

---

### Step 2: Run test to verify it fails

```
flutter test test/data/daos/achievement_dao_test.dart -v
```

Expected: FAIL — `hasAchievement` method not found.

---

### Step 3: Add `hasAchievement()` to AchievementDao

In `lib/data/daos/achievement_dao.dart`, add after `markAsNotified()`:

```dart
/// Returns true if an achievement of the given type and value already exists.
Future<bool> hasAchievement(String type, int value) async {
  final row = await (select(achievements)
        ..where((t) => t.type.equals(type) & t.value.equals(value)))
      .getSingleOrNull();
  return row != null;
}
```

---

### Step 4: Run test to verify it passes

```
flutter test test/data/daos/achievement_dao_test.dart -v
```

Expected: 3 tests PASS.

---

### Step 5: Modify HomeScreen to add milestone check + pending popup

In `lib/features/home/home_screen.dart`:

**5a. Add imports** (at the top, after existing imports):

```dart
import 'package:jpstudy/data/db/database_provider.dart';
import 'package:jpstudy/data/daos/learn_dao.dart';
import 'package:jpstudy/data/daos/achievement_dao.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
import 'package:jpstudy/features/learn/models/achievement.dart' as model;
import 'package:jpstudy/features/learn/services/learn_session_service.dart';
```

**5b. Add field to `_HomeScreenState`** (after existing `DateTime? _lastAutoBackup;`):

```dart
int? _lastKnownLevel;
```

**5c. Modify `initState()`** — add postFrameCallback after existing calls:

```dart
@override
void initState() {
  super.initState();
  _loadReminderPrefs();
  _loadBackupPrefs();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _showPendingAchievements();
    _initLevelTracking();
  });
}
```

**5d. Add `ref.listen` in `build()`** — add after the `ref.watch(appInitProvider);` line:

```dart
ref.listen<AsyncValue<DashboardState>>(dashboardProvider, (_, next) {
  next.whenData((state) => _checkMilestones(state));
});
```

**5e. Add four new methods** to `_HomeScreenState` (before `_setLevel()`):

```dart
Future<void> _initLevelTracking() async {
  final repo = ref.read(lessonRepositoryProvider);
  final progress = await repo.fetchProgressSummary();
  final service = LearnSessionService(
    LearnDao(ref.read(databaseProvider)),
    AchievementDao(ref.read(databaseProvider)),
  );
  _lastKnownLevel = service.calculateLevel(progress.totalXp);
}

Future<void> _checkMilestones(DashboardState state) async {
  if (!mounted) return;
  final db = ref.read(databaseProvider);
  final achievementDao = AchievementDao(db);

  // Streak milestones
  const milestones = [7, 14, 30, 60, 100];
  if (milestones.contains(state.streak)) {
    final already = await achievementDao.hasAchievement(
      model.AchievementType.streak.name,
      state.streak,
    );
    if (!already) {
      await achievementDao.addAchievement(
        AchievementsCompanion(
          type: Value(model.AchievementType.streak.name),
          value: Value(state.streak),
          earnedAt: Value(DateTime.now()),
          isNotified: const Value(false),
        ),
      );
    }
  }

  // Level-up milestone
  if (_lastKnownLevel != null) {
    final repo = ref.read(lessonRepositoryProvider);
    final progress = await repo.fetchProgressSummary();
    final service = LearnSessionService(
      LearnDao(db),
      AchievementDao(db),
    );
    final newLevel = service.calculateLevel(progress.totalXp);
    if (newLevel > _lastKnownLevel!) {
      final already = await achievementDao.hasAchievement(
        model.AchievementType.levelUp.name,
        newLevel,
      );
      if (!already) {
        await achievementDao.addAchievement(
          AchievementsCompanion(
            type: Value(model.AchievementType.levelUp.name),
            value: Value(newLevel),
            earnedAt: Value(DateTime.now()),
            isNotified: const Value(false),
          ),
        );
      }
      _lastKnownLevel = newLevel;
    }
  }

  if (!mounted) return;
  await _showPendingAchievements();
}

Future<void> _showPendingAchievements() async {
  final db = ref.read(databaseProvider);
  final service = LearnSessionService(LearnDao(db), AchievementDao(db));
  final achievements = await service.getPendingAchievements();
  if (!mounted || achievements.isEmpty) return;

  final language = ref.read(appLanguageProvider);
  for (final achievement in achievements) {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AchievementDialog(
        achievement: achievement,
        language: language,
      ),
    );
  }
}
```

**5f. Add `_AchievementDialog` widget** (private class at the bottom of the file, before `_LanguagePicker`):

```dart
class _AchievementDialog extends StatelessWidget {
  const _AchievementDialog({
    required this.achievement,
    required this.language,
  });

  final model.Achievement achievement;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(language.achievementUnlockedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            achievement.type.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.type.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(achievement.description),
          const SizedBox(height: 8),
          Text(
            '+${achievement.bonusXP} XP',
            style: TextStyle(
              color: achievement.type.color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('🎉 Awesome!'),
        ),
      ],
    );
  }
}
```

---

### Step 6: Run all tests

```
flutter test
```

Expected: All tests pass (existing + 3 new).

---

### Step 7: Analyze

```
flutter analyze lib/
```

Expected: No issues.

---

### Step 8: Commit

```bash
git add lib/data/daos/achievement_dao.dart lib/features/home/home_screen.dart test/data/daos/achievement_dao_test.dart
git commit -m "feat(F1): add streak/level achievement triggers and home popup

- AchievementDao.hasAchievement() guards against duplicate awards
- HomeScreen.ref.listen(dashboardProvider) checks streak {7,14,30,60,100} and level-up milestones
- postFrameCallback shows pending achievements on every home screen open"
```

---

## Task 2: SRS Retention Breakdown Card

**Files:**
- Modify: `lib/data/daos/srs_dao.dart` (add `getStageBreakdown()` + `SrsStageBreakdown`)
- Modify: `lib/data/repositories/lesson_repository.dart` (add `srsRetentionProvider`)
- Modify: `lib/features/progress/progress_screen.dart` (add `_SrsRetentionCard`)
- Test: `test/data/daos/srs_dao_stage_test.dart` (new)

---

### Step 1: Write failing test

Create `test/data/daos/srs_dao_stage_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/srs_dao.dart';

void main() {
  late AppDatabase db;
  late SrsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SrsDao(db);
  });

  tearDown(() => db.close());

  Future<void> insertState(int vocabId, double stability) async {
    await dao.initializeSrsState(vocabId);
    await dao.updateSrsState(
      vocabId: vocabId,
      box: 1,
      repetitions: 1,
      ease: 2.5,
      stability: stability,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: DateTime.now().add(const Duration(days: 1)),
    );
  }

  test('getStageBreakdown returns zeros when no SRS state', () async {
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 0);
    expect(breakdown.young, 0);
    expect(breakdown.mature, 0);
    expect(breakdown.total, 0);
  });

  test('getStageBreakdown classifies stability < 1 as learning', () async {
    await insertState(1, 0.5);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 1);
    expect(breakdown.young, 0);
    expect(breakdown.mature, 0);
  });

  test('getStageBreakdown classifies 1 <= stability < 21 as young', () async {
    await insertState(1, 1.0);
    await insertState(2, 10.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.young, 2);
  });

  test('getStageBreakdown classifies stability >= 21 as mature', () async {
    await insertState(1, 21.0);
    await insertState(2, 100.0);
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.mature, 2);
  });

  test('getStageBreakdown mixes all three stages correctly', () async {
    await insertState(1, 0.3); // learning
    await insertState(2, 5.0); // young
    await insertState(3, 30.0); // mature
    final breakdown = await dao.getStageBreakdown();
    expect(breakdown.learning, 1);
    expect(breakdown.young, 1);
    expect(breakdown.mature, 1);
    expect(breakdown.total, 3);
  });
}
```

---

### Step 2: Run test to verify it fails

```
flutter test test/data/daos/srs_dao_stage_test.dart -v
```

Expected: FAIL — `getStageBreakdown` and `SrsStageBreakdown` not found.

---

### Step 3: Add `SrsStageBreakdown` + `getStageBreakdown()` to SrsDao

In `lib/data/daos/srs_dao.dart`, add at the TOP of the file (after imports, before `@DriftAccessor`):

```dart
class SrsStageBreakdown {
  const SrsStageBreakdown({
    required this.learning,
    required this.young,
    required this.mature,
  });

  final int learning; // stability < 1.0
  final int young;    // 1.0 ≤ stability < 21.0
  final int mature;   // stability ≥ 21.0

  int get total => learning + young + mature;
}
```

Then add after `watchDueReviewCount()`:

```dart
/// Returns counts of SRS items in each FSRS stability bracket.
/// Only items that have been reviewed at least once are counted.
Future<SrsStageBreakdown> getStageBreakdown() async {
  final rows = await select(srsState).get();
  int learning = 0, young = 0, mature = 0;
  for (final r in rows) {
    final s = r.stability ?? 0;
    if (s < 1.0) {
      learning++;
    } else if (s < 21.0) {
      young++;
    } else {
      mature++;
    }
  }
  return SrsStageBreakdown(learning: learning, young: young, mature: mature);
}
```

---

### Step 4: Run test to verify it passes

```
flutter test test/data/daos/srs_dao_stage_test.dart -v
```

Expected: 5 tests PASS.

---

### Step 5: Add `srsRetentionProvider` to lesson_repository.dart

In `lib/data/repositories/lesson_repository.dart`, add after `activityCalendarProvider`:

```dart
final srsRetentionProvider = FutureProvider<SrsStageBreakdown>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.srsDao.getStageBreakdown();
});
```

Also add import at the top if missing:

```dart
import 'package:jpstudy/data/daos/srs_dao.dart';
```

---

### Step 6: Add `_SrsRetentionCard` to progress_screen.dart

In `lib/features/progress/progress_screen.dart`:

**6a. Add import** for `srsRetentionProvider`:

The import `lesson_repository.dart` is already present. `SrsStageBreakdown` comes from `srs_dao.dart` — add:

```dart
import 'package:jpstudy/data/daos/srs_dao.dart';
```

**6b. In `ProgressScreen.build()`, insert `_SrsRetentionCard` after `_ActivityCalendar`** — change:

```dart
_ActivityCalendar(streak: summary.streak),
const SizedBox(height: 16),
_StatCard(
```

to:

```dart
_ActivityCalendar(streak: summary.streak),
const SizedBox(height: 16),
const _SrsRetentionCard(),
const SizedBox(height: 16),
_StatCard(
```

**6c. Add `_SrsRetentionCard` class** at the bottom of the file, before `_SectionHeader`:

```dart
class _SrsRetentionCard extends ConsumerWidget {
  const _SrsRetentionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdownAsync = ref.watch(srsRetentionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A2E3A59),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: breakdownAsync.when(
        data: (bd) => _buildContent(bd),
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, _) => const SizedBox(height: 60),
      ),
    );
  }

  Widget _buildContent(SrsStageBreakdown bd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vocabulary SRS',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Text(
          '${bd.total} items reviewed via SRS',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7390)),
        ),
        const SizedBox(height: 10),
        if (bd.total > 0) ...[
          _buildBar(bd),
          const SizedBox(height: 8),
        ],
        _buildLabels(bd),
      ],
    );
  }

  Widget _buildBar(SrsStageBreakdown bd) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            if (bd.learning > 0)
              Expanded(
                flex: bd.learning,
                child: Container(color: const Color(0xFFEF4444)),
              ),
            if (bd.young > 0)
              Expanded(
                flex: bd.young,
                child: Container(color: const Color(0xFFEAB308)),
              ),
            if (bd.mature > 0)
              Expanded(
                flex: bd.mature,
                child: Container(color: const Color(0xFF22C55E)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabels(SrsStageBreakdown bd) {
    return Wrap(
      spacing: 12,
      children: [
        _StageLabel(label: 'Learning', count: bd.learning, color: const Color(0xFFEF4444)),
        _StageLabel(label: 'Young', count: bd.young, color: const Color(0xFFEAB308)),
        _StageLabel(label: 'Mature', count: bd.mature, color: const Color(0xFF22C55E)),
      ],
    );
  }
}

class _StageLabel extends StatelessWidget {
  const _StageLabel({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $count',
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7390)),
        ),
      ],
    );
  }
}
```

---

### Step 7: Analyze

```
flutter analyze lib/
```

Expected: No issues.

---

### Step 8: Run all tests

```
flutter test
```

Expected: All tests pass.

---

### Step 9: Commit

```bash
git add lib/data/daos/srs_dao.dart lib/data/repositories/lesson_repository.dart lib/features/progress/progress_screen.dart test/data/daos/srs_dao_stage_test.dart
git commit -m "feat(F2): add SRS retention breakdown card to progress screen

- SrsDao.getStageBreakdown() returns learning/young/mature item counts
- srsRetentionProvider wraps DAO call
- _SrsRetentionCard shows stacked bar + labels in progress screen"
```

---

## Task 3: Kanji Next Review Chip

**Files:**
- Modify: `lib/data/daos/kanji_srs_dao.dart` (add `getNextScheduledReview()`)
- Modify: `lib/data/repositories/lesson_repository.dart` (add `nextKanjiReviewProvider`)
- Modify: `lib/features/write/screens/handwriting_practice_screen.dart` (add optional `headerWidget`)
- Modify: `lib/features/write/screens/home_handwriting_practice_screen.dart` (add `_KanjiReviewChip`)
- Test: `test/data/daos/kanji_srs_dao_test.dart` (new)

---

### Step 1: Write failing test

Create `test/data/daos/kanji_srs_dao_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/db/app_database.dart';
import 'package:jpstudy/data/daos/kanji_srs_dao.dart';

void main() {
  late AppDatabase db;
  late KanjiSrsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = KanjiSrsDao(db);
  });

  tearDown(() => db.close());

  test('getNextScheduledReview returns null when no state exists', () async {
    final result = await dao.getNextScheduledReview();
    expect(result, isNull);
  });

  test('getNextScheduledReview returns nearest future date', () async {
    final future1 = DateTime.now().add(const Duration(hours: 2));
    final future2 = DateTime.now().add(const Duration(hours: 5));
    await dao.initializeSrsState(1);
    await dao.updateSrsState(
      kanjiId: 1,
      stability: 1.0,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: future2,
    );
    await dao.initializeSrsState(2);
    await dao.updateSrsState(
      kanjiId: 2,
      stability: 1.0,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: future1,
    );
    final result = await dao.getNextScheduledReview();
    expect(result, isNotNull);
    // Should return the nearer one (future1)
    expect(result!.isBefore(future2), isTrue);
  });

  test('getNextScheduledReview ignores past dates', () async {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    await dao.initializeSrsState(1);
    await dao.updateSrsState(
      kanjiId: 1,
      stability: 1.0,
      difficulty: 0.3,
      lastConfidence: 3,
      nextReviewAt: past,
    );
    final result = await dao.getNextScheduledReview();
    expect(result, isNull);
  });
}
```

---

### Step 2: Run test to verify it fails

```
flutter test test/data/daos/kanji_srs_dao_test.dart -v
```

Expected: FAIL — `getNextScheduledReview` not found.

---

### Step 3: Add `getNextScheduledReview()` to KanjiSrsDao

In `lib/data/daos/kanji_srs_dao.dart`, add after `watchDueReviewCount()`:

```dart
/// Returns the nearest future review date (nextReviewAt > now).
/// Returns null if all reviews are past-due or no state exists.
Future<DateTime?> getNextScheduledReview() async {
  final row = await (select(kanjiSrsState)
        ..where((t) => t.nextReviewAt.isBiggerThanValue(DateTime.now()))
        ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)])
        ..limit(1))
      .getSingleOrNull();
  return row?.nextReviewAt;
}
```

---

### Step 4: Run test to verify it passes

```
flutter test test/data/daos/kanji_srs_dao_test.dart -v
```

Expected: 3 tests PASS.

---

### Step 5: Add `nextKanjiReviewProvider` to lesson_repository.dart

In `lib/data/repositories/lesson_repository.dart`, add after `nextVocabReviewProvider`:

```dart
/// Returns the nearest future kanji review date, refreshing on SRS changes.
final nextKanjiReviewProvider = StreamProvider.autoDispose<DateTime?>((ref) async* {
  final db = ref.watch(databaseProvider);
  await for (final _ in db.kanjiSrsDao.watchDueReviewCount()) {
    yield await db.kanjiSrsDao.getNextScheduledReview();
  }
});
```

---

### Step 6: Add optional `headerWidget` to HandwritingPracticeScreen

In `lib/features/write/screens/handwriting_practice_screen.dart`:

**6a. Add `headerWidget` parameter to the constructor:**

Change:
```dart
class HandwritingPracticeScreen extends ConsumerStatefulWidget {
  const HandwritingPracticeScreen({
    super.key,
    required this.lessonTitle,
    required this.items,
    this.includeCompoundWords = true,
    this.maxCompoundsPerKanji = -1,
    this.initialKanjiId,
  });

  final String lessonTitle;
  final List<KanjiItem> items;
  final bool includeCompoundWords;
  final int maxCompoundsPerKanji;
  final int? initialKanjiId;
```

To:
```dart
class HandwritingPracticeScreen extends ConsumerStatefulWidget {
  const HandwritingPracticeScreen({
    super.key,
    required this.lessonTitle,
    required this.items,
    this.includeCompoundWords = true,
    this.maxCompoundsPerKanji = -1,
    this.initialKanjiId,
    this.headerWidget,
  });

  final String lessonTitle;
  final List<KanjiItem> items;
  final bool includeCompoundWords;
  final int maxCompoundsPerKanji;
  final int? initialKanjiId;
  final Widget? headerWidget;
```

**6b. In `_HandwritingPracticeScreenState.build()`, find the `Scaffold` body column** and add `headerWidget` before the main content. Look for the body construction and add:

```dart
// At the top of the body's main Column/Stack, before existing content:
if (widget.headerWidget != null) widget.headerWidget!,
```

*Note: The exact insertion point depends on the Scaffold body structure. Add after the Scaffold's body opens, as the first child of whatever Column/Stack is the root of the body. If the body is a Column, add `if (widget.headerWidget != null) widget.headerWidget!,` as the first child.*

---

### Step 7: Add `_KanjiReviewChip` to HomeHandwritingPracticeScreen

In `lib/features/write/screens/home_handwriting_practice_screen.dart`:

**7a. Add import for `dashboardProvider` and `nextKanjiReviewProvider`:**

Add after existing imports:
```dart
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';
```

(The `nextKanjiReviewProvider` is already accessible via `lesson_repository.dart` which is already imported.)

**7b. Modify the `HandwritingPracticeScreen` call** — change:

```dart
return HandwritingPracticeScreen(
  lessonTitle: '${level.shortLabel} - ${language.handwritingLabel}',
  items: items,
);
```

to:

```dart
return HandwritingPracticeScreen(
  lessonTitle: '${level.shortLabel} - ${language.handwritingLabel}',
  items: items,
  headerWidget: _KanjiReviewChip(language: language),
);
```

**7c. Add `_KanjiReviewChip` class** at the bottom of the file:

```dart
class _KanjiReviewChip extends ConsumerWidget {
  const _KanjiReviewChip({required this.language});

  final AppLanguage language;

  String _formatDuration(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final nextReviewAsync = ref.watch(nextKanjiReviewProvider);
    final kanjiDue = dashboard?.kanjiDue ?? 0;

    String chipText;
    if (kanjiDue > 0) {
      chipText = '$kanjiDue kanji due for review';
    } else {
      final nextReview = nextReviewAsync.valueOrNull;
      if (nextReview == null) {
        chipText = '✅ All caught up!';
      } else {
        final diff = nextReview.difference(DateTime.now());
        if (diff.isNegative) {
          chipText = '✅ Review ready now!';
        } else {
          chipText = '✅ All caught up! Next review in ${_formatDuration(diff)}';
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: kanjiDue > 0
          ? const Color(0xFFFFF3CD)
          : const Color(0xFFE8F5E9),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kanjiDue > 0
              ? const Color(0xFF856404)
              : const Color(0xFF2E7D32),
        ),
      ),
    );
  }
}
```

---

### Step 8: Analyze

```
flutter analyze lib/
```

Expected: No issues.

---

### Step 9: Run all tests

```
flutter test
```

Expected: All tests pass.

---

### Step 10: Commit

```bash
git add lib/data/daos/kanji_srs_dao.dart lib/data/repositories/lesson_repository.dart lib/features/write/screens/handwriting_practice_screen.dart lib/features/write/screens/home_handwriting_practice_screen.dart test/data/daos/kanji_srs_dao_test.dart
git commit -m "feat(F3): add kanji next-review chip to handwriting practice screen

- KanjiSrsDao.getNextScheduledReview() mirrors vocab DAO pattern
- nextKanjiReviewProvider watches due count stream
- _KanjiReviewChip shows due count or next-review countdown
- HandwritingPracticeScreen accepts optional headerWidget"
```

---

## Task 4: Home Week Summary Row

**Files:**
- Modify: `lib/data/repositories/lesson_repository.dart` (add `WeekSummary` + `weekSummaryProvider`)
- Modify: `lib/features/home/widgets/daily_session_card.dart` (add `_WeekSummaryRow`)
- Test: `test/data/repositories/week_summary_test.dart` (new)

---

### Step 1: Write failing test

Create `test/data/repositories/week_summary_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';

void main() {
  test('WeekSummary accuracy is 0 when no attempts', () {
    const summary = WeekSummary(
      totalReviewed: 0,
      accuracy: 0,
      daysStudied: 0,
    );
    expect(summary.accuracy, 0);
    expect(summary.totalReviewed, 0);
    expect(summary.daysStudied, 0);
  });

  test('WeekSummary stores values correctly', () {
    const summary = WeekSummary(
      totalReviewed: 47,
      accuracy: 83,
      daysStudied: 5,
    );
    expect(summary.totalReviewed, 47);
    expect(summary.accuracy, 83);
    expect(summary.daysStudied, 5);
  });
}
```

---

### Step 2: Run test to verify it fails

```
flutter test test/data/repositories/week_summary_test.dart -v
```

Expected: FAIL — `WeekSummary` not found.

---

### Step 3: Add `WeekSummary` + `weekSummaryProvider` to lesson_repository.dart

In `lib/data/repositories/lesson_repository.dart`, add after `attemptHistoryProvider`:

```dart
class WeekSummary {
  const WeekSummary({
    required this.totalReviewed,
    required this.accuracy,
    required this.daysStudied,
  });

  final int totalReviewed;
  final int accuracy;   // percentage 0–100
  final int daysStudied;
}

final weekSummaryProvider = FutureProvider<WeekSummary>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  final history = await repo.fetchReviewHistory(limit: 7);
  final attempts = await repo.fetchAttemptHistory(limit: 50);
  final cutoff = DateTime.now().subtract(const Duration(days: 7));

  final totalReviewed = history.fold(0, (s, d) => s + d.reviewed);
  final daysStudied = history.where((d) => d.reviewed > 0).length;

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

---

### Step 4: Run test to verify it passes

```
flutter test test/data/repositories/week_summary_test.dart -v
```

Expected: 2 tests PASS.

---

### Step 5: Add `_WeekSummaryRow` to DailySessionCard

In `lib/features/home/widgets/daily_session_card.dart`:

**5a. Add import** for `weekSummaryProvider` and `go_router` (for navigation) — `go_router` is already imported. `lesson_repository.dart` is not yet imported here. Add:

```dart
import 'package:jpstudy/data/repositories/lesson_repository.dart';
```

**5b. Add `_WeekSummaryRow` to the Column in `build()`** — after `_BackupStatusLine`:

Change:
```dart
const SizedBox(height: 12),
_BackupStatusLine(language: language),
```

To:
```dart
const SizedBox(height: 12),
_BackupStatusLine(language: language),
const _WeekSummaryRow(),
```

**5c. Add `_WeekSummaryRow` class** at the bottom of `daily_session_card.dart`, before `_DailyRoute`:

```dart
class _WeekSummaryRow extends ConsumerWidget {
  const _WeekSummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(weekSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        if (summary.totalReviewed == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GestureDetector(
            onTap: () => context.push('/progress'),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: Color(0xFFDBEAFE),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This week: ${summary.totalReviewed} reviews · ${summary.accuracy}% accuracy · ${summary.daysStudied}/7 days',
                    style: const TextStyle(
                      color: Color(0xFFDBEAFE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
```

---

### Step 6: Analyze

```
flutter analyze lib/
```

Expected: No issues.

---

### Step 7: Run all tests

```
flutter test
```

Expected: All tests pass.

---

### Step 8: Commit

```bash
git add lib/data/repositories/lesson_repository.dart lib/features/home/widgets/daily_session_card.dart test/data/repositories/week_summary_test.dart
git commit -m "feat(F4): add week summary row to home daily session card

- WeekSummary class + weekSummaryProvider aggregate last 7 days
- _WeekSummaryRow shows reviews/accuracy/days, taps to /progress
- Hidden when totalReviewed == 0"
```

---

## Final Verification

```
flutter analyze lib/
flutter test
```

Expected:
- `flutter analyze` → No issues
- All tests pass (existing + 13 new DAO/model tests)

**Manual checks:**
- F1: Set streak to 7 days → reopen home screen → popup appears → reopen again → no duplicate
- F2: Progress screen shows SRS Retention card between Activity Calendar and Streak stat
- F3: Kanji practice screen shows chip: "X kanji due" when due > 0, or "Next review in Xh" when caught up
- F4: Home screen shows "This week: N reviews · M% accuracy · K/7 days" when user has reviewed this week
