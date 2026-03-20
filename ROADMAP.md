# Roadmap

This roadmap tracks the product direction of `JpStudy-v2` and keeps wording aligned with the current repo structure.

## Vision

Build a Japanese learning app that combines:
- efficient spaced repetition with FSRS
- structured lesson content
- immersion reading
- handwriting practice
- exam-style review
- a maintainable local-first architecture

## Current status

| Phase | Focus | Status | Target |
| :--- | :--- | :--- | :--- |
| Phase 1 | Learning foundation | Completed | Done |
| Phase 2 | App structure and UI system | Completed | Done |
| Phase 3 | Grammar Practice + Handwriting reliability | In progress | 2026-03 to 2026-04 |
| Phase 4 | Cloud sync ecosystem | Parked behind core hardening | Later |

## Phase summary

### Phase 1 ? Foundation

Completed foundations include:
- local persistence with Drift + SQLite
- FSRS-based scheduling for vocab, grammar, and kanji
- core study flows for vocab/grammar/kanji review
- initial localization and app shell setup

### Phase 2 ? Structure and UI system

Completed structural work includes:
- clearer feature-based app organization
- shared theme and widget foundations
- reusable screens/components for major study flows
- improved navigation and test coverage for core experiences

### Phase 3 ? Core learning quality hardening

Primary goal:
- improve learning quality through stronger Grammar Practice sessions and more reliable handwriting evaluation

Completed / active items:
- Ghost Review captures mistakes with context
- FSRS is the active scheduling model
- immersion reader cleanup is largely complete and is now maintenance-only unless new regressions appear
- Grammar Practice is the current active hardening milestone
- handwriting uses support assets for stroke templates and stroke vector data
- N5/N4 handwriting template coverage and promotion workflow are in place
- content/data layout has been refactored into runtime content, support assets, and archive data

Remaining direction:
- harden Grammar Practice from canonical grammar ingest through question generation and session UX
- improve handwriting scoring quality and confidence further
- keep immersion regression-safe without reopening a large cleanup program
- keep lesson/data quality audits active for the canonical report set

### Phase 4 ? Cloud sync ecosystem

Primary goal:
- add reliable backup and sync without weakening the local-first app model

Near-term targets:
- backup/export experience improvements
- cloud sync MVP exploration for supported platforms
- conflict-handling and data integrity design

## Current priorities

### Now

- keep the repo baseline green with `flutter analyze`, `flutter test`, and `flutter build web`
- finish Grammar Practice hardening as the active milestone
- continue the handwriting reliability pass immediately after Grammar Practice
- keep immersion in maintenance mode and fix only regressions / residual data defects

### Next

- refresh the canonical grammar quality report and keep tooling/report semantics aligned with actual app behavior
- extend route smoke / regression coverage for the main learning surfaces
- resume cloud backup/sync groundwork only after the core learning flows are steadier

### Later

- deeper gamification and progression systems
- broader ecosystem integrations where they remain maintainable

## Success criteria

The roadmap is on track when:
- runtime content stays cleanly separated from support and archive data
- feature flows remain covered by tests after refactors
- tooling can regenerate/validate content reproducibly
- the app remains understandable for future contributors

## Related documents

- repo map: `PROJECT_STRUCTURE.md`
- docs index: `docs/README.md`
- app architecture: `lib/README.md`
- tooling index: `tooling/README.md`
- test strategy: `test/README.md`
- data layout: `assets/data/README.md`
