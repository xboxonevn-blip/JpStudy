# App Architecture

`lib/` contains the Flutter application source code.

## Top-level structure

- `main.dart`: app entrypoint
- `app/`: application bootstrap, routing, shell-level setup
- `core/`: shared foundations such as services, utils, constants, and common app logic
- `data/`: persistence, repositories, DAOs, seeders, and data models
- `features/`: feature-oriented UI and business flows
- `shared/`: cross-feature shared code that does not fit a single feature cleanly
- `theme/`: colors, typography, styling tokens, and theme composition
- `widgets/`: reusable widgets used across multiple features

## Layer responsibilities

### `app/`

Use for:
- app initialization
- route configuration
- dependency wiring at the highest level
- app shell and navigation setup

### `core/`

Use for:
- language settings
- utility helpers
- global services
- app-wide constants
- domain-agnostic infrastructure logic

Rule of thumb:
- if code is reusable across many features and is not specifically persistence-related, it usually belongs in `core/`.

### `data/`

Use for:
- database definitions
- Drift tables and generated persistence glue
- DAOs and repositories
- seeders and data ingestion logic
- data-facing models and mappers

This layer is where app code meets stored content and local persistence.

### `features/`

Use for:
- screens
- controllers / feature services
- user flows
- feature-specific state and UI logic

Rule of thumb:
- if a screen or flow belongs to one product area (immersion, review, grammar, handwriting, mock exam), prefer putting it under `features/`.

### `shared/`

Use for:
- small shared pieces that are reused across features but are too UI/business-specific for `core/`

Keep this folder disciplined.
If code can live clearly in `core/`, `widgets/`, or one feature, prefer that first.

### `theme/`

Use for:
- design tokens
- color systems
- typography presets
- spacing/radius/shadow conventions
- theme builders and theme extensions

### `widgets/`

Use for:
- reusable presentational widgets with broad app reuse
- components that are not owned by just one feature

## Routing Rules

Use these routing rules consistently across the codebase:

- UI layer (`screens/`, `widgets/`) uses `context.open...` helpers from `lib/app/navigation/app_navigation_extensions.dart`
- model/provider/persistence layers store route strings only via `AppRoutePath` or `AppRouteLocation`
- dynamic routes must be built through `AppRouteLocation`, never by manual string interpolation
- route configs remain centralized under `lib/app/navigation/`

Examples:
- use `context.openLesson(id)` in widgets
- use `AppRoutePath.grammarPractice` for persisted/static route values
- use `AppRouteLocation.vocabReview(args: ...)` for persisted/dynamic route values

Avoid:
- `context.go('/...')` or `context.push('/...')` in UI
- `'/lesson/$id'` or `Uri(path: '/...')` outside `lib/app/navigation/`
- model/provider code constructing paths ad hoc

## Suggested dependency direction

Prefer this flow:
- `app` -> `features` -> `data`
- `app` / `features` / `data` -> `core`
- shared UI can depend on `core`, `theme`, and narrowly on `data` models when needed

Avoid:
- feature-to-feature tight coupling
- putting screen logic in `widgets/`
- putting persistence details in `core/`

## Practical navigation order

When tracing a feature:
- start at `lib/features/...`
- follow providers/services into `lib/data/...`
- check shared helpers in `lib/core/...`
- inspect reusable UI pieces in `lib/widgets/` and `lib/theme/`

## Current data integration points

Important content/runtime paths are typically loaded through:
- `lib/data/db/`
- `lib/data/repositories/`
- services under feature folders that read support assets

See also:
- `PROJECT_STRUCTURE.md`
- `assets/data/README.md`
- `docs/DATA_SCHEMA_V2.md`
