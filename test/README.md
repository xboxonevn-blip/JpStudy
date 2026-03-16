# Tests

`test/` contains automated tests for the Flutter app.

## Test strategy

The repo uses a practical layered strategy:

- small logic tests for pure/core behavior
- data-layer tests for DAOs, repositories, and content/database behavior
- widget/component tests for reusable UI pieces
- feature flow tests for higher-value user journeys

The goal is to validate important behavior at the cheapest level first, then cover key integrated flows where regressions would be expensive.

## Folder map

### `test/components/`

Focus:
- reusable UI components
- isolated widget rendering and interaction

Usually maps to:
- `lib/widgets/`
- shared visual components used across features

Typical checks:
- widget renders expected child/content
- buttons, cards, and small UI pieces behave correctly
- styling-dependent behavior remains stable enough for interaction tests

### `test/core/`

Focus:
- pure logic and domain helpers
- utility-level behavior that should stay deterministic

Usually maps to:
- `lib/core/`

Typical checks:
- milestone logic
- challenge generation
- helper functions and calculations
- date/time-independent logic where possible

### `test/data/`

Focus:
- persistence and content loading behavior
- DAOs, repositories, local DB rules, and data asset integrity checks

Usually maps to:
- `lib/data/`
- parts of `assets/data/`

Typical checks:
- DAO query behavior
- repository fallbacks / loading behavior
- content seeding assumptions
- support asset integrity such as stroke template coverage

This folder is especially important for protecting content/data refactors.

### `test/features/`

Focus:
- feature-level user flows and app behavior
- route transitions and multi-step interactions

Usually maps to:
- `lib/features/`
- sometimes `lib/app/` and `lib/data/` when the flow crosses boundaries

Typical checks:
- onboarding or dashboard flows
- recovery pack/test flows
- grammar/ghost review interactions
- immersion reader flows
- handwriting flows
- mock exam routing and configuration

These tests give confidence that major product paths still work end-to-end-ish inside the app test environment.

## App-area mapping

### App shell and routing

Covered mostly by:
- `test/features/`
- some widget-level tests when a shell component is isolated

Relevant code areas:
- `lib/app/`
- route entry points inside feature screens

### Core logic

Covered mostly by:
- `test/core/`

Relevant code areas:
- `lib/core/`

### Data layer

Covered mostly by:
- `test/data/`

Relevant code areas:
- `lib/data/db/`
- `lib/data/daos/`
- `lib/data/repositories/`
- content/support assets under `assets/data/`

### Shared widgets and design-system pieces

Covered mostly by:
- `test/components/`

Relevant code areas:
- `lib/widgets/`
- some reusable pieces under feature folders

### Feature flows

Covered mostly by:
- `test/features/`

Relevant code areas:
- `lib/features/immersion/`
- `lib/features/write/`
- `lib/features/test/`
- `lib/features/ui/`
- other product-facing feature folders

## Practical testing guidance

When changing code:

- start with the smallest affected test set
- prefer running the nearest folder or single file first
- run broader app tests after high-confidence local fixes

Examples:
- change DAO/repository logic -> start in `test/data/`
- change a reusable widget -> start in `test/components/`
- change feature behavior -> start in the matching `test/features/` file/folder
- change pure helper logic -> start in `test/core/`

## Content and asset refactors

For data/layout migrations, pay special attention to:
- `test/data/`
- feature tests that load content indirectly
- handwriting-related tests if kanji support assets move or regenerate

## Validation commands

Common commands:

- `flutter test`
- `flutter test test/data/`
- `flutter test test/features/`
- `flutter analyze`

Use narrower test targets during iteration and the full suite before finalizing broad refactors.
