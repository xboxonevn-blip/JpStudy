# Example - Resume Interrupted Learn Session Spec

This file is a reference example for the docs templates. It demonstrates the level of detail expected for a non-trivial user-visible behavior change.

**Date:** 2026-04-16  
**Status:** Reference Example  
**Owner:** Docs workflow example  
**Related docs:** [design](../plans/2026-04-16-example-learn-session-resume-design.md), [plan](../plans/2026-04-16-example-learn-session-resume-plan.md), [template](./_template-spec.md)

## Overview

Allow a learner to resume an interrupted Learn Mode session for a lesson from the normal Learn entry flow, instead of forcing the learner to restart the whole lesson session after closing the app or leaving the screen.

## Desired Result

When a valid unfinished Learn Mode snapshot exists for a lesson, the learner sees a clear resume option, can continue from the saved question state, and can also discard the saved snapshot to start fresh.

## Purpose

- reduce frustration when a learner leaves mid-session
- protect progress during local-first study flows
- make Learn Mode feel more reliable on mobile and desktop restarts

## Scope

- Learn Mode lesson sessions only
- local snapshot persistence only
- one saved snapshot per lesson
- resume and discard actions from the Learn configuration entry screen
- restoration of question progress, results, and retry/hint state

## Non-goals

- cross-device sync for in-progress sessions
- multiple saved snapshots per lesson
- resume support for every study mode in the same pass
- a new dashboard or home-level resume surface

## User Stories / Use Cases

- As a learner, I want to continue an unfinished lesson session after reopening the app so I do not lose progress.
- As a learner, I want to discard a stale or unwanted saved session so I can restart with a clean configuration.
- As a learner, I want the resumed session to preserve the current question state closely enough that the flow still feels coherent.

## User Experience

Describe the intended behavior from the user's point of view.

### Entry Points

- opening Learn Mode for a lesson through `LearnModeIntegration`
- landing on `LearnConfigScreen` for a lesson that has a saved snapshot

### Main Flow

1. The learner opens Learn Mode for a lesson.
2. If a valid unfinished snapshot exists for that lesson, the config screen shows a resume card above the normal configuration controls.
3. The learner can choose `Resume` to continue the saved session or `Discard` to remove it.
4. On resume, Learn Mode opens at the saved question index with saved results and retry/hint metadata restored.
5. During the session, progress is saved often enough that leaving the screen does not reset the whole run.
6. When the session finishes, the saved snapshot is cleared automatically.

### Edge Cases

- no saved snapshot: show the normal config flow only
- invalid or unreadable snapshot payload: ignore it and show a normal start flow
- lesson data changed since the snapshot was created: restore as safely as possible without crashing
- resumed snapshot points past the last valid question: clamp to a valid question index
- learner discards the snapshot: remove saved state and remain on the config screen

## Requirements

### Functional Requirements

- snapshots must be stored and loaded by lesson identity
- resume UI must only appear when a valid unfinished snapshot is available
- resume must restore question list, answered results, progress index, and retry/hint state
- discard must remove the saved snapshot immediately
- completed sessions must clear the saved snapshot automatically
- a fresh start must still honor the selected Learn configuration

### Content / Localization Requirements

- resume card title, subtitle, button labels, and discard copy must be localized
- saved progress wording must remain understandable in English, Vietnamese, and Japanese
- date wording on the resume subtitle should use platform-localized formatting where available

### Accessibility Requirements

- resume and discard actions must remain reachable by keyboard and screen readers
- the resume card should expose clear button labels and progress text

## Constraints

- local-first architecture remains the source of truth
- persistence should stay lightweight and not require a new database table for this flow
- the change should preserve the existing Learn Mode route and entry structure
- resume must not break normal lesson startup when no snapshot exists

## Failure Modes

List the most likely ways the change could fail or regress.

- stale snapshots restore mismatched question data after content changes
- resume UI appears for a finished or corrupted session
- snapshot persistence misses important metadata, leading to confusing resumed state
- saved sessions never clear, causing permanent stale resume prompts

## Acceptance Criteria

- opening Learn Mode for a lesson with a saved unfinished snapshot shows a resume card
- choosing `Resume` continues from the saved session instead of starting from question 1
- choosing `Discard` removes the snapshot and hides the resume card
- completing the session clears the saved snapshot
- invalid snapshot data does not crash the flow and falls back to a normal start path

## Open Questions

- should the home screen eventually surface a cross-lesson "continue learning" action for interrupted Learn Mode sessions
- should very old snapshots expire automatically instead of being shown forever

## Notes

- Relevant implementation paths in the current codebase include:
  - `lib/core/services/session_storage.dart`
  - `lib/features/learn/integration/learn_mode_integration.dart`
  - `lib/features/learn/screens/learn_config_screen.dart`
  - `lib/features/learn/screens/learn_screen.dart`
