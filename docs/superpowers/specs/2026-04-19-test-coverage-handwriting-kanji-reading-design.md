# Design: Test Coverage — HandwritingEvaluator & Kanji Reading Providers

**Date:** 2026-04-19  
**Status:** Approved  
**Scope:** Add missing unit test coverage for two high-risk modules identified in the app audit.

---

## Context

An app-wide audit (2026-04-19) identified two modules with significant logic complexity but no dedicated unit tests:

1. `lib/features/write/services/handwriting_evaluator.dart` — complex multi-gate scoring engine with per-character threshold overrides; currently only covered by widget-level walkthrough tests that don't exercise individual scoring paths.
2. `lib/features/kanji_reading/providers/kanji_reading_providers.dart` — recently refactored with a two-path cache strategy (`valueOrNull` fast path vs. `fetchKanjiByIds` fallback) that has no test verifying which path fires under which conditions.

---

## Approach

**Approach C selected:** Add both test files independently — they share no dependencies and can be implemented in parallel.

No source code changes. No refactoring. No `@visibleForTesting` annotations added. Tests exercise the public API surface only.

---

## Part A: HandwritingEvaluator Unit Tests

**File:** `test/features/write/handwriting_evaluator_test.dart`

### Why unit tests (not widget tests)

`HandwritingEvaluator` is a pure static class. All methods are deterministic functions of their inputs — no side effects, no DB, no Flutter widget tree. Unit tests run in ~1–2s vs. ~10–20s for widget tests and cover exact numeric thresholds more precisely.

### Architecture

Tests call `HandwritingEvaluator.evaluate()` with crafted `List<List<Offset>>` strokes and `KanjiStrokeTemplate` stubs. Since all scoring is deterministic, expected outputs can be calculated manually from the profile math.

Public methods (`strokeScoreForCounts`, `strokeToleranceForExpectedCount`) are tested directly. Private methods (`_shapeScore`, `_orderScore`, `_applyPerKanjiTuning`, gate functions) are exercised indirectly through `evaluate()` by controlling all inputs.

### Test Groups

#### `strokeToleranceForExpectedCount`
| Input | Expected |
|-------|----------|
| 1–5   | 0        |
| 6–11  | 1        |
| 12+   | 2        |

#### `strokeScoreForCounts`
| drawnStrokes | expectedStrokes | Expected score |
|---|---|---|
| exact match | any | 1.0 |
| 1 under, tol=0 | 1 | 0.0 |
| 1 over, tol=0 | 1 | 0.0 (×2 over-penalty) |
| 1 under, tol=1 | 6 | 0.50 |
| 1 over, tol=1 | 6 | ~0.33 (effectiveDelta=2, denom=2) |
| 2 over, tol=1 | 6 | 0.0 (clamp) |

#### `evaluate — tier=none, no template`
- Sufficient ink, centered strokes → `isCorrect = true`
- Zero strokes → `isCorrect = false`
- Excess strokes (×2 over-penalty exceeds minStrokeScore) → `isCorrect = false`

#### `evaluate — tier=manual, showGuide=true`
- Wrong stroke count → false (minStrokeScore gate blocks)
- Guided enclosure character (口): near-correct override fires with acceptable scores → true
- Non-enclosure character: near-correct override does NOT fire with same scores → false

#### `evaluate — tier=curated, showGuide=false`
- Unguided enclosure override fires for 日 with per-character slack applied
- Unguided enclosure override does NOT fire when template is null
- 日 uses larger `enclosureOrderSlack` (0.20) vs. other enclosure chars (0.16)

#### `_passesSimpleTemplateGate — 1-stroke template, unguided`
| Tier | Threshold | templateScore below → wrong |
|---|---|---|
| manual | 0.90 | yes |
| curated | 0.84 | yes |
| generated | 0.66 | yes |
| none | n/a | gate skipped (always true) |

#### `_applyPerKanjiTuning — character overrides`

Verify that `evaluate()` produces tighter `isCorrect=false` for characters with positive deltas and looser for negative deltas:

| Character | requiredScoreDelta | minOrderScoreDelta | minTemplateScoreDelta | minDirectionScoreDelta |
|---|---|---|---|---|
| 未 | +0.02 | +0.04 | +0.05 | 0 |
| 末 | +0.02 | +0.04 | +0.05 | 0 |
| 土 | +0.01 | +0.03 | +0.04 | 0 |
| 士 | +0.01 | +0.03 | +0.04 | 0 |
| 口 | 0 | 0 | −0.04 | 0 |
| 日 | 0 | −0.03 | −0.06 | −0.18 |

#### `_applyPerKanjiTuning — complexity tuning`
- 12-stroke kanji: `requiredScore` and `minTemplateScore` higher than 4-stroke kanji (same tier)
- ≤2-stroke kanji: extra tightening applied on top of complexity tuning
- Legacy scoring version: tuning skipped entirely (returns base profile)

### Dependencies
- `package:flutter/material.dart` (Offset, Size)
- `package:flutter_test/flutter_test.dart`
- `package:jpstudy/features/write/services/handwriting_evaluator.dart`
- `package:jpstudy/features/write/services/kanji_stroke_template_service.dart` (KanjiStrokeTemplate, StrokeTemplate)

No DB, no ProviderScope, no widget pump.

---

## Part B: Kanji Reading Provider Tests

**File:** `test/features/kanji_reading/kanji_reading_providers_test.dart`

### Architecture

Uses `ProviderContainer` with overrides for `lessonRepositoryProvider` and `databaseProvider`. Follows the fake-class pattern established in `home_kanji_reading_screen_test.dart` — no mockito/mocktail.

Fake implementations:
- `_FakeProviderLessonRepository` — extends `LessonRepository`, tracks call counts for `fetchKanjiByIds` and `fetchKanjiByLevel`, returns controllable data per level
- In-memory `AppDatabase` via `NativeDatabase.memory()` — controls `kanjiSrsDao.getDueKanjiIds()` by inserting real SRS rows

### Test Groups

#### `_normalizeLevelCode — via kanjiByLevelCodeProvider`
- `'n5'` → same result as `'N5'`
- `' N5 '` → whitespace trimmed, resolves correctly
- `'n4'` → resolves to N4 dataset, not N5

#### `kanjiByLevelCodeProvider`
- Returns items matching levelCode from repo
- Returns `[]` when repo returns empty
- Two different family args (`N5`, `N4`) return independent cached values

#### `kanjiReadingDueItemsByLevelCodeProvider — cache-hit path`
- Pre-warm `kanjiByLevelCodeProvider('N5')` in the container
- Provider reads `valueOrNull` cache and filters by dueIds
- `fetchKanjiByIds` is NOT called (verified via call counter on fake repo)

#### `kanjiReadingDueItemsByLevelCodeProvider — non-cache path`
- `kanjiByLevelCodeProvider('N5')` not pre-warmed
- `dueIds` non-empty → `fetchKanjiByIds` IS called
- Result filtered to correct level only (items from N4 excluded)

#### `kanjiReadingDueItemsByLevelCodeProvider — edge cases`
- `dueIds` empty → returns `[]` immediately, no repo calls
- `dueIds` non-empty but none match level → returns `[]`
- `levelCode = 'n5'` → same result as `'N5'` (normalization)

#### `kanjiReadingDueItemsProvider — integration`
- `studyLevelProvider = null` → returns `[]`
- `studyLevelProvider = N5` → delegates to `kanjiReadingDueItemsByLevelCodeProvider('N5')`

### Dependencies
- `package:flutter_riverpod/flutter_riverpod.dart`
- `package:drift/native.dart`
- `package:jpstudy/features/kanji_reading/providers/kanji_reading_providers.dart`
- `package:jpstudy/data/db/app_database.dart`
- `package:jpstudy/data/db/database_provider.dart`
- `package:jpstudy/data/repositories/lesson_repository.dart`
- `package:jpstudy/core/level_provider.dart`
- `package:jpstudy/core/study_level.dart`

---

## Summary

| File | Test type | Est. cases | Est. run time |
|---|---|---|---|
| `handwriting_evaluator_test.dart` | Pure unit | ~38 | ~1–2s |
| `kanji_reading_providers_test.dart` | Provider unit | ~20 | ~3–5s |

**No source files modified.** Both test files are fully independent and can be written in parallel.

### Out of scope
- Widget tests for `HandwritingPracticeScreen` (already covered)
- `HandwritingTemplateMatcher` (covered indirectly via evaluator tests with templates)
- JLPT coach screen integration tests (separate audit item)
- Mistake screen due-bucket tests (separate audit item)
