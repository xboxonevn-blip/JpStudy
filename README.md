# JpStudy-v2

JpStudy-v2 is a Flutter app for Japanese learning with FSRS scheduling, immersion reading, handwriting practice, and exam-style review.

## Current Status (as of 2026-02-03)

| Phase | Focus | Status | Target |
| :--- | :--- | :--- | :--- |
| Phase 1 | Foundation (Anki-like learning core) | 100% | Completed |
| Phase 2 | Structure and UI system | 100% | Completed |
| Phase 3 | Smart Immersion + Handwriting | 98% | Feb 2026 |
| Phase 4 | Cloud Sync ecosystem | 10% | Q2 2026 |

## Implemented Highlights

- FSRS replaced SM-2 for vocab, grammar, and kanji scheduling.
- Ghost Review 2.0 auto-captures mistakes with context.
- Immersion Reader supports local content + NHK Easy style flow, mark-as-learned, and auto-scroll.
- Handwriting includes stroke/order/shape heuristics with template quality tiers (`manual`, `curated`, `generated`).
- N5 and N4 kanji template coverage is in place, with curated-to-manual promotion workflow.
- Mock Exam flow for N5/N4 exists with timer, scoring, and review.
- Export/Import JSON backup includes progress, attempts, sessions, settings, mistakes, grammar SRS, and kanji SRS.

## Current Priorities (from roadmap)

### NOW (2026-02-03 -> 2026-02-10)
- Close Phase 3 with Stroke Check v2 quality improvements and regression benchmarks.

### NEXT (2026-02-10 -> 2026-02-24)
- Google Drive Backup MVP for Android and Windows.

### LATER (after 2026-02-24)
- Mock Exam polish (time pressure mode + deeper review analytics).

## Tech Stack

- Flutter (Dart 3.10+)
- Riverpod (state management)
- Drift + SQLite (local database)
- GoRouter (navigation)
- SharedPreferences + local files for app settings/cache

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Python 3.10+ (for tooling scripts)

### Setup

```bash
flutter pub get
flutter run
```

### Quality Checks

```bash
flutter analyze
flutter test
```

## Where to Look First

- Repo map: `PROJECT_STRUCTURE.md`
- Data layout: `assets/data/README.md`
- Runtime content/support schema: `assets/data/content/README.md`, `assets/data/support/README.md`
- App architecture: `lib/README.md`
- Tooling index: `tooling/README.md`
- Test strategy: `test/README.md`
- Docs index: `docs/README.md`
- Main roadmap: `ROADMAP.md`

## Tooling Workflows

### Kanji Template / Promotion

```bash
# Regenerate N5/N4 stroke template baseline
python tooling/generate_stroke_templates.py

# Promote N4 curated templates to manual by Mistake Bank priority
python tooling/promote_n4_curated_from_mistakes.py
```

### Scheduled Promotion Runner

```bash
# Run on app start, but only when interval is due
python tooling/run_promotion_workflow.py --schedule app-start --interval-days 7

# Weekly job mode
python tooling/run_promotion_workflow.py --schedule weekly --interval-days 7

# Force run immediately
python tooling/run_promotion_workflow.py --force
```

Reports:
- `tooling/reports/n4_promotion_history.json`
- `tooling/reports/n4_promotion_schedule_state.json`

### Content Schema v2

```bash
# Sync decomposition and regenerate support export
python tooling/sync_kanji_decomposition_labels.py

# Export runtime content vocab + kanji lesson assets
python tooling/build_canonical_content_v2.py

# Validate archive + runtime content integrity
python tooling/validate_content_assets_v2.py
```

References:
- `docs/DATA_SCHEMA_V2.md`
- `docs/reports/canonical-content-v2-report.json`
- `docs/reports/content-validation-v2.json`

## UI/UX Process Visibility

- Open in app: Settings -> `Design Lab` (route: `/design-lab`).
- Track design iteration notes in `docs/uiux-progress.md`.
- Use review checklist in `docs/uiux-review-checklist.md`.

## Project Structure

For the current repo map, use `PROJECT_STRUCTURE.md`.

Quick summary:

```text
lib/          app source code
test/         automated tests
tooling/      data generation, migration, and validation scripts
assets/       bundled runtime content, support assets, and archive data
docs/         plans, reports, notes, specs, and reference docs
```

## Roadmap

- Main roadmap: `ROADMAP.md`
- Tooling usage details: `tooling/README.md`
- Architecture guide: `lib/README.md`
- Test guide: `test/README.md`
