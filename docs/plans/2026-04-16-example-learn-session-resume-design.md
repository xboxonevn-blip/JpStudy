# Example - Resume Interrupted Learn Session Design

This file is a reference example for the docs templates. It shows how to translate a user-visible requirement into a focused technical design.

**Date:** 2026-04-16  
**Status:** Reference Example  
**Owner:** Docs workflow example  
**Related docs:** [spec](../specs/2026-04-16-example-learn-session-resume-spec.md), [plan](./2026-04-16-example-learn-session-resume-plan.md), [template](./_template-design.md)

## Summary

Persist unfinished Learn Mode sessions as lightweight lesson-scoped JSON snapshots in local storage, surface the resume decision on the Learn config screen, and restore provider state when the learner chooses to continue.

## Problem

Learn Mode sessions are multi-step and can include retries, hints, and reordered questions. Without local resume support, leaving the screen or closing the app forces the learner to restart the whole session and lose context.

## Desired Result

The system should be able to save an unfinished Learn Mode session, load it by lesson ID, restore runtime state into `learnSessionProvider`, and clear the saved state on discard or completion.

## Constraints

- keep the app local-first and offline-friendly
- avoid introducing a new database table for transient in-progress session state
- preserve the existing Learn Mode entry flow through `LearnModeIntegration` and `LearnConfigScreen`
- keep restore logic bounded to Learn Mode instead of creating a generic cross-mode resume framework in this pass

## Non-goals

- test and exam mode resume unification in the same design
- cross-device sync or account-backed persistence
- a global "resume anywhere" surface on the home screen

## Current State

- `lib/core/services/session_storage.dart` already defines `SessionStorage` and a `LearnSessionSnapshot` model for JSON persistence via `SharedPreferences`
- `lib/features/learn/integration/learn_mode_integration.dart` is the lesson-scoped Learn entry surface and can load lesson data plus any saved snapshot
- `lib/features/learn/screens/learn_config_screen.dart` already owns pre-session configuration UI and is the right place to ask the learner whether to resume or discard
- `lib/features/learn/providers/learn_session_provider.dart` already supports `restoreSession`
- `lib/features/learn/screens/learn_screen.dart` owns in-session interactions and is the right place to persist progress after meaningful state changes

## Proposed Design

Use a lesson-scoped snapshot lifecycle with three phases:

1. `load` during Learn entry
2. `restore / discard / start fresh` on the config screen
3. `persist and clear` during runtime and completion

### Architecture / Data Flow

```text
LearnModeIntegration
  -> SessionStorage.loadLearnSession(lessonId)
  -> LearnConfigScreen(resumeSnapshot, onResume, onDiscardResume, onStart)

Resume path:
LearnConfigScreen
  -> LearnScreen(resumeSnapshot)
  -> LearnSessionNotifier.restoreSession(session)

Runtime persistence:
LearnScreen
  -> build LearnSessionSnapshot from provider state + UI metadata
  -> SessionStorage.saveLearnSession(snapshot)

Completion / discard:
LearnSummaryScreen or config discard action
  -> SessionStorage.clearLearnSession(lessonId)
```

### Interfaces Affected

- `SessionStorage`
  - stores and loads `LearnSessionSnapshot` by `lessonId`
- `LearnSessionSnapshot`
  - serializes session progress plus Learn-specific UI metadata such as hint/retry state
- `LearnModeIntegration`
  - decides whether a resume option should be shown
- `LearnConfigScreen`
  - renders resume/discard UI and forwards learner choice
- `LearnScreen`
  - restores provider state and persists progress after interactions

### Files Likely To Change

- `lib/core/services/session_storage.dart` - snapshot model and persistence rules
- `lib/core/services/session_storage_provider.dart` - storage provider wiring
- `lib/features/learn/integration/learn_mode_integration.dart` - resume snapshot loading and Learn entry branching
- `lib/features/learn/screens/learn_config_screen.dart` - resume card UI and actions
- `lib/features/learn/screens/learn_screen.dart` - restore, persist, and clear logic
- `lib/features/learn/providers/learn_session_provider.dart` - provider restore entry point
- `test/core/session_storage_test.dart` - persistence round-trip coverage
- `test/features/learn/learn_mode_config_test.dart` - config and restore behavior coverage

## Alternatives Considered

### Option A

Store in-progress Learn state only in Riverpod memory.

- Pros: simple implementation, no serialization work
- Cons: no cold-start resume, no protection against app termination, poor learner experience

### Option B

Store in-progress Learn state in a dedicated Drift table.

- Pros: structured persistence and future query flexibility
- Cons: heavier migration cost, overkill for transient lesson-scoped state, more schema churn

### Option C

Store one JSON snapshot per lesson in `SharedPreferences`.

- Pros: lightweight, local-first, cheap to wire into current Learn flow, easy to clear
- Cons: requires careful serialization compatibility and stale-snapshot handling

Chosen approach: Option C.

## Risks

- snapshot payload drifts out of sync with `Question` or `LearnConfig` serialization shape
- partial hydration after content changes could produce confusing restore results
- runtime persistence misses some UI metadata and produces non-faithful resumes
- snapshot clearing path is missed and leaves stale resume prompts behind

## Failure Modes

- invalid JSON causes resume crashes instead of clean fallback
- snapshot restores a session whose current question no longer exists
- completion path navigates away but fails to clear storage

## Test Strategy

### Targeted Checks

- `flutter test test/core/session_storage_test.dart`
- `flutter test test/features/learn/learn_mode_config_test.dart`
- `flutter test test/features/learn/learn_summary_screen_test.dart`

### Final Gates

- `flutter analyze`
- `flutter test`
- `flutter build web`

## Acceptance Criteria

- persisted snapshots round-trip with config and retry metadata intact
- Learn entry can show resume or normal start based on storage state
- restored sessions rebuild a coherent `LearnSession` and continue from saved progress
- saved state clears on discard and completion

## Rollout / Follow-up

- if the pattern remains stable, evaluate whether Test Mode should share a similar entry convention
- consider a stale-snapshot age policy only after observing real user friction
