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
| Phase 3 | Immersion + handwriting quality | In progress | 2026 |
| Phase 4 | Cloud sync ecosystem | Early | Q2 2026 |

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

### Phase 3 ? Immersion and handwriting

Primary goal:
- improve learning quality through better review context, immersion support, and handwriting accuracy

Completed / active items:
- Ghost Review captures mistakes with context
- FSRS is the active scheduling model
- immersion reader includes progress-oriented UX improvements
- handwriting uses support assets for stroke templates and stroke vector data
- N5/N4 handwriting template coverage and promotion workflow are in place
- content/data layout has been refactored into runtime content, support assets, and archive data

Remaining direction:
- improve handwriting scoring quality and confidence further
- continue refining immersion learning loops and review integration
- keep lesson/data quality audits active for N3/N4/N5

### Phase 4 ? Cloud sync ecosystem

Primary goal:
- add reliable backup and sync without weakening the local-first app model

Near-term targets:
- backup/export experience improvements
- cloud sync MVP exploration for supported platforms
- conflict-handling and data integrity design

## Current priorities

### Now

- stabilize the current data/content architecture
- keep immersion and handwriting flows regression-safe
- improve data quality, lesson coherence, and grammar coverage where needed

### Next

- continue cloud backup/sync groundwork
- improve exam/review analytics and polish
- strengthen tooling repeatability for content generation and validation

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
