# Example - Resume Interrupted Learn Session Plan

This file is a reference example for the docs templates. It demonstrates a practical execution breakdown for a bounded feature pass.

**Date:** 2026-04-16  
**Status:** Reference Example  
**Owner:** Docs workflow example  
**Related docs:** [spec](../specs/2026-04-16-example-learn-session-resume-spec.md), [design](./2026-04-16-example-learn-session-resume-design.md), [template](./_template-plan.md)

## Goal

Deliver a lesson-scoped Learn Mode resume flow that survives app exits, lets the learner resume or discard saved progress, and clears saved state once the session is done.

## Scope

- local persistence for unfinished Learn Mode sessions
- resume card and discard action on the Learn config screen
- runtime restore into `learnSessionProvider`
- clear-on-completion behavior
- focused tests for persistence and entry flow

## Non-goals

- new home-level continue surface for Learn Mode
- multi-device resume
- broad refactor of all study modes to a unified resume abstraction

## Assumptions

- lesson identity is stable enough to use as the snapshot key
- `SharedPreferences` is acceptable for lightweight transient session state
- `LearnScreen` remains the source of truth for in-session UI metadata such as retries and hints

## Dependencies / Preconditions

- `SessionStorage` and `sessionStorageProvider` are available in `lib/core/services/`
- `LearnSessionNotifier.restoreSession` exists and can seed provider state
- Learn entry continues to flow through `LearnModeIntegration`

## Execution Steps

### Step 1: Define and stabilize persistence payload

- Files:
  - `lib/core/services/session_storage.dart`
  - `test/core/session_storage_test.dart`
- Work:
  - define the Learn snapshot payload with question list, results, config, and retry/hint metadata
  - ensure JSON round-trip and backward-safe parsing for optional or legacy fields
  - key snapshots by lesson ID and expose save, load, and clear helpers
- Verify:
  - `flutter test test/core/session_storage_test.dart`

### Step 2: Wire resume discovery into Learn entry

- Files:
  - `lib/features/learn/integration/learn_mode_integration.dart`
  - `lib/features/learn/screens/learn_config_screen.dart`
- Work:
  - load any existing snapshot before showing the config screen
  - render a resume card only when a valid snapshot exists
  - support `Resume` and `Discard` actions without breaking the normal start path
- Verify:
  - `flutter test test/features/learn/learn_mode_config_test.dart`

### Step 3: Restore and persist runtime state

- Files:
  - `lib/features/learn/screens/learn_screen.dart`
  - `lib/features/learn/providers/learn_session_provider.dart`
- Work:
  - restore the saved session into provider state on resume
  - persist updated snapshot state after meaningful interactions
  - include hint/requeue metadata so the resumed flow remains coherent
- Verify:
  - `flutter test test/features/learn/learn_mode_config_test.dart`

### Step 4: Clear saved state on terminal paths

- Files:
  - `lib/features/learn/screens/learn_screen.dart`
  - `lib/features/learn/screens/learn_summary_screen.dart`
- Work:
  - clear the snapshot when the learner discards or completes the session
  - keep terminal navigation behavior intact
- Verify:
  - `flutter test test/features/learn/learn_summary_screen_test.dart`

## Risks / Watchouts

- restoring with changed lesson data may silently drop some questions
- snapshot persistence that runs too often could be noisy, while saving too rarely could lose progress
- UI metadata can drift if it is stored separately from provider state assumptions

## Verification Plan

### Targeted Verification

- `flutter test test/core/session_storage_test.dart`
- `flutter test test/features/learn/learn_mode_config_test.dart`
- `flutter test test/features/learn/learn_summary_screen_test.dart`

### Final Gates

- `flutter analyze`
- `flutter test`
- `flutter build web`

## Exit Criteria

- learners can resume an unfinished Learn session for a lesson
- learners can discard saved progress and start cleanly
- saved Learn session state is cleared after completion
- storage round-trip and entry behavior are covered by focused tests

## Follow-up Candidates

- evaluate whether Home `continue` logic should eventually incorporate interrupted Learn sessions
- add an age-based stale snapshot policy only if it solves a real user problem
