# Project Structure

This file gives a quick map of the repository so it is easier to navigate and maintain.

## Top level

- `README.md`: project overview and primary getting-started entry
- `ROADMAP.md`: product and implementation roadmap
- `CLEANUP.md`: cleanup notes / backlog reference
- `pubspec.yaml`: Flutter package config and asset declarations
- `assets/`: bundled static assets used by the app
- `lib/`: application source code
- `test/`: automated tests
- `tooling/`: local scripts for data generation, validation, and migration
- `docs/`: plans, reports, notes, specs, and reference docs
- `android/`, `ios/`, `web/`, `windows/`: platform runners and platform-specific configs

## `assets/`

- `assets/images/`: UI images and illustrations
- `assets/fonts/`: bundled fonts
- `assets/data/`: app content, support assets, and archived lesson data

See also:
- `assets/data/README.md`
- `assets/data/content/README.md`
- `assets/data/support/README.md`

## `lib/`

Main app code lives here.

- `lib/app/`: app bootstrap, routing, high-level app wiring
- `lib/core/`: shared services, constants, utilities, and low-level app logic
- `lib/data/`: database layer, repositories, DAOs, seeders, data models
- `lib/features/`: feature-oriented UI and business flows
- `lib/shared/`: cross-feature UI helpers/models if needed
- `lib/theme/`: theme tokens and styling infrastructure
- `lib/widgets/`: reusable widgets used across multiple features

## `test/`

Mirrors major app areas.

- `test/components/`: widget/component-level tests
- `test/core/`: tests for utilities and core domain logic
- `test/data/`: DAO, repository, and content/data-related tests
- `test/features/`: end-to-end-ish feature and flow tests

## `tooling/`

Scripts for maintaining and validating data.

Common categories include:
- content generation/export
- audits and validation
- migration/backfill scripts
- quality normalization helpers
- temporary caches in `tooling/_tmpcache/` (ignored locally)

## `docs/`

Documentation is grouped by purpose.

- `docs/README.md`: index for docs folder
- `docs/plans/`: implementation plans
- `docs/plans/legacy/`: historical plan docs
- `docs/reports/`: generated and audit outputs
- `docs/notes/`: exploratory or design notes
- `docs/specs/`: product/feature specifications
- root files inside `docs/`: stable references like schema docs

## `assets/data/`

Data is organized by purpose.

- `assets/data/content/`: runtime learning content
- `assets/data/support/`: technical support assets for engine/features
- `assets/data/archive/`: archived lesson schemas for migration and tooling

## Suggested navigation order

When exploring the repo for the first time:
- `README.md`
- `PROJECT_STRUCTURE.md`
- `ROADMAP.md`
- `docs/README.md`
- `assets/data/README.md`
- then the specific feature/data area you want to work on
