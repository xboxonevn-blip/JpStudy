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
| Phase 3 | Learning quality and release hardening | Completed | Done |
| Phase 4 | Cloud sync ecosystem | MVP shipped | Done |
| Phase 5 | Hardening and ecosystem polish | In progress | Open |

## Phase summary

### Phase 1 — Foundation

Completed foundations include:
- local persistence with Drift + SQLite
- FSRS-based scheduling for vocab, grammar, and kanji
- core study flows for vocab/grammar/kanji review
- initial localization and app shell setup

### Phase 2 — Structure and UI system

Completed structural work includes:
- clearer feature-based app organization
- shared theme and widget foundations
- reusable screens/components for major study flows
- improved navigation and test coverage for core experiences

### Phase 3 — Core learning quality hardening

Primary goal:
- improve learning quality through stronger content-backed grammar behavior, more reliable handwriting evaluation, and steadier core release paths

Completed items:
- Ghost Review captures mistakes with context
- FSRS is the active scheduling model
- immersion reader cleanup is largely complete and is now maintenance-only unless new regressions appear
- Grammar Practice hardening is complete for the current audit semantics
- the canonical grammar audit reports `0` real quality gaps across `N5`, `N4`, and `N3` as of `2026-03-24`
- handwriting uses support assets for stroke templates and stroke vector data
- N5/N4 handwriting template coverage and promotion workflow are in place
- content/data layout has been refactored into runtime content, support assets, and archive data
- route and release smoke coverage has been hardened around core study paths
- Learn session resume is implemented and verified
- N1/N2 immersion comprehension questions are available and human-approved
- N1/N2 vocab and grammar Vietnamese editorial tags are marked reviewed
- dependency refresh and Riverpod 3 migration are complete on `main`

Maintenance direction:
- keep grammar/content audits green after data or heuristic changes
- keep handwriting scoring changes measurement-first
- keep route smoke tests focused and stable instead of long/flaky walkthroughs
- keep immersion regression-safe without reopening a large cleanup program

### Phase 4 — Cloud sync ecosystem

Primary goal:
- add reliable backup and sync without weakening the local-first app model

Shipped (file-based MVP):
- manual export and import flows in `DataSettingsScreen`
- daily auto-backup with retention of the 7 most recent files
- linked sync target (user-picked file in any cloud-mounted folder) via
  `CloudSyncService.linkTarget` / `unlinkTarget`
- upload and download envelope flows with conflict detection
  (`skipOlder`, `invalidChecksum`) backed by `BackupSyncService`
- SHA-256 envelope checksum and stable device-id metadata
- status surface (`cloudSyncStatusProvider`) for last sync time and direction
- coverage in `test/core/cloud_sync_service_test.dart`,
  `test/core/backup_sync_service_test.dart`,
  `test/features/me/data_settings_screen_test.dart`

Maintenance direction:
- keep the local-first model: cloud transports must exchange the same portable
  backup envelope instead of becoming a second persistence model
- keep envelope versioning stable and any new fields backward compatible
- keep checksum and device-id metadata authoritative for conflict decisions

### Phase 5 — Hardening and ecosystem polish

Primary goal:
- raise privacy, automation, and discovery quality on top of the working
  Phase 4 cloud sync MVP without expanding scope into new platforms

Near-term targets:
- AES-256-GCM at-rest encryption for backup envelopes (opt-in passphrase) — shipped
- Firebase Auth + Storage account sync for the same backup envelope — shipped
- automatic upload trigger after meaningful study sessions when a sync target
  is linked
- conflict surface in the data settings UI when import is older than current
- documentation pass for backup/sync architecture under `docs/` — started in
  `docs/notes/2026-05-08-backup-sync-architecture.md`

## Current priorities

### Now

- keep the repo baseline green with `flutter analyze`, `flutter test`, and `flutter build web`
- keep `docs/reports/grammar-example-quality-report.json` current and green after grammar data or heuristic changes
- keep Phase 3 learning-quality surfaces in maintenance mode and fix regressions quickly
- keep dependency upgrades isolated from feature work

### Next

- evaluate auto-upload trigger after clearer telemetry on session completion
- keep any larger handwriting/content work behind explicit scoped plans

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
- latest completed hardening plan: `docs/plans/2026-03-24-handwriting-reliability-route-hardening-plan.md`
- handwriting audit note: `docs/notes/2026-04-02-handwriting-measurement-audit.md`
- app architecture: `lib/README.md`
- tooling index: `tooling/README.md`
- test strategy: `test/README.md`
- data layout: `assets/data/README.md`
