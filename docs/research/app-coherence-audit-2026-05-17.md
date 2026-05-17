# App Coherence Audit - 2026-05-17

Timestamp: `2026-05-17T12:00+07:00`

Scope: Phase 0 only. No source-code changes. This audit verifies the owner-directed claims before the content pipeline and IA refactors.

## Hypothesis Verdicts

| Claim | Verdict | Evidence |
| --- | --- | --- |
| Routing has 11 `StatefulShellRoute` branches and roughly 60 routes. | Confirmed, more exact: 11 shell branches and 68 `GoRoute` declarations. | `lib/app/navigation/app_router.dart:48-63` lists 11 branches. `rg -n "GoRoute\\(" lib/app/navigation/routes lib/app/navigation/app_router.dart` reports 68 matches: 2 onboarding routes plus 66 shell routes. |
| `/`, `/roadmap`, and `/today` all build `HomeScreen`. | Confirmed. | `lib/app/navigation/routes/home_routes.dart:19-33` maps all three paths to `const HomeScreen()`. |
| "Enhanced" lesson routes duplicate older lesson modes. | Confirmed. | Generic route: `lib/app/navigation/routes/home_routes.dart:66-85` handles `/lesson/:id/practice/:mode` and `/learn-enhanced`. Separate route helpers exist at `lib/app/navigation/app_route_locations.dart:64-84`. Flashcard/test enhanced routes live separately in `lib/app/navigation/routes/memory_routes.dart:28-35` and `lib/app/navigation/routes/exam_routes.dart:50-57`. Lesson detail also exposes overlapping practice CTAs at `lib/features/lesson/lesson_detail_screen.dart:1454-1493`. |
| Onboarding is handled twice. | Confirmed. Keep router redirect; remove inline Home onboarding in Phase 2. | Router gate: `lib/app/navigation/app_router.dart:35-36` calls `_onboardingRedirect`; logic is `lib/app/navigation/app_router.dart:69-102`. Production config injects preferences before app boot in `lib/main.dart:45-51`, and `MaterialApp.router` uses `AppRouter.router` in `lib/app/app.dart:25-40`. Home still renders `OnboardingScreen` inline at `lib/features/home/home_screen.dart:86-96`. Tests prove router redirect runs for clean prefs: `test/app/navigation/onboarding_gate_test.dart:39-54`. |
| Home uses different desktop and mobile implementations. | Confirmed. | `lib/features/home/home_screen.dart:98-106` branches to `_MobileHomeFallback` for widths below tablet. Desktop returns `LearningPathScreen` at `lib/features/home/home_screen.dart:108-125`. `_MobileHomeFallback` starts at `lib/features/home/home_screen.dart:283`. |
| `assets/data/content/index.json` says `series=minna`, only N5/N4/N3, vocab `3105`, N3 `300`, no N2/N1 lesson vocab; grammar/immersion absent. | Confirmed for manifest, but stale versus actual assets/runtime code. | Manifest: `assets/data/content/index.json:1-37` has `series: minna`, vocab levels only N3/N4/N5, `entries: 3105`, N3 `entries: 300`, and no grammar/immersion dataset. Actual asset scan found vocab N1 `6939`, N2 `3590`, N3 `2084`, N4 `2110`, N5 `1989`; grammar and immersion files exist. |
| The 16,712-item edited vocab dataset may not reach `/lesson/:id`. | Corrected: it can reach, but the path is fragile and partly bypasses DB tag lookup. | `/lesson/:id` renders `LessonDetailScreen` via `lib/app/navigation/routes/home_routes.dart:54-59`. The screen watches `lessonTermsProvider` at `lib/features/lesson/lesson_detail_screen.dart:100-104`. That provider ensures/seeds terms at `lib/data/repositories/lesson_repository.dart:43-59`. Runtime seeding specs include N5-N1 in `lib/data/db/content_database.dart:1259-1265`. N2/N1 ShinKanzen indexes map lessons to files in `assets/data/content/vocab/n2/ShinKanzen/index.json:1-20` and `assets/data/content/vocab/n1/ShinKanzen/index.json:1-20`. However `_fetchLessonVocabFromContent` only queries `minna_$lessonId` tags at `lib/data/repositories/lesson_repository.dart:1174-1189`, so ShinKanzen rows tagged `shinkanzen_1` are missed. The direct asset fallback then loads the resolved ShinKanzen file at `lib/data/repositories/lesson_repository.dart:1234-1243` and `lib/data/repositories/lesson_repository.dart:1347-1468`. |

## Route Inventory

- Shell branches: 11 (`kanji`, `foundations`, `vocab`, `grammar`, `home`, `memory`, `practice`, `exam`, `leaderboard`, `premium`, `profile`) from `lib/app/navigation/app_router.dart:52-62`.
- Desktop nav items still model those 11 branch indexes in `lib/app/navigation/app_shell_scaffold.dart:205-284`.
- Sidebar grouping already exists (`NavigationGroup.learning/progress/other/footer`) in `lib/app/navigation/app_shell_scaffold.dart:15` and `lib/app/navigation/app_shell_scaffold.dart:748-754`, so the visual "long sidebar" issue was partially addressed. The information architecture still has 11 primary shell branches.
- Mobile bottom nav exposes 3-4 primary branches plus More in `lib/app/navigation/app_shell_scaffold.dart:99-149` and `lib/app/navigation/app_shell_scaffold.dart:773-778`.

## Content Inventory Snapshot

Command used:

```powershell
node -e "<JSON asset scan over assets/data/content>"
```

Result:

| Dataset | N5 | N4 | N3 | N2 | N1 | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| vocab | 1,989 / 39 files | 2,110 / 45 files | 2,084 / 54 files | 3,590 / 64 files | 6,939 / 76 files | Total vocab entries: 16,712. Series totals: `hajimete=8334`, `ShinKanzen=5573`, `minna=2805`. |
| kanji | 185 / 25 files | 141 / 25 files | 203 / 25 files | 200 / 25 files | 200 / 25 files | Manifest only reports N5-N3. |
| grammar | 118 / 25 files | 100 / 25 files | 100 / 25 files | 191 / 25 files | 245 / 25 files | Manifest omits grammar. |
| grammar_examples | 118 / 25 files | 100 / 25 files | 100 / 25 files | 0 counted / 25 files | 0 counted / 25 files | N1/N2 files use a shape not counted by the simple `entries` scanner. |
| immersion | 0 counted / 25 files | 0 counted / 25 files | 0 counted / 25 files | 0 counted / 25 files | 0 counted / 25 files | Files exist, but simple `entries` count is not meaningful for this schema. |

## Vocab Pipeline Trace To `/lesson/:id`

1. Route: `/lesson/:id` -> `LessonDetailScreen` in `lib/app/navigation/routes/home_routes.dart:54-59`.
2. Screen state: `LessonDetailScreen` derives current `StudyLevel` and watches `lessonTermsProvider(LessonTermsArgs(widget.lessonId, level.shortLabel, fallbackTitle))` in `lib/features/lesson/lesson_detail_screen.dart:92-104`.
3. Provider: `lessonTermsProvider` calls `ensureLesson`, `seedTermsIfEmpty`, then `fetchTerms` in `lib/data/repositories/lesson_repository.dart:43-59`.
4. Seeder: `seedTermsIfEmpty` calls `_fetchLessonVocabFromContent` if a lesson has no non-dummy terms in `lib/data/repositories/lesson_repository.dart:1054-1097`.
5. Content DB seed: `ContentDatabase` seeds active-level Minna/ShinKanzen and Hajimete vocab at create/before-open in `lib/data/db/content_database.dart:39-44` and `lib/data/db/content_database.dart:146-154`.
6. Canonical content specs include N5-N1 at `lib/data/db/content_database.dart:1259-1265`.
7. For N2/N1/N3, `_resolveCanonicalVocabAssetPath` checks `assets/data/content/vocab/<level>/ShinKanzen/index.json` first in `lib/data/db/content_database.dart:665-690` and `lib/data/repositories/lesson_repository.dart:1347-1377`.
8. Gap: the DB fetch for `/lesson/:id` only accepts `minna_$lessonId` tags, so seeded ShinKanzen rows are skipped even when present in the content DB (`lib/data/repositories/lesson_repository.dart:1174-1189`).
9. Fallback: if the DB result is empty, the repository loads the same lesson asset directly and returns synthetic rows (`lib/data/repositories/lesson_repository.dart:1234-1243`, `1288-1335`, `1379-1468`).

Conclusion: the edited 16,712 vocab assets are present. `/lesson/:id` can show N3-N1 vocab through the asset fallback, but the canonical DB query is inconsistent with the seeded series and the manifest is stale. Phase 1 should remove the fallback dependency by making the runtime lesson query source-aware.

## Phase 1 Decision Record

Recommended canonical source for runtime lessons:

| Level | Canonical source for `/lesson/:id` | Reason |
| --- | --- | --- |
| N5 | `assets/data/content/vocab/n5/minna/lesson_XX.json` | Existing Minna beginner curriculum; already in manifest and local lesson path. |
| N4 | `assets/data/content/vocab/n4/minna/lesson_XX.json` | Existing Minna II continuation; lesson IDs 26-50. |
| N3 | `assets/data/content/vocab/n3/ShinKanzen/index.json` + files | Current N3 lesson asset count is much larger than manifest, source-aware, and already indexed. |
| N2 | `assets/data/content/vocab/n2/ShinKanzen/index.json` + files | N2 lesson vocab exists and has 25 indexed lesson files. |
| N1 | `assets/data/content/vocab/n1/ShinKanzen/index.json` + files | N1 lesson vocab exists and has 25 indexed lesson files. |

`hajimete` should stay as a separate vocab/catalog lane, not the canonical `/lesson/:id` curriculum source, unless product decides to make Hajimete the N3-N1 lesson route. The current code already models Hajimete with negative synthetic lesson IDs in `lib/data/repositories/lesson_repository.dart:977-1037`.

## Phase 1 Implementation Targets

- Make `_fetchLessonVocabFromContent` query the canonical series tag for the active level (`minna_*` for N5/N4, `shinkanzen_*` for N3/N2/N1), or query by `series + level + lesson tag`.
- Fix `_seriesForCanonicalLevel` in `LessonRepository` so it matches N3/N2/N1, not only N3.
- Regenerate `assets/data/content/index.json` from actual files, including vocab, kanji, grammar, grammar examples, immersion, and source-series counts.
- Add a manifest guard that compares `index.json` to actual asset files.
- Keep `vi-human-approved` untouched; Phase 1 is routing/manifest integrity, not owner approval.

## Surprise

The audit claim that N2/N1 runtime vocab is absent is false at the asset layer: N2/N1 ShinKanzen lesson files and indexes exist. The real defect is coherence: stale manifest plus series-blind lesson DB lookup, masked by a direct asset fallback.
