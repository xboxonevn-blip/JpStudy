# Cleanup Guide

This file tracks cleanup principles for keeping the repository maintainable.

## Goals

- keep the repo easy to navigate
- reduce stale generated artifacts and redundant files
- separate runtime content from support assets and archive data
- keep documentation grouped by purpose
- avoid reintroducing legacy paths into active runtime code

## Current structure conventions

### Repo docs

Use these locations consistently:
- `docs/plans/`: active or recent implementation plans
- `docs/plans/legacy/`: older plan/walkthrough material
- `docs/reports/`: generated audits and validation outputs
- `docs/notes/`: one-off design notes and exploration docs
- `docs/specs/`: feature or product specifications

### Data layout

Use these locations consistently:
- `assets/data/content/`: runtime lesson and learning content
- `assets/data/support/`: technical support assets used by runtime features
- `assets/data/archive/`: archived lesson schemas used for migration/tooling only

Do not reintroduce runtime dependencies on `archive/` data.

### Code layout

Use these locations consistently:
- `lib/app/`: app bootstrap and routing
- `lib/core/`: shared non-persistence foundations
- `lib/data/`: persistence, repositories, seeders, data models
- `lib/features/`: feature-specific flows and screens
- `lib/widgets/`: broadly reusable widgets

## Cleanup rules

### Safe to remove or ignore

Usually safe to ignore or delete locally when regenerated:
- `.dart_tool/`
- `build/`
- local caches in `tooling/_tmpcache/`
- local workspace folders such as `.claude/worktrees/`
- generated reports only if they are intentionally reproducible and not needed for review history

### Keep under version control

Keep when they describe project intent or stable structure:
- `README.md`
- `PROJECT_STRUCTURE.md`
- `ROADMAP.md`
- schema/reference docs
- curated reports that capture meaningful audit snapshots
- source content in `assets/data/content/`
- support assets in `assets/data/support/`

### Move instead of leaving at root

Prefer moving files rather than leaving them scattered:
- design notes -> `docs/notes/`
- old plans/walkthroughs -> `docs/plans/legacy/`
- formal specs -> `docs/specs/`

## Before large refactors

Check these first:
- `README.md`
- `PROJECT_STRUCTURE.md`
- `docs/README.md`
- `assets/data/README.md`
- `lib/README.md`
- `tooling/README.md`
- `test/README.md`

## After cleanup or refactor work

Run at minimum:

```bash
flutter analyze
flutter test
```

For content/data work, also consider:

```bash
python tooling/validate_content_assets_v2.py
python tooling/audit_content_completeness.py
```

## Anti-patterns to avoid

- mixing runtime content with archive data
- leaving temporary planning docs in the repo root
- adding generated local cache outputs to version control accidentally
- putting feature-specific logic into generic shared folders
- rewriting docs in a way that conflicts with the actual repo layout

## Related documents

- `PROJECT_STRUCTURE.md`
- `docs/README.md`
- `assets/data/README.md`
- `lib/README.md`
- `tooling/README.md`
- `test/README.md`
