# Data layout audit

## Summary

- `assets/data/content/` is the runtime source of truth for vocab and kanji lesson content.
- Legacy lesson datasets should live under `assets/data/archive/`.
- `assets/data/support/kanji/` remains active only for decomposition and handwriting support assets.

## Runtime behavior

- `lib/data/db/content_database.dart` seeds vocab and kanji from `assets/data/content/` lesson exports only.
- `lib/data/repositories/lesson_repository.dart` reads lesson vocab ordering and rows from `assets/data/content/` assets only.
- Runtime no longer falls back to legacy lesson folders such as `assets/data/archive/vocab/` or `assets/data/archive/kanji/`.

## Tooling behavior

- Legacy migration scripts now point at `assets/data/archive/vocab/` and `assets/data/archive/kanji/` explicitly.
- Stroke/decomposition tooling continues to use active files in `assets/data/support/kanji/`.

## Recommendation

- Keep all new editing in `assets/data/content/` and `assets/data/content/grammar/`.
- Keep `archive/` as archive/import-only storage.
- Avoid adding any new runtime dependency on archived lesson schemas.
