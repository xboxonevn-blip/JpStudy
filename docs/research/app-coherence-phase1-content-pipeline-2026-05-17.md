# App Coherence Phase 1 - Content Pipeline

Timestamp: `2026-05-17T12:45+07:00`

## Hypothesis

If `/lesson/:id` is source-aware, then lesson vocab should load from the canonical source for the active JLPT level instead of relying on a direct asset fallback:

- N5/N4: `minna`
- N3/N2/N1: `ShinKanzen`

## Result

Phase 1 content-pipeline work is shipped on `main`:

- `2dcd5938 fix(content): make lesson vocab source-aware`
- `39020712 test(content): guard generated content manifest inventory`
- `98cad1bf test(content): cover all-level lesson vocab seeding`

## Changes

- Runtime lesson vocab lookup now derives the canonical series by level and queries the matching lesson tag (`minna_*` or `shinkanzen_*`) before any asset fallback.
- Legacy offset fallback is limited to N5/N4 Minna data, so upper-level lessons cannot borrow unrelated rows from the same level.
- `ContentDatabase` and `LessonRepository` now agree that N3/N2/N1 canonical lesson vocab is `ShinKanzen`.
- `assets/data/content/index.json` was regenerated from actual assets and now reports all runtime datasets: vocab, kanji, grammar, grammar examples, immersion, Han-Viet rules, and kana.
- `test/data/content/content_manifest_test.dart` fails if `index.json` drifts from actual asset inventory.
- `test/data/repositories/lesson_repository_test.dart` now covers source-aware ShinKanzen tags and all-level lesson vocab seeding.
- `npm run generate:content-index` regenerates the manifest through `tool/research/generate_content_index.js`.

## Verified Inventory

| Dataset | Files | Entries |
| --- | ---: | ---: |
| vocab | 278 | 16,712 |
| kanji | 125 | 929 |
| grammar | 125 | 754 |
| grammar examples | 125 | 4,924 |
| immersion | 125 | 125 |

Vocab source totals:

| Series | Entries |
| --- | ---: |
| `hajimete` | 8,334 |
| `ShinKanzen` | 5,573 |
| `minna` | 2,805 |

## Caveat

The app still stores curriculum lesson progress by integer `lessonId`. N5, N3, N2, and N1 all use lesson IDs 1-25, so cross-level switching can still collide with already-seeded user lesson terms. Phase 2/3 IA work should decide whether lesson identity becomes `(level, lessonId)` or routes use stable level-scoped IDs.
