# Handwriting SRS Session Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rework `HomeHandwritingPracticeScreen` so it loads only SRS-due kanji by default (like Recall Sprint / Ghost Review), falls back to a batch of unseen kanji when nothing is due, and offers a "Free practice" escape hatch to the full pool.

**Architecture:** Add a `fetchDueKanjiByLevel(level)` method to `LessonRepository` that joins `KanjiSrsState` against the content `Kanji` table filtered by level and `nextReviewAt <= now`. `HomeHandwritingPracticeScreen` calls this new method and decides which item set to pass to `HandwritingPracticeScreen`. The core `HandwritingPracticeScreen` is unchanged — it already handles empty items, weak sets, and session-complete states cleanly.

**Tech Stack:** Flutter, Drift ORM, Riverpod, existing `KanjiSrsDao`, `LessonRepository`, `HandwritingPracticeScreen`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/data/repositories/lesson_repository.dart` | Modify | Add `fetchDueKanjiByLevel(level)` and `fetchUnseenKanjiByLevel(level, limit)` |
| `lib/features/write/screens/home_handwriting_practice_screen.dart` | Modify | Load due → fallback to unseen batch → pass to inner screen; add "Free practice" link |
| `lib/core/app_language.dart` | Modify | Add localized strings for new UI states |
| `test/features/write/handwriting_walkthrough_test.dart` | Modify | Add tests for due-first and unseen-batch paths |

---

## Task 1: Add `fetchDueKanjiByLevel` to LessonRepository

**Files:**
- Modify: `lib/data/repositories/lesson_repository.dart`

- [ ] **Step 1: Write failing test**

In `test/features/write/handwriting_walkthrough_test.dart`, add this test inside `main()`:

```dart
group('LessonRepository kanji session helpers', () {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late LessonRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    contentDb = ContentDatabase(NativeDatabase.memory());
    repo = LessonRepository(db, contentDb);

    // Seed one N5 kanji in content DB
    await contentDb.into(contentDb.kanji).insert(
      KanjiCompanion.insert(
        id: const Value(1),
        lessonId: 1,
        character: '一',
        strokeCount: 1,
        meaning: 'one',
        jlptLevel: 'N5',
      ),
    );
  });

  tearDown(() async {
    await db.close();
    await contentDb.close();
  });

  test('fetchDueKanjiByLevel returns kanji whose SRS state is due', () async {
    // Initialize SRS state as already due (nextReviewAt in the past)
    await db.kanjiSrsDao.insertTestState(
      kanjiId: 1,
      nextReviewAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    final due = await repo.fetchDueKanjiByLevel('N5');
    expect(due.length, 1);
    expect(due.first.character, '一');
  });

  test('fetchDueKanjiByLevel excludes kanji due in the future', () async {
    await db.kanjiSrsDao.insertTestState(
      kanjiId: 1,
      nextReviewAt: DateTime.now().add(const Duration(days: 1)),
    );

    final due = await repo.fetchDueKanjiByLevel('N5');
    expect(due, isEmpty);
  });

  test('fetchDueKanjiByLevel excludes kanji with no SRS state', () async {
    // No SRS state inserted
    final due = await repo.fetchDueKanjiByLevel('N5');
    expect(due, isEmpty);
  });

  test('fetchUnseenKanjiByLevel returns kanji with no SRS state', () async {
    final unseen = await repo.fetchUnseenKanjiByLevel('N5', limit: 10);
    expect(unseen.length, 1);
    expect(unseen.first.character, '一');
  });

  test('fetchUnseenKanjiByLevel respects limit', () async {
    // Seed more kanji
    for (var i = 2; i <= 20; i++) {
      await contentDb.into(contentDb.kanji).insert(
        KanjiCompanion.insert(
          id: Value(i),
          lessonId: 1,
          character: '二',
          strokeCount: 2,
          meaning: 'two',
          jlptLevel: 'N5',
        ),
      );
    }
    final unseen = await repo.fetchUnseenKanjiByLevel('N5', limit: 10);
    expect(unseen.length, 10);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

```
flutter test test/features/write/handwriting_walkthrough_test.dart --name="fetchDueKanjiByLevel"
```

Expected: Compilation error — `fetchDueKanjiByLevel` does not exist yet.

- [ ] **Step 3: Add `insertTestState` helper to KanjiSrsDao (test helper only)**

In `lib/data/daos/kanji_srs_dao.dart`, add at the bottom of the class:

```dart
/// Test helper — inserts a state row with a specific nextReviewAt.
/// Only used in unit tests to set up SRS state without going through FSRS.
Future<void> insertTestState({
  required int kanjiId,
  required DateTime nextReviewAt,
}) {
  return into(kanjiSrsState).insert(
    KanjiSrsStateCompanion.insert(
      kanjiId: kanjiId,
      nextReviewAt: nextReviewAt,
    ),
    mode: InsertMode.insertOrReplace,
  );
}
```

- [ ] **Step 4: Add `fetchDueKanjiByLevel` to LessonRepository**

In `lib/data/repositories/lesson_repository.dart`, add after `fetchKanjiByLevel`:

```dart
/// Returns kanji at [level] whose SRS state is currently due (nextReviewAt <= now).
/// Kanji with no SRS state are excluded (they are "unseen", not "due").
Future<List<KanjiItem>> fetchDueKanjiByLevel(String level) async {
  final dueStates = await _db.kanjiSrsDao.getDueReviews();
  if (dueStates.isEmpty) return const [];

  final dueIds = dueStates.map((s) => s.kanjiId).toList();

  final rows = await (_contentDb.select(_contentDb.kanji)
        ..where(
          (tbl) => tbl.jlptLevel.equals(level) & tbl.id.isIn(dueIds),
        )
        ..orderBy([
          (tbl) => OrderingTerm.asc(tbl.lessonId),
          (tbl) => OrderingTerm.asc(tbl.id),
        ]))
      .get();

  return _mapKanjiRows(rows);
}

/// Returns up to [limit] kanji at [level] that have never been practiced
/// (no row exists in KanjiSrsState for them), ordered by lesson then id.
Future<List<KanjiItem>> fetchUnseenKanjiByLevel(
  String level, {
  int limit = 15,
}) async {
  final seenStates = await _db.kanjiSrsDao.getStatesForIds(
    // fetch all IDs we have SRS state for — not level-filtered, but that's OK
    // because we filter by level in the content query below
    await (_db.select(_db.kanjiSrsState)
            ..addColumns([_db.kanjiSrsState.kanjiId]))
        .map((row) => row.read(_db.kanjiSrsState.kanjiId)!)
        .get(),
  );
  final seenIds = seenStates.map((s) => s.kanjiId).toList();

  final query = _contentDb.select(_contentDb.kanji)
    ..where((tbl) => tbl.jlptLevel.equals(level))
    ..orderBy([
      (tbl) => OrderingTerm.asc(tbl.lessonId),
      (tbl) => OrderingTerm.asc(tbl.id),
    ])
    ..limit(limit + seenIds.length); // overfetch, then filter in memory

  final rows = await query.get();
  final unseenRows = seenIds.isEmpty
      ? rows
      : rows.where((r) => !seenIds.contains(r.id)).take(limit).toList();

  return _mapKanjiRows(
    unseenRows.length > limit ? unseenRows.sublist(0, limit) : unseenRows,
  );
}
```

- [ ] **Step 5: Run tests to verify they pass**

```
flutter test test/features/write/handwriting_walkthrough_test.dart --name="fetchDueKanjiByLevel|fetchUnseenKanjiByLevel"
```

Expected: All 5 new tests pass.

- [ ] **Step 6: Run analyzer**

```
flutter analyze lib/data/repositories/lesson_repository.dart lib/data/daos/kanji_srs_dao.dart
```

Expected: No issues.

- [ ] **Step 7: Commit**

```bash
git add lib/data/repositories/lesson_repository.dart lib/data/daos/kanji_srs_dao.dart test/features/write/handwriting_walkthrough_test.dart
git commit -m "feat(kanji): add fetchDueKanjiByLevel and fetchUnseenKanjiByLevel to LessonRepository"
```

---

## Task 2: Add localized strings for the new Handwriting session states

**Files:**
- Modify: `lib/core/app_language.dart`

- [ ] **Step 1: Find where handwriting strings live**

Search for `handwritingLabel` in `lib/core/app_language.dart`. The strings are defined as getters on the `AppLanguage` class.

- [ ] **Step 2: Add new strings**

Add after the existing handwriting strings in both `AppLanguage.vi` and `AppLanguage.en` (and any other language instances):

```dart
// In AppLanguage, add these abstract getters:
String get handwritingDueSessionTitle;
String get handwritingNewBatchTitle;
String get handwritingFreePracticeLabel;
String get handwritingNothingDueLabel;
String get handwritingNewBatchSubtitle; // e.g. "15 new kanji to learn"

// Vietnamese values:
String get handwritingDueSessionTitle => 'Ôn tập hôm nay';
String get handwritingNewBatchTitle => 'Học kanji mới';
String get handwritingFreePracticeLabel => 'Luyện tập tự do';
String get handwritingNothingDueLabel => 'Không có gì cần ôn hôm nay';
String get handwritingNewBatchSubtitle => 'Lô mới'; // prefix, append count

// English values:
String get handwritingDueSessionTitle => 'Due for review';
String get handwritingNewBatchTitle => 'New kanji to learn';
String get handwritingFreePracticeLabel => 'Free practice';
String get handwritingNothingDueLabel => 'Nothing due today';
String get handwritingNewBatchSubtitle => 'New batch';
```

- [ ] **Step 3: Run analyzer**

```
flutter analyze lib/core/app_language.dart
```

Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/core/app_language.dart
git commit -m "feat(i18n): add handwriting session state strings"
```

---

## Task 3: Rework `HomeHandwritingPracticeScreen` to use SRS-first loading

**Files:**
- Modify: `lib/features/write/screens/home_handwriting_practice_screen.dart`

The goal: replace the flat `fetchKanjiByLevel(level)` call with a smarter loader that:
1. Tries `fetchDueKanjiByLevel(level)` first
2. If empty → tries `fetchUnseenKanjiByLevel(level, limit: 15)`
3. If both empty → shows a "nothing due" message with a "Free practice" button
4. Always shows a "Free practice" button at the bottom to bypass into the full pool

- [ ] **Step 1: Write the failing test**

Add to `test/features/write/handwriting_walkthrough_test.dart`:

```dart
testWidgets('HomeHandwriting shows due session when kanji are due',
    (tester) async {
  KanjiStrokeTemplateService.setDebugTemplateOverrides(oneStrokeTemplate());
  addTearDown(() => KanjiStrokeTemplateService.setDebugTemplateOverrides(null));

  // We'll use the lessonRepositoryProvider override to inject deterministic data
  final dueKanji = [
    const KanjiItem(
      id: 1, lessonId: 1, character: '一', strokeCount: 1,
      meaning: 'one', meaningEn: 'one', examples: [], jlptLevel: 'N5',
    ),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override the repository so fetchDueKanjiByLevel returns our list
        lessonRepositoryProvider.overrideWith((ref) {
          final mock = _MockLessonRepo(dueKanji: dueKanji, unseenKanji: const []);
          return mock;
        }),
        studyLevelProvider.overrideWith((ref) => StudyLevel.n5),
      ],
      child: const MaterialApp(home: HomeHandwritingPracticeScreen()),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Session title should indicate "due review" not free practice
  expect(find.text(AppLanguage.en.handwritingDueSessionTitle), findsOneWidget);
  // The HandwritingPracticeScreen should be showing item 1/1
  expect(find.textContaining('1 / 1'), findsWidgets);
});
```

Note: `_MockLessonRepo` is a simple stub class added at the bottom of the test file. See implementation in Step 3.

- [ ] **Step 2: Run test to verify it fails**

```
flutter test test/features/write/handwriting_walkthrough_test.dart --name="HomeHandwriting shows due"
```

Expected: Compile error or test failure — `handwritingDueSessionTitle` doesn't exist yet / HomeHandwriting still uses old loader.

- [ ] **Step 3: Rewrite `HomeHandwritingPracticeScreen`**

Replace the content of `lib/features/write/screens/home_handwriting_practice_screen.dart`:

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/theme/app_spacing.dart';
import 'package:jpstudy/app/theme/app_theme_palette.dart';
import 'package:jpstudy/core/app_language.dart';
import 'package:jpstudy/core/language_provider.dart';
import 'package:jpstudy/core/level_provider.dart';
import 'package:jpstudy/core/study_level.dart';
import 'package:jpstudy/data/models/kanji_item.dart';
import 'package:jpstudy/data/repositories/lesson_repository.dart';
import 'package:jpstudy/features/home/providers/dashboard_provider.dart';

import 'handwriting_practice_screen.dart';

/// How the current handwriting session was seeded.
enum _HandwritingSessionSource { due, newBatch, free }

class HomeHandwritingPracticeScreen extends ConsumerStatefulWidget {
  const HomeHandwritingPracticeScreen({super.key});

  @override
  ConsumerState<HomeHandwritingPracticeScreen> createState() =>
      _HomeHandwritingPracticeScreenState();
}

class _HomeHandwritingPracticeScreenState
    extends ConsumerState<HomeHandwritingPracticeScreen> {
  Future<({List<KanjiItem> items, _HandwritingSessionSource source})>?
      _sessionFuture;
  List<KanjiItem>? _freeItems;
  StudyLevel? _loadedLevel;
  int _sessionShuffleSeed = DateTime.now().microsecondsSinceEpoch;
  bool _freeMode = false;

  int _newSeed() =>
      DateTime.now().microsecondsSinceEpoch ^
      identityHashCode(this) ^
      Random().nextInt(1 << 32);

  void _ensureSessionFuture(StudyLevel level) {
    if (_loadedLevel == level && _sessionFuture != null && !_freeMode) return;
    if (_freeMode) return;
    _loadedLevel = level;
    _sessionShuffleSeed = _newSeed();
    _sessionFuture = _buildSession(level);
  }

  Future<({List<KanjiItem> items, _HandwritingSessionSource source})>
      _buildSession(StudyLevel level) async {
    final repo = ref.read(lessonRepositoryProvider);

    // 1. Try due items first
    final due = await repo.fetchDueKanjiByLevel(level.shortLabel);
    if (due.isNotEmpty) {
      return (items: due, source: _HandwritingSessionSource.due);
    }

    // 2. Fall back to a batch of unseen kanji
    final unseen = await repo.fetchUnseenKanjiByLevel(
      level.shortLabel,
      limit: 15,
    );
    if (unseen.isNotEmpty) {
      return (items: unseen, source: _HandwritingSessionSource.newBatch);
    }

    // 3. Nothing to show — caller handles empty list
    return (items: const <KanjiItem>[], source: _HandwritingSessionSource.due);
  }

  Future<void> _loadFreeItems(StudyLevel level) async {
    final repo = ref.read(lessonRepositoryProvider);
    final all = await repo.fetchKanjiByLevel(level.shortLabel);
    if (mounted) {
      setState(() {
        _freeItems = all;
        _freeMode = true;
        _sessionShuffleSeed = _newSeed();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(appLanguageProvider);
    final level = ref.watch(studyLevelProvider);

    if (level == null) {
      return Scaffold(
        appBar: AppBar(title: Text(language.handwritingLabel)),
        body: Center(child: Text(language.levelMenuTitle)),
      );
    }

    if (_freeMode && _freeItems != null) {
      return HandwritingPracticeScreen(
        lessonTitle:
            '${level.shortLabel} - ${language.handwritingFreePracticeLabel}',
        items: _freeItems!,
        headerWidget: _KanjiReviewChip(language: language),
        randomizeSessionOrder: true,
        sessionShuffleSeed: _sessionShuffleSeed,
      );
    }

    _ensureSessionFuture(level);

    return FutureBuilder(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${language.handwritingLabel} ${level.shortLabel}',
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '${language.handwritingLabel} ${level.shortLabel}',
              ),
            ),
            body: Center(child: Text(language.loadErrorLabel)),
          );
        }

        final data = snapshot.data;
        final items = data?.items ?? const [];
        final source = data?.source ?? _HandwritingSessionSource.due;

        // Nothing to review — offer free practice instead
        if (items.isEmpty) {
          return _NothingDueScreen(
            language: language,
            level: level,
            onFreePractice: () => _loadFreeItems(level),
          );
        }

        final sessionTitle = switch (source) {
          _HandwritingSessionSource.due =>
            '${level.shortLabel} — ${language.handwritingDueSessionTitle}',
          _HandwritingSessionSource.newBatch =>
            '${level.shortLabel} — ${language.handwritingNewBatchTitle}',
          _HandwritingSessionSource.free =>
            '${level.shortLabel} — ${language.handwritingFreePracticeLabel}',
        };

        return HandwritingPracticeScreen(
          lessonTitle: sessionTitle,
          items: items,
          headerWidget: _HandwritingSessionHeader(
            language: language,
            source: source,
            itemCount: items.length,
            onFreePractice: source != _HandwritingSessionSource.free
                ? () => _loadFreeItems(level)
                : null,
          ),
          randomizeSessionOrder: source == _HandwritingSessionSource.newBatch,
          sessionShuffleSeed: _sessionShuffleSeed,
        );
      },
    );
  }
}

/// Header widget shown inside the HandwritingPracticeScreen scroll body.
class _HandwritingSessionHeader extends ConsumerWidget {
  const _HandwritingSessionHeader({
    required this.language,
    required this.source,
    required this.itemCount,
    this.onFreePractice,
  });

  final AppLanguage language;
  final _HandwritingSessionSource source;
  final int itemCount;
  final VoidCallback? onFreePractice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final dashboard = ref.watch(dashboardProvider).valueOrNull;
    final kanjiDue = dashboard?.kanjiDue ?? 0;

    final Color accent;
    final IconData icon;
    final String label;

    switch (source) {
      case _HandwritingSessionSource.due:
        accent = palette.warning;
        icon = Icons.schedule_rounded;
        label = language.handwritingReviewDueLabel(kanjiDue > 0 ? kanjiDue : itemCount);
      case _HandwritingSessionSource.newBatch:
        accent = palette.accent;
        icon = Icons.auto_awesome_rounded;
        label = '${language.handwritingNewBatchSubtitle}: $itemCount';
      case _HandwritingSessionSource.free:
        accent = palette.success;
        icon = Icons.shuffle_rounded;
        label = language.handwritingFreePracticeLabel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              if (onFreePractice != null)
                TextButton(
                  onPressed: onFreePractice,
                  style: TextButton.styleFrom(
                    foregroundColor: palette.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text(language.handwritingFreePracticeLabel),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown when both due and unseen pools are exhausted.
class _NothingDueScreen extends StatelessWidget {
  const _NothingDueScreen({
    required this.language,
    required this.level,
    required this.onFreePractice,
  });

  final AppLanguage language;
  final StudyLevel level;
  final VoidCallback onFreePractice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${language.handwritingLabel} ${level.shortLabel}'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  size: 56, color: Colors.green),
              const SizedBox(height: AppSpacing.md),
              Text(
                language.handwritingNothingDueLabel,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onFreePractice,
                icon: const Icon(Icons.shuffle_rounded),
                label: Text(language.handwritingFreePracticeLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Existing _KanjiReviewChip kept unchanged below
// ─────────────────────────────────────────────────────────────────────────────

class _KanjiReviewChip extends ConsumerWidget {
  const _KanjiReviewChip({required this.language});

  final AppLanguage language;

  String _formatDiff(Duration d) {
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
    final palette = context.appPalette;

    final String chipText;
    final Color accent;
    final IconData icon;

    if (kanjiDue > 0) {
      chipText = language.handwritingReviewDueLabel(kanjiDue);
      accent = palette.warning;
      icon = Icons.schedule_rounded;
    } else {
      final next = nextReviewAsync.valueOrNull;
      if (next == null) {
        chipText = language.handwritingAllCaughtUpLabel;
      } else {
        final diff = next.difference(DateTime.now());
        chipText = diff.isNegative
            ? language.handwritingAllCaughtUpLabel
            : '${language.handwritingNextReviewLabel}: ${_formatDiff(diff)}';
      }
      accent = palette.success;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            chipText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run analyzer**

```
flutter analyze lib/features/write/screens/home_handwriting_practice_screen.dart
```

Expected: No issues.

- [ ] **Step 5: Run the new test**

```
flutter test test/features/write/handwriting_walkthrough_test.dart --name="HomeHandwriting shows due"
```

Expected: Pass.

- [ ] **Step 6: Run full handwriting test suite**

```
flutter test test/features/write/handwriting_walkthrough_test.dart
```

Expected: All tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/features/write/screens/home_handwriting_practice_screen.dart lib/core/app_language.dart test/features/write/handwriting_walkthrough_test.dart
git commit -m "feat(handwriting): SRS-first session — due kanji first, then new batch, with free practice escape"
```

---

## Task 4: Final verification

- [ ] **Step 1: Format all changed files**

```
dart format lib/data/repositories/lesson_repository.dart lib/data/daos/kanji_srs_dao.dart lib/features/write/screens/home_handwriting_practice_screen.dart lib/core/app_language.dart test/features/write/handwriting_walkthrough_test.dart
```

- [ ] **Step 2: Full analyze**

```
flutter analyze lib/data/repositories/lesson_repository.dart lib/data/daos/kanji_srs_dao.dart lib/features/write/screens/home_handwriting_practice_screen.dart lib/core/app_language.dart
```

Expected: No issues.

- [ ] **Step 3: Full test suite**

```
flutter test
```

Expected: All tests pass.

- [ ] **Step 4: Update work log**

Append a new session entry to `docs/logs/codex-work-log.md` summarizing what was done.
